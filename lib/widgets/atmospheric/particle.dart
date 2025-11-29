import 'dart:ui';

/// Represents a single particle in the atmospheric particle system
class Particle {
  /// Current position (x, y) in screen coordinates
  Offset position;

  /// Movement vector (pixels per second)
  Offset velocity;

  /// Particle size in pixels
  double size;

  /// Current opacity (0.0 to 1.0)
  double opacity;

  /// Remaining lifetime in seconds
  double lifetime;

  /// Maximum lifetime for opacity calculations
  double maxLifetime;

  /// Current rotation angle in radians
  double rotation;

  /// Particle color
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.lifetime,
    required this.maxLifetime,
    this.rotation = 0.0,
    required this.color,
  });

  /// Update particle state based on delta time
  void update(double dt) {
    // Update position based on velocity
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );

    // Decrease lifetime
    lifetime -= dt;

    // Update opacity based on remaining lifetime
    opacity = (lifetime / maxLifetime).clamp(0.0, 1.0);
  }

  /// Check if particle is still alive
  bool get isAlive => lifetime > 0;

  /// Reset particle with new properties for recycling
  void reset({
    required Offset newPosition,
    required Offset newVelocity,
    required double newSize,
    required double newOpacity,
    required double newLifetime,
    required double newMaxLifetime,
    double newRotation = 0.0,
    required Color newColor,
  }) {
    position = newPosition;
    velocity = newVelocity;
    size = newSize;
    opacity = newOpacity;
    lifetime = newLifetime;
    maxLifetime = newMaxLifetime;
    rotation = newRotation;
    color = newColor;
  }
}
