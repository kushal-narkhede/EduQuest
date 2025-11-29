# Design Document: Haunted Atmospheric Visuals

## Overview

The Haunted Atmospheric Visuals system transforms EduQuest into an immersive, spooky educational experience through a collection of modular, reusable Flutter widgets that provide ghostly mascots, particle effects, glow effects, floating animations, and dynamic shadows. The system is designed to be performant (60fps), responsive across all devices, and seamlessly integrated with the existing theme system.

The architecture follows Flutter best practices with stateful widgets for animations, custom painters for particle systems, and wrapper widgets for easy integration. All effects are configurable and can be disabled for performance-constrained devices.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                     │
│              (Screens, Quiz Modes, UI)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Atmospheric Widget Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Ghost Mascot │  │ Glow Wrapper │  │Float Wrapper │  │
│  │   Widget     │  │   Widget     │  │   Widget     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Particle   │  │    Shadow    │  │   Wisp Burst │  │
│  │   System     │  │   Wrapper    │  │   Widget     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Core Animation System                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Animation Controllers & Tickers                 │   │
│  │  Performance Monitor & Auto-Scaling              │   │
│  │  Particle Pool & Recycling System                │   │
│  └──────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  Theme Integration                       │
│              (Colors, Styles, Configuration)             │
└─────────────────────────────────────────────────────────┘
```

### Design Principles

1. **Modularity**: Each effect is a self-contained widget that can be used independently
2. **Composability**: Effects can be layered and combined without conflicts
3. **Performance-First**: All effects monitor frame rate and auto-scale to maintain 60fps
4. **Theme-Aware**: Effects adapt colors and intensity based on the current theme
5. **Accessibility**: Effects can be disabled or reduced for users with motion sensitivity

## Components and Interfaces

### 1. Ghost Mascot Widget

**Purpose**: Display an animated ghost character using the existing ghostLoader.json Lottie animation.

**Interface**:
```dart
class GhostMascot extends StatefulWidget {
  final GhostState state; // idle, celebrating, encouraging
  final Alignment alignment; // Position on screen
  final double size; // Size of the mascot
  final bool autoHide; // Hide during user interactions
  
  const GhostMascot({
    this.state = GhostState.idle,
    this.alignment = Alignment.topRight,
    this.size = 80.0,
    this.autoHide = true,
  });
}

enum GhostState {
  idle,        // Gentle floating animation
  celebrating, // Happy bounce when user answers correctly
  encouraging, // Supportive gesture when user answers incorrectly
}
```

**Behavior**:
- Loads ghostLoader.json using the Lottie package
- Applies floating animation overlay for idle state
- Transitions between states with smooth animations
- Automatically hides when user is interacting with quiz elements (if autoHide is true)
- Positioned using Stack and Alignment to avoid obstructing UI

### 2. Particle System Widget

**Purpose**: Render fog, mist, ember, and wisp particles with efficient recycling.

**Interface**:
```dart
class AtmosphericParticles extends StatefulWidget {
  final ParticleType type; // fog, ember, wisp
  final int particleCount; // Number of particles
  final Color baseColor; // Base color for particles
  final double opacity; // Overall opacity
  final bool enabled; // Enable/disable particles
  
  const AtmosphericParticles({
    required this.type,
    this.particleCount = 30,
    this.baseColor = Colors.white,
    this.opacity = 0.3,
    this.enabled = true,
  });
}

