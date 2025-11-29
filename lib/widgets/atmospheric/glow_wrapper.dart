import 'package:flutter/material.dart';
import 'atmospheric_theme_config.dart';
import 'atmospheric_constants.dart';
import 'atmospheric_error_handler.dart';

/// Wrapper widget that applies phosphorescent glow effects to interactive UI elements
/// 
/// The glow effect uses multiple layered BoxShadow to create an eerie illumination
/// that intensifies on user interaction with a pulsing animation.
class GlowWrapper extends StatefulWidget {
  /// The child widget to wrap with glow effects
  final Widget child;
  
  /// Color of the glow effect
  final Color glowColor;
  
  /// Intensity of the glow effect (0.0 to 1.0)
  final double glowIntensity;
  
  /// Whether to pulse the glow when user interacts
  final bool pulseOnHover;
  
  /// Duration of the pulse animation
  final Duration pulseDuration;
  
  /// Optional theme configuration for color selection
  final AtmosphericThemeConfig? themeConfig;

  const GlowWrapper({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF9D4EDD), // Purple
    this.glowIntensity = AtmosphericConstants.defaultGlowIntensity,
    this.pulseOnHover = true,
    this.pulseDuration = AtmosphericConstants.defaultPulseDuration,
    this.themeConfig,
  });

  @override
  State<GlowWrapper> createState() => _GlowWrapperState();
}

class _GlowWrapperState extends State<GlowWrapper>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePulseAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      if (_isInteracting && widget.pulseOnHover) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GlowWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.pulseDuration != widget.pulseDuration) {
      _pulseController.duration = widget.pulseDuration;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AtmosphericErrorHandler.safeDisposeController(
      _pulseController,
      context: 'GlowWrapper',
    );
    super.dispose();
  }

  void _handleInteractionStart() {
    if (!widget.pulseOnHover) return;
    
    setState(() {
      _isInteracting = true;
    });
    
    _pulseController.repeat(reverse: true);
  }

  void _handleInteractionEnd() {
    if (!widget.pulseOnHover) return;
    
    setState(() {
      _isInteracting = false;
    });
    
    _pulseController.stop();
    _pulseController.reset();
  }

  Color _getEffectiveGlowColor() {
    try {
      // Use theme config if provided
      if (widget.themeConfig != null) {
        return AtmosphericErrorHandler.validateColorAlpha(
          widget.themeConfig!.primaryGlowColor,
          context: 'GlowWrapper',
        );
      }
      
      // Try to get theme config from provider first, then fallback to detection
      final atmosphericConfig = AtmosphericErrorHandler.validateThemeConfig(
        getAtmosphericThemeFromProvider(context),
        context: 'GlowWrapper',
      );
      
      // Use theme-aware color if widget's glowColor is default purple
      if (widget.glowColor == const Color(0xFF9D4EDD)) {
        return AtmosphericErrorHandler.validateColorAlpha(
          atmosphericConfig.primaryGlowColor,
          context: 'GlowWrapper',
        );
      }
      
      return AtmosphericErrorHandler.validateColorAlpha(
        widget.glowColor,
        context: 'GlowWrapper',
      );
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error getting effective glow color',
        error: e,
      );
      return const Color(0xFF9D4EDD); // Purple fallback
    }
  }

  List<BoxShadow> _buildGlowShadows(double intensityMultiplier) {
    final effectiveColor = _getEffectiveGlowColor();
    final baseIntensity = AtmosphericErrorHandler.validateOpacity(
      widget.glowIntensity,
      context: 'GlowWrapper baseIntensity',
    );
    final intensity = baseIntensity * intensityMultiplier.clamp(0.0, 2.0);
    
    return [
      // Inner glow - tight and bright
      BoxShadow(
        color: effectiveColor.withValues(alpha: intensity * 0.6),
        blurRadius: 8.0 * intensity,
        spreadRadius: 2.0 * intensity,
        offset: Offset.zero,
      ),
      // Middle glow - medium spread
      BoxShadow(
        color: effectiveColor.withValues(alpha: intensity * 0.4),
        blurRadius: 16.0 * intensity,
        spreadRadius: 4.0 * intensity,
        offset: Offset.zero,
      ),
      // Outer glow - diffuse and dim
      BoxShadow(
        color: effectiveColor.withValues(alpha: intensity * 0.2),
        blurRadius: 24.0 * intensity,
        spreadRadius: 6.0 * intensity,
        offset: Offset.zero,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleInteractionStart(),
      onTapUp: (_) => _handleInteractionEnd(),
      onTapCancel: _handleInteractionEnd,
      onLongPressStart: (_) => _handleInteractionStart(),
      onLongPressEnd: (_) => _handleInteractionEnd(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final intensityMultiplier = _isInteracting 
              ? _pulseAnimation.value 
              : 1.0;
          
          return Container(
            decoration: BoxDecoration(
              boxShadow: _buildGlowShadows(intensityMultiplier),
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
