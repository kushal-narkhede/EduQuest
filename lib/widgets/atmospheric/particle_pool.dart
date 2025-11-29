import 'dart:ui';
import 'particle.dart';
import 'atmospheric_constants.dart';

/// Manages a pool of particles for efficient recycling
/// Prevents garbage collection pressure by reusing particle objects
class ParticlePool {
  final List<Particle> _activeParticles = [];
  final List<Particle> _inactiveParticles = [];
  final int maxPoolSize;

  ParticlePool({
    this.maxPoolSize = AtmosphericConstants.maxParticlePoolSize,
  });

  /// Get all currently active particles
  List<Particle> get activeParticles => _activeParticles;

  /// Get the count of active particles
  int get activeCount => _activeParticles.length;

  /// Get the count of inactive particles available for reuse
  int get inactiveCount => _inactiveParticles.length;

  /// Spawn a new particle or recycle an inactive one
  Particle spawn({
    required Offset position,
    required Offset velocity,
    required double size,
    required double opacity,
    required double lifetime,
    double rotation = 0.0,
    required Color color,
  }) {
    Particle particle;

    // Try to recycle an inactive particle first
    if (_inactiveParticles.isNotEmpty) {
      particle = _inactiveParticles.removeLast();
      particle.reset(
        newPosition: position,
        newVelocity: velocity,
        newSize: size,
        newOpacity: opacity,
        newLifetime: lifetime,
        newMaxLifetime: lifetime,
        newRotation: rotation,
        newColor: color,
      );
    } else if (_activeParticles.length < maxPoolSize) {
      // Create a new particle if we haven't reached the pool size limit
      particle = Particle(
        position: position,
        velocity: velocity,
        size: size,
        opacity: opacity,
        lifetime: lifetime,
        maxLifetime: lifetime,
        rotation: rotation,
        color: color,
      );
    } else {
      // Pool is full, recycle the oldest active particle
      particle = _activeParticles.removeAt(0);
      particle.reset(
        newPosition: position,
        newVelocity: velocity,
        newSize: size,
        newOpacity: opacity,
        newLifetime: lifetime,
        newMaxLifetime: lifetime,
        newRotation: rotation,
        newColor: color,
      );
    }

    _activeParticles.add(particle);
    return particle;
  }

  /// Update all active particles and recycle dead ones
  void update(double dt) {
    // Update all particles
    for (var particle in _activeParticles) {
      particle.update(dt);
    }

    // Move dead particles to inactive pool
    _activeParticles.removeWhere((particle) {
      if (!particle.isAlive) {
        _inactiveParticles.add(particle);
        return true;
      }
      return false;
    });
  }

  /// Recycle a specific particle manually
  void recycle(Particle particle) {
    if (_activeParticles.remove(particle)) {
      _inactiveParticles.add(particle);
    }
  }

  /// Recycle particles that meet a certain condition
  void recycleWhere(bool Function(Particle) test) {
    final toRecycle = _activeParticles.where(test).toList();
    for (var particle in toRecycle) {
      recycle(particle);
    }
  }

  /// Clear all particles from the pool
  void clear() {
    _inactiveParticles.addAll(_activeParticles);
    _activeParticles.clear();
  }

  /// Reduce the number of active particles by a percentage
  void reduceParticles(double percentage) {
    final reductionCount = (_activeParticles.length * percentage).round();
    for (var i = 0; i < reductionCount && _activeParticles.isNotEmpty; i++) {
      final particle = _activeParticles.removeAt(0);
      _inactiveParticles.add(particle);
    }
  }

  /// Get total particle count (active + inactive)
  int get totalCount => _activeParticles.length + _inactiveParticles.length;
}
