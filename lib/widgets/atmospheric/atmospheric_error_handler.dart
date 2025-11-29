import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'atmospheric_theme_config.dart';

/// Centralized error handling and validation for atmospheric effects
class AtmosphericErrorHandler {
  /// Validate and clamp opacity value to valid range [0.0, 1.0]
  static double validateOpacity(double opacity, {String? context}) {
    if (!opacity.isFinite || opacity.isNaN) {
      _logWarning('Invalid opacity value: $opacity${context != null ? ' in $context' : ''}. Using 0.5 as fallback.');
      return 0.5;
    }
    
    final clamped = opacity.clamp(0.0, 1.0);
    if (clamped != opacity) {
      _logWarning('Opacity value $opacity${context != null ? ' in $context' : ''} was clamped to $clamped');
    }
    
    return clamped;
  }

  /// Validate and clamp color alpha channel
  static Color validateColorAlpha(Color color, {String? context}) {
    final alpha = color.a;
    if (!alpha.isFinite || alpha.isNaN) {
      _logWarning('Invalid color alpha: $alpha${context != null ? ' in $context' : ''}. Using default color.');
      return color.withValues(alpha: 0.5);
    }
    
    final clampedAlpha = alpha.clamp(0.0, 1.0);
    if (clampedAlpha != alpha) {
      _logWarning('Color alpha $alpha${context != null ? ' in $context' : ''} was clamped to $clampedAlpha');
      return color.withValues(alpha: clampedAlpha);
    }
    
    return color;
  }

  /// Validate color luminance for shadow colors (should be dark)
  static bool isValidShadowColor(Color color) {
    return color.computeLuminance() < 0.3;
  }

  /// Validate and ensure shadow color is dark enough
  static Color validateShadowColor(Color color, {String? context}) {
    if (!isValidShadowColor(color)) {
      _logWarning('Shadow color luminance too high (${color.computeLuminance()})${context != null ? ' in $context' : ''}. Using dark fallback.');
      return const Color(0xFF1A0033); // Dark purple fallback
    }
    return color;
  }

  /// Validate particle count and clamp to reasonable bounds
  static int validateParticleCount(int count, {int min = 5, int max = 100, String? context}) {
    if (count < min || count > max) {
      _logWarning('Particle count $count${context != null ? ' in $context' : ''} out of bounds [$min, $max]. Clamping.');
      return count.clamp(min, max);
    }
    return count;
  }

  /// Validate size dimensions
  static Size validateSize(Size size, {String? context}) {
    if (!size.width.isFinite || !size.height.isFinite || 
        size.width <= 0 || size.height <= 0) {
      _logWarning('Invalid size: $size${context != null ? ' in $context' : ''}. Using fallback size.');
      return const Size(375.0, 667.0); // iPhone 8 size as fallback
    }
    return size;
  }

  /// Validate offset values
  static Offset validateOffset(Offset offset, {String? context}) {
    if (!offset.dx.isFinite || !offset.dy.isFinite) {
      _logWarning('Invalid offset: $offset${context != null ? ' in $context' : ''}. Using zero offset.');
      return Offset.zero;
    }
    return offset;
  }

  /// Validate duration
  static Duration validateDuration(Duration duration, {Duration? min, Duration? max, String? context}) {
    if (duration.inMicroseconds <= 0) {
      _logWarning('Invalid duration: $duration${context != null ? ' in $context' : ''}. Using 1 second fallback.');
      return const Duration(seconds: 1);
    }
    
    if (min != null && duration < min) {
      _logWarning('Duration $duration${context != null ? ' in $context' : ''} below minimum $min. Using minimum.');
      return min;
    }
    
    if (max != null && duration > max) {
      _logWarning('Duration $duration${context != null ? ' in $context' : ''} above maximum $max. Using maximum.');
      return max;
    }
    
    return duration;
  }

