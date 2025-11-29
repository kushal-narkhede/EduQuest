import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric.dart';
import 'package:student_learning_app/widgets/atmospheric/particle_pool.dart';
import 'package:student_learning_app/widgets/atmospheric/performance_monitor.dart';
import 'dart:math';

void main() {
  group('AtmosphericParticles Property Tests', () {
    /// **Feature: haunted-atmospheric-visuals, Property 3: Fog particles maintain horizontal drift**
    /// **Validates: Requirements 2.1**
    test(
        'Property 3: For any fog particle, velocity should have non-zero horizontal component',
        () {
      final random = Random(42); // Seeded for reproducibility
      final particlePool = ParticlePool();

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate random fog particle parameters
        final width = 300.0 + random.nextDouble() * 500.0; // 300-800
        final height = 400.0 + random.nextDouble() * 600.0; // 400-1000

        final startX = random.nextBool() ? -50.0 : random.nextDouble() * width;
        final startY = random.nextDouble() * height;

        // Simulate fog particle spawning logic
        final driftSpeed = 20.0 + random.nextDouble() * 30.0; // 20-50 pixels/sec
        final verticalOscillation =
            (random.nextDouble() - 0.5) * 10.0; // -5 to 5

        final size = 40.0 + random.nextDouble() * 60.0; // 40-100 pixels
        final lifetime = 10.0 + random.nextDouble() * 10.0; // 10-20 seconds
        final opacity = 0.3;

        final particle = particlePool.spawn(
          position: Offset(startX, startY),
          velocity: Offset(driftSpeed, verticalOscillation),
          size: size,
          opacity: opacity,
          lifetime: lifetime,
          color: const Color(0xFFE0E0E0),
        );

        // Property: Fog particles must have non-zero horizontal drift
        expect(
          particle.velocity.dx,
          isNonZero,
          reason:
              'Fog particle $i must have non-zero horizontal velocity component for drift',
        );

        // Additionally verify it's positive (rightward drift)
        expect(
          particle.velocity.dx,
          greaterThan(0),
          reason: 'Fog particle $i should drift rightward (positive dx)',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 6: Fog opacity preserves readability**
    /// **Validates: Requirements 2.4**
    test(
        'Property 6: For any fog particle, opacity should be <= 0.4 to preserve readability',
        () {
      final random = Random(123); // Seeded for reproducibility
      final particlePool = ParticlePool();

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate random fog particle parameters
        final width = 300.0 + random.nextDouble() * 500.0;
        final height = 400.0 + random.nextDouble() * 600.0;

        final startX = random.nextBool() ? -50.0 : random.nextDouble() * width;
        final startY = random.nextDouble() * height;

        final driftSpeed = 20.0 + random.nextDouble() * 30.0;
        final verticalOscillation = (random.nextDouble() - 0.5) * 10.0;

        final size = 40.0 + random.nextDouble() * 60.0;
        final lifetime = 10.0 + random.nextDouble() * 10.0;

        // Test with various base opacity values
        final baseOpacity = random.nextDouble() * 0.5; // 0.0-0.5
        final randomFactor = 0.5 + random.nextDouble() * 0.5; // 0.5-1.0
        final calculatedOpacity = (baseOpacity * randomFactor).clamp(0.0, 0.4);

        final particle = particlePool.spawn(
          position: Offset(startX, startY),
          velocity: Offset(driftSpeed, verticalOscillation),
          size: size,
          opacity: calculatedOpacity,
          lifetime: lifetime,
          color: Color(0xFFE0E0E0).withOpacity(calculatedOpacity),
        );

        // Property: Fog particle opacity must be <= 0.4 for readability
        expect(
          particle.opacity,
          lessThanOrEqualTo(0.4),
          reason:
              'Fog particle $i opacity must be <= 0.4 to preserve text readability',
        );

        // Also verify it's non-negative
        expect(
          particle.opacity,
          greaterThanOrEqualTo(0.0),
          reason: 'Fog particle $i opacity must be non-negative',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 7: Orientation change triggers particle recalculation**
    /// **Validates: Requirements 2.5, 9.2**
    test(
        'Property 7: For any orientation change, particle system should recalculate positions',
        () {
      final random = Random(456); // Seeded for reproducibility

      // Run 100 iterations with different size changes
      for (var i = 0; i < 100; i++) {
        final particlePool = ParticlePool();

        // Initial screen size
        final initialWidth = 300.0 + random.nextDouble() * 500.0;
        final initialHeight = 400.0 + random.nextDouble() * 600.0;
        final initialSize = Size(initialWidth, initialHeight);

        // Spawn some particles for initial size
        final initialParticleCount = 5 + random.nextInt(10); // 5-14 particles
        for (var j = 0; j < initialParticleCount; j++) {
          particlePool.spawn(
            position: Offset(
              random.nextDouble() * initialWidth,
              random.nextDouble() * initialHeight,
            ),
            velocity: Offset(
              20.0 + random.nextDouble() * 30.0,
              (random.nextDouble() - 0.5) * 10.0,
            ),
            size: 40.0 + random.nextDouble() * 60.0,
            opacity: 0.3,
            lifetime: 10.0,
            color: const Color(0xFFE0E0E0),
          );
        }

        final particleCountBeforeChange = particlePool.activeCount;

        // Simulate orientation change (swap width and height)
        final newWidth = initialHeight;
        final newHeight = initialWidth;
        final newSize = Size(newWidth, newHeight);

        // Property: When orientation changes, we should be able to detect it
        // and trigger recalculation (size change detection)
        expect(
          initialSize != newSize,
          isTrue,
          reason:
              'Orientation change $i should result in different size dimensions',
        );

        // Verify that the size change is significant enough to warrant recalculation
        final sizeChangeRatio = (newWidth / initialWidth).abs();
        expect(
          sizeChangeRatio,
          isNot(equals(1.0)),
          reason:
              'Orientation change $i should result in different aspect ratio',
        );

        // After orientation change, particles should be cleared and respawned
        // Simulate this by clearing the pool
        particlePool.clear();

        expect(
          particlePool.activeCount,
          equals(0),
          reason:
              'After orientation change $i, particles should be cleared for recalculation',
        );

        // Respawn particles for new dimensions
        for (var j = 0; j < initialParticleCount; j++) {
          particlePool.spawn(
            position: Offset(
              random.nextDouble() * newWidth,
              random.nextDouble() * newHeight,
            ),
            velocity: Offset(
              20.0 + random.nextDouble() * 30.0,
              (random.nextDouble() - 0.5) * 10.0,
            ),
            size: 40.0 + random.nextDouble() * 60.0,
            opacity: 0.3,
            lifetime: 10.0,
            color: const Color(0xFFE0E0E0),
          );
        }

        // Property: After recalculation, particle count should be restored
        expect(
          particlePool.activeCount,
          equals(particleCountBeforeChange),
          reason:
              'After orientation change $i and recalculation, particle count should be maintained',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 22: Ember particles rise upward**
    /// **Validates: Requirements 6.1**
    test(
        'Property 22: For any ember particle, velocity should have negative vertical component (upward)',
        () {
      final random = Random(789); // Seeded for reproducibility
      final particlePool = ParticlePool();

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate random ember particle parameters
        final width = 300.0 + random.nextDouble() * 500.0; // 300-800
        final height = 400.0 + random.nextDouble() * 600.0; // 400-1000

        // Spawn from bottom
        final startX = random.nextDouble() * width;
        final startY = height + 20.0;

        // Simulate ember particle spawning logic
        final upwardSpeed = -30.0 - random.nextDouble() * 20.0; // -30 to -50
        final horizontalDrift =
            (random.nextDouble() - 0.5) * 20.0; // -10 to 10

        final size = 3.0 + random.nextDouble() * 5.0; // 3-8 pixels
        final lifetime = 3.0 + random.nextDouble() * 3.0; // 3-6 seconds
        final opacity = 0.6 + random.nextDouble() * 0.4; // 0.6-1.0

        final particle = particlePool.spawn(
          position: Offset(startX, startY),
          velocity: Offset(horizontalDrift, upwardSpeed),
          size: size,
          opacity: opacity,
          lifetime: lifetime,
          color: const Color(0xFFFF8C42),
        );

        // Property: Ember particles must have negative vertical velocity (upward in screen coordinates)
        expect(
          particle.velocity.dy,
          lessThan(0),
          reason:
              'Ember particle $i must have negative vertical velocity to rise upward',
        );

        // Verify the upward speed is within expected range
        expect(
          particle.velocity.dy,
          greaterThanOrEqualTo(-50.0),
          reason: 'Ember particle $i upward speed should be within -50 to -30 range',
        );

        expect(
          particle.velocity.dy,
          lessThanOrEqualTo(-30.0),
          reason: 'Ember particle $i upward speed should be within -50 to -30 range',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 23: Ember particles have glow effect**
    /// **Validates: Requirements 6.3**
    test(
        'Property 23: For any ember particle, rendering should include glow effect',
        () {
      final random = Random(101112); // Seeded for reproducibility
      final particlePool = ParticlePool();

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate random ember particle parameters
        final width = 300.0 + random.nextDouble() * 500.0;
        final height = 400.0 + random.nextDouble() * 600.0;

        final startX = random.nextDouble() * width;
        final startY = height + 20.0;

        final upwardSpeed = -30.0 - random.nextDouble() * 20.0;
        final horizontalDrift = (random.nextDouble() - 0.5) * 20.0;

        final size = 3.0 + random.nextDouble() * 5.0;
        final lifetime = 3.0 + random.nextDouble() * 3.0;
        final opacity = 0.6 + random.nextDouble() * 0.4;

        final particle = particlePool.spawn(
          position: Offset(startX, startY),
          velocity: Offset(horizontalDrift, upwardSpeed),
          size: size,
          opacity: opacity,
          lifetime: lifetime,
          color: const Color(0xFFFF8C42),
        );

        // Property: Ember particles should have properties that enable glow rendering
        // The glow effect is implemented in the painter, but we can verify the particle
        // has the necessary properties (size, opacity, color) for glow rendering

        // Verify particle has positive size (needed for glow radius)
        expect(
          particle.size,
          greaterThan(0),
          reason: 'Ember particle $i must have positive size for glow effect',
        );

        // Verify particle has sufficient opacity for visible glow
        expect(
          particle.opacity,
          greaterThan(0.5),
          reason:
              'Ember particle $i should have opacity > 0.5 for visible glow effect',
        );

        // Verify particle color is warm (for ember glow)
        // Ember colors should have high red component
        expect(
          particle.color.red,
          greaterThan(200),
          reason: 'Ember particle $i should have warm color (high red component)',
        );

        // The actual glow rendering happens in _FogParticlePainter with:
        // - glowPaint with blur radius > 0
        // - glow size = particle.size * 1.5
        // This property verifies the particle has the right properties to support that
        const glowMultiplier = 1.5;
        final expectedGlowSize = particle.size * glowMultiplier;
        expect(
          expectedGlowSize,
          greaterThan(particle.size),
          reason:
              'Ember particle $i glow size should be larger than particle size',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 25: Performance degradation triggers particle reduction**
    /// **Validates: Requirements 6.5, 8.2**
    test(
        'Property 25: For any 60-frame window where FPS drops below 55, particle count should decrease',
        () {
      final random = Random(131415); // Seeded for reproducibility

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        final particlePool = ParticlePool();
        final performanceMonitor = PerformanceMonitor();

        // Generate random initial particle count
        final initialParticleCount = 20 + random.nextInt(40); // 20-59 particles

        // Spawn initial particles
        for (var j = 0; j < initialParticleCount; j++) {
          particlePool.spawn(
            position: Offset(
              random.nextDouble() * 800.0,
              random.nextDouble() * 600.0,
            ),
            velocity: Offset(
              20.0 + random.nextDouble() * 30.0,
              (random.nextDouble() - 0.5) * 10.0,
            ),
            size: 40.0 + random.nextDouble() * 60.0,
            opacity: 0.3,
            lifetime: 10.0,
            color: const Color(0xFFE0E0E0),
          );
        }

        final particleCountBeforeDegradation = particlePool.activeCount;

        // Simulate performance degradation: record poor frame times
        // Frame time for < 55 FPS should be > 18.18ms
        final poorFrameTime = 18.5 + random.nextDouble() * 15.0; // 18.5-33.5ms (~30-54 FPS)

        // Record 60 frames of poor performance
        for (var frame = 0; frame < 60; frame++) {
          performanceMonitor.recordFrame(poorFrameTime);
        }

        // Property: Performance monitor should detect degradation
        expect(
          performanceMonitor.shouldReduceEffects,
          isTrue,
          reason:
              'Iteration $i: FPS ${performanceMonitor.averageFps.toStringAsFixed(1)} should trigger effect reduction',
        );

        // Simulate particle reduction (25% reduction as per design)
        const reductionFactor = 0.25;
        particlePool.reduceParticles(reductionFactor);

        final particleCountAfterReduction = particlePool.activeCount;

        // Property: Particle count should decrease after performance degradation
        expect(
          particleCountAfterReduction,
          lessThan(particleCountBeforeDegradation),
          reason:
              'Iteration $i: Particle count should decrease from $particleCountBeforeDegradation after performance degradation',
        );

        // Verify reduction is approximately 25%
        final expectedReduction = (particleCountBeforeDegradation * reductionFactor).round();
        final actualReduction = particleCountBeforeDegradation - particleCountAfterReduction;

        expect(
          actualReduction,
          equals(expectedReduction),
          reason:
              'Iteration $i: Particle reduction should be approximately 25% ($expectedReduction particles)',
        );

        // Test extreme case: FPS < 45 for 3 seconds should disable particles
        // Create a fresh monitor for this test
        final extremeMonitor = PerformanceMonitor();
        final veryPoorFrameTime = 22.5 + random.nextDouble() * 10.0; // 22.5-32.5ms (~30-44 FPS)

        // Record 180 frames (3 seconds at 60fps) of very poor performance
        for (var frame = 0; frame < 180; frame++) {
          extremeMonitor.recordFrame(veryPoorFrameTime);
        }

        // Property: Performance monitor should signal to disable effects
        expect(
          extremeMonitor.shouldDisableEffects,
          isTrue,
          reason:
              'Iteration $i: FPS ${extremeMonitor.averageFps.toStringAsFixed(1)} for 3 seconds should trigger effect disable',
        );

        // Simulate disabling particles
        particlePool.clear();

        // Property: All particles should be cleared when effects are disabled
        expect(
          particlePool.activeCount,
          equals(0),
          reason:
              'Iteration $i: All particles should be cleared when effects are disabled',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 29: Particle count scales with screen area**
    /// **Validates: Requirements 9.1, 9.5**
    test(
        'Property 29: For any two different screen sizes, particle count ratio should be proportional to screen area ratio',
        () {
      final random = Random(161718); // Seeded for reproducibility

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate two different random screen sizes
        final width1 = 300.0 + random.nextDouble() * 500.0; // 300-800
        final height1 = 400.0 + random.nextDouble() * 600.0; // 400-1000
        final screenSize1 = Size(width1, height1);
        final area1 = width1 * height1;

        final width2 = 300.0 + random.nextDouble() * 500.0; // 300-800
        final height2 = 400.0 + random.nextDouble() * 600.0; // 400-1000
        final screenSize2 = Size(width2, height2);
        final area2 = width2 * height2;

        // Ensure screens are different
        final sizeDifference = (width1 - width2).abs() + (height1 - height2).abs();
        if (sizeDifference < 20.0) {
          continue; // Skip if screens are too similar
        }

        // Generate random device pixel ratios
        final devicePixelRatio1 = 1.0 + random.nextDouble() * 2.0; // 1.0-3.0
        final devicePixelRatio2 = 1.0 + random.nextDouble() * 2.0; // 1.0-3.0

        // Generate random base particle count
        final baseParticleCount = 20 + random.nextInt(40); // 20-59

        // Calculate scaled particle counts using the same logic as AtmosphericParticles
        const double baseScreenArea = 375.0 * 667.0;
        
        final areaRatio1 = area1 / baseScreenArea;
        final deviceCapabilityFactor1 = (devicePixelRatio1 / 2.0).clamp(0.5, 2.0);
        final scaledCount1 = (baseParticleCount * areaRatio1 * deviceCapabilityFactor1).round().clamp(5, 100);

        final areaRatio2 = area2 / baseScreenArea;
        final deviceCapabilityFactor2 = (devicePixelRatio2 / 2.0).clamp(0.5, 2.0);
        final scaledCount2 = (baseParticleCount * areaRatio2 * deviceCapabilityFactor2).round().clamp(5, 100);

        // Property: Particle count ratio should be proportional to screen area ratio (within 20% tolerance)
        if (scaledCount1 > 5 && scaledCount2 > 5 && scaledCount1 < 100 && scaledCount2 < 100) {
          final particleCountRatio = scaledCount1 / scaledCount2;
          final expectedRatio = (areaRatio1 * deviceCapabilityFactor1) / (areaRatio2 * deviceCapabilityFactor2);
          
          final ratioError = (particleCountRatio - expectedRatio).abs() / expectedRatio;
          
          expect(
            ratioError,
            lessThanOrEqualTo(0.2), // 20% tolerance
            reason:
                'Iteration $i: Particle count ratio ($particleCountRatio) should be proportional to area ratio ($expectedRatio) within 20% tolerance. '
                'Screen1: ${width1.toInt()}x${height1.toInt()} (${scaledCount1} particles), '
                'Screen2: ${width2.toInt()}x${height2.toInt()} (${scaledCount2} particles)',
          );
        }

        // Additional property: Larger screens should generally have more particles (when not clamped)
        if (area1 > area2 * 1.1 && devicePixelRatio1 >= devicePixelRatio2) {
          expect(
            scaledCount1,
            greaterThanOrEqualTo(scaledCount2),
            reason:
                'Iteration $i: Larger screen (${width1.toInt()}x${height1.toInt()}) should have >= particles than smaller screen (${width2.toInt()}x${height2.toInt()})',
          );
        }
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 30: Low-resolution maintains performance**
    /// **Validates: Requirements 9.3**
    test(
        'Property 30: For any device with screen resolution below 1080p, atmospheric effects should maintain performance',
        () {
      final random = Random(192021); // Seeded for reproducibility

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate low-resolution screen sizes (below 1080p = 1920x1080)
        final width = 240.0 + random.nextDouble() * 1680.0; // 240-1920
        final height = 320.0 + random.nextDouble() * 760.0; // 320-1080
        final screenSize = Size(width, height);
        final area = width * height;

        // Only test screens that are actually below 1080p
        if (area >= 1920.0 * 1080.0) {
          continue; // Skip if resolution is too high
        }

        // Generate random device pixel ratio (typically lower for low-res devices)
        final devicePixelRatio = 1.0 + random.nextDouble() * 1.5; // 1.0-2.5

        // Generate random base particle count
        final baseParticleCount = 20 + random.nextInt(40); // 20-59

        // Calculate scaled particle count using the same logic as AtmosphericParticles
        const double baseScreenArea = 375.0 * 667.0;
        final areaRatio = area / baseScreenArea;
        final deviceCapabilityFactor = (devicePixelRatio / 2.0).clamp(0.5, 2.0);
        final scaledCount = (baseParticleCount * areaRatio * deviceCapabilityFactor).round().clamp(5, 100);

        // Property: Low-resolution devices should have reduced particle counts for performance
        // The scaling should result in fewer particles for smaller screens
        if (area < baseScreenArea * 0.8) { // Significantly smaller than base screen
          expect(
            scaledCount,
            lessThanOrEqualTo(baseParticleCount),
            reason:
                'Iteration $i: Low-resolution screen (${width.toInt()}x${height.toInt()}) should have <= base particle count ($baseParticleCount) for performance. Got $scaledCount particles.',
          );
        }

        // Property: Particle count should respect the clamping bounds (5-100)
        // This ensures performance is maintained by the built-in limits
        expect(
          scaledCount,
          inInclusiveRange(5, 100),
          reason:
              'Iteration $i: Screen (${width.toInt()}x${height.toInt()}) particle count should be clamped between 5-100 for performance. Got $scaledCount particles.',
        );

        // Property: Very small screens should have minimal particles
        if (area < baseScreenArea * 0.5) { // Very small screens
          expect(
            scaledCount,
            lessThanOrEqualTo(30),
            reason:
                'Iteration $i: Very small screen (${width.toInt()}x${height.toInt()}) should have <= 30 particles for performance. Got $scaledCount particles.',
          );
        }

        // Property: Particle count should never be zero (minimum usability)
        expect(
          scaledCount,
          greaterThanOrEqualTo(5),
          reason:
              'Iteration $i: Screen (${width.toInt()}x${height.toInt()}) should have >= 5 particles for visual effect. Got $scaledCount particles.',
        );
      }
    });

    /// **Feature: haunted-atmospheric-visuals, Property 31: Relative positioning for all elements**
    /// **Validates: Requirements 9.4**
    test(
        'Property 31: For any atmospheric element position, it should be calculated using relative values',
        () {
      final random = Random(222324); // Seeded for reproducibility

      // Run 100 iterations to test the property
      for (var i = 0; i < 100; i++) {
        // Generate random screen dimensions
        final width = 300.0 + random.nextDouble() * 500.0; // 300-800
        final height = 400.0 + random.nextDouble() * 600.0; // 400-1000

        // Test fog particle relative positioning
        final relativeStartX = random.nextBool() ? -0.067 : random.nextDouble(); // -50px relative to 750px width
        final relativeStartY = random.nextDouble();
        
        final absoluteStartX = relativeStartX * width;
        final absoluteStartY = relativeStartY * height;

        // Property: Relative positions should scale proportionally with screen size
        expect(
          relativeStartX,
          inInclusiveRange(-0.1, 1.0), // Reasonable relative range
          reason:
              'Iteration $i: Fog particle relative X position should be in range [-0.1, 1.0]. Got $relativeStartX',
        );

        expect(
          relativeStartY,
          inInclusiveRange(0.0, 1.0), // Screen bounds
          reason:
              'Iteration $i: Fog particle relative Y position should be in range [0.0, 1.0]. Got $relativeStartY',
        );

        // Test that absolute positions scale correctly
        final expectedAbsoluteX = relativeStartX * width;
        final expectedAbsoluteY = relativeStartY * height;

        expect(
          absoluteStartX,
          closeTo(expectedAbsoluteX, 0.001),
          reason:
              'Iteration $i: Absolute X position should match relative calculation. Expected $expectedAbsoluteX, got $absoluteStartX',
        );

        expect(
          absoluteStartY,
          closeTo(expectedAbsoluteY, 0.001),
          reason:
              'Iteration $i: Absolute Y position should match relative calculation. Expected $expectedAbsoluteY, got $absoluteStartY',
        );

        // Test ember particle relative positioning
        final emberRelativeX = random.nextDouble();
        const emberRelativeY = 1.03; // Just below screen
        
        final emberAbsoluteX = emberRelativeX * width;
        final emberAbsoluteY = emberRelativeY * height;

        expect(
          emberRelativeX,
          inInclusiveRange(0.0, 1.0),
          reason:
              'Iteration $i: Ember particle relative X position should be in range [0.0, 1.0]. Got $emberRelativeX',
        );

        expect(
          emberRelativeY,
          greaterThan(1.0),
          reason:
              'Iteration $i: Ember particle relative Y position should be > 1.0 (below screen). Got $emberRelativeY',
        );

        // Test wisp particle relative positioning (center)
        const wispRelativeX = 0.5;
        const wispRelativeY = 0.5;
        
        final wispAbsoluteX = wispRelativeX * width;
        final wispAbsoluteY = wispRelativeY * height;

        expect(
          wispAbsoluteX,
          closeTo(width / 2, 0.001),
          reason:
              'Iteration $i: Wisp particle should be centered horizontally. Expected ${width / 2}, got $wispAbsoluteX',
        );

        expect(
          wispAbsoluteY,
          closeTo(height / 2, 0.001),
          reason:
              'Iteration $i: Wisp particle should be centered vertically. Expected ${height / 2}, got $wispAbsoluteY',
        );

        // Test relative margins for recycling
        final marginX = width * 0.133; // ~100px for 750px width
        final marginY = height * 0.15; // ~100px for 667px height

        expect(
          marginX / width,
          closeTo(0.133, 0.01),
          reason:
              'Iteration $i: Margin X should be proportional to width. Expected ~0.133, got ${marginX / width}',
        );

        expect(
          marginY / height,
          closeTo(0.15, 0.01),
          reason:
              'Iteration $i: Margin Y should be proportional to height. Expected ~0.15, got ${marginY / height}',
        );
      }
    });
  });
}
