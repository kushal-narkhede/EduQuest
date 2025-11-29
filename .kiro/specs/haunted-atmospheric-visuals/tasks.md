# Implementation Plan

- [x] 1. Set up atmospheric effects infrastructure




  - Create directory structure: `lib/widgets/atmospheric/`
  - Create base configuration file for atmospheric theme colors and constants
  - Define AtmosphericThemeConfig class with haunted and ember presets
  - Create PerformanceMonitor class for FPS tracking
  - _Requirements: 7.1, 7.3, 8.1, 8.2_

- [x] 1.1 Write property test for performance monitor


  - **Property 4: Particle system maintains target frame rate**
  - **Validates: Requirements 2.2, 8.1**

- [x] 2. Implement particle system foundation




  - Create Particle data class with position, velocity, size, opacity, lifetime, rotation, color
  - Implement particle update logic (position updates, opacity fade, lifetime countdown)
  - Create ParticlePool class for efficient particle recycling
  - Implement particle lifecycle management (spawn, update, recycle)
  - _Requirements: 2.1, 2.3, 6.1, 6.4_

- [x] 2.1 Write property test for particle recycling


  - **Property 5: Particle recycling maintains constant count**
  - **Validates: Requirements 2.3**

- [x] 2.2 Write property test for particle update logic



  - **Property 24: Wisp particles have physics properties**
  - **Validates: Requirements 6.4**

- [x] 3. Create AtmosphericParticles widget for fog effects




  - Implement StatefulWidget with CustomPainter for particle rendering
  - Create FogParticlePainter that renders semi-transparent fog particles
  - Implement horizontal drift animation with slight vertical oscillation
  - Add particle recycling when particles exit viewport
  - Integrate with PerformanceMonitor to adjust particle count dynamically
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3.1 Write property test for fog particle drift


  - **Property 3: Fog particles maintain horizontal drift**
  - **Validates: Requirements 2.1**

- [x] 3.2 Write property test for fog opacity


  - **Property 6: Fog opacity preserves readability**
  - **Validates: Requirements 2.4**

- [x] 3.3 Write property test for orientation handling


  - **Property 7: Orientation change triggers particle recalculation**
  - **Validates: Requirements 2.5, 9.2**

- [x] 4. Implement GhostMascot widget




  - Create StatefulWidget that loads ghostLoader.json using Lottie package
  - Implement GhostState enum (idle, celebrating, encouraging)
  - Add state transition logic with smooth animations
  - Implement floating animation overlay for idle state
  - Add positioning logic using Stack and Alignment
  - Implement autoHide functionality during user interactions
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 4.1 Write property test for ghost positioning


  - **Property 2: Ghost positioning does not obstruct interactions**
  - **Validates: Requirements 1.5**

- [x] 4.2 Write property test for ghost persistence


  - **Property 1: Ghost mascot persistence across navigation**
  - **Validates: Requirements 1.2**

- [x] 5. Create GlowWrapper widget




  - Implement StatefulWidget that wraps child with glow effects
  - Create BoxDecoration with multiple layered BoxShadow for glow
  - Implement GestureDetector for touch interaction detection
  - Add pulsing animation using AnimationController on interaction
  - Integrate with theme system to get glow colors
  - Implement intensity variation for visual hierarchy
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 5.1 Write property test for glow application


  - **Property 8: Interactive elements receive glow effects**
  - **Validates: Requirements 3.1**

- [x] 5.2 Write property test for glow interaction


  - **Property 9: Touch interaction intensifies glow**
  - **Validates: Requirements 3.2**

- [x] 5.3 Write property test for glow colors


  - **Property 10: Glow colors match theme palette**
  - **Validates: Requirements 3.3, 10.1, 10.2**

- [x] 5.4 Write property test for glow intensity variation


  - **Property 11: Multiple glows have varied intensity**
  - **Validates: Requirements 3.4**

- [x] 6. Implement FloatingWrapper widget





  - Create StatefulWidget with AnimationController for floating animation
  - Implement Transform.translate for vertical oscillation
  - Add slight rotation (1-2 degrees) for natural sway
  - Implement phase offset parameter to stagger multiple elements
  - Add GestureDetector to pause animation during interaction
  - Use easing curves (Curves.easeInOut) for organic movement
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 6.1 Write property test for floating animation


  - **Property 12: Floating animations apply vertical translation**
  - **Validates: Requirements 4.1**

- [x] 6.2 Write property test for easing curves

  - **Property 13: Floating animations use smooth easing**
  - **Validates: Requirements 4.2**

- [x] 6.3 Write property test for phase staggering

  - **Property 14: Floating phases are staggered**
  - **Validates: Requirements 4.3**

- [x] 6.4 Write property test for amplitude constraints

  - **Property 15: Floating amplitude is constrained**
  - **Validates: Requirements 4.4**

- [x] 6.5 Write property test for interaction pause

  - **Property 16: Floating pauses on interaction**
  - **Validates: Requirements 4.5**

- [x] 7. Create DynamicShadowWrapper widget





  - Implement StatefulWidget with GestureDetector for press/drag detection
  - Create layered BoxShadow configuration (3-4 shadows with varying blur)
  - Implement AnimatedContainer for smooth shadow transitions
  - Add press detection to reduce elevation
  - Add drag detection to update shadow position in real-time
  - Use haunted theme colors for shadows (dark purple, black tints)
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 7.1 Write property test for shadow layers


  - **Property 17: Shadows have multiple layers**
  - **Validates: Requirements 5.1**

- [x] 7.2 Write property test for press shadow reduction

  - **Property 18: Press reduces shadow elevation**
  - **Validates: Requirements 5.2**

