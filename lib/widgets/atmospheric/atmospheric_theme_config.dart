import 'package:flutter/material.dart';

/// Intensity level for atmospheric effects
enum AtmosphericIntensity {
  /// Reduced effects for performance-constrained devices
  minimal,
  
  /// Standard effects for most devices
  normal,
  
  /// Full effects for high-end devices
  maximum,
}

/// Configuration class for atmospheric visual effects theme
/// Defines color palettes and intensity settings for haunted visual effects
class AtmosphericThemeConfig {
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final Color particleColor;
  final Color shadowColor;
  final double baseIntensity;

  const AtmosphericThemeConfig({
    required this.primaryGlowColor,
    required this.secondaryGlowColor,
    required this.particleColor,
    required this.shadowColor,
    this.baseIntensity = 1.0,
  });

  /// Haunted theme preset with purple and ghostly green colors
  static const haunted = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF9D4EDD), // Purple
    secondaryGlowColor: Color(0xFF10B981), // Ghostly green
    particleColor: Color(0xFFE0E0E0), // Light gray
    shadowColor: Color(0xFF1A0033), // Dark purple
  );

  /// Ember theme preset with warm orange and yellow colors
  static const ember = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFFFF6B35), // Orange
    secondaryGlowColor: Color(0xFFFBBD08), // Yellow
    particleColor: Color(0xFFFF8C42), // Warm orange
    shadowColor: Color(0xFF2D1B00), // Dark brown
  );

  /// Beach theme preset with tropical colors
  static const beach = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF4DD0E1), // Turquoise
    secondaryGlowColor: Color(0xFF4CAF50), // Tropical green
    particleColor: Color(0xFFE0F7FA), // Light aqua
    shadowColor: Color(0xFF006064), // Dark teal
  );

  /// Forest theme preset with natural colors
  static const forest = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF66BB6A), // Forest green
    secondaryGlowColor: Color(0xFF8BC34A), // Lime green
    particleColor: Color(0xFFC8E6C9), // Light green
    shadowColor: Color(0xFF1B5E20), // Dark green
  );

  /// Arctic theme preset with icy colors
  static const arctic = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF81D4FA), // Icy blue
    secondaryGlowColor: Color(0xFFB3E5FC), // Pale ice
    particleColor: Color(0xFFE1F5FE), // Very light blue
    shadowColor: Color(0xFF01579B), // Dark blue
  );

  /// Crystal theme preset with glassy colors
  static const crystal = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF80DEEA), // Glassy teal
    secondaryGlowColor: Color(0xFF4DD0E1), // Bright teal
    particleColor: Color(0xFFE0F7FA), // Light aqua
    shadowColor: Color(0xFF00695C), // Dark teal
  );

  /// Space theme preset with cosmic colors
  static const space = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF7986CB), // Space blue
    secondaryGlowColor: Color(0xFF9C27B0), // Cosmic purple
    particleColor: Color(0xFFE8EAF6), // Light space blue
    shadowColor: Color(0xFF1A237E), // Dark space blue
  );

  /// Halloween theme preset with spooky colors
  static const halloween = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFFFF6F00), // Pumpkin orange
    secondaryGlowColor: Color(0xFF9D4EDD), // Purple
    particleColor: Color(0xFFFFF3E0), // Light orange
    shadowColor: Color(0xFF1A0B2E), // Midnight violet
  );

  /// Create a copy with modified properties
  AtmosphericThemeConfig copyWith({
    Color? primaryGlowColor,
    Color? secondaryGlowColor,
    Color? particleColor,
    Color? shadowColor,
    double? baseIntensity,
  }) {
    return AtmosphericThemeConfig(
      primaryGlowColor: primaryGlowColor ?? this.primaryGlowColor,
      secondaryGlowColor: secondaryGlowColor ?? this.secondaryGlowColor,
      particleColor: particleColor ?? this.particleColor,
      shadowColor: shadowColor ?? this.shadowColor,
      baseIntensity: baseIntensity ?? this.baseIntensity,
    );
  }

  /// Get atmospheric theme configuration for a given theme name
  /// Falls back to haunted theme if theme is not recognized
  static AtmosphericThemeConfig forTheme(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'beach':
        return beach;
      case 'forest':
        return forest;
      case 'arctic':
        return arctic;
      case 'crystal':
        return crystal;
      case 'space':
        return space;
      case 'halloween':
        return halloween;
      case 'ember':
        return ember;
      case 'haunted':
      default:
        return haunted;
    }
  }
}