enum ParticleType {
  fog,   // Horizontal drifting fog
  ember, // Rising embers with glow
  wisp,  // Burst particles for feedback
}
```

**Implementation Details**:
- Uses CustomPainter for efficient rendering
- Particle pool pattern for recycling (no garbage collection pressure)
- Each particle has: position, velocity, size, opacity, lifetime
- Fog particles drift horizontally with slight vertical oscillation
- Ember particles rise with random drift and fade out
- Wisp particles burst from a point with physics-based movement
- Frame rate monitoring: reduces particle count if FPS drops below 55

### 3. Glow Effect Wrapper

**Purpose**: Apply phosphorescent glow effects to interactive UI elements.

**Interface**:
```dart
class GlowWrapper extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity; // 0.0 to 1.0
  final bool pulseOnHover; // Pulse when user interacts
  final Duration pulseDuration;
  
  const GlowWrapper({
    required this.child,
    this.glowColor = const Color(0xFF9D4EDD), // Purple
    this.glowIntensity = 0.6,
    this.pulseOnHover = true,
    this.pulseDuration = const Duration(milliseconds: 800),
  });
}
```

**Implementation Details**:
- Uses BoxDecoration with multiple BoxShadow layers for glow effect
- Detects user interaction with GestureDetector
- Animates glow intensity on interaction using AnimationController
- Supports theme-aware color selection (purple, green, orange based on theme)
- Layered shadows: inner glow (tight, bright) + outer glow (diffuse, dim)

### 4. Floating Animation Wrapper

**Purpose**: Apply gentle floating and swaying animations to UI elements.

**Interface**:
```dart
class FloatingWrapper extends StatefulWidget {
  final Widget child;
  final double amplitude; // Vertical movement range in pixels
  final Duration duration; // Animation cycle duration
  final Curve curve; // Easing curve
  final double phase; // Initial phase offset (0.0 to 1.0)
  final bool pauseOnInteraction; // Pause when user touches
  
  const FloatingWrapper({
    required this.child,
    this.amplitude = 8.0,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
    this.phase = 0.0,
    this.pauseOnInteraction = true,
  });
}
```

**Implementation Details**:
- Uses AnimationController with repeat mode
- Applies Transform.translate for vertical movement
- Slight rotation (1-2 degrees) for natural sway
- Phase offset prevents synchronized movement of multiple elements
- Pauses animation during user interaction to prevent confusion

### 5. Dynamic Shadow Wrapper

**Purpose**: Apply responsive shadows that react to user interactions.

**Interface**:
```dart
class DynamicShadowWrapper extends StatefulWidget {
  final Widget child;
  final Color shadowColor;
  final double restingElevation; // Shadow intensity at rest
  final double pressedElevation; // Shadow intensity when pressed
  final Duration transitionDuration;
  
  const DynamicShadowWrapper({
    required this.child,
    this.shadowColor = const Color(0xFF1A0033), // Dark purple
    this.restingElevation = 8.0,
    this.pressedElevation = 2.0,
    this.transitionDuration = const Duration(milliseconds: 150),
  });
}
```

**Implementation Details**:
- Uses GestureDetector to track press/release events
- Animates BoxShadow properties (blur radius, spread, offset)
- Multiple shadow layers for depth (3-4 shadows with varying blur)
- Smooth transitions using AnimatedContainer
- Theme-aware shadow colors (dark purple, black with color tints)

### 6. Wisp Burst Widget

**Purpose**: Generate burst of wisp particles for milestone feedback.

**Interface**:
```dart
class WispBurst extends StatefulWidget {
  final Offset origin; // Burst origin point
  final int particleCount; // Number of wisps
  final Color color;
  final VoidCallback? onComplete; // Callback when animation completes
  
  const WispBurst({
    required this.origin,
    this.particleCount = 20,
    this.color = const Color(0xFF10B981), // Ghostly green
    this.onComplete,
  });
}
```

**Implementation Details**:
- Short-lived widget (auto-disposes after animation)
- Particles radiate outward from origin with random angles
- Physics simulation: initial velocity, gravity, air resistance
- Fade out over 1-2 seconds
- Calls onComplete callback when all particles fade

### 7. Atmospheric Scaffold Wrapper

**Purpose**: Convenience widget that applies multiple atmospheric effects to a screen.

**Interface**:
```dart
class AtmosphericScaffold extends StatelessWidget {
  final Widget child;
  final bool showGhost;
  final bool showFog;
  final bool showEmbers;
  final AtmosphericIntensity intensity;
  
