import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/performance_monitor.dart';
import 'package:faker/faker.dart';

void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
    });

    test('should initialize with 60 FPS', () {
      expect(monitor.averageFps, equals(60.0));
    });

    test('should record frame times', () {
      monitor.recordFrame(16.67); // ~60 FPS
      expect(monitor.frameTimes.length, equals(1));
      expect(monitor.averageFps, closeTo(60.0, 0.1));
    });

    test('should maintain sample size limit', () {
      // Record more than sample size
      for (int i = 0; i < 100; i++) {
        monitor.recordFrame(16.67);
      }
      expect(monitor.frameTimes.length, equals(60));
    });

    test('should calculate average FPS correctly', () {
      // Record 30 FPS (33.33ms per frame)
      for (int i = 0; i < 60; i++) {
        monitor.recordFrame(33.33);
      }
      expect(monitor.averageFps, closeTo(30.0, 1.0));
    });

    test('should detect when effects should be reduced', () {
      // Record frames at 50 FPS (20ms per frame)
      for (int i = 0; i < 60; i++) {
        monitor.recordFrame(20.0);
      }
      expect(monitor.shouldReduceEffects, isTrue);
    });

    test('should not reduce effects at good FPS', () {
      // Record frames at 60 FPS
      for (int i = 0; i < 60; i++) {
        monitor.recordFrame(16.67);
      }
      expect(monitor.shouldReduceEffects, isFalse);
    });

    test('should detect when effects should be disabled', () {
      // Record frames at 40 FPS (25ms per frame) for 3 seconds
      for (int i = 0; i < 180; i++) {
        monitor.recordFrame(25.0);
      }
      expect(monitor.shouldDisableEffects, isTrue);
    });

    test('should reset low FPS counter when performance improves', () {
      // Record low FPS
      for (int i = 0; i < 100; i++) {
        monitor.recordFrame(25.0);
      }
      // Record good FPS
      monitor.recordFrame(16.67);
      expect(monitor.shouldDisableEffects, isFalse);
    });

    test('should reset monitor state', () {
      monitor.recordFrame(16.67);
      monitor.recordFrame(20.0);
      monitor.reset();
      expect(monitor.frameTimes.length, equals(0));
      expect(monitor.averageFps, equals(60.0));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 4: Particle system maintains target frame rate**
    /// **Validates: Requirements 2.2, 8.1**
    /// 
    /// Property: For any 60-frame sampling window while atmospheric effects are active,
    /// the average frame rate should be at or above 55 fps.
    test('Property 4: Performance monitor correctly identifies target frame rate maintenance', () {
      final faker = Faker();
      const int iterations = 100;
      const double targetFps = 55.0;

      for (int iteration = 0; iteration < iterations; iteration++) {
        final testMonitor = PerformanceMonitor();

        // Generate random frame times that should maintain target FPS
        // Frame time for 55+ FPS should be <= 18.18ms
        final bool shouldMaintainTarget = faker.randomGenerator.boolean();

        if (shouldMaintainTarget) {
          // Generate frame times for good performance (55-65 FPS)
          final double targetFrameTime = faker.randomGenerator.decimal(
            min: 15.38, // ~65 FPS
            scale: 18.18 - 15.38, // up to ~55 FPS
          );

          // Record 60 frames at this rate
          for (int i = 0; i < 60; i++) {
            testMonitor.recordFrame(targetFrameTime);
          }

          // Property: Average FPS should be at or above target
          expect(
            testMonitor.averageFps,
            greaterThanOrEqualTo(targetFps),
            reason:
                'Iteration $iteration: Frame time ${targetFrameTime.toStringAsFixed(2)}ms should maintain target FPS',
          );

          // Should not trigger reduction
          expect(
            testMonitor.shouldReduceEffects,
            isFalse,
            reason:
                'Iteration $iteration: Good performance should not trigger effect reduction',
          );
        } else {
          // Generate frame times for poor performance (30-54 FPS)
          final double poorFrameTime = faker.randomGenerator.decimal(
            min: 18.52, // ~54 FPS
            scale: 33.33 - 18.52, // up to ~30 FPS
          );

          // Record 60 frames at this rate
          for (int i = 0; i < 60; i++) {
            testMonitor.recordFrame(poorFrameTime);
          }

          // Property: Average FPS should be below target
          expect(
            testMonitor.averageFps,
            lessThan(targetFps),
            reason:
                'Iteration $iteration: Frame time ${poorFrameTime.toStringAsFixed(2)}ms should be below target FPS',
          );

          // Should trigger reduction
          expect(
            testMonitor.shouldReduceEffects,
            isTrue,
            reason:
                'Iteration $iteration: Poor performance should trigger effect reduction',
          );
        }
      }
    });

    /// Additional property test: Frame time recording maintains consistency
    test('Property: Frame time recording maintains mathematical consistency', () {
      final faker = Faker();
      const int iterations = 100;

      for (int iteration = 0; iteration < iterations; iteration++) {
        final testMonitor = PerformanceMonitor();

        // Generate random frame time between 10ms (100 FPS) and 50ms (20 FPS)
        final double frameTime = faker.randomGenerator.decimal(
          min: 10.0,
          scale: 40.0,
        );

        // Record the same frame time multiple times
        final int frameCount = faker.randomGenerator.integer(60, min: 10);
        for (int i = 0; i < frameCount; i++) {
          testMonitor.recordFrame(frameTime);
        }

        // Property: Average FPS should match the mathematical expectation
        final double expectedFps = 1000.0 / frameTime;
        expect(
          testMonitor.averageFps,
          closeTo(expectedFps, 0.01),
          reason:
              'Iteration $iteration: Frame time ${frameTime.toStringAsFixed(2)}ms should produce ${expectedFps.toStringAsFixed(2)} FPS',
        );
      }
    });

    /// Property test: Sample size limit is always maintained
    test('Property: Sample size limit is always maintained regardless of input', () {
      final faker = Faker();
      const int iterations = 100;

      for (int iteration = 0; iteration < iterations; iteration++) {
        final testMonitor = PerformanceMonitor();

        // Generate random number of frames to record (more than sample size)
        final int frameCount = faker.randomGenerator.integer(200, min: 61);

        for (int i = 0; i < frameCount; i++) {
          final double frameTime = faker.randomGenerator.decimal(
            min: 10.0,
            scale: 40.0,
          );
          testMonitor.recordFrame(frameTime);
        }

        // Property: Frame times list should never exceed sample size
        expect(
          testMonitor.frameTimes.length,
          lessThanOrEqualTo(60),
          reason:
              'Iteration $iteration: After recording $frameCount frames, sample size should be capped at 60',
        );
      }
    });
  });
}