- [x] 7.3 Write property test for drag shadow updates

  - **Property 19: Drag updates shadow in real-time**
  - **Validates: Requirements 5.3**

- [x] 7.4 Write property test for shadow colors

  - **Property 20: Shadow colors match haunted theme**
  - **Validates: Requirements 5.4**

- [x] 7.5 Write property test for shadow return animation

  - **Property 21: Shadows return to resting state**
  - **Validates: Requirements 5.5**

- [x] 8. Implement ember particle effects





  - Extend AtmosphericParticles widget to support ParticleType.ember
  - Create EmberParticlePainter with upward velocity and glow rendering
  - Implement physics: upward movement with random horizontal drift
  - Add glow effect to each ember particle (small BoxShadow or blur)
  - Implement fade-out over particle lifetime
  - _Requirements: 6.1, 6.3_

- [x] 8.1 Write property test for ember upward movement


  - **Property 22: Ember particles rise upward**
  - **Validates: Requirements 6.1**

- [x] 8.2 Write property test for ember glow


  - **Property 23: Ember particles have glow effect**
  - **Validates: Requirements 6.3**

- [x] 9. Create WispBurst widget




  - Implement StatefulWidget that generates burst of wisp particles
  - Create wisp particles with radial outward velocity from origin point
  - Implement physics simulation: velocity, gravity, air resistance
  - Add fade-out animation over 1-2 seconds
  - Implement onComplete callback
  - Auto-dispose widget after animation completes
  - _Requirements: 6.2, 6.4_

- [x] 10. Implement performance monitoring and auto-scaling



  - Integrate PerformanceMonitor into all particle widgets
  - Add FPS sampling (60-frame rolling average)
  - Implement auto-scaling: reduce particle count when FPS < 55
  - Add particle count reduction by 25% increments
  - Disable particles entirely if FPS < 45 for 3 seconds
  - _Requirements: 2.2, 6.5, 8.1, 8.2_

- [x] 10.1 Write property test for performance degradation response


  - **Property 25: Performance degradation triggers particle reduction**
  - **Validates: Requirements 6.5, 8.2**

- [x] 11. Create AtmosphericScaffold convenience wrapper



  - Implement StatelessWidget that combines multiple atmospheric effects
  - Add Stack layout with atmospheric layers (fog, embers, ghost)
  - Implement AtmosphericIntensity enum (minimal, normal, maximum)
  - Add boolean flags for enabling/disabling individual effects
  - Integrate with theme system for color configuration
  - Ensure child widget is rendered on top of atmospheric layers
  - _Requirements: 7.1, 7.2, 7.3, 7.5_

- [x] 12. Implement lifecycle management and resource cleanup











  - Add WidgetsBindingObserver to all stateful atmospheric widgets
  - Implement didChangeAppLifecycleState to pause animations when backgrounded
  - Ensure all AnimationController.dispose() calls are in try-catch blocks
  - Add proper cleanup in dispose() methods for all widgets
  - Test memory leak prevention with Flutter DevTools
  - _Requirements: 8.4, 8.5_

- [x] 12.1 Write property test for animation controller disposal



  - **Property 27: Animation controllers are disposed**
  - **Validates: Requirements 8.4**

- [x] 12.2 Write property test for background pause


  - **Property 28: Backgrounded app pauses animations**
  - **Validates: Requirements 8.5**

- [x] 13. Implement responsive design and device scaling






  - Add MediaQuery-based particle count calculation
  - Implement screen area proportional scaling for particle density
  - Add orientation change detection and particle recalculation
  - Use relative positioning (fractions) for all atmospheric elements
  - Test on multiple screen sizes (phone, tablet, different resolutions)
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 13.1 Write property test for particle count scaling


  - **Property 29: Particle count scales with screen area**
  - **Validates: Requirements 9.1, 9.5**



- [x] 13.2 Write property test for low-resolution performance




  - **Property 30: Low-resolution maintains performance**


  - **Validates: Requirements 9.3**

- [x] 13.3 Write property test for relative positioning




  - **Property 31: Relative positioning for all elements**
  - **Validates: Requirements 9.4**

- [x] 14. Integrate with existing theme system







  - Create AtmosphericThemeConfig extension for existing ThemeData
  - Add theme color mapping for atmospheric effects
  - Implement theme-aware color selection in all atmospheric widgets
  - Add fallback to default haunted colors if theme is missing
  - Test theme switching at runtime
  - Ensure compatibility with existing HalloweenBackground
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 14.1 Write property test for theme integration



  - **Property 26: Theme integration uses theme colors**
  - **Validates: Requirements 7.4**

- [x] 14.2 Write property test for layout preservation



  - **Property 32: Atmospheric effects preserve existing layouts**
  - **Validates: Requirements 10.5**

- [x] 15. Add atmospheric effects to key screens





  - Wrap main quiz screens with AtmosphericScaffold
  - Add GlowWrapper to quiz option buttons
  - Add FloatingWrapper to study cards
  - Add DynamicShadowWrapper to interactive cards
  - Integrate GhostMascot on quiz screens with state transitions
  - Add WispBurst on correct answer feedback
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 4.1, 5.1_

- [x] 16. Implement error handling and fallbacks





  - Add try-catch for ghostLoader.json loading with fallback icon
  - Add error handling for animation controller disposal
  - Implement graceful degradation for unsupported devices
  - Add validation for color values and opacity clamping
  - Add null checks for theme configuration with fallbacks
  - Log warnings for missing assets or configuration
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 17. Final checkpoint - Ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.
