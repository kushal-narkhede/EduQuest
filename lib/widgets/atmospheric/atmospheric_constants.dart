/// Constants for atmospheric visual effects
class AtmosphericConstants {
  // Performance thresholds
  static const double targetFps = 60.0;
  static const double minAcceptableFps = 55.0;
  static const double criticalFps = 45.0;
  static const int performanceSampleSize = 60;
  static const int lowFpsThresholdFrames = 180; // 3 seconds at 60fps

  // Particle system defaults
  static const int defaultFogParticleCount = 30;
  static const int defaultEmberParticleCount = 20;
  static const int defaultWispParticleCount = 20;
  static const int maxParticlePoolSize = 100;
  static const double particleReductionFactor = 0.25; // 25% reduction

  // Animation durations
  static const Duration defaultFloatingDuration = Duration(seconds: 3);
  static const Duration defaultPulseDuration = Duration(milliseconds: 800);
  static const Duration defaultShadowTransitionDuration = Duration(milliseconds: 150);
  static const Duration wispBurstDuration = Duration(milliseconds: 1500);

  // Visual parameters
  static const double defaultFogOpacity = 0.3;
  static const double maxFogOpacity = 0.4;
  static const double defaultFloatingAmplitude = 8.0;
  static const double maxFloatingAmplitude = 10.0;
  static const double defaultGlowIntensity = 0.6;
  static const double ghostMascotSize = 80.0;

  // Shadow parameters
  static const double defaultRestingElevation = 8.0;
  static const double defaultPressedElevation = 2.0;
  static const int shadowLayerCount = 3;

  // Rotation parameters (in radians)
  static const double minFloatingRotation = -0.035; // ~-2 degrees
  static const double maxFloatingRotation = 0.035; // ~2 degrees

  AtmosphericConstants._();
}
