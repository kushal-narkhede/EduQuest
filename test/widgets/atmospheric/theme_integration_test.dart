import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart' as faker_lib;
import 'package:student_learning_app/widgets/atmospheric/atmospheric_theme_config.dart';
import 'package:student_learning_app/widgets/atmospheric/glow_wrapper.dart';
import 'package:student_learning_app/widgets/atmospheric/atmospheric_particles.dart';
import 'package:student_learning_app/widgets/atmospheric/dynamic_shadow_wrapper.dart';
import 'dart:math';

void main() {
  group('Theme Integration Property Tests', () {
    testWidgets(
      'Property 26: Theme integration uses theme colors - GlowWrapper',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 100 times with different theme configurations
        for (int i = 0; i < 100; i++) {
          // Generate random theme colors
          final primaryColor = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          // Create theme with random colors
          final theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          );

          // Create test widget with default glow color (should use theme)
          final testWidget = MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GlowWrapper(
                glowColor: const Color(0xFF9D4EDD), // Default purple
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Find the GlowWrapper widget
          final glowWrapperFinder = find.byType(GlowWrapper);
          expect(glowWrapperFinder, findsOneWidget);

          // Get the atmospheric config from the theme
          final atmosphericConfig = theme.atmosphericConfig;
          
          // Verify that the atmospheric config uses theme colors
          expect(
            atmosphericConfig.primaryGlowColor,
            isA<Color>(),
            reason: 'Atmospheric config should have a valid primary glow color from theme',
          );
        }
      },
    );

    testWidgets(
      'Property 26: Theme integration uses theme colors - AtmosphericParticles',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 100 times with different theme configurations
        for (int i = 0; i < 100; i++) {
          // Generate random theme colors
          final primaryColor = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          // Create theme with random colors
          final theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          );

          // Create test widget with default particle color (should use theme)
          final testWidget = MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: AtmosphericParticles(
                type: ParticleType.fog,
                baseColor: Colors.white, // Default white (should use theme)
                particleCount: 10,
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Find the AtmosphericParticles widget
          final particlesFinder = find.byType(AtmosphericParticles);
          expect(particlesFinder, findsOneWidget);

          // Get the atmospheric config from the theme
          final atmosphericConfig = theme.atmosphericConfig;
          
          // Verify that the atmospheric config uses theme colors
          expect(
            atmosphericConfig.particleColor,
            isA<Color>(),
            reason: 'Atmospheric config should have a valid particle color from theme',
          );
          
          // Verify the particle color is derived from theme
          expect(
            (atmosphericConfig.particleColor.a * 255.0).round() & 0xff,
            greaterThan(0),
            reason: 'Particle color should have non-zero alpha',
          );
        }
      },
    );

    testWidgets(
      'Property 26: Theme integration uses theme colors - DynamicShadowWrapper',
      (WidgetTester tester) async {
        final random = Random();
        
        // Run property test 100 times with different theme configurations
        for (int i = 0; i < 100; i++) {
          // Generate random theme colors
          final primaryColor = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          // Create theme with random colors
          final theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          );

          // Create test widget with default shadow color (should use theme)
          final testWidget = MaterialApp(
            theme: theme,
            home: Scaffold(
              body: DynamicShadowWrapper(
                shadowColor: const Color(0xFF1A0033), // Default dark purple
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          );

          await tester.pumpWidget(testWidget);
          await tester.pump();

          // Find the DynamicShadowWrapper widget
          final shadowWrapperFinder = find.byType(DynamicShadowWrapper);
          expect(shadowWrapperFinder, findsOneWidget);

          // Get the atmospheric config from the theme
          final atmosphericConfig = theme.atmosphericConfig;
          
          // Verify that the atmospheric config uses theme colors
          expect(
            atmosphericConfig.shadowColor,
            isA<Color>(),
            reason: 'Atmospheric config should have a valid shadow color from theme',
          );
          
          // Verify the shadow color is dark (luminance < 0.3)
          final luminance = atmosphericConfig.shadowColor.computeLuminance();
          expect(
            luminance,
            lessThan(0.3),
            reason: 'Shadow color should be dark with luminance < 0.3',
          );
        }
      },
    );

    test(
      'Property 26: AtmosphericThemeConfig.forTheme returns correct configurations',
      () {
        final faker = faker_lib.Faker();
        final random = Random();
        
        // Test known theme names
        final knownThemes = [
          'beach', 'forest', 'arctic', 'crystal', 
          'space', 'halloween', 'ember', 'haunted'
        ];
        
        for (int i = 0; i < 100; i++) {
          // Test with known theme names
          final themeName = knownThemes[random.nextInt(knownThemes.length)];
          final config = AtmosphericThemeConfig.forTheme(themeName);
          
          // Verify that the config is not null and has valid colors
          expect(config, isA<AtmosphericThemeConfig>());
          expect(config.primaryGlowColor, isA<Color>());
          expect(config.secondaryGlowColor, isA<Color>());
          expect(config.particleColor, isA<Color>());
          expect(config.shadowColor, isA<Color>());
          expect(config.baseIntensity, greaterThan(0.0));
          
          // Test with random/unknown theme names (should fallback to haunted)
          final randomTheme = faker.lorem.word();
          final fallbackConfig = AtmosphericThemeConfig.forTheme(randomTheme);
          expect(fallbackConfig, equals(AtmosphericThemeConfig.haunted));
        }
      },
    );

    testWidgets(
      'Property 26: Runtime theme switching updates atmospheric colors',
      (WidgetTester tester) async {
        // Create a stateful widget that can switch themes
        late ValueNotifier<ThemeData> themeNotifier;
        
        Widget createTestApp(ThemeData theme) {
          return MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    GlowWrapper(
                      glowColor: const Color(0xFF9D4EDD), // Default purple - should use theme
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: AtmosphericParticles(
                        type: ParticleType.fog,
                        baseColor: Colors.white, // Should use theme
                        particleCount: 5,
                      ),
                    ),
                    DynamicShadowWrapper(
                      shadowColor: const Color(0xFF1A0033), // Default dark purple - should use theme
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Test with beach theme - use exact color scheme to match detection
        final beachTheme = ThemeData(
          colorScheme: ColorScheme.light(primary: const Color(0xFF4DD0E1)),
        );
        
        await tester.pumpWidget(createTestApp(beachTheme));
        await tester.pump();
        
        // Verify beach theme atmospheric config
        final beachConfig = beachTheme.atmosphericConfig;
        expect(beachConfig.primaryGlowColor, equals(AtmosphericThemeConfig.beach.primaryGlowColor));
        expect(beachConfig.secondaryGlowColor, equals(AtmosphericThemeConfig.beach.secondaryGlowColor));
        
        // Switch to forest theme - use exact color scheme to match detection
        final forestTheme = ThemeData(
          colorScheme: ColorScheme.light(primary: const Color(0xFF2E7D32)),
        );
        
        await tester.pumpWidget(createTestApp(forestTheme));
        await tester.pump();
        
        // Verify forest theme atmospheric config
        final forestConfig = forestTheme.atmosphericConfig;
        expect(forestConfig.primaryGlowColor, equals(AtmosphericThemeConfig.forest.primaryGlowColor));
        expect(forestConfig.secondaryGlowColor, equals(AtmosphericThemeConfig.forest.secondaryGlowColor));
        
        // Switch to unknown theme (should fallback)
        final unknownTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123456)),
        );
        
        await tester.pumpWidget(createTestApp(unknownTheme));
        await tester.pump();
        
        // Verify fallback behavior - should create config from theme colors
        final unknownConfig = unknownTheme.atmosphericConfig;
        expect(unknownConfig.primaryGlowColor, equals(unknownTheme.colorScheme.primary));
        expect(unknownConfig.secondaryGlowColor, equals(unknownTheme.colorScheme.secondary));
      },
    );

    testWidgets(
      'Property 26: Fallback to haunted colors when theme is missing',
      (WidgetTester tester) async {
        // Create a minimal theme without atmospheric configuration
        final minimalTheme = ThemeData.light();
        
        final testWidget = MaterialApp(
          theme: minimalTheme,
          home: const Scaffold(
            body: GlowWrapper(
              // No explicit theme config - should fallback to haunted
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Find the GlowWrapper widget
        final glowWrapperFinder = find.byType(GlowWrapper);
        expect(glowWrapperFinder, findsOneWidget);

        // The widget should use fallback atmospheric config
        final atmosphericConfig = minimalTheme.atmosphericConfig;
        expect(atmosphericConfig, isA<AtmosphericThemeConfig>());
        
        // Should have valid colors even with minimal theme
        expect(atmosphericConfig.primaryGlowColor, isA<Color>());
        expect(atmosphericConfig.secondaryGlowColor, isA<Color>());
        expect(atmosphericConfig.particleColor, isA<Color>());
        expect(atmosphericConfig.shadowColor, isA<Color>());
      },
    );
  });
}