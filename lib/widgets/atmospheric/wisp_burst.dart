import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'particle.dart';
import 'atmospheric_theme_config.dart';
import 'atmospheric_error_handler.dart';

/// Widget that generates a burst of wisp particles for milestone feedback
/// Auto-disposes after animation completes
class WispBurst extends StatefulWidget {
  /// Origin point for the burst
  final Offset origin;

  /// Number of wisp particles to generate
  final int particleCount;

  /// Color of the wisp particles
  final Color color;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  /// Optional theme configuration for color selection
  final AtmosphericThemeConfig? themeConfig;

  const WispBurst({
    super.key,
    required this.origin,
    this.particleCount = 20,
    this.color = const Color(0xFF10B981), // Ghostly green
    this.onComplete,
    this.themeConfig,
  });

  @override
  State<WispBurst> createState() => _WispBurstState();
}

class _WispBurstState extends State<WispBurst>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  late List<Particle> _particles;
  late Random _random;
  DateTime? _lastFrameTime;
  bool _animationComplete = false;

  // Physics constants
  static const double _gravity = 100.0; // pixels/sec^2 downward
  static const double _airResistance = 0.95; // velocity multiplier per second

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _random = Random();
    _particles = [];
    _initializeParticles();

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      if (!_animationComplete && !_ticker.isActive) {
        _ticker.start();
      }
    }
  }

  void _initializeParticles() {
    // Get effective color from theme or widget parameter
    // Note: We can't access context in initState, so we use widget parameters only
    Color effectiveColor = widget.color;
    try {
      if (widget.themeConfig != null) {
        effectiveColor = AtmosphericErrorHandler.validateColorAlpha(
          widget.themeConfig!.secondaryGlowColor,
          context: 'WispBurst',
        );
      } else {
        effectiveColor = AtmosphericErrorHandler.validateColorAlpha(
          widget.color,
          context: 'WispBurst',
        );
      }
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error getting effective wisp color',
        error: e,
      );
      effectiveColor = const Color(0xFF10B981); // Ghostly green fallback
    }

    for (var i = 0; i < widget.particleCount; i++) {
      // Random angle for radial burst
      final angle = _random.nextDouble() * 2 * pi;

      // Random speed with variation
      final speed = 50.0 + _random.nextDouble() * 100.0; // 50-150 pixels/sec

      // Calculate velocity components
      final velocityX = cos(angle) * speed;
      final velocityY = sin(angle) * speed;

      // Random size
      final size = 5.0 + _random.nextDouble() * 10.0; // 5-15 pixels

      // Random lifetime between 1-2 seconds
      final lifetime = 1.0 + _random.nextDouble() * 1.0;

      // Initial opacity
      final opacity = 0.7 + _random.nextDouble() * 0.3; // 0.7-1.0

      _particles.add(Particle(
        position: widget.origin,
        velocity: Offset(velocityX, velocityY),
        size: size,
        opacity: opacity,
        lifetime: lifetime,
        maxLifetime: lifetime,
        rotation: 0.0,
        color: effectiveColor,
      ));
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted || _animationComplete) return;

    final now = DateTime.now();
    final dt = _lastFrameTime == null
        ? 0.016 // ~60fps default
        : now.difference(_lastFrameTime!).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    // Update all particles with physics
    for (final particle in _particles) {
      // Apply gravity (downward acceleration)
      particle.velocity = Offset(
        particle.velocity.dx,
        particle.velocity.dy + _gravity * dt,
      );

      // Apply air resistance
      final resistanceFactor = pow(_airResistance, dt).toDouble();
      particle.velocity = Offset(
        particle.velocity.dx * resistanceFactor,
        particle.velocity.dy * resistanceFactor,
      );

      // Update particle (position, lifetime, opacity)
      particle.update(dt);
    }

    // Check if all particles are dead
    final allDead = _particles.every((p) => !p.isAlive);
    if (allDead) {
      _animationComplete = true;
      _ticker.stop();

      // Call onComplete callback
      if (widget.onComplete != null) {
        widget.onComplete!();
      }

      // Auto-dispose by removing from tree
      if (mounted) {
        // Schedule removal after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Widget will be removed by parent or can trigger its own removal
            setState(() {});
          }
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AtmosphericErrorHandler.safeDisposeTicker(
      _ticker,
      context: 'WispBurst',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationComplete) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _WispBurstPainter(particles: _particles),
      child: const SizedBox.expand(),
    );
  }
}

/// Custom painter for rendering wisp burst particles
class _WispBurstPainter extends CustomPainter {
  final List<Particle> particles;

  _WispBurstPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (!particle.isAlive) continue;

      // Create paint with current opacity
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      // Draw wisp as small glowing circle
      canvas.drawCircle(particle.position, particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_WispBurstPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
