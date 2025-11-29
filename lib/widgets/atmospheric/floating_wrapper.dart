import 'package:flutter/material.dart';
import 'atmospheric_error_handler.dart';

/// A wrapper widget that applies gentle floating and swaying animations to its child.
/// 
/// The FloatingWrapper creates a natural, organic movement by combining:
/// - Vertical oscillation (floating up and down)
/// - Slight rotation (1-2 degrees for natural sway)
/// - Phase offset to stagger multiple elements
/// - Pause on interaction to prevent confusion
class FloatingWrapper extends StatefulWidget {
  final Widget child;
  final double amplitude; // Vertical movement range in pixels
  final Duration duration; // Animation cycle duration
  final Curve curve; // Easing curve
  final double phase; // Initial phase offset (0.0 to 1.0)
  final bool pauseOnInteraction; // Pause when user touches

  const FloatingWrapper({
    super.key,
    required this.child,
    this.amplitude = 8.0,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
    this.phase = 0.0,
    this.pauseOnInteraction = true,
  });

  @override
  State<FloatingWrapper> createState() => _FloatingWrapperState();
}

class _FloatingWrapperState extends State<FloatingWrapper>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Create animation controller with repeat mode
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create animation with easing curve
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation with phase offset
    _controller.repeat();
    if (widget.phase > 0.0) {
      _controller.value = widget.phase.clamp(0.0, 1.0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      if (!_isPaused) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AtmosphericErrorHandler.safeDisposeController(
      _controller,
      context: 'FloatingWrapper',
    );
    super.dispose();
  }

  void _handleInteractionStart() {
    if (widget.pauseOnInteraction && !_isPaused) {
      setState(() {
        _isPaused = true;
        _controller.stop();
      });
    }
  }

  void _handleInteractionEnd() {
    if (widget.pauseOnInteraction && _isPaused) {
      setState(() {
        _isPaused = false;
        _controller.repeat();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = AtmosphericErrorHandler.validateSize(
      mediaQuery.size,
      context: 'FloatingWrapper',
    );
    final screenHeight = screenSize.height;
    
    // Validate amplitude
    final validatedAmplitude = widget.amplitude.isFinite && widget.amplitude > 0
        ? widget.amplitude
        : 8.0;
    
    // Scale amplitude relative to screen height (maintain visual consistency)
    final scaledAmplitude = validatedAmplitude * (screenHeight / 667.0).clamp(0.8, 2.0);
    
    return GestureDetector(
      onTapDown: (_) => _handleInteractionStart(),
      onTapUp: (_) => _handleInteractionEnd(),
      onTapCancel: _handleInteractionEnd,
      onPanStart: (_) => _handleInteractionStart(),
      onPanEnd: (_) => _handleInteractionEnd(),
      onPanCancel: _handleInteractionEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate vertical offset using sine wave for smooth oscillation
          final progress = _animation.value;
          final verticalOffset = scaledAmplitude * (2 * progress - 1);
          
          // Calculate slight rotation (1-2 degrees) for natural sway
          final rotation = 0.02 * (2 * progress - 1); // ~1.15 degrees max
          
          return Transform.translate(
            offset: Offset(0, verticalOffset),
            child: Transform.rotate(
              angle: rotation,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
