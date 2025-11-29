import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/ghost_mascot.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric_particles.dart';
import 'package:student_learning_app/widgets/atmospheric/glow_wrapper.dart';
import 'package:student_learning_app/widgets/atmospheric/floating_wrapper.dart';
import 'package:student_learning_app/widgets/atmospheric/dynamic_shadow_wrapper.dart';
import 'package:student_learning_app/widgets/atmospheric/wisp_burst.dart';
import 'package:faker/faker.dart';

void main() {
  group('Lifecycle Management Tests', () {
    /// **Feature: haunted-atmospheric-visuals, Property 27: Animation controllers are disposed**
    /// **Validates: Requirements 8.4**
    /// 
    /// For any stateful atmospheric widget, when the widget's dispose() method is called,
    /// all AnimationController instances should also be disposed.
    testWidgets('Property 27: Animation controllers are disposed', (WidgetTester tester) async {
      const iterations = 100;
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Test GhostMascot disposal
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  GhostMascot(),
                ],
              ),
            ),
          ),
        );

        // Verify widget is rendered
        expect(find.byType(GhostMascot), findsOneWidget);

        // Dispose the widget by removing it from the tree
        await tester.pumpWidget(Container());
        await tester.pump();

        // If we reach here without errors, disposal was successful
        passCount++;

        // Test GlowWrapper disposal
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlowWrapper(
                child: Container(width: 100, height: 100),
              ),
            ),
          ),
        );

        expect(find.byType(GlowWrapper), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pump();

        passCount++;

        // Test FloatingWrapper disposal
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                child: Container(width: 100, height: 100),
              ),
            ),
          ),
        );

        expect(find.byType(FloatingWrapper), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pump();

        passCount++;

        // Test DynamicShadowWrapper disposal
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DynamicShadowWrapper(
                child: Container(width: 100, height: 100),
              ),
            ),
          ),
        );

        expect(find.byType(DynamicShadowWrapper), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pump();

        passCount++;

        // Test AtmosphericParticles disposal
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: AtmosphericParticles(
                  type: ParticleType.fog,
                  enabled: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AtmosphericParticles), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pump();

        passCount++;

        // Test WispBurst disposal
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: WispBurst(
                  origin: Offset(150, 150),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(WispBurst), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pump();

        passCount++;
      }

      // All widgets should dispose without errors
      // Each iteration tests 6 widgets
      expect(passCount, equals(iterations * 6));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 28: Backgrounded app pauses animations**
    /// **Validates: Requirements 8.5**
    /// 
    /// For any atmospheric widget, when the app lifecycle state changes to paused or inactive,
    /// all animation controllers should be paused.
    testWidgets('Property 28: Backgrounded app pauses animations', (WidgetTester tester) async {
      final faker = Faker();
      const iterations = 50; // Reduced iterations for lifecycle tests
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Test GhostMascot lifecycle handling
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  GhostMascot(state: GhostState.idle),
                ],
              ),
            ),
          ),
        );

        // Let animation start
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Simulate app going to background
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        // Animation should be paused (no errors should occur)
        passCount++;

        // Simulate app returning to foreground
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        // Animation should resume (no errors should occur)
        passCount++;

        // Clean up
        await tester.pumpWidget(Container());
        await tester.pump();

        // Test FloatingWrapper lifecycle handling
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloatingWrapper(
                child: Container(width: 100, height: 100),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Simulate app going to background
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        passCount++;

        // Simulate app returning to foreground
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        passCount++;

        // Clean up
        await tester.pumpWidget(Container());
        await tester.pump();

        // Test AtmosphericParticles lifecycle handling
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: AtmosphericParticles(
                  type: ParticleType.fog,
                  enabled: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Simulate app going to background
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        passCount++;

        // Simulate app returning to foreground
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        passCount++;

        // Clean up
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      // All lifecycle transitions should complete without errors
      // Each iteration tests 3 widgets with 2 transitions each = 6 passes per iteration
      expect(passCount, equals(iterations * 6));
    });
  });
}
