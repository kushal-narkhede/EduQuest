import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/particle_pool.dart';
import 'package:student_learning_app/widgets/atmospheric/particle.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  group('ParticlePool', () {
    late ParticlePool pool;

    setUp(() {
      pool = ParticlePool(maxPoolSize: 50);
    });

    test('should initialize with zero particles', () {
      expect(pool.activeCount, equals(0));
      expect(pool.inactiveCount, equals(0));
    });

    test('should spawn new particles', () {
      pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        color: Colors.white,
      );

      expect(pool.activeCount, equals(1));
    });

    test('should update particles', () {
      final particle = pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 2.0,
        color: Colors.white,
      );

      final initialX = particle.position.dx;
      pool.update(0.1); // Update with 0.1 second delta

      expect(particle.position.dx, greaterThan(initialX));
    });

    test('should recycle dead particles', () {
      pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 0.5,
        color: Colors.white,
      );

      expect(pool.activeCount, equals(1));
      expect(pool.inactiveCount, equals(0));

      // Update enough to kill the particle
      pool.update(0.6);

      expect(pool.activeCount, equals(0));
      expect(pool.inactiveCount, equals(1));
    });

    test('should reuse inactive particles', () {
      // Spawn and kill a particle
      pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 0.5,
        color: Colors.white,
      );
      pool.update(0.6);

      expect(pool.totalCount, equals(1));

      // Spawn another particle - should reuse the inactive one
      pool.spawn(
        position: const Offset(200, 200),
        velocity: const Offset(5, 5),
        size: 3.0,
        opacity: 0.8,
        lifetime: 1.0,
        color: Colors.blue,
      );

      expect(pool.activeCount, equals(1));
      expect(pool.inactiveCount, equals(0));
      expect(pool.totalCount, equals(1)); // Total count should remain the same
    });

    test('should respect max pool size', () {
      // Spawn more particles than max pool size
      for (int i = 0; i < 60; i++) {
        pool.spawn(
          position: Offset(i.toDouble(), i.toDouble()),
          velocity: const Offset(10, 0),
          size: 5.0,
          opacity: 1.0,
          lifetime: 10.0,
          color: Colors.white,
        );
      }

      expect(pool.activeCount, lessThanOrEqualTo(50));
      expect(pool.totalCount, lessThanOrEqualTo(50));
    });

    test('should manually recycle particles', () {
      final particle = pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 10.0,
        color: Colors.white,
      );

      expect(pool.activeCount, equals(1));

      pool.recycle(particle);

      expect(pool.activeCount, equals(0));
      expect(pool.inactiveCount, equals(1));
    });

    test('should recycle particles based on condition', () {
      // Spawn particles at different positions
      pool.spawn(
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 10.0,
        color: Colors.white,
      );
      pool.spawn(
        position: const Offset(500, 100),
        velocity: const Offset(10, 0),
        size: 5.0,
        opacity: 1.0,
        lifetime: 10.0,
        color: Colors.white,
      );

      expect(pool.activeCount, equals(2));

      // Recycle particles outside viewport (x > 400)
      pool.recycleWhere((particle) => particle.position.dx > 400);

      expect(pool.activeCount, equals(1));
      expect(pool.inactiveCount, equals(1));
    });

    test('should clear all particles', () {
      for (int i = 0; i < 10; i++) {
        pool.spawn(
          position: Offset(i.toDouble(), i.toDouble()),
          velocity: const Offset(10, 0),
          size: 5.0,
          opacity: 1.0,
          lifetime: 10.0,
          color: Colors.white,
        );
      }

      expect(pool.activeCount, equals(10));

      pool.clear();

      expect(pool.activeCount, equals(0));
      expect(pool.inactiveCount, equals(10));
    });

    test('should reduce particles by percentage', () {
      for (int i = 0; i < 20; i++) {
        pool.spawn(
          position: Offset(i.toDouble(), i.toDouble()),
          velocity: const Offset(10, 0),
          size: 5.0,
          opacity: 1.0,
          lifetime: 10.0,
          color: Colors.white,
        );
      }

      expect(pool.activeCount, equals(20));

      pool.reduceParticles(0.25); // Reduce by 25%

      expect(pool.activeCount, equals(15));
      expect(pool.inactiveCount, equals(5));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 5: Particle recycling maintains constant count**
    /// **Validates: Requirements 2.3**
    /// 
    /// Property: For any particle that exits the viewport boundaries,
    /// the total particle count should remain constant before and after the particle is recycled.
    test('Property 5: Particle recycling maintains constant count', () {
      final faker = Faker();
      final random = math.Random();
      const int iterations = 100;
      
      // Predefined colors to avoid import conflicts
      final colors = [
        const ui.Color(0xFFFFFFFF), // White
        const ui.Color(0xFF9D4EDD), // Purple
        const ui.Color(0xFF10B981), // Green
        const ui.Color(0xFFFF6B35), // Orange
        const ui.Color(0xFFE0E0E0), // Gray
      ];

      for (int iteration = 0; iteration < iterations; iteration++) {
        final testPool = ParticlePool(maxPoolSize: 100);

        // Generate random initial particle count
        final int initialParticleCount = faker.randomGenerator.integer(50, min: 10);

        // Spawn initial particles with random properties
        for (int i = 0; i < initialParticleCount; i++) {
          testPool.spawn(
            position: Offset(
              faker.randomGenerator.decimal(scale: 1000),
              faker.randomGenerator.decimal(scale: 1000),
            ),
            velocity: Offset(
              faker.randomGenerator.decimal(min: -100, scale: 200),
              faker.randomGenerator.decimal(min: -100, scale: 200),
            ),
            size: faker.randomGenerator.decimal(min: 2, scale: 10),
            opacity: faker.randomGenerator.decimal(scale: 1),
            lifetime: faker.randomGenerator.decimal(min: 1, scale: 10),
            rotation: faker.randomGenerator.decimal(scale: 6.28), // 0 to 2π
            color: colors[random.nextInt(colors.length)],
          );
        }

        final int totalCountBefore = testPool.totalCount;
        expect(totalCountBefore, equals(initialParticleCount),
            reason: 'Iteration $iteration: Initial total count should match spawned count');

        // Simulate viewport boundaries
        final double viewportWidth = faker.randomGenerator.decimal(min: 500, scale: 1000);
        final double viewportHeight = faker.randomGenerator.decimal(min: 500, scale: 1000);

        // Update particles multiple times to move them
        final int updateSteps = faker.randomGenerator.integer(10, min: 1);
        for (int step = 0; step < updateSteps; step++) {
          testPool.update(0.1); // Update with 0.1 second delta

          // Recycle particles that exit viewport boundaries
          testPool.recycleWhere((particle) =>
              particle.position.dx < 0 ||
              particle.position.dx > viewportWidth ||
              particle.position.dy < 0 ||
              particle.position.dy > viewportHeight);

          // Property: Total count should remain constant after recycling
          final int totalCountAfterRecycle = testPool.totalCount;
          expect(
            totalCountAfterRecycle,
            equals(totalCountBefore),
            reason:
                'Iteration $iteration, Step $step: Total count should remain constant after recycling particles outside viewport',
          );
        }

        // Spawn new particles to replace recycled ones
        final int particlesToSpawn = faker.randomGenerator.integer(10, min: 1);
        for (int i = 0; i < particlesToSpawn; i++) {
          testPool.spawn(
            position: Offset(
              faker.randomGenerator.decimal(scale: viewportWidth),
              faker.randomGenerator.decimal(scale: viewportHeight),
            ),
            velocity: Offset(
              faker.randomGenerator.decimal(min: -100, scale: 200),
              faker.randomGenerator.decimal(min: -100, scale: 200),
            ),
            size: faker.randomGenerator.decimal(min: 2, scale: 10),
            opacity: faker.randomGenerator.decimal(scale: 1),
            lifetime: faker.randomGenerator.decimal(min: 1, scale: 10),
            color: colors[random.nextInt(colors.length)],
          );
        }

        // Property: Total count should increase by the number of new particles spawned
        // (unless we hit the max pool size)
        final int expectedTotalCount = math.min(
          totalCountBefore + particlesToSpawn,
          testPool.maxPoolSize,
        );
        expect(
          testPool.totalCount,
          lessThanOrEqualTo(expectedTotalCount),
          reason:
              'Iteration $iteration: Total count after spawning should not exceed expected count',
        );
      }
    });
  });
}