  const AtmosphericScaffold({
    required this.child,
    this.showGhost = true,
    this.showFog = true,
    this.showEmbers = true,
    this.intensity = AtmosphericIntensity.normal,
  });
}

enum AtmosphericIntensity {
  minimal,  // Reduced effects for performance
  normal,   // Standard effects
  maximum,  // Full effects for high-end devices
}
```

**Implementation Details**:
- Wraps child in Stack with atmospheric layers
- Automatically adjusts particle counts based on intensity
- Integrates with existing theme system
- Provides consistent atmospheric experience across screens

## Data Models

### Particle Data Structure

```dart
class Particle {
  Offset position;      // Current position (x, y)
  Offset velocity;      // Movement vector
  double size;          // Particle size in pixels
  double opacity;       // Current opacity (0.0 to 1.0)
  double lifetime;      // Remaining lifetime in seconds
  double rotation;      // Current rotation angle
  Color color;          // Particle color
  
  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.lifetime,
    this.rotation = 0.0,
    required this.color,
  });
  
  // Update particle state based on delta time
  void update(double dt) {
    position += velocity * dt;
    opacity = (lifetime / maxLifetime).clamp(0.0, 1.0);
    lifetime -= dt;
  }
  
  bool get isAlive => lifetime > 0;
}
```

### Performance Metrics

```dart
class PerformanceMonitor {
  final List<double> _frameTimes = [];
  static const int _sampleSize = 60; // Monitor last 60 frames
  
  double get averageFps {
    if (_frameTimes.isEmpty) return 60.0;
    final avgFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return 1000.0 / avgFrameTime;
  }
  
  void recordFrame(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);
    if (_frameTimes.length > _sampleSize) {
      _frameTimes.removeAt(0);
    }
  }
  
  bool get shouldReduceEffects => averageFps < 55.0;
}
```

### Theme Configuration

```dart
class AtmosphericThemeConfig {
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final Color particleColor;
  final Color shadowColor;
  final double baseIntensity;
  
  const AtmosphericThemeConfig({
    required this.primaryGlowColor,
    required this.secondaryGlowColor,
    required this.particleColor,
    required this.shadowColor,
    this.baseIntensity = 1.0,
  });
  
  // Predefined theme configurations
  static const haunted = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFF9D4EDD),    // Purple
    secondaryGlowColor: Color(0xFF10B981),  // Ghostly green
    particleColor: Color(0xFFE0E0E0),       // Light gray
    shadowColor: Color(0xFF1A0033),         // Dark purple
  );
  
  static const ember = AtmosphericThemeConfig(
    primaryGlowColor: Color(0xFFFF6B35),    // Orange
    secondaryGlowColor: Color(0xFFFBBD08),  // Yellow
    particleColor: Color(0xFFFF8C42),       // Warm orange
    shadowColor: Color(0xFF2D1B00),         // Dark brown
  );
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Ghost mascot persistence across navigation
*For any* screen navigation event, the ghost mascot widget should remain present in the widget tree after navigation completes.
**Validates: Requirements 1.2**

### Property 2: Ghost positioning does not obstruct interactions
*For any* screen layout with interactive elements, the ghost mascot's bounding box should not intersect with the bounding boxes of buttons, input fields, or other touchable widgets.
**Validates: Requirements 1.5**

### Property 3: Fog particles maintain horizontal drift
*For any* fog particle in the particle system, its velocity vector should have a non-zero horizontal component indicating drift across the viewport.
**Validates: Requirements 2.1**

### Property 4: Particle system maintains target frame rate
*For any* 60-frame sampling window while atmospheric effects are active, the average frame rate should be at or above 55 fps.
**Validates: Requirements 2.2, 8.1**

### Property 5: Particle recycling maintains constant count
*For any* particle that exits the viewport boundaries, the total particle count should remain constant before and after the particle is recycled.
**Validates: Requirements 2.3**

