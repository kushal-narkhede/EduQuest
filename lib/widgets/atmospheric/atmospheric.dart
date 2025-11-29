import 'package:flutter/material.dart';
import 'atmospheric_particles.dart';
import 'ghost_mascot.dart';
import 'atmospheric_theme_config.dart';
import 'atmospheric_constants.dart';
import 'atmospheric_error_handler.dart';

// Export enums and classes for external use
export 'atmospheric_theme_config.dart' show AtmosphericIntensity, AtmosphericThemeConfig;
export 'ghost_mascot.dart' show GhostState;

/// Convenience wrapper that combines multiple atmospheric effects
/// 
/// This widget provides a simple way to add fog, embers, and ghost mascot
/// to any screen while maintaining performance and theme consistency.
/// 
/// Example usage:
/// ```dart
/// AtmosphericScaffold(
///   intensity: AtmosphericIntensity.normal,
///   showFog: true,
///   showEmbers: true,
///   showGhost: true,
///   child: YourScreenContent(),
/// )
/// ```
class AtmosphericScaffold extends StatelessWidget {
  /// The main content widget to display
  final Widget child;
  
  /// Whether to show the ghost mascot
  final bool showGhost;
  
  /// Whether to show fog particles
  final bool showFog;
  
  /// Whether to show ember particles
  final bool showEmbers;
  
  /// Intensity level for atmospheric effects
  final AtmosphericIntensity intensity;
  
  /// Optional theme configuration for atmospheric effects
  /// If null, uses AtmosphericThemeConfig.haunted as default
  final AtmosphericThemeConfig? themeConfig;
  
  /// Ghost mascot state (idle, celebrating, encouraging)
  final GhostState ghostState;
  
  /// Ghost mascot alignment on screen
  final Alignment ghostAlignment;
  
  /// Whether to auto-hide ghost during interactions
  final bool autoHideGhost;

  const AtmosphericScaffold({
    super.key,
    required this.child,
    this.showGhost = true,
    this.showFog = true,
    this.showEmbers = true,
    this.intensity = AtmosphericIntensity.normal,
    this.themeConfig,
    this.ghostState = GhostState.idle,
    this.ghostAlignment = Alignment.topRight,
    this.autoHideGhost = true,
  });

  /// Get particle count based on intensity level and screen area
  int _getParticleCount(int baseCount, BuildContext context) {
    try {
      final mediaQuery = MediaQuery.of(context);
      final screenSize = AtmosphericErrorHandler.validateSize(
        mediaQuery.size,
        context: 'AtmosphericScaffold',
      );
      final devicePixelRatio = mediaQuery.devicePixelRatio;
      
      // Validate base count
      final validatedBaseCount = AtmosphericErrorHandler.validateParticleCount(
        baseCount,
        context: 'AtmosphericScaffold baseCount',
      );
      
      // Base screen area (reference: 375x667 iPhone 8)
      const double baseScreenArea = 375.0 * 667.0;
      final double currentScreenArea = screenSize.width * screenSize.height;
      
      // Calculate area ratio with bounds checking
      final double areaRatio = (currentScreenArea / baseScreenArea).clamp(0.1, 10.0);
      
      // Adjust for device pixel ratio (higher DPI = more capable device)
      final double deviceCapabilityFactor = (devicePixelRatio / 2.0).clamp(0.5, 2.0);
      
      // Apply intensity scaling
      double intensityMultiplier;
      switch (intensity) {
        case AtmosphericIntensity.minimal:
          intensityMultiplier = 0.5;
          break;
        case AtmosphericIntensity.normal:
          intensityMultiplier = 1.0;
          break;
        case AtmosphericIntensity.maximum:
          intensityMultiplier = 1.5;
          break;
      }
      
      // Combine all scaling factors
      final double scaledCount = validatedBaseCount * areaRatio * deviceCapabilityFactor * intensityMultiplier;
      
      // Ensure scaledCount is finite before rounding
      if (!scaledCount.isFinite) {
        AtmosphericErrorHandler.logError('Calculated particle count is not finite');
        return validatedBaseCount;
      }
      
      // Clamp to reasonable bounds (min 5, max 100)
      return AtmosphericErrorHandler.validateParticleCount(scaledCount.round());
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error calculating particle count',
        error: e,
      );
      return AtmosphericErrorHandler.validateParticleCount(baseCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme config from widget parameter, provider, current theme, or fallback to haunted
    AtmosphericThemeConfig effectiveThemeConfig;
    try {
      if (themeConfig != null) {
        effectiveThemeConfig = AtmosphericErrorHandler.validateThemeConfig(
          themeConfig,
          context: 'AtmosphericScaffold',
        );
      } else {
        effectiveThemeConfig = AtmosphericErrorHandler.validateThemeConfig(
          getAtmosphericThemeFromProvider(context),
          context: 'AtmosphericScaffold',
        );
      }
    } catch (e) {
      AtmosphericErrorHandler.logError(
        'Error getting theme config in AtmosphericScaffold',
        error: e,
      );
      effectiveThemeConfig = AtmosphericThemeConfig.haunted;
    }
    
    // Use Stack with fit: StackFit.passthrough to avoid adding constraints
    // This ensures the child maintains its original size and position
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none, // Don't clip atmospheric effects
      children: [
        // Fog layer (bottom-most atmospheric layer, ignore pointer events)
        if (showFog)
          Positioned.fill(
            child: IgnorePointer(
              child: AtmosphericParticles(
                type: ParticleType.fog,
                particleCount: _getParticleCount(
                  AtmosphericConstants.defaultFogParticleCount,
                  context,
                ),
                baseColor: effectiveThemeConfig.particleColor,
                opacity: AtmosphericConstants.defaultFogOpacity,
                enabled: true,
                themeConfig: effectiveThemeConfig,
              ),
            ),
          ),
        
        // Main content (rendered on top of fog but below embers and ghost)
        // No Positioned wrapper to preserve original layout
        child,
        
        // Ember layer (above content)
        if (showEmbers)
          Positioned.fill(
            child: IgnorePointer(
              child: AtmosphericParticles(
                type: ParticleType.ember,
                particleCount: _getParticleCount(
                  AtmosphericConstants.defaultEmberParticleCount,
                  context,
                ),
                baseColor: effectiveThemeConfig.secondaryGlowColor,
                opacity: 0.8,
                enabled: true,
                themeConfig: effectiveThemeConfig,
              ),
            ),
          ),
        
        // Ghost mascot (top-most layer, but positioned to avoid interactions)
        if (showGhost)
          GhostMascot(
            state: ghostState,
            alignment: ghostAlignment,
            size: AtmosphericConstants.ghostMascotSize,
            autoHide: autoHideGhost,
            isVisible: true,
          ),
      ],
    );
  }
}
