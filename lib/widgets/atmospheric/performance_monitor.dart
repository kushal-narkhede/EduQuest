/// Performance monitoring class for tracking frame rates
/// Used to auto-scale atmospheric effects based on device performance
class PerformanceMonitor {
  final List<double> _frameTimes = [];
  static const int _sampleSize = 60; // Monitor last 60 frames
  int _lowFpsFrameCount = 0;
  static const int _lowFpsThreshold = 180; // 3 seconds at 60fps

  /// Get the average FPS from recent frame samples
  double get averageFps {
    if (_frameTimes.isEmpty) return 60.0;
    final avgFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return 1000.0 / avgFrameTime;
  }

  /// Record a frame time in milliseconds
  void recordFrame(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);
    if (_frameTimes.length > _sampleSize) {
      _frameTimes.removeAt(0);
    }

    // Track consecutive low FPS frames
    if (averageFps < 45.0) {
      _lowFpsFrameCount++;
    } else {
      _lowFpsFrameCount = 0;
    }
  }

  /// Check if effects should be reduced due to low FPS
  bool get shouldReduceEffects => averageFps < 55.0;

  /// Check if effects should be disabled entirely
  bool get shouldDisableEffects => _lowFpsFrameCount >= _lowFpsThreshold;

  /// Reset the performance monitor
  void reset() {
    _frameTimes.clear();
    _lowFpsFrameCount = 0;
  }

  /// Get the current frame time samples
  List<double> get frameTimes => List.unmodifiable(_frameTimes);
}