/// Extension on ThemeData to add atmospheric theme configuration
extension AtmosphericThemeExtension on ThemeData {
  /// Get the atmospheric theme configuration from the current theme
  /// Uses theme colors to create an appropriate atmospheric configuration
  AtmosphericThemeConfig get atmosphericConfig {
    // Try to determine theme from primary color
    final primaryColor = colorScheme.primary;
    
    // Match against known theme colors from EduQuest ThemeColors
    if (primaryColor == const Color(0xFF4DD0E1)) {
      return AtmosphericThemeConfig.beach;
    } else if (primaryColor == const Color(0xFF2E7D32)) {
      return AtmosphericThemeConfig.forest;
    } else if (primaryColor == const Color(0xFF81D4FA)) {
      return AtmosphericThemeConfig.arctic;
    } else if (primaryColor == const Color(0xFF80DEEA)) {
      return AtmosphericThemeConfig.crystal;
    } else if (primaryColor == const Color(0xFF1A0B2E)) {
      return AtmosphericThemeConfig.halloween;
    } else if (primaryColor == const Color(0xFF0A0E21)) {
      return AtmosphericThemeConfig.space;
    }
    
    // Fallback: create atmospheric config from theme colors
    return AtmosphericThemeConfig(
      primaryGlowColor: colorScheme.primary,
      secondaryGlowColor: colorScheme.secondary,
      particleColor: colorScheme.onSurface.withValues(alpha: 0.7),
      shadowColor: colorScheme.shadow,
    );
  }

  /// Get atmospheric theme configuration for a specific theme name
  /// This method provides theme-aware color selection
  AtmosphericThemeConfig atmosphericConfigForTheme(String themeName) {
    return AtmosphericThemeConfig.forTheme(themeName);
  }
}

/// Extension to integrate with EduQuest's ThemeColors class
extension EduQuestThemeColorsIntegration on AtmosphericThemeConfig {
  /// Create atmospheric theme configuration from EduQuest ThemeColors
  /// This integrates directly with the existing theme system
  static AtmosphericThemeConfig fromEduQuestThemeColors(String themeName) {
    // Import the ThemeColors class functionality
    switch (themeName.toLowerCase()) {
      case 'beach':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFF4DD0E1), // ThemeColors.getPrimaryColor('beach')
          secondaryGlowColor: const Color(0xFF4CAF50), // ThemeColors.getTropicalGreen('beach')
          particleColor: const Color(0xFFE0F7FA), // Light aqua
          shadowColor: const Color(0xFF006064), // Dark teal
        );
      case 'forest':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFF2E7D32), // ThemeColors.getPrimaryColor('forest')
          secondaryGlowColor: const Color(0xFF8BC34A), // ThemeColors.getAccentColor('forest')
          particleColor: const Color(0xFFC8E6C9), // Light green
          shadowColor: const Color(0xFF1B5E20), // Dark green
        );
      case 'arctic':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFF81D4FA), // ThemeColors.getPrimaryColor('arctic')
          secondaryGlowColor: const Color(0xFFB3E5FC), // ThemeColors.getSecondaryColor('arctic')
          particleColor: const Color(0xFFE1F5FE), // Very light blue
          shadowColor: const Color(0xFF01579B), // Dark blue
        );
      case 'crystal':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFF80DEEA), // ThemeColors.getPrimaryColor('crystal')
          secondaryGlowColor: const Color(0xFF4DD0E1), // ThemeColors.getButtonColor('crystal')
          particleColor: const Color(0xFFE0F7FA), // Light aqua
          shadowColor: const Color(0xFF00695C), // Dark teal
        );
      case 'space':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFF7986CB), // Space blue
          secondaryGlowColor: const Color(0xFF9C27B0), // Cosmic purple
          particleColor: const Color(0xFFE8EAF6), // Light space blue
          shadowColor: const Color(0xFF1A237E), // Dark space blue
        );
      case 'halloween':
        return AtmosphericThemeConfig(
          primaryGlowColor: const Color(0xFFFF6F00), // ThemeColors.getSecondaryColor('halloween')
          secondaryGlowColor: const Color(0xFF9D4EDD), // Purple
          particleColor: const Color(0xFFFFF3E0), // Light orange
          shadowColor: const Color(0xFF1A0B2E), // ThemeColors.getPrimaryColor('halloween')
        );
      case 'haunted':
      default:
        return AtmosphericThemeConfig.haunted;
    }
  }
}



/// Global helper function to get atmospheric theme configuration
/// This provides a bridge between the existing theme system and atmospheric effects
/// 
/// This is the main function used by atmospheric widgets for theme integration
AtmosphericThemeConfig getAtmosphericThemeConfig(BuildContext context, [String? themeName]) {
  // If explicit theme is provided, use EduQuest integration
  if (themeName != null && themeName.isNotEmpty) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(themeName);
  }
  
  // Try to detect current theme from context
  final detectedTheme = detectCurrentEduQuestTheme(context);
  if (detectedTheme != null) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(detectedTheme);
  }
  
  // Fallback to theme extension
  return Theme.of(context).atmosphericConfig;
}

