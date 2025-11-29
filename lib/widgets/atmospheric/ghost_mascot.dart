import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'atmospheric_error_handler.dart';

/// State of the ghost mascot animation
enum GhostState {
  /// Gentle floating animation
  idle,
  
  /// Happy bounce when user answers correctly
  celebrating,
  
  /// Supportive gesture when user answers incorrectly
  encouraging,
}

/// Ghost mascot widget that displays an animated character using ghostLoader.json
/// 
/// The ghost provides visual feedback and guidance throughout the application,
/// creating an immersive haunted theme experience.
class GhostMascot extends StatefulWidget {
  /// Current state of the ghost animation
  final GhostState state;
  
  /// Position of the ghost on screen
  final Alignment alignment;
  
  /// Size of the ghost mascot in logical pixels
  final double size;
  
  /// Whether to hide the ghost during user interactions
  final bool autoHide;
  
  /// Whether the ghost is currently visible
  final bool isVisible;

  const GhostMascot({
    super.key,
    this.state = GhostState.idle,
    this.alignment = Alignment.topRight,
    this.size = 80.0,
    this.autoHide = true,
    this.isVisible = true,
  });

  @override
  State<GhostMascot> createState() => _GhostMascotState();
}

class _GhostMascotState extends State<GhostMascot>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFloatingAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_floatingController.isAnimating) {
        _floatingController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      if (!_floatingController.isAnimating && widget.state == GhostState.idle) {
        _floatingController.repeat(reverse: true);
      }
    }
  }

  void _initializeFloatingAnimation() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _floatingController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(GhostMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle state transitions
    if (oldWidget.state != widget.state) {
      _handleStateTransition();
    }
  }

  void _handleStateTransition() {
    // Reset and restart animation for state changes
    if (widget.state == GhostState.idle) {
      if (!_floatingController.isAnimating) {
        _floatingController.repeat(reverse: true);
      }
    } else {
      // For celebrating and encouraging states, we rely on Lottie animation
      // The floating animation continues in the background
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AtmosphericErrorHandler.safeDisposeController(
      _floatingController,
      context: 'GhostMascot',
    );
    super.dispose();
  }

  Widget _buildScaledGhostAnimation(double scaledSize) {
    try {
      return Lottie.asset(
        'assets/animation/ghostLoader.json',
        width: scaledSize,
        height: scaledSize,
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Log the error and provide fallback
          AtmosphericErrorHandler.logError(
            'Failed to load ghostLoader.json',
            error: error,
            stackTrace: stackTrace,
          );
          return _buildFallbackGhost(scaledSize);
        },
      );
    } catch (e, stackTrace) {
      // Fallback if asset is missing or other error occurs
      AtmosphericErrorHandler.logError(
        'Exception loading ghost mascot animation',
        error: e,
        stackTrace: stackTrace,
      );
      return _buildFallbackGhost(scaledSize);
    }
  }

  Widget _buildFallbackGhost(double scaledSize) {
    AtmosphericErrorHandler.logInfo('Using fallback ghost icon');
    
    // Validate size
    final validatedSize = scaledSize.isFinite && scaledSize > 0 
        ? scaledSize 
        : 80.0;
    
    return Container(
      width: validatedSize,
      height: validatedSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(validatedSize / 2),
      ),
      child: Icon(
        Icons.sentiment_satisfied_alt,
        size: validatedSize * 0.6,
        color: const Color(0xFF9D4EDD),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final screenSize = AtmosphericErrorHandler.validateSize(
      mediaQuery.size,
      context: 'GhostMascot',
    );
    final viewPadding = mediaQuery.viewPadding;
    
    // Validate widget size
    final validatedWidgetSize = widget.size.isFinite && widget.size > 0 
        ? widget.size 
        : 80.0;
    
    // Scale ghost size relative to screen dimensions (maintain aspect ratio)
    // Reduce size slightly to minimize visual footprint
    final scaledSize = (validatedWidgetSize * 0.85) * (screenSize.width / 375.0).clamp(0.8, 1.5);
    
    // Calculate safe positioning that avoids common UI areas
    // Use absolute positioning from edges instead of alignment to prevent overlap
    double? top, bottom, left, right;
    
    if (widget.alignment == Alignment.topRight) {
      // Position in top-right corner with safe area padding
      top = viewPadding.top + 8.0;
      right = 8.0;
    } else if (widget.alignment == Alignment.topLeft) {
      top = viewPadding.top + 8.0;
      left = 8.0;
    } else if (widget.alignment == Alignment.bottomRight) {
      bottom = viewPadding.bottom + 8.0;
      right = 8.0;
    } else if (widget.alignment == Alignment.bottomLeft) {
      bottom = viewPadding.bottom + 8.0;
      left = 8.0;
    } else {
      // For other alignments, use a safe default (top-right)
      top = viewPadding.top + 8.0;
      right = 8.0;
    }

    // Use Positioned instead of Positioned.fill + Align to avoid layout interference
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: SizedBox(
          width: scaledSize,
          height: scaledSize,
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Transform.rotate(
                  angle: _floatingAnimation.value * 0.02, // Slight rotation
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: widget.isVisible ? 1.0 : 0.0,
                    child: _buildScaledGhostAnimation(scaledSize),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
