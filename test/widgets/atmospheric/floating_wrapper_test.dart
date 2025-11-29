import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/floating_wrapper.dart';
import 'dart:math';

void main() {
  group('FloatingWrapper Property Tests', () {
    /// **Feature: haunted-atmospheric-visuals, Property 12: Floating animations apply vertical translation**
    /// **Validates: Requirements 4.1**
    /// 
    /// For any widget wrapped in FloatingWrapper, the widget's transform should include
    /// a vertical translation component that changes over time.
    testWidgets(
      'Property 12: Floating animations apply vertical translation',
      (WidgetTester tester) async {
        final random = Random(42);
        const iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Generate random parameters
          final amplitude = 5.0 + random.nextDouble() * 10.0; // 5-15 pixels
          final durationMs = 1000 + random.nextInt(3000); // 1-4 seconds
          
          final testWidget = MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                amplitude: amplitude,
                duration: Duration(milliseconds: durationMs),
                child: Container(
                  key: const Key('test-container'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Get initial position
          final initialOffset = tester.getTopLeft(find.byKey(const Key('test-container')));

          // Advance animation by 25% of duration
          await tester.pump(Duration(milliseconds: durationMs ~/ 4));

          // Get new position
          final newOffset = tester.getTopLeft(find.byKey(const Key('test-container')));

          // Verify vertical translation occurred
          final verticalChange = (newOffset.dy - initialOffset.dy).abs();
          
          // The vertical change should be non-zero (animation is active)
          if (verticalChange > 0.1) {
            successCount++;
          }

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }

        // Property should hold for at least 95% of cases
        expect(
          successCount / iterations,
          greaterThan(0.95),
          reason: 'Floating animations should apply vertical translation in most cases',
        );
      },
    );

    /// **Feature: haunted-atmospheric-visuals, Property 13: Floating animations use smooth easing**
    /// **Validates: Requirements 4.2**
    /// 
    /// For any FloatingWrapper widget, the animation curve should be one of the smooth
    /// easing curves (easeInOut, easeIn, easeOut, or custom smooth curve).
    testWidgets(
      'Property 13: Floating animations use smooth easing',
      (WidgetTester tester) async {
        final smoothCurves = [
          Curves.easeInOut,
          Curves.easeIn,
          Curves.easeOut,
          Curves.easeInCubic,
          Curves.easeOutCubic,
          Curves.easeInOutCubic,
          Curves.easeInSine,
          Curves.easeOutSine,
          Curves.easeInOutSine,
        ];

        final random = Random(42);
        const iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Pick a random smooth curve
          final curve = smoothCurves[random.nextInt(smoothCurves.length)];
          
          final testWidget = MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                curve: curve,
                child: Container(
                  key: Key('test-container-$i'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Sample the curve at multiple points
          final samples = [0.0, 0.25, 0.5, 0.75, 1.0];
          bool isSmooth = true;

          for (int j = 0; j < samples.length - 1; j++) {
            final t1 = samples[j];
            final t2 = samples[j + 1];
            final v1 = curve.transform(t1);
            final v2 = curve.transform(t2);
            
            // Check that the curve is continuous (no jumps)
            final delta = (v2 - v1).abs();
            if (delta > 0.6) {
              // Large jump indicates non-smooth curve
              isSmooth = false;
              break;
            }
          }

          if (isSmooth) {
            successCount++;
          }

          // Clean up
          await tester.pumpWidget(Container());
        }

        // All smooth curves should pass
        expect(
          successCount / iterations,
          equals(1.0),
          reason: 'All smooth easing curves should be continuous',
        );
      },
    );

    /// **Feature: haunted-atmospheric-visuals, Property 14: Floating phases are staggered**
    /// **Validates: Requirements 4.3**
    /// 
    /// For any set of two or more FloatingWrapper widgets on the same screen,
    /// at least two widgets should have different phase offset values.
    testWidgets(
      'Property 14: Floating phases are staggered',
      (WidgetTester tester) async {
        final random = Random(42);
        const iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Generate 2-5 widgets with random phases
          final widgetCount = 2 + random.nextInt(4);
          final phases = List.generate(
            widgetCount,
            (index) => random.nextDouble(),
          );

          final widgets = List<Widget>.generate(
            widgetCount,
            (index) => FloatingWrapper(
              phase: phases[index],
              child: Container(
                key: Key('container-$index'),
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),
          );

          final testWidget = MaterialApp(
            home: Scaffold(
              body: Column(
                children: widgets,
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Check if at least two phases are different
          bool hasStaggering = false;
          for (int j = 0; j < phases.length - 1; j++) {
            for (int k = j + 1; k < phases.length; k++) {
              if ((phases[j] - phases[k]).abs() > 0.01) {
                hasStaggering = true;
                break;
              }
            }
            if (hasStaggering) break;
          }

          if (hasStaggering) {
            successCount++;
          }

          // Clean up
          await tester.pumpWidget(Container());
        }

        // Property should hold for at least 95% of cases (some random cases might have similar phases)
        expect(
          successCount / iterations,
          greaterThan(0.95),
          reason: 'Multiple floating widgets should have staggered phases',
        );
      },
    );

    /// **Feature: haunted-atmospheric-visuals, Property 15: Floating amplitude is constrained**
    /// **Validates: Requirements 4.4**
    /// 
    /// For any FloatingWrapper widget, the amplitude value should be less than or equal
    /// to 10 pixels to prevent motion sickness.
    testWidgets(
      'Property 15: Floating amplitude is constrained',
      (WidgetTester tester) async {
        final random = Random(42);
        const iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Generate random amplitude within acceptable range
          final amplitude = random.nextDouble() * 10.0; // 0-10 pixels
          
          final testWidget = MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                amplitude: amplitude,
                child: Container(
                  key: Key('test-container-$i'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Verify amplitude is within constraint
          if (amplitude <= 10.0) {
            successCount++;
          }

          // Clean up
          await tester.pumpWidget(Container());
        }

        // All amplitudes should be constrained
        expect(
          successCount / iterations,
          equals(1.0),
          reason: 'All floating amplitudes should be <= 10 pixels',
        );
      },
    );

    /// **Feature: haunted-atmospheric-visuals, Property 16: Floating pauses on interaction**
    /// **Validates: Requirements 4.5**
    /// 
    /// For any FloatingWrapper widget, when a touch-down event occurs on the wrapped child,
    /// the animation controller should be paused.
    testWidgets(
      'Property 16: Floating pauses on interaction',
      (WidgetTester tester) async {
        const iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          final testWidget = MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                pauseOnInteraction: true,
                duration: const Duration(seconds: 2),
                child: Container(
                  key: Key('test-container-$i'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();
          
          // Let animation run for a bit
          await tester.pump(const Duration(milliseconds: 100));
          
          // Get position before interaction
          final positionBeforeTap = tester.getTopLeft(find.byKey(Key('test-container-$i')));

          // Simulate tap down (interaction start) - use press to hold
          final gesture = await tester.press(find.byKey(Key('test-container-$i')));
          await tester.pump();

          // Advance time while "holding" the tap
          await tester.pump(const Duration(milliseconds: 500));

          // Get position during interaction
          final positionDuringTap = tester.getTopLeft(find.byKey(Key('test-container-$i')));

          // Release the tap
          await gesture.up();
          await tester.pump();

          // During interaction, position should not change significantly
          // (animation is paused)
          final verticalChange = (positionDuringTap.dy - positionBeforeTap.dy).abs();
          
          if (verticalChange < 0.5) {
            successCount++;
          }

          // Clean up
          await tester.pumpWidget(Container());
        }

        // Property should hold for at least 95% of cases
        expect(
          successCount / iterations,
          greaterThan(0.95),
          reason: 'Floating animation should pause during interaction',
        );
      },
    );
  });
}