/// Helper function to create atmospheric theme configuration from EduQuest theme name
/// This is the main integration point with the existing theme system
AtmosphericThemeConfig getAtmosphericThemeForEduQuest(String themeName) {
  return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(themeName);
}

/// Helper function to determine if a theme supports atmospheric effects
bool supportsAtmosphericEffects(String themeName) {
  // All themes support atmospheric effects, but some may have reduced intensity
  return true;
}

/// Helper function to get recommended atmospheric intensity for a theme
AtmosphericIntensity getRecommendedIntensityForTheme(String themeName) {
  switch (themeName.toLowerCase()) {
    case 'beach':
    case 'arctic':
    case 'crystal':
      // Lighter themes may benefit from reduced intensity to maintain readability
      return AtmosphericIntensity.normal;
    case 'halloween':
    case 'haunted':
    case 'space':
      // Dark themes can handle maximum intensity
      return AtmosphericIntensity.maximum;
    case 'forest':
    default:
      return AtmosphericIntensity.normal;
  }
}

/// Advanced theme detection that works with EduQuest's theme system
/// This function attempts to detect the current theme from multiple sources
String? detectCurrentEduQuestTheme(BuildContext context) {
  final theme = Theme.of(context);
  
  // Method 1: Check scaffold background color (most reliable for EduQuest)
  final scaffoldColor = theme.scaffoldBackgroundColor;
  
  // EduQuest uses specific scaffold colors for each theme
  if (scaffoldColor == const Color(0xFF0A0E21)) {
    return 'space'; // Default dark theme
  }
  
  // Method 2: Check primary color from ThemeColors
  final primaryColor = theme.colorScheme.primary;
  if (primaryColor == const Color(0xFF4DD0E1)) {
    return 'beach';
  } else if (primaryColor == const Color(0xFF2E7D32)) {
    return 'forest';
  } else if (primaryColor == const Color(0xFF81D4FA)) {
    return 'arctic';
  } else if (primaryColor == const Color(0xFF80DEEA)) {
    return 'crystal';
  } else if (primaryColor == const Color(0xFF1A0B2E)) {
    return 'halloween';
  }
  
  // Method 3: Check for specific color combinations that indicate themes
  final secondaryColor = theme.colorScheme.secondary;
  
  // Beach theme has specific turquoise + beige combination
  if (primaryColor == const Color(0xFF4DD0E1) && 
      scaffoldColor != const Color(0xFF0A0E21)) {
    return 'beach';
  }
  
  // Halloween theme has midnight violet primary
  if (primaryColor == const Color(0xFF1A0B2E)) {
    return 'halloween';
  }
  
  // Default to space theme if we can't detect
  return 'space';
}

/// Get atmospheric theme configuration with enhanced EduQuest integration
/// This is the main integration point that should be used by atmospheric widgets
AtmosphericThemeConfig getAtmosphericThemeConfigWithFallback(BuildContext context, [String? explicitTheme]) {
  // If explicit theme is provided, use EduQuest integration
  if (explicitTheme != null && explicitTheme.isNotEmpty) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(explicitTheme);
  }
  
  // Try to detect current theme
  final detectedTheme = detectCurrentEduQuestTheme(context);
  if (detectedTheme != null) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(detectedTheme);
  }
  
  // Fallback to theme extension
  return Theme.of(context).atmosphericConfig;
}

/// Create a theme-aware atmospheric configuration that adapts to runtime theme changes
/// This function ensures atmospheric effects always match the current theme
AtmosphericThemeConfig createAdaptiveAtmosphericConfig(BuildContext context, {
  String? preferredTheme,
  AtmosphericIntensity? intensity,
}) {
  // Get base config using EduQuest integration
  AtmosphericThemeConfig baseConfig;
  
  if (preferredTheme != null && preferredTheme.isNotEmpty) {
    baseConfig = EduQuestThemeColorsIntegration.fromEduQuestThemeColors(preferredTheme);
  } else {
    final detectedTheme = detectCurrentEduQuestTheme(context);
    if (detectedTheme != null) {
      baseConfig = EduQuestThemeColorsIntegration.fromEduQuestThemeColors(detectedTheme);
    } else {
      baseConfig = Theme.of(context).atmosphericConfig;
    }
  }
  
  // Apply intensity adjustment if specified
  if (intensity != null) {
    final intensityMultiplier = switch (intensity) {
      AtmosphericIntensity.minimal => 0.5,
      AtmosphericIntensity.normal => 1.0,
      AtmosphericIntensity.maximum => 1.5,
    };
    
    return baseConfig.copyWith(
      baseIntensity: baseConfig.baseIntensity * intensityMultiplier,
    );
  }
  
  return baseConfig;
}

