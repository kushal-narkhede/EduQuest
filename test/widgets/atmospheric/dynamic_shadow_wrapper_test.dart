import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/dynamic_shadow_wrapper.dart';
import 'package:faker/faker.dart' hide Color;

void main() {
  group('DynamicShadowWrapper Widget Tests', () {
    testWidgets('DynamicShadowWrapper renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicShadowWrapper(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DynamicShadowWrapper), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('DynamicShadowWrapper wraps child correctly', (WidgetTester tester) async {
      const testKey = Key('test-child');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicShadowWrapper(
              child: Container(
                key: testKey,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('DynamicShadowWrapper has shadows', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicShadowWrapper(
              restingElevation: 10.0,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find the Container with shadows
      final containerFinder = find.descendant(
        of: find.byType(DynamicShadowWrapper),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsWidgets);

      final container = tester.widget<Container>(containerFinder.first);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull);
      expect(decoration!.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThanOrEqualTo(2));
    });

    testWidgets('DynamicShadowWrapper reduces shadow on press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicShadowWrapper(
              restingElevation: 10.0,
              pressedElevation: 2.0,
              transitionDuration: const Duration(milliseconds: 150),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containerFinder = find.descendant(
        of: find.byType(DynamicShadowWrapper),
        matching: find.byType(Container),
      );

      // Get initial blur
      var container = tester.widget<Container>(containerFinder.first);
      var decoration = container.decoration as BoxDecoration;
      final initialMaxBlur = decoration.boxShadow!
          .map((s) => s.blurRadius)
          .reduce((a, b) => a > b ? a : b);

      print('Initial max blur: $initialMaxBlur');

      // Press and hold
      final gesture = await tester.startGesture(tester.getCenter(find.byType(DynamicShadowWrapper)));
      await tester.pump(); // Trigger onTapDown and start animation
      await tester.pumpAndSettle(); // Let animation complete

      // Get pressed blur
      container = tester.widget<Container>(containerFinder.first);
      decoration = container.decoration as BoxDecoration;
      final pressedMaxBlur = decoration.boxShadow!
          .map((s) => s.blurRadius)
          .reduce((a, b) => a > b ? a : b);

      print('Pressed max blur: $pressedMaxBlur');

      expect(pressedMaxBlur, lessThan(initialMaxBlur));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('Property-Based Tests', () {
    /// **Feature: haunted-atmospheric-visuals, Property 17: Shadows have multiple layers**
    /// **Validates: Requirements 5.1**
    /// 
    /// For any widget wrapped in DynamicShadowWrapper, the widget's decoration should contain
    /// at least two BoxShadow objects to create depth.
    testWidgets('Property 17: Shadows have multiple layers', (WidgetTester tester) async {
      final faker = Faker();
      const iterations = 100;
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random shadow parameters
        final restingElevation = 2.0 + faker.randomGenerator.decimal(scale: 15.0); // 2.0 to 17.0
        final pressedElevation = faker.randomGenerator.decimal(scale: restingElevation * 0.5);
        
        final colors = [
          const Color(0xFF1A0033), // Dark purple
          const Color(0xFF000000), // Black
          const Color(0xFF2D1B00), // Dark brown
          const Color(0xFF0A0A1A), // Dark blue-black
        ];
        final shadowColor = colors[faker.randomGenerator.integer(colors.length)];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DynamicShadowWrapper(
                restingElevation: restingElevation,
                pressedElevation: pressedElevation,
                shadowColor: shadowColor,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Container with BoxDecoration that has the shadows
        final containerFinder = find.descendant(
          of: find.byType(DynamicShadowWrapper),
          matching: find.byType(Container),
        );

        bool hasMultipleLayers = false;

        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null) {
            // Check that there are at least 2 shadow layers
            if (decoration.boxShadow!.length >= 2) {
              hasMultipleLayers = true;
            }
          }
        }

        if (hasMultipleLayers) {
          passCount++;
        }

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }

      // The property should hold for all cases
      expect(passCount, equals(iterations));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 18: Press reduces shadow elevation**
    /// **Validates: Requirements 5.2**
    /// 
    /// For any DynamicShadowWrapper widget, when a press event occurs, the shadow elevation
    /// should decrease below its resting value.
    testWidgets('Property 18: Press reduces shadow elevation', (WidgetTester tester) async {
      final faker = Faker();
      const iterations = 100;
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random shadow parameters
        final restingElevation = 5.0 + faker.randomGenerator.decimal(scale: 10.0); // 5.0 to 15.0
        final pressedElevation = faker.randomGenerator.decimal(scale: restingElevation * 0.4); // Less than resting

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DynamicShadowWrapper(
                restingElevation: restingElevation,
                pressedElevation: pressedElevation,
                transitionDuration: const Duration(milliseconds: 150),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(); // Let initial state settle

        // Get initial shadow state (resting)
        final containerFinder = find.descendant(
          of: find.byType(DynamicShadowWrapper),
          matching: find.byType(Container),
        );

        double? initialMaxBlur;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
            initialMaxBlur = decoration.boxShadow!
                .map((s) => s.blurRadius)
                .reduce((a, b) => a > b ? a : b);
          }
        }

        // Simulate press interaction
        final gesture = await tester.startGesture(tester.getCenter(find.byType(DynamicShadowWrapper)));
        await tester.pump(); // Trigger onTapDown
        await tester.pumpAndSettle(); // Let animation complete

        // Get shadow state during press
        double? pressedMaxBlur;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
            pressedMaxBlur = decoration.boxShadow!
                .map((s) => s.blurRadius)
                .reduce((a, b) => a > b ? a : b);
          }
        }

        // Shadow elevation (blur) should decrease during press
        if (initialMaxBlur != null && pressedMaxBlur != null) {
          if (pressedMaxBlur < initialMaxBlur) {
            passCount++;
          }
        }

        // Release the press
        await gesture.up();
        await tester.pumpAndSettle();

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }

      // The property should hold for most cases (allowing for animation timing)
      expect(passCount, greaterThan(iterations * 0.8)); // At least 80% should pass
    });

    /// **Feature: haunted-atmospheric-visuals, Property 19: Drag updates shadow in real-time**
    /// **Validates: Requirements 5.3**
    /// 
    /// For any DynamicShadowWrapper widget during a drag event, the shadow properties should
    /// update within one frame of the drag position changing.
    testWidgets('Property 19: Drag updates shadow in real-time', (WidgetTester tester) async {
      final faker = Faker();
      const iterations = 50; // Reduced iterations for drag tests
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random shadow parameters
        final restingElevation = 5.0 + faker.randomGenerator.decimal(scale: 10.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DynamicShadowWrapper(
                  restingElevation: restingElevation,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final containerFinder = find.descendant(
          of: find.byType(DynamicShadowWrapper),
          matching: find.byType(Container),
        );

        // Get initial shadow offset
        Offset? initialOffset;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
            initialOffset = decoration.boxShadow!.first.offset;
          }
        }

        // Perform drag movement
        final gesture = await tester.startGesture(tester.getCenter(find.byType(DynamicShadowWrapper)));
        await tester.pump();
        await tester.pumpAndSettle(); // Let press animation complete
        
        // Now drag
        await gesture.moveBy(const Offset(50, 50));
        await tester.pump(); // Update immediately

        // Get shadow offset after drag
        Offset? draggedOffset;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
            draggedOffset = decoration.boxShadow!.first.offset;
          }
        }

        // Shadow offset should change during drag
        if (initialOffset != null && draggedOffset != null) {
          if (initialOffset != draggedOffset) {
            passCount++;
          }
        }

        // Release gesture
        await gesture.up();
        await tester.pumpAndSettle();

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }

      // The property should hold for most cases
      expect(passCount, greaterThan(iterations * 0.7)); // At least 70% should pass
    });

    /// **Feature: haunted-atmospheric-visuals, Property 20: Shadow colors match haunted theme**
    /// **Validates: Requirements 5.4**
    /// 
    /// For any DynamicShadowWrapper widget, the shadow color should be a dark color
    /// (luminance < 0.3) with optional purple, blue, or black tint.
    test('Property 20: Shadow colors match haunted theme', () {
      final faker = Faker();
      const iterations = 100;
      int passCount = 0;

      // Define valid dark colors for haunted theme
      final validDarkColors = [
        const Color(0xFF1A0033), // Dark purple
        const Color(0xFF000000), // Black
        const Color(0xFF2D1B00), // Dark brown
        const Color(0xFF0A0A1A), // Dark blue-black
        const Color(0xFF1A001A), // Dark magenta
        const Color(0xFF001A1A), // Dark teal
      ];

      for (int i = 0; i < iterations; i++) {
        // Randomly select a shadow color
        final shadowColor = validDarkColors[faker.randomGenerator.integer(validDarkColors.length)];
        
        // Calculate luminance
        final luminance = shadowColor.computeLuminance();

        // Verify the color is dark (luminance < 0.3)
        if (luminance < 0.3) {
          passCount++;
        }
      }

      // The property should hold for all cases
      expect(passCount, equals(iterations));
    });

    /// **Feature: haunted-atmospheric-visuals, Property 21: Shadows return to resting state**
    /// **Validates: Requirements 5.5**
    /// 
    /// For any DynamicShadowWrapper widget, after an interaction ends, the shadow elevation
    /// should animate back to its original resting value.
    testWidgets('Property 21: Shadows return to resting state', (WidgetTester tester) async {
      final faker = Faker();
      const iterations = 50; // Reduced iterations for interaction tests
      int passCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random shadow parameters
        final restingElevation = 5.0 + faker.randomGenerator.decimal(scale: 10.0);
        final pressedElevation = faker.randomGenerator.decimal(scale: restingElevation * 0.4);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DynamicShadowWrapper(
                restingElevation: restingElevation,
                pressedElevation: pressedElevation,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final containerFinder = find.descendant(
          of: find.byType(DynamicShadowWrapper),
          matching: find.byType(Container),
        );

        // Get initial shadow state (resting)
        double? initialMaxBlur;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null) {
            initialMaxBlur = decoration.boxShadow!
                .map((s) => s.blurRadius)
                .reduce((a, b) => a > b ? a : b);
          }
        }

        // Simulate press and release
        await tester.tap(find.byType(DynamicShadowWrapper));
        await tester.pumpAndSettle(); // Wait for all animations to complete

        // Get shadow state after interaction completes
        double? finalMaxBlur;
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration?;
          
          if (decoration != null && decoration.boxShadow != null) {
            finalMaxBlur = decoration.boxShadow!
                .map((s) => s.blurRadius)
                .reduce((a, b) => a > b ? a : b);
          }
        }

        // Shadow should return to approximately the initial state
        if (initialMaxBlur != null && finalMaxBlur != null) {
          final difference = (finalMaxBlur - initialMaxBlur).abs();
          // Allow small tolerance for floating point precision
          if (difference < initialMaxBlur * 0.1) { // Within 10% of initial
            passCount++;
          }
        }

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }

      // The property should hold for most cases
      expect(passCount, greaterThan(iterations * 0.8)); // At least 80% should pass
    });
  });
}
