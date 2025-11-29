import 'package:flutter/material.dart';
import 'atmospheric_theme_config.dart';
import 'atmospheric_constants.dart';
import 'atmospheric_error_handler.dart';

/// Wrapper widget that applies dynamic shadows that respond to user interactions
/// 
/// The shadow system creates depth perception through layered shadows that:
/// - Reduce intensity when pressed (element moves closer to screen)
/// - Update position in real-time during drag
/// - Smoothly transition back to resting state
/// - Use haunted theme colors (dark purples, blacks with tints)
class DynamicShadowWrapper extends StatefulWidget {
  /// The child widget to wrap with dynamic shadows
  final Widget child;
  
  /// Color of the shadow effect
  final Color shadowColor;
  
  /// Shadow intensity at rest (elevation)
  final double restingElevation;
  
  /// Shadow intensity when pressed (reduced elevation)
  final double pressedElevation;
  
  /// Duration of shadow transitions
  final Duration transitionDuration;
  
  /// Optional theme configuration for color selection
  final AtmosphericThemeConfig? themeConfig;

  const DynamicShadowWrapper({
    super.key,
    required this.child,
    this.shadowColor = const Color(0xFF1A0033), // Dark purple
    this.restingElevation = 8.0,
    this.pressedElevation = 2.0,
    this.transitionDuration = AtmosphericConstants.defaultShadowTransitionDuration,
    this.themeConfig,
  });

  @override
  State<DynamicShadowWrapper> createState() => _DynamicShadowWrapperState();
}

class _DynamicShadowWrapperState extends State<DynamicShadowWrapper>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _transitionController;
  late Animation<double> _elevationAnimation;
  
  double _currentElevation = 0.0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentElevation = widget.restingElevation;
    _initializeTransitionAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause animations when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_transitionController.isAnimating) {
        _transitionController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume animations when app returns to foreground
      // Shadow animations are typically short, so we don't need to resume them
    }
  }

  void _initializeTransitionAnimation() {
    _transitionController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.restingElevation,
      end: widget.pressedElevation,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(DynamicShadowWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.transitionDuration != widget.transitionDuration) {
      _transitionController.duration = widget.transitionDuration;
    }
    
    if (oldWidget.restingElevation != widget.restingElevation ||
        oldWidget.pressedElevation != widget.pressedElevation) {
      _elevationAnimation = Tween<double>(
        begin: widget.restingElevation,
        end: widget.pressedElevation,
      ).animate(CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOut,
      ));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AtmosphericErrorHandler.safeDisposeController(
      _transitionController,
      context: 'DynamicShadowWrapper',
    );
    super.dispose();
  }

  void _handlePressStart() {
    _transitionController.forward();
  }

  void _handlePressEnd() {
    if (!_isDragging) {
      setState(() {
        _dragOffset = Offset.zero;
      });
      _transitionController.reverse();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _transitionController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = details.localPosition;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
    _transitionController.reverse();
  }

  void _handleDragCancel() {
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
    _transitionController.reverse();
  }

  Color _getEffectiveShadowColor() {
    try {
      // Use theme config if provided
      if (widget.themeConfig != null) {
        return AtmosphericErrorHandler.validateShadowColor(
          widget.themeConfig!.shadowColor,
          context: 'DynamicShadowWrapper',
        );
      }
      
      // Try to get theme config from provider first, then fallback to detection
      final atmosphericConfig = AtmosphericErrorHandler.validateThemeConfig(
        getAtmosphericThemeFromProvider(context),
        context: 'DynamicShadowWrapper',
      );
      
      // Use theme-aware color if widget's shadowColor is default dark purple
      if (widget.shadowColor == const Color(0xFF1A0033)) {
        return AtmosphericErrorHandler.validateShadowColor(
          atmosphericConfig.shadowColor,
          context: 'DynamicShadowWrapper',
        );
      }
      
      return AtmosphericErrorHandler.validateShadowColor(
        widget.shadowColor,
        context: 'DynamicShadowWrapper',
      );
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error getting effective shadow color',
        error: e,
      );
      return const Color(0xFF1A0033); // Dark purple fallback
    }
  }

  List<BoxShadow> _buildDynamicShadows() {
    final effectiveColor = _getEffectiveShadowColor();
    final elevation = _currentElevation.isFinite && _currentElevation >= 0
        ? _currentElevation
        : widget.restingElevation;
    
    // Calculate shadow offset based on drag position
    // Shadows should appear opposite to the drag direction
    final shadowOffsetX = _isDragging ? -_dragOffset.dx * 0.05 : 0.0;
    final shadowOffsetY = _isDragging ? -_dragOffset.dy * 0.05 : elevation * 0.5;
    
    return [
      // Layer 1: Tight shadow close to element
      BoxShadow(
        color: effectiveColor.withValues(alpha: 0.4),
        blurRadius: elevation * 0.5,
        spreadRadius: elevation * 0.1,
        offset: Offset(shadowOffsetX * 0.3, shadowOffsetY * 0.3),
      ),
      // Layer 2: Medium shadow for depth
      BoxShadow(
        color: effectiveColor.withValues(alpha: 0.3),
        blurRadius: elevation * 1.0,
        spreadRadius: elevation * 0.2,
        offset: Offset(shadowOffsetX * 0.6, shadowOffsetY * 0.6),
      ),
      // Layer 3: Wide shadow for ambient depth
      BoxShadow(
        color: effectiveColor.withValues(alpha: 0.2),
        blurRadius: elevation * 1.5,
        spreadRadius: elevation * 0.3,
        offset: Offset(shadowOffsetX, shadowOffsetY),
      ),
      // Layer 4: Very diffuse outer shadow
      BoxShadow(
        color: effectiveColor.withValues(alpha: 0.1),
        blurRadius: elevation * 2.0,
        spreadRadius: elevation * 0.4,
        offset: Offset(shadowOffsetX * 1.2, shadowOffsetY * 1.2),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handlePressStart(),
      onTapUp: (_) => _handlePressEnd(),
      onTapCancel: _handlePressEnd,
      onLongPressStart: (_) => _handlePressStart(),
      onLongPressEnd: (_) => _handlePressEnd(),
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      onPanCancel: _handleDragCancel,
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          _currentElevation = _elevationAnimation.value;
          return Container(
            decoration: BoxDecoration(
              boxShadow: _buildDynamicShadows(),
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
