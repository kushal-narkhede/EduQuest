import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/particle.dart';
import 'package:faker/faker.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  group('Particle', () {
    test('should initialize with given properties', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        maxLifetime: 2.0,
        rotation: 0.5,
        color: const ui.Color(0xFFFFFFFF),
      );

      expect(particle.position, equals(const ui.Offset(100, 100)));
      expect(particle.velocity, equals(const ui.Offset(10, 5)));
      expect(particle.size, equals(5.0));
      expect(particle.opacity, equals(1.0));
      expect(particle.lifetime, equals(2.0));
      expect(particle.rotation, equals(0.5));
      expect(particle.isAlive, isTrue);
    });

    test('should update position based on velocity', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        maxLifetime: 2.0,
        color: const ui.Color(0xFFFFFFFF),
      );

      particle.update(0.1); // Update with 0.1 second delta

      expect(particle.position.dx, closeTo(101.0, 0.01));
      expect(particle.position.dy, closeTo(100.5, 0.01));
    });

    test('should decrease lifetime on update', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        maxLifetime: 2.0,
        color: const ui.Color(0xFFFFFFFF),
      );

      particle.update(0.5);

      expect(particle.lifetime, closeTo(1.5, 0.01));
    });

    test('should update opacity based on remaining lifetime', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        maxLifetime: 2.0,
        color: const ui.Color(0xFFFFFFFF),
      );

      particle.update(1.0); // Half lifetime remaining

      expect(particle.opacity, closeTo(0.5, 0.01));
    });

    test('should be dead when lifetime reaches zero', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 1.0,
        maxLifetime: 1.0,
        color: const ui.Color(0xFFFFFFFF),
      );

      particle.update(1.5);

      expect(particle.isAlive, isFalse);
      expect(particle.lifetime, lessThan(0));
    });

    test('should reset particle properties', () {
      final particle = Particle(
        position: const ui.Offset(100, 100),
        velocity: const ui.Offset(10, 5),
        size: 5.0,
        opacity: 1.0,
        lifetime: 1.0,
        maxLifetime: 1.0,
        color: const ui.Color(0xFFFFFFFF),
      );

      particle.reset(
        newPosition: const ui.Offset(200, 200),
        newVelocity: const ui.Offset(20, 10),
        newSize: 10.0,
        newOpacity: 0.5,
        newLifetime: 3.0,
        newMaxLifetime: 3.0,
        newRotation: 1.0,
        newColor: const ui.Color(0xFF0000FF),
      );

      expect(particle.position, equals(const ui.Offset(200, 200)));
      expect(particle.velocity, equals(const ui.Offset(20, 10)));
      expect(particle.size, equals(10.0));
      expect(particle.opacity, equals(0.5));
      expect(particle.lifetime, equals(3.0));
      expect(particle.rotation, equals(1.0));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 24: Wisp particles have physics properties**
    /// **Validates: Requirements 6.4**
    /// 
    /// Property: For any wisp particle, the particle should have velocity,
    /// gravity acceleration (represented by changing velocity), and decreasing opacity over its lifetime.
    test('Property 24: Wisp particles have physics properties', () {
      final faker = Faker();
      final random = math.Random();
      const int iterations = 100;

      // Predefined colors
      final colors = [
        const ui.Color(0xFFFFFFFF),
        const ui.Color(0xFF9D4EDD),
        const ui.Color(0xFF10B981),
        const ui.Color(0xFFFF6B35),
        const ui.Color(0xFFE0E0E0),
      ];

      for (int iteration = 0; iteration < iterations; iteration++) {
        // Generate random wisp particle with physics properties
        final initialVelocity = ui.Offset(
          faker.randomGenerator.decimal(min: -100, scale: 200),
          faker.randomGenerator.decimal(min: -100, scale: 200),
        );

        final lifetime = faker.randomGenerator.decimal(min: 0.5, scale: 2.0);

        final particle = Particle(
          position: ui.Offset(
            faker.randomGenerator.decimal(scale: 1000),
            faker.randomGenerator.decimal(scale: 1000),
          ),
          velocity: initialVelocity,
          size: faker.randomGenerator.decimal(min: 2, scale: 10),
          opacity: 1.0,
          lifetime: lifetime,
          maxLifetime: lifetime,
          rotation: faker.randomGenerator.decimal(scale: 6.28),
          color: colors[random.nextInt(colors.length)],
        );

        // Property 1: Particle should have velocity
        expect(
          particle.velocity,
          isNotNull,
          reason: 'Iteration $iteration: Particle must have velocity',
        );

        // Store initial state
        final initialOpacity = particle.opacity;
        final initialLifetime = particle.lifetime;
        final initialPosition = particle.position;

        // Simulate physics update with time delta
        final dt = faker.randomGenerator.decimal(min: 0.01, scale: 0.2);
        particle.update(dt);

        // Property 2: Position should change based on velocity (physics simulation)
        final expectedDx = initialPosition.dx + initialVelocity.dx * dt;
        final expectedDy = initialPosition.dy + initialVelocity.dy * dt;

        expect(
          particle.position.dx,
          closeTo(expectedDx, 0.01),
          reason:
              'Iteration $iteration: Position X should update based on velocity',
        );

        expect(
          particle.position.dy,
          closeTo(expectedDy, 0.01),
          reason:
              'Iteration $iteration: Position Y should update based on velocity',
        );

        // Property 3: Lifetime should decrease
        expect(
          particle.lifetime,
          lessThan(initialLifetime),
          reason: 'Iteration $iteration: Lifetime should decrease over time',
        );

        // Property 4: Opacity should decrease over lifetime (fade out)
        final expectedOpacity = (particle.lifetime / lifetime).clamp(0.0, 1.0);
        expect(
          particle.opacity,
          closeTo(expectedOpacity, 0.01),
          reason:
              'Iteration $iteration: Opacity should decrease proportionally to remaining lifetime',
        );

        expect(
          particle.opacity,
          lessThanOrEqualTo(initialOpacity),
          reason: 'Iteration $iteration: Opacity should not increase',
        );

        // Property 5: Opacity should be clamped between 0 and 1
        expect(
          particle.opacity,
          greaterThanOrEqualTo(0.0),
          reason: 'Iteration $iteration: Opacity should not be negative',
        );

        expect(
          particle.opacity,
          lessThanOrEqualTo(1.0),
          reason: 'Iteration $iteration: Opacity should not exceed 1.0',
        );

        // Simulate multiple updates to test physics over time
        final updateSteps = faker.randomGenerator.integer(10, min: 3);
        for (int step = 0; step < updateSteps; step++) {
          final stepDt = faker.randomGenerator.decimal(min: 0.01, scale: 0.1);
          final prevLifetime = particle.lifetime;

          particle.update(stepDt);

          // Property 6: Lifetime should continuously decrease
          if (particle.isAlive) {
            expect(
              particle.lifetime,
              lessThan(prevLifetime),
              reason:
                  'Iteration $iteration, Step $step: Lifetime should continuously decrease',
            );
          }

          // Property 7: Opacity should be proportional to remaining lifetime
          if (particle.isAlive) {
            final currentExpectedOpacity =
                (particle.lifetime / lifetime).clamp(0.0, 1.0);
            expect(
              particle.opacity,
              closeTo(currentExpectedOpacity, 0.01),
              reason:
                  'Iteration $iteration, Step $step: Opacity should remain proportional to lifetime',
            );
          }
        }

        // Property 8: Particle should eventually die
        if (particle.lifetime <= 0) {
          expect(
            particle.isAlive,
            isFalse,
            reason:
                'Iteration $iteration: Particle with zero or negative lifetime should be dead',
          );
        }
      }
    });

    /// Additional property test: Particle update maintains mathematical consistency
    test('Property: Particle update maintains mathematical consistency', () {
      final faker = Faker();
      const int iterations = 100;

      for (int iteration = 0; iteration < iterations; iteration++) {
        final velocity = ui.Offset(
          faker.randomGenerator.decimal(min: -50, scale: 100),
          faker.randomGenerator.decimal(min: -50, scale: 100),
        );

        final lifetime = faker.randomGenerator.decimal(min: 1, scale: 5);

        final particle = Particle(
          position: const ui.Offset(0, 0),
          velocity: velocity,
          size: 5.0,
          opacity: 1.0,
          lifetime: lifetime,
          maxLifetime: lifetime,
          color: const ui.Color(0xFFFFFFFF),
        );

        // Update multiple times with small time steps
        final steps = faker.randomGenerator.integer(20, min: 5);
        final dt = 0.1;
        double totalTime = 0;

        for (int step = 0; step < steps; step++) {
          particle.update(dt);
          totalTime += dt;

          if (particle.isAlive) {
            // Position should be initial + velocity * total time
            final expectedX = velocity.dx * totalTime;
            final expectedY = velocity.dy * totalTime;

            expect(
              particle.position.dx,
              closeTo(expectedX, 0.1),
              reason:
                  'Iteration $iteration, Step $step: Position X should match physics calculation',
            );

            expect(
              particle.position.dy,
              closeTo(expectedY, 0.1),
              reason:
                  'Iteration $iteration, Step $step: Position Y should match physics calculation',
            );

            // Lifetime should be initial - total time
            final expectedLifetime = lifetime - totalTime;
            expect(
              particle.lifetime,
              closeTo(expectedLifetime, 0.01),
              reason:
                  'Iteration $iteration, Step $step: Lifetime should match time calculation',
            );
          }
        }
      }
    });
  });
}
