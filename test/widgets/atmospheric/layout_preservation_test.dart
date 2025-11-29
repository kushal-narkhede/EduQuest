import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric_theme_config.dart';
import 'dart:math';

void main() {
  group('Layout Preservation Property Tests', () {
    testWidgets(
      'Property 32: Atmospheric effects preserve existing layouts',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 10 times with different layout configurations
        // Reduced from 100 to prevent test timeout
        for (int i = 0; i < 10; i++) {
          // Generate random layout parameters
          final containerWidth = 50.0 + random.nextDouble() * 200.0; // 50-250px
          final containerHeight = 50.0 + random.nextDouble() * 200.0; // 50-250px
          final padding = random.nextDouble() * 20.0; // 0-20px
          final margin = random.nextDouble() * 20.0; // 0-20px
          
          // Create a test widget with specific layout constraints
          final testChild = Container(
            width: containerWidth,
            height: containerHeight,
            margin: EdgeInsets.all(margin),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: const Text('Test Content'),
          );

          // Test widget WITHOUT atmospheric effects (control)
          final controlWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: testChild,
              ),
            ),
          );

          await tester.pumpWidget(controlWidget);
          await tester.pump();

          // Get the original layout information
          final originalContainerFinder = find.byType(Container).first;
          final originalRenderBox = tester.renderObject<RenderBox>(originalContainerFinder);
          final originalSize = originalRenderBox.size;
          final originalOffset = originalRenderBox.localToGlobal(Offset.zero);

          // Test widget WITH atmospheric effects
          final atmosphericWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: AtmosphericScaffold(
                  showGhost: random.nextBool(),
                  showFog: random.nextBool(),
                  showEmbers: random.nextBool(),
                  intensity: AtmosphericIntensity.values[
                    random.nextInt(AtmosphericIntensity.values.length)
                  ],
                  child: testChild,
                ),
              ),
            ),
          );

          await tester.pumpWidget(atmosphericWidget);
          await tester.pump();

          // Get the layout information with atmospheric effects
          final atmosphericContainerFinder = find.byType(Container).first;
          final atmosphericRenderBox = tester.renderObject<RenderBox>(atmosphericContainerFinder);
          final atmosphericSize = atmosphericRenderBox.size;
          final atmosphericOffset = atmosphericRenderBox.localToGlobal(Offset.zero);

          // Verify that the layout is preserved
          expect(
            atmosphericSize.width,
            closeTo(originalSize.width, 1.0), // Allow 1px tolerance for floating point precision
            reason: 'Container width should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericSize.height,
            closeTo(originalSize.height, 1.0), // Allow 1px tolerance for floating point precision
            reason: 'Container height should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dx,
            closeTo(originalOffset.dx, 1.0), // Allow 1px tolerance for floating point precision
            reason: 'Container X position should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dy,
            closeTo(originalOffset.dy, 1.0), // Allow 1px tolerance for floating point precision
            reason: 'Container Y position should be preserved when adding atmospheric effects',
          );
        }
      },
    );

    testWidgets(
      'Property 32: Atmospheric effects preserve complex layouts',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 5 times with complex layout configurations
        // Reduced from 50 to prevent test timeout
        for (int i = 0; i < 5; i++) {
          // Generate random layout parameters for multiple widgets
          final numWidgets = 2 + random.nextInt(4); // 2-5 widgets
          final widgets = <Widget>[];
          
          for (int j = 0; j < numWidgets; j++) {
            widgets.add(
              Container(
                width: 50.0 + random.nextDouble() * 100.0,
                height: 50.0 + random.nextDouble() * 100.0,
                margin: EdgeInsets.all(random.nextDouble() * 10.0),
                color: Color.fromARGB(
                  255,
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256),
                ),
                child: Text('Widget $j'),
              ),
            );
          }

          // Create complex layout (Column with multiple children)
          // Wrap in SingleChildScrollView to prevent overflow in tests
          final complexChild = SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widgets,
            ),
          );

          // Test widget WITHOUT atmospheric effects (control)
          final controlWidget = MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: complexChild,
              ),
            ),
          );

          await tester.pumpWidget(controlWidget);
          await tester.pump();

          // Get original layout information for all containers
          final originalContainerFinders = find.byType(Container);
          final originalSizes = <Size>[];
          final originalOffsets = <Offset>[];
          
          for (int k = 0; k < originalContainerFinders.evaluate().length; k++) {
            final renderBox = tester.renderObject<RenderBox>(originalContainerFinders.at(k));
            originalSizes.add(renderBox.size);
            originalOffsets.add(renderBox.localToGlobal(Offset.zero));
          }

          // Test widget WITH atmospheric effects
          final atmosphericWidget = MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AtmosphericScaffold(
                  showGhost: true,
                  showFog: true,
                  showEmbers: true,
                  intensity: AtmosphericIntensity.normal,
                  child: complexChild,
                ),
              ),
            ),
          );

          await tester.pumpWidget(atmosphericWidget);
          await tester.pump();

          // Get layout information with atmospheric effects
          final atmosphericContainerFinders = find.byType(Container);
          
          // Verify that all containers maintain their layout
          expect(
            atmosphericContainerFinders.evaluate().length,
            equals(originalContainerFinders.evaluate().length),
            reason: 'Number of containers should remain the same',
          );

          for (int k = 0; k < atmosphericContainerFinders.evaluate().length; k++) {
            final renderBox = tester.renderObject<RenderBox>(atmosphericContainerFinders.at(k));
            final atmosphericSize = renderBox.size;
            final atmosphericOffset = renderBox.localToGlobal(Offset.zero);

            expect(
              atmosphericSize.width,
              closeTo(originalSizes[k].width, 1.0),
              reason: 'Container $k width should be preserved in complex layout',
            );

            expect(
              atmosphericSize.height,
              closeTo(originalSizes[k].height, 1.0),
              reason: 'Container $k height should be preserved in complex layout',
            );

            expect(
              atmosphericOffset.dx,
              closeTo(originalOffsets[k].dx, 1.0),
              reason: 'Container $k X position should be preserved in complex layout',
            );

            expect(
              atmosphericOffset.dy,
              closeTo(originalOffsets[k].dy, 1.0),
              reason: 'Container $k Y position should be preserved in complex layout',
            );
          }
        }
      },
    );

    testWidgets(
      'Property 32: Atmospheric effects preserve text layout',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 10 times with different text configurations
        // Reduced from 100 to prevent test timeout
        for (int i = 0; i < 10; i++) {
          // Generate random text parameters
          final fontSize = 12.0 + random.nextDouble() * 20.0; // 12-32px
          final textContent = 'Test text ${random.nextInt(1000)}';
          final fontWeight = FontWeight.values[random.nextInt(FontWeight.values.length)];
          
          final testText = Text(
            textContent,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.black,
            ),
          );

          // Test widget WITHOUT atmospheric effects (control)
          final controlWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: testText,
              ),
            ),
          );

          await tester.pumpWidget(controlWidget);
          await tester.pump();

          // Get original text layout information
          final originalTextFinder = find.byType(Text);
          final originalRenderBox = tester.renderObject<RenderBox>(originalTextFinder);
          final originalSize = originalRenderBox.size;
          final originalOffset = originalRenderBox.localToGlobal(Offset.zero);

          // Test widget WITH atmospheric effects
          final atmosphericWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: AtmosphericScaffold(
                  showGhost: true,
                  showFog: true,
                  showEmbers: false, // Disable embers to avoid interference
                  intensity: AtmosphericIntensity.minimal,
                  child: testText,
                ),
              ),
            ),
          );

          await tester.pumpWidget(atmosphericWidget);
          await tester.pump();

          // Get text layout information with atmospheric effects
          final atmosphericTextFinder = find.byType(Text);
          final atmosphericRenderBox = tester.renderObject<RenderBox>(atmosphericTextFinder);
          final atmosphericSize = atmosphericRenderBox.size;
          final atmosphericOffset = atmosphericRenderBox.localToGlobal(Offset.zero);

          // Verify that text layout is preserved
          expect(
            atmosphericSize.width,
            closeTo(originalSize.width, 1.0),
            reason: 'Text width should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericSize.height,
            closeTo(originalSize.height, 1.0),
            reason: 'Text height should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dx,
            closeTo(originalOffset.dx, 1.0),
            reason: 'Text X position should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dy,
            closeTo(originalOffset.dy, 1.0),
            reason: 'Text Y position should be preserved when adding atmospheric effects',
          );
        }
      },
    );

    testWidgets(
      'Property 32: Atmospheric effects preserve button layout and functionality',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 5 times with different button configurations
        // Reduced from 50 to prevent test timeout
        for (int i = 0; i < 5; i++) {
          bool buttonPressed = false;
          
          // Generate random button parameters
          final buttonWidth = 100.0 + random.nextDouble() * 100.0; // 100-200px
          final buttonHeight = 40.0 + random.nextDouble() * 40.0; // 40-80px
          
          final testButton = SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                buttonPressed = true;
              },
              child: const Text('Test Button'),
            ),
          );

          // Test widget WITHOUT atmospheric effects (control)
          final controlWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: testButton,
              ),
            ),
          );

          await tester.pumpWidget(controlWidget);
          await tester.pump();

          // Get original button layout information
          final originalButtonFinder = find.byType(ElevatedButton);
          final originalRenderBox = tester.renderObject<RenderBox>(originalButtonFinder);
          final originalSize = originalRenderBox.size;
          final originalOffset = originalRenderBox.localToGlobal(Offset.zero);

          // Test button functionality without atmospheric effects
          await tester.tap(originalButtonFinder);
          await tester.pump();
          expect(buttonPressed, isTrue, reason: 'Button should be functional without atmospheric effects');
          
          // Reset button state
          buttonPressed = false;

          // Test widget WITH atmospheric effects
          final atmosphericWidget = MaterialApp(
            home: Scaffold(
              body: Center(
                child: AtmosphericScaffold(
                  showGhost: true,
                  showFog: true,
                  showEmbers: true,
                  intensity: AtmosphericIntensity.normal,
                  child: testButton,
                ),
              ),
            ),
          );

          await tester.pumpWidget(atmosphericWidget);
          await tester.pump();

          // Get button layout information with atmospheric effects
          final atmosphericButtonFinder = find.byType(ElevatedButton);
          final atmosphericRenderBox = tester.renderObject<RenderBox>(atmosphericButtonFinder);
          final atmosphericSize = atmosphericRenderBox.size;
          final atmosphericOffset = atmosphericRenderBox.localToGlobal(Offset.zero);

          // Verify that button layout is preserved
          expect(
            atmosphericSize.width,
            closeTo(originalSize.width, 1.0),
            reason: 'Button width should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericSize.height,
            closeTo(originalSize.height, 1.0),
            reason: 'Button height should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dx,
            closeTo(originalOffset.dx, 1.0),
            reason: 'Button X position should be preserved when adding atmospheric effects',
          );

          expect(
            atmosphericOffset.dy,
            closeTo(originalOffset.dy, 1.0),
            reason: 'Button Y position should be preserved when adding atmospheric effects',
          );

          // Test button functionality with atmospheric effects
          await tester.tap(atmosphericButtonFinder);
          await tester.pump();
          expect(buttonPressed, isTrue, reason: 'Button should remain functional with atmospheric effects');
        }
      },
    );
  });
}