import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'particle.dart';
import 'particle_pool.dart';
import 'performance_monitor.dart';
import 'atmospheric_constants.dart';
import 'atmospheric_theme_config.dart';
import 'atmospheric_error_handler.dart';

/// Type of particle effect to render
enum ParticleType {
  fog, // Horizontal drifting fog
  ember, // Rising embers with glow
  wisp, // Burst particles for feedback
}

/// Widget that renders atmospheric particle effects (fog, embers, wisps)
/// Uses CustomPainter for efficient rendering and particle pooling for performance
class AtmosphericParticles extends StatefulWidget {
  final ParticleType type;
  final int particleCount;
  final Color baseColor;
  final double opacity;
  final bool enabled;
  final AtmosphericThemeConfig? themeConfig;

  const AtmosphericParticles({
    super.key,
    required this.type,
    this.particleCount = AtmosphericConstants.defaultFogParticleCount,
    this.baseColor = Colors.white,
    this.opacity = AtmosphericConstants.defaultFogOpacity,
    this.enabled = true,
    this.themeConfig,
  });

  @override
  State<AtmosphericParticles> createState() => _AtmosphericParticlesState();
}

class _AtmosphericParticlesState extends State<AtmosphericParticles>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  late ParticlePool _particlePool;
  late PerformanceMonitor _performanceMonitor;
  late Random _random;
  DateTime? _lastFrameTime;
  Size _lastSize = Size.zero;
  int _currentParticleCount = 0;
  bool _isTickerInitialized = false;
  double _devicePixelRatio = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _random = Random();
    _particlePool = ParticlePool();
    _performanceMonitor = PerformanceMonitor();
    _currentParticleCount = widget.particleCount;

    if (widget.enabled) {
      _ticker = createTicker(_onTick);
      _isTickerInitialized = true;
      _ticker.start();
    }
  }

  Color _getEffectiveParticleColor(AtmosphericThemeConfig themeConfig) {
    try {
      // Use theme config if provided
      if (widget.themeConfig != null) {
        return AtmosphericErrorHandler.validateColorAlpha(
          widget.themeConfig!.particleColor,
          context: 'AtmosphericParticles',
        );
      }
      
      // Use theme-aware color if widget's baseColor is default white
      if (widget.baseColor == Colors.white) {
        return AtmosphericErrorHandler.validateColorAlpha(
          themeConfig.particleColor,
          context: 'AtmosphericParticles',
        );
      }
      
      return AtmosphericErrorHandler.validateColorAlpha(
        widget.baseColor,
        context: 'AtmosphericParticles',
      );
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error getting effective particle color',
        error: e,
      );
      return Colors.white.withValues(alpha: 0.3);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isTickerInitialized && _ticker.isActive) {
        _ticker.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      if (_isTickerInitialized && !_ticker.isActive && widget.enabled) {
        _ticker.start();
      }
    }
  }

  @override
  void didUpdateWidget(AtmosphericParticles oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle enable/disable
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        if (!_isTickerInitialized) {
          _ticker = createTicker(_onTick);
          _isTickerInitialized = true;
        }
        _ticker.start();
      } else {
        if (_isTickerInitialized) {
          _ticker.stop();
          try {
            _ticker.dispose();
          } catch (e) {
            debugPrint('Error disposing ticker in didUpdateWidget: $e');
          }
          _isTickerInitialized = false;
        }
        _particlePool.clear();
      }
    }

    // Handle particle count changes
    if (widget.particleCount != oldWidget.particleCount) {
      _currentParticleCount = widget.particleCount;
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final now = DateTime.now();
    final dt = _lastFrameTime == null
        ? 0.016 // ~60fps default
        : now.difference(_lastFrameTime!).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    // Record frame time for performance monitoring
    _performanceMonitor.recordFrame(dt * 1000);

    // Auto-scale based on performance
    if (_performanceMonitor.shouldDisableEffects) {
      _particlePool.clear();
      setState(() {});
      return;
    }

    if (_performanceMonitor.shouldReduceEffects) {
      _currentParticleCount = (_currentParticleCount * 0.75).round();
      _particlePool.reduceParticles(AtmosphericConstants.particleReductionFactor);
    }

    // Update existing particles
    _particlePool.update(dt);

    // Spawn new particles if needed
    _spawnParticlesIfNeeded();

    // Recycle particles that exit viewport
    _recycleOffscreenParticles();

    setState(() {});
  }

  void _spawnParticlesIfNeeded() {
    if (_lastSize == Size.zero) return;

    final targetCount = _currentParticleCount.clamp(0, widget.particleCount);
    final currentCount = _particlePool.activeCount;

    if (currentCount < targetCount) {
      final spawnCount = targetCount - currentCount;
      for (var i = 0; i < spawnCount; i++) {
        _spawnParticle();
      }
    }
  }

  void _spawnParticle() {
    if (_lastSize == Size.zero) return;

    // Get theme config from widget, provider, current theme, or fallback to haunted
    AtmosphericThemeConfig themeConfig;
    if (widget.themeConfig != null) {
      themeConfig = widget.themeConfig!;
    } else if (mounted) {
      themeConfig = getAtmosphericThemeFromProvider(context);
    } else {
      themeConfig = AtmosphericThemeConfig.haunted;
    }

    // Get effective color using enhanced theme integration
    final color = _getEffectiveParticleColor(themeConfig);

    switch (widget.type) {
      case ParticleType.fog:
        _spawnFogParticle(color);
        break;
      case ParticleType.ember:
        _spawnEmberParticle(color);
        break;
      case ParticleType.wisp:
        _spawnWispParticle(color);
        break;
    }
  }

  void _spawnFogParticle(Color color) {
    final width = _lastSize.width;
    final height = _lastSize.height;

    // Use relative positioning (fractions of screen dimensions)
    final relativeStartX = _random.nextBool() ? -0.067 : _random.nextDouble(); // -50px relative to 750px width
    final relativeStartY = _random.nextDouble();
    
    final startX = relativeStartX * width;
    final startY = relativeStartY * height;

    // Scale drift speed relative to screen width for consistent visual speed
    final baseDriftSpeed = width * 0.027; // ~20px for 750px width
    final driftSpeedVariation = width * 0.04; // ~30px for 750px width
    final driftSpeed = baseDriftSpeed + _random.nextDouble() * driftSpeedVariation;
    
    // Scale vertical oscillation relative to screen height
    final verticalOscillation = (_random.nextDouble() - 0.5) * height * 0.015; // ~10px for 667px height

    // Scale particle size relative to screen dimensions
    final baseSize = (width + height) * 0.03; // ~40px for average 708px dimension
    final sizeVariation = (width + height) * 0.045; // ~60px for average 708px dimension
    final size = baseSize + _random.nextDouble() * sizeVariation;
    
    final lifetime = 10.0 + _random.nextDouble() * 10.0; // 10-20 seconds
    
    // Validate and clamp opacity
    final rawOpacity = widget.opacity * (0.5 + _random.nextDouble() * 0.5);
    final opacity = AtmosphericErrorHandler.validateOpacity(
      rawOpacity.clamp(0.0, AtmosphericConstants.maxFogOpacity),
      context: 'FogParticle',
    );

    // Validate position and velocity
    final position = AtmosphericErrorHandler.validateOffset(
      Offset(startX, startY),
      context: 'FogParticle position',
    );
    final velocity = AtmosphericErrorHandler.validateOffset(
      Offset(driftSpeed, verticalOscillation),
      context: 'FogParticle velocity',
    );

    _particlePool.spawn(
      position: position,
      velocity: velocity,
      size: size,
      opacity: opacity,
      lifetime: lifetime,
      color: color.withValues(alpha: opacity),
    );
  }

  void _spawnEmberParticle(Color color) {
    final width = _lastSize.width;
    final height = _lastSize.height;

    // Use relative positioning (fractions of screen dimensions)
    final relativeStartX = _random.nextDouble();
    final relativeStartY = 1.03; // Just below screen (20px relative to 667px height)
    
    final startX = relativeStartX * width;
    final startY = relativeStartY * height;

    // Scale upward speed relative to screen height for consistent visual speed
    final baseUpwardSpeed = -height * 0.045; // ~-30px/sec for 667px height
    final upwardSpeedVariation = height * 0.03; // ~-20px/sec for 667px height
    final upwardSpeed = baseUpwardSpeed - _random.nextDouble() * upwardSpeedVariation;
    
    // Scale horizontal drift relative to screen width
    final horizontalDrift = (_random.nextDouble() - 0.5) * width * 0.027; // ~20px for 750px width

    // Scale particle size relative to screen dimensions (smaller particles)
    final baseSize = (width + height) * 0.004; // ~3px for average 708px dimension
    final sizeVariation = (width + height) * 0.007; // ~5px for average 708px dimension
    final size = baseSize + _random.nextDouble() * sizeVariation;
    
    final lifetime = 3.0 + _random.nextDouble() * 3.0; // 3-6 seconds
    final opacity = 0.6 + _random.nextDouble() * 0.4; // 0.6-1.0

    _particlePool.spawn(
      position: Offset(startX, startY),
      velocity: Offset(horizontalDrift, upwardSpeed),
      size: size,
      opacity: opacity,
      lifetime: lifetime,
      color: color.withValues(alpha: opacity),
    );
  }

  void _spawnWispParticle(Color color) {
    final width = _lastSize.width;
    final height = _lastSize.height;

    // Use relative positioning (center of screen)
    const relativeCenterX = 0.5;
    const relativeCenterY = 0.5;
    
    final centerX = relativeCenterX * width;
    final centerY = relativeCenterY * height;

    // Radial outward velocity scaled to screen dimensions
    final angle = _random.nextDouble() * 2 * pi;
    final baseSpeed = (width + height) * 0.035; // ~50px/sec for average 708px dimension
    final speedVariation = (width + height) * 0.07; // ~100px/sec for average 708px dimension
    final speed = baseSpeed + _random.nextDouble() * speedVariation;
    final velocityX = cos(angle) * speed;
    final velocityY = sin(angle) * speed;

    // Scale particle size relative to screen dimensions
    final baseSize = (width + height) * 0.007; // ~5px for average 708px dimension
    final sizeVariation = (width + height) * 0.014; // ~10px for average 708px dimension
    final size = baseSize + _random.nextDouble() * sizeVariation;
    
    final lifetime = 1.0 + _random.nextDouble() * 1.0; // 1-2 seconds
    final opacity = 0.7 + _random.nextDouble() * 0.3; // 0.7-1.0

    _particlePool.spawn(
      position: Offset(centerX, centerY),
      velocity: Offset(velocityX, velocityY),
      size: size,
      opacity: opacity,
      lifetime: lifetime,
      color: color.withValues(alpha: opacity),
    );
  }

  void _recycleOffscreenParticles() {
    if (_lastSize == Size.zero) return;

    final width = _lastSize.width;
    final height = _lastSize.height;
    
    // Use relative margins (proportional to screen size)
    final marginX = width * 0.133; // ~100px for 750px width
    final marginY = height * 0.15; // ~100px for 667px height

    _particlePool.recycleWhere((particle) {
      // Recycle particles that exit viewport with relative margins
      return particle.position.dx < -marginX ||
          particle.position.dx > width + marginX ||
          particle.position.dy < -marginY ||
          particle.position.dy > height + marginY;
    });
  }

  /// Calculate particle count based on screen area and device capabilities
  int _calculateScaledParticleCount(Size screenSize, double devicePixelRatio) {
    // Handle infinite or invalid dimensions
    if (!screenSize.width.isFinite || !screenSize.height.isFinite || 
        screenSize.width <= 0 || screenSize.height <= 0) {
      return widget.particleCount.clamp(5, 100);
    }
    
    // Base screen area (reference: 375x667 iPhone 8)
    const double baseScreenArea = 375.0 * 667.0;
    final double currentScreenArea = screenSize.width * screenSize.height;
    
    // Calculate area ratio with bounds checking
    final double areaRatio = (currentScreenArea / baseScreenArea).clamp(0.1, 10.0);
    
    // Adjust for device pixel ratio (higher DPI = more capable device)
    final double deviceCapabilityFactor = (devicePixelRatio / 2.0).clamp(0.5, 2.0);
    
    // Scale particle count proportionally to screen area and device capability
    final double scaledCount = widget.particleCount * areaRatio * deviceCapabilityFactor;
    
    // Ensure scaledCount is finite before rounding
    if (!scaledCount.isFinite) {
      return widget.particleCount.clamp(5, 100);
    }
    
    // Clamp to reasonable bounds (min 5, max 100)
    return scaledCount.round().clamp(5, 100);
  }

  /// Recalculate particles when orientation changes
  void _handleOrientationChange(Size newSize, double devicePixelRatio) {
    final bool sizeChanged = _lastSize != Size.zero && _lastSize != newSize;
    final bool pixelRatioChanged = _devicePixelRatio != devicePixelRatio;
    
    if (sizeChanged || pixelRatioChanged) {
      // Clear existing particles and respawn for new dimensions
      _particlePool.clear();
      _lastSize = newSize;
      _devicePixelRatio = devicePixelRatio;
      
      // Recalculate particle count based on new screen dimensions
      _currentParticleCount = _calculateScaledParticleCount(newSize, devicePixelRatio);
      
      _spawnParticlesIfNeeded();
    } else {
      _lastSize = newSize;
      _devicePixelRatio = devicePixelRatio;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isTickerInitialized) {
      AtmosphericErrorHandler.safeDisposeTicker(
        _ticker,
        context: 'AtmosphericParticles',
      );
    }
    _particlePool.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final mediaQuery = MediaQuery.of(context);
        final devicePixelRatio = mediaQuery.devicePixelRatio;
        
        _handleOrientationChange(size, devicePixelRatio);

        return CustomPaint(
          size: size,
          painter: _FogParticlePainter(
            particles: _particlePool.activeParticles,
            particleType: widget.type,
          ),
        );
      },
    );
  }
}

/// Custom painter for rendering fog particles efficiently
class _FogParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ParticleType particleType;

  _FogParticlePainter({
    required this.particles,
    required this.particleType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

      // Render based on particle type
      switch (particleType) {
        case ParticleType.fog:
          // Render fog as soft circles
          canvas.drawCircle(particle.position, particle.size / 2, paint);
          break;
        case ParticleType.ember:
          // Render embers with glow effect
          final glowPaint = Paint()
            ..color = particle.color.withValues(alpha: particle.opacity * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
          canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
          canvas.drawCircle(particle.position, particle.size / 2, paint);
          break;
        case ParticleType.wisp:
          // Render wisps as small glowing dots
          canvas.drawCircle(particle.position, particle.size / 2, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(_FogParticlePainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