  /// Validate theme configuration and provide fallback
  static AtmosphericThemeConfig validateThemeConfig(
    AtmosphericThemeConfig? config, {
    String? context,
  }) {
    if (config == null) {
      _logWarning('Null theme configuration${context != null ? ' in $context' : ''}. Using haunted theme fallback.');
      return AtmosphericThemeConfig.haunted;
    }
    
    // Validate colors in the config
    try {
      // Check if colors are valid by accessing their properties
      config.primaryGlowColor.value;
      config.secondaryGlowColor.value;
      config.particleColor.value;
      config.shadowColor.value;
      
      // Validate base intensity
      if (!config.baseIntensity.isFinite || config.baseIntensity < 0) {
        _logWarning('Invalid base intensity in theme config${context != null ? ' in $context' : ''}. Using haunted theme fallback.');
        return AtmosphericThemeConfig.haunted;
      }
      
      return config;
    } catch (e) {
      _logWarning('Error validating theme config${context != null ? ' in $context' : ''}: $e. Using haunted theme fallback.');
      return AtmosphericThemeConfig.haunted;
    }
  }

  /// Check if device supports atmospheric effects
  static bool isDeviceSupported() {
    // Check for basic Flutter rendering support
    // In practice, all Flutter-supported devices should work
    // This is a placeholder for future device-specific checks
    return true;
  }

  /// Get recommended particle count based on device capabilities
  static int getRecommendedParticleCount(BuildContext context, int baseCount) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    
    // Validate screen size
    final validatedSize = validateSize(screenSize, context: 'getRecommendedParticleCount');
    
    // Base screen area (reference: 375x667 iPhone 8)
    const double baseScreenArea = 375.0 * 667.0;
    final double currentScreenArea = validatedSize.width * validatedSize.height;
    
    // Calculate area ratio with bounds checking
    final double areaRatio = (currentScreenArea / baseScreenArea).clamp(0.1, 10.0);
    
    // Adjust for device pixel ratio (higher DPI = more capable device)
    final double deviceCapabilityFactor = (devicePixelRatio / 2.0).clamp(0.5, 2.0);
    
    // Scale particle count
    final double scaledCount = baseCount * areaRatio * deviceCapabilityFactor;
    
    // Ensure scaledCount is finite before rounding
    if (!scaledCount.isFinite) {
      _logWarning('Calculated particle count is not finite. Using base count.');
      return validateParticleCount(baseCount);
    }
    
    return validateParticleCount(scaledCount.round());
  }

  /// Handle animation controller disposal errors
  static void safeDisposeController(AnimationController controller, {String? context}) {
    try {
      controller.dispose();
    } catch (e) {
      _logWarning('Error disposing animation controller${context != null ? ' in $context' : ''}: $e');
    }
  }

  /// Handle ticker disposal errors
  static void safeDisposeTicker(Ticker ticker, {String? context}) {
    try {
      ticker.stop();
      ticker.dispose();
    } catch (e) {
      _logWarning('Error disposing ticker${context != null ? ' in $context' : ''}: $e');
    }
  }

  /// Log warning message (only in debug mode)
  static void _logWarning(String message) {
    if (kDebugMode) {
      debugPrint('[AtmosphericEffects] WARNING: $message');
    }
  }

  /// Log error message (only in debug mode)
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[AtmosphericEffects] ERROR: $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  Stack trace: $stackTrace');
      }
    }
  }

  /// Log info message (only in debug mode)
  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('[AtmosphericEffects] INFO: $message');
    }
  }

  /// Check if asset exists (basic check)
  static Future<bool> checkAssetExists(String assetPath) async {
    try {
      // This is a simplified check - in production you might want more robust checking
      return true; // Assume assets exist unless proven otherwise
    } catch (e) {
      _logWarning('Error checking asset existence for $assetPath: $e');
      return false;
    }
  }

  /// Create fallback widget for failed atmospheric effects
  static Widget createFallbackWidget({
    required String effectName,
    String? errorMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: kDebugMode
          ? Text(
              'Atmospheric effect "$effectName" failed${errorMessage != null ? ': $errorMessage' : ''}',
              style: const TextStyle(color: Colors.red, fontSize: 10),
            )
          : const SizedBox.shrink(),
    );
  }
}
