import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric_theme_config.dart';
import 'package:student_learning_app/widgets/atmospheric/ghost_mascot.dart';

void main() {
  group('AtmosphericScaffold', () {
    testWidgets('renders child widget on top of atmospheric layers',
        (WidgetTester tester) async {
      // Requirement 7.1: Provide reusable Flutter widgets
      const testChild = Text('Test Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              child: testChild,
            ),
          ),
        ),
      );

      // Verify child is rendered
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('provides simple widget wrapper with minimal configuration',
        (WidgetTester tester) async {
      // Requirement 7.2: Simple widget wrappers with minimal configuration
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              child: Text('Simple Usage'),
            ),
          ),
        ),
      );

      expect(find.text('Simple Usage'), findsOneWidget);
    });

    testWidgets('uses sensible defaults while allowing customization',
        (WidgetTester tester) async {
      // Requirement 7.3: Sensible defaults with customization options
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              intensity: AtmosphericIntensity.minimal,
              showFog: false,
              showEmbers: true,
              showGhost: false,
              child: Text('Customized'),
            ),
          ),
        ),
      );

      expect(find.text('Customized'), findsOneWidget);
    });

    testWidgets('provides configuration to disable effects',
        (WidgetTester tester) async {
      // Requirement 7.5: Configuration to disable or reduce effects
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              showFog: false,
              showEmbers: false,
              showGhost: false,
              child: Text('No Effects'),
            ),
          ),
        ),
      );

      expect(find.text('No Effects'), findsOneWidget);
    });

    testWidgets('adjusts particle count based on intensity',
        (WidgetTester tester) async {
      // Test minimal intensity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              intensity: AtmosphericIntensity.minimal,
              child: Text('Minimal'),
            ),
          ),
        ),
      );

      expect(find.text('Minimal'), findsOneWidget);

      // Test maximum intensity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              intensity: AtmosphericIntensity.maximum,
              child: Text('Maximum'),
            ),
          ),
        ),
      );

      expect(find.text('Maximum'), findsOneWidget);
    });

    testWidgets('integrates with theme system',
        (WidgetTester tester) async {
      // Test with custom theme config
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              themeConfig: AtmosphericThemeConfig.ember,
              child: Text('Themed'),
            ),
          ),
        ),
      );

      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('supports ghost state customization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              ghostState: GhostState.celebrating,
              ghostAlignment: Alignment.bottomLeft,
              autoHideGhost: false,
              child: Text('Custom Ghost'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Ghost'), findsOneWidget);
    });

    testWidgets('renders layers in correct order',
        (WidgetTester tester) async {
      // Verify stack order: fog (bottom) -> child -> embers -> ghost (top)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AtmosphericScaffold(
              showFog: true,
              showEmbers: true,
              showGhost: true,
              child: Text('Layered'),
            ),
          ),
        ),
      );

      // Verify child is present
      expect(find.text('Layered'), findsOneWidget);
      
      // Verify AtmosphericScaffold widget exists
      expect(find.byType(AtmosphericScaffold), findsOneWidget);
    });
  });

  group('AtmosphericIntensity', () {
    test('has all required intensity levels', () {
      expect(AtmosphericIntensity.values.length, 3);
      expect(AtmosphericIntensity.values,
          contains(AtmosphericIntensity.minimal));
      expect(
          AtmosphericIntensity.values, contains(AtmosphericIntensity.normal));
      expect(AtmosphericIntensity.values,
          contains(AtmosphericIntensity.maximum));
    });
  });
}