### Property 6: Fog opacity preserves readability
*For any* fog particle, its opacity value should be less than or equal to 0.4 to ensure text remains readable.
**Validates: Requirements 2.4**

### Property 7: Orientation change triggers particle recalculation
*For any* device orientation change event, the particle system should recalculate particle positions to fit within the new viewport dimensions.
**Validates: Requirements 2.5, 9.2**

### Property 8: Interactive elements receive glow effects
*For any* widget wrapped in GlowWrapper, the widget's decoration should contain at least one BoxShadow with a blur radius greater than zero.
**Validates: Requirements 3.1**

### Property 9: Touch interaction intensifies glow
*For any* GlowWrapper widget, when a touch-down event occurs, the glow intensity should increase above its resting value.
**Validates: Requirements 3.2**

### Property 10: Glow colors match theme palette
*For any* GlowWrapper widget, the glow color should be present in the current theme's atmospheric color configuration.
**Validates: Requirements 3.3, 10.1, 10.2**

### Property 11: Multiple glows have varied intensity
*For any* set of two or more GlowWrapper widgets on the same screen, at least two widgets should have different glow intensity values.
**Validates: Requirements 3.4**

### Property 12: Floating animations apply vertical translation
*For any* widget wrapped in FloatingWrapper, the widget's transform should include a vertical translation component that changes over time.
**Validates: Requirements 4.1**

### Property 13: Floating animations use smooth easing
*For any* FloatingWrapper widget, the animation curve should be one of the smooth easing curves (easeInOut, easeIn, easeOut, or custom smooth curve).
**Validates: Requirements 4.2**

### Property 14: Floating phases are staggered
*For any* set of two or more FloatingWrapper widgets on the same screen, at least two widgets should have different phase offset values.
**Validates: Requirements 4.3**

### Property 15: Floating amplitude is constrained
*For any* FloatingWrapper widget, the amplitude value should be less than or equal to 10 pixels to prevent motion sickness.
**Validates: Requirements 4.4**

### Property 16: Floating pauses on interaction
*For any* FloatingWrapper widget, when a touch-down event occurs on the wrapped child, the animation controller should be paused.
**Validates: Requirements 4.5**

### Property 17: Shadows have multiple layers
*For any* widget wrapped in DynamicShadowWrapper, the widget's decoration should contain at least two BoxShadow objects to create depth.
**Validates: Requirements 5.1**

### Property 18: Press reduces shadow elevation
*For any* DynamicShadowWrapper widget, when a press event occurs, the shadow elevation should decrease below its resting value.
**Validates: Requirements 5.2**

### Property 19: Drag updates shadow in real-time
*For any* DynamicShadowWrapper widget during a drag event, the shadow properties should update within one frame of the drag position changing.
**Validates: Requirements 5.3**

### Property 20: Shadow colors match haunted theme
*For any* DynamicShadowWrapper widget, the shadow color should be a dark color (luminance < 0.3) with optional purple, blue, or black tint.
**Validates: Requirements 5.4**

### Property 21: Shadows return to resting state
*For any* DynamicShadowWrapper widget, after an interaction ends, the shadow elevation should animate back to its original resting value.
**Validates: Requirements 5.5**

### Property 22: Ember particles rise upward
*For any* ember particle in the particle system, its velocity vector should have a negative vertical component (upward movement in screen coordinates).
**Validates: Requirements 6.1**

### Property 23: Ember particles have glow effect
*For any* ember particle, the particle's rendering should include a glow or shadow effect with blur radius greater than zero.
**Validates: Requirements 6.3**

### Property 24: Wisp particles have physics properties
*For any* wisp particle, the particle should have velocity, gravity acceleration, and decreasing opacity over its lifetime.
**Validates: Requirements 6.4**

### Property 25: Performance degradation triggers particle reduction
*For any* 60-frame sampling window where average FPS drops below 55, the particle count should decrease in the next sampling window.
**Validates: Requirements 6.5, 8.2**