/// Widget that provides atmospheric theme context to child widgets
/// This widget ensures atmospheric effects respond to theme changes at runtime
class AtmosphericThemeProvider extends StatefulWidget {
  final Widget child;
  final String? explicitTheme;
  final AtmosphericIntensity intensity;
  final bool enableThemeDetection;

  const AtmosphericThemeProvider({
    super.key,
    required this.child,
    this.explicitTheme,
    this.intensity = AtmosphericIntensity.normal,
    this.enableThemeDetection = true,
  });

  @override
  State<AtmosphericThemeProvider> createState() => _AtmosphericThemeProviderState();
}

class _AtmosphericThemeProviderState extends State<AtmosphericThemeProvider> {
  AtmosphericThemeConfig? _cachedConfig;
  String? _lastDetectedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateThemeConfig();
  }

  void _updateThemeConfig() {
    final newConfig = createAdaptiveAtmosphericConfig(
      context,
      preferredTheme: widget.explicitTheme,
      intensity: widget.intensity,
    );
    
    final currentTheme = widget.explicitTheme ?? detectCurrentEduQuestTheme(context);
    
    // Only update if theme actually changed
    if (_cachedConfig != newConfig || _lastDetectedTheme != currentTheme) {
      setState(() {
        _cachedConfig = newConfig;
        _lastDetectedTheme = currentTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AtmosphericThemeScope(
      config: _cachedConfig ?? AtmosphericThemeConfig.haunted,
      child: widget.child,
    );
  }
}

/// Internal widget that provides atmospheric theme configuration through InheritedWidget
class _AtmosphericThemeScope extends InheritedWidget {
  final AtmosphericThemeConfig config;

  const _AtmosphericThemeScope({
    required this.config,
    required super.child,
  });

  static AtmosphericThemeConfig? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AtmosphericThemeScope>();
    return scope?.config;
  }

  @override
  bool updateShouldNotify(_AtmosphericThemeScope oldWidget) {
    return config != oldWidget.config;
  }
}

/// Enhanced helper function that uses AtmosphericThemeProvider if available
/// This provides the most accurate theme configuration for atmospheric widgets
AtmosphericThemeConfig getAtmosphericThemeFromProvider(BuildContext context, [String? fallbackTheme]) {
  // Try to get from provider first
  final providerConfig = _AtmosphericThemeScope.of(context);
  if (providerConfig != null) {
    return providerConfig;
  }
  
  // Fallback to EduQuest theme integration
  if (fallbackTheme != null && fallbackTheme.isNotEmpty) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(fallbackTheme);
  }
  
  // Detect current theme and use EduQuest integration
  final detectedTheme = detectCurrentEduQuestTheme(context);
  if (detectedTheme != null) {
    return EduQuestThemeColorsIntegration.fromEduQuestThemeColors(detectedTheme);
  }
  
  // Final fallback to theme extension
  return Theme.of(context).atmosphericConfig;
}

/// Helper function to get current theme name from various sources
/// This function attempts to determine the current theme name for atmospheric widgets
String getCurrentThemeName(BuildContext context, [String? explicitTheme]) {
  // If explicit theme is provided, use it
  if (explicitTheme != null && explicitTheme.isNotEmpty) {
    return explicitTheme;
  }
  
  // Try to detect from context
  final detectedTheme = detectCurrentEduQuestTheme(context);
  if (detectedTheme != null) {
    return detectedTheme;
  }
  
  // Default fallback
  return 'space';
}

/// Test if atmospheric effects should be enabled for the current theme
/// Some themes may want reduced or disabled atmospheric effects
bool shouldEnableAtmosphericEffects(String themeName) {
  switch (themeName.toLowerCase()) {
    case 'beach':
    case 'arctic':
    case 'crystal':
      // Light themes may want reduced atmospheric effects
      return true;
    case 'halloween':
    case 'haunted':
    case 'space':
    case 'forest':
      // Dark themes work well with full atmospheric effects
      return true;
    default:
      return true;
  }
}

/// Get the recommended atmospheric intensity for a theme
/// This helps atmospheric widgets choose appropriate effect levels
AtmosphericIntensity getAtmosphericIntensityForTheme(String themeName) {
  return getRecommendedIntensityForTheme(themeName);
}