### Property 26: Theme integration uses theme colors
*For any* atmospheric widget, the widget should read color values from the current ThemeData or AtmosphericThemeConfig.
**Validates: Requirements 7.4**

### Property 27: Animation controllers are disposed
*For any* stateful atmospheric widget, when the widget's dispose() method is called, all AnimationController instances should also be disposed.
**Validates: Requirements 8.4**

### Property 28: Backgrounded app pauses animations
*For any* atmospheric widget, when the app lifecycle state changes to paused or inactive, all animation controllers should be paused.
**Validates: Requirements 8.5**

### Property 29: Particle count scales with screen area
*For any* two different screen sizes, the ratio of particle counts should be proportional to the ratio of screen areas (within 20% tolerance).
**Validates: Requirements 9.1, 9.5**

### Property 30: Low-resolution maintains performance
*For any* device with screen resolution below 1080p, atmospheric effects should maintain at least 55 fps average frame rate.
**Validates: Requirements 9.3**

### Property 31: Relative positioning for all elements
*For any* atmospheric element's position, the position should be calculated using relative values (percentages or fractions of screen dimensions) rather than absolute pixel values.
**Validates: Requirements 9.4**

### Property 32: Atmospheric effects preserve existing layouts
*For any* existing screen, adding AtmosphericScaffold wrapper should not change the positions or sizes of existing UI elements.
**Validates: Requirements 10.5**

## Error Handling

### Particle System Errors

**Missing Animation Assets**:
- If ghostLoader.json is not found, display a fallback static ghost icon
- Log warning to console for debugging
- Continue app execution without crashing

**Performance Degradation**:
- Monitor frame rate continuously
- If FPS drops below 55 for 3 consecutive seconds, reduce particle count by 25%
- If FPS drops below 45, disable particle effects entirely
- Show optional user notification: "Atmospheric effects reduced for performance"

**Memory Pressure**:
- Implement particle pool with maximum size (e.g., 100 particles)
- Reuse particle objects instead of creating new ones
- If memory warnings occur, reduce particle pool size by 50%

### Animation Controller Errors

**Dispose Errors**:
- Wrap all dispose() calls in try-catch blocks
- Log errors but don't crash the app
- Use WidgetsBindingObserver to ensure cleanup on app lifecycle changes

**Ticker Errors**:
- If ticker is disposed while animation is running, catch TickerCanceled exception
- Gracefully stop animation without visual glitches
- Prevent multiple tickers from being created for the same animation

### Theme Integration Errors

**Missing Theme Configuration**:
- Provide fallback AtmosphericThemeConfig.haunted as default
- If theme colors are null, use hardcoded haunted palette
- Log warning for developers to configure theme properly

**Invalid Color Values**:
- Validate color values are within valid ranges (0-255 for RGB)
- If invalid, fall back to default haunted colors
- Ensure opacity values are clamped between 0.0 and 1.0

### Device Compatibility Errors

**Unsupported Features**:
- Check for CustomPainter support (should be universal in Flutter)
- If Lottie animations fail to load, use static images
- Gracefully degrade on very old devices (Android < 5.0)

**Orientation Change Errors**:
- If orientation change occurs during animation, pause and resume smoothly
- Recalculate all positions and bounds
- Prevent particle positions from becoming NaN or infinite

## Testing Strategy

### Unit Testing

**Widget Tests**:
- Test that each atmospheric widget renders without errors
- Verify default parameter values are sensible
- Test that widgets accept and apply custom parameters
- Verify widget disposal cleans up resources

**Particle System Tests**:
- Test particle creation and initialization
- Test particle update logic (position, velocity, opacity)
- Test particle recycling when exiting viewport
- Test particle pool size limits

**Animation Tests**:
- Test animation controller creation and disposal
- Test animation curves produce expected values
- Test animation pause/resume functionality
- Test animation state transitions

**Theme Integration Tests**:
- Test that widgets read from theme configuration
- Test fallback to default colors when theme is missing
- Test color validation and clamping

### Property-Based Testing

We will use the **test** and **flutter_test** packages along with **faker** for generating random test data. Property-based tests will run a minimum of 100 iterations to ensure robustness.

**Performance Properties**:
- Generate random particle counts (10-100) and verify FPS remains above 55
- Generate random screen sizes and verify particle scaling is proportional
- Generate random animation durations and verify smooth playback

**Positioning Properties**:
- Generate random screen layouts and verify ghost doesn't obstruct interactive elements
- Generate random particle positions and verify they stay within viewport bounds
- Generate random floating amplitudes and verify they're below maximum threshold

**Color Properties**:
- Generate random themes and verify atmospheric colors match theme palette
- Generate random glow intensities and verify they're within valid range (0.0-1.0)
- Generate random shadow colors and verify they're dark (luminance < 0.3)

**Animation Properties**:
- Generate random phase offsets and verify multiple floating elements are staggered
- Generate random interaction events and verify animations pause/resume correctly
- Generate random lifecycle events and verify animations are disposed properly

### Integration Testing

**Screen Integration**:
- Test AtmosphericScaffold on multiple existing screens
- Verify atmospheric effects don't break existing layouts
- Test navigation between atmospheric and non-atmospheric screens

**Performance Integration**:
- Test multiple atmospheric effects running simultaneously
- Measure combined CPU and GPU usage
- Verify app remains responsive during heavy atmospheric rendering

**Theme Integration**:
- Test switching between different themes at runtime
- Verify atmospheric colors update immediately
- Test with existing HalloweenBackground for compatibility

### Manual Testing

**Visual Quality**:
- Verify fog appears atmospheric and not distracting
- Verify glow effects enhance UI without overwhelming
- Verify floating animations feel natural and organic
- Verify shadows create convincing depth perception

**User Experience**:
- Test on multiple device sizes (phone, tablet)
- Test on different Android versions
- Verify effects don't cause motion sickness
- Verify ghost mascot feels friendly and helpful

**Performance**:
- Test on low-end devices (2GB RAM, older processors)
- Monitor battery drain during extended use
- Verify effects scale down appropriately on limited hardware

## Implementation Notes

### Performance Optimization Techniques

1. **Particle Pooling**: Reuse particle objects instead of creating/destroying
2. **Batch Rendering**: Use CustomPainter to render all particles in single draw call
3. **Culling**: Don't update or render particles outside viewport
4. **LOD (Level of Detail)**: Reduce particle complexity based on distance/size
5. **Frame Rate Monitoring**: Continuously monitor and auto-adjust effect complexity

### Flutter-Specific Considerations

1. **Use RepaintBoundary**: Wrap atmospheric layers to prevent unnecessary repaints
2. **Const Constructors**: Use const wherever possible to reduce rebuilds
3. **AnimatedBuilder**: Use for efficient animation-driven rebuilds
4. **CustomPainter**: Use for particle rendering instead of individual widgets
5. **Ticker Providers**: Use SingleTickerProviderStateMixin for single animations

### Accessibility Considerations

1. **Motion Sensitivity**: Provide option to disable or reduce animations
2. **Color Contrast**: Ensure glow effects don't reduce text contrast below WCAG AA
3. **Screen Reader**: Ensure atmospheric effects don't interfere with TalkBack/VoiceOver
4. **Reduced Motion**: Respect system-level reduced motion preferences

### Future Enhancements

1. **Sound Integration**: Add subtle atmospheric sounds (wind, whispers)
2. **Haptic Feedback**: Add gentle vibrations for ghost interactions
3. **Seasonal Themes**: Expand beyond Halloween to other spooky themes
4. **Customization**: Allow users to adjust effect intensity in settings
5. **Advanced Particles**: Add more particle types (sparkles, leaves, snow)
