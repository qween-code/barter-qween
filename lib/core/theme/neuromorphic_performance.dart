import 'package:flutter/material.dart';

/// Neuromorphic Performance Optimization Utilities
/// 
/// Provides caching and optimization strategies for complex shadow systems
/// Target: 60fps on mid-range devices

class NeuromorphicPerformance {
  // Shadow cache for static elements
  static final Map<String, List<BoxShadow>> _shadowCache = {};
  
  /// Cache shadow configuration with key
  static void cacheShadows(String key, List<BoxShadow> shadows) {
    _shadowCache[key] = shadows;
  }
  
  /// Get cached shadows or compute and cache
  static List<BoxShadow> getCachedShadows(
    String key,
    List<BoxShadow> Function() computeShadows,
  ) {
    if (_shadowCache.containsKey(key)) {
      return _shadowCache[key]!;
    }
    
    final shadows = computeShadows();
    _shadowCache[key] = shadows;
    return shadows;
  }
  
  /// Clear shadow cache (call when theme changes)
  static void clearCache() {
    _shadowCache.clear();
  }
  
  /// Clear specific cached shadow
  static void clearCachedShadow(String key) {
    _shadowCache.remove(key);
  }
  
  /// Wrap widget with RepaintBoundary for better performance
  static Widget optimized(Widget child, {bool enabled = true}) {
    if (!enabled) return child;
    return RepaintBoundary(child: child);
  }
  
  /// Create optimized shadow container
  static Widget optimizedShadowContainer({
    required Widget child,
    required List<BoxShadow> shadows,
    required BorderRadius borderRadius,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    bool enableOptimization = true,
  }) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: child,
    );
    
    return enableOptimization ? RepaintBoundary(child: container) : container;
  }
  
  /// Check device performance tier
  static PerformanceTier getDevicePerformanceTier() {
    // This is a simplified version. In production, you would check:
    // - Device model
    // - Available RAM
    // - GPU capabilities
    // - Frame rate history
    
    // For now, return medium tier
    return PerformanceTier.medium;
  }
  
  /// Get optimal shadow count based on device performance
  static int getOptimalShadowCount(int desiredCount) {
    final tier = getDevicePerformanceTier();
    
    switch (tier) {
      case PerformanceTier.low:
        return (desiredCount * 0.5).round().clamp(4, 8);
      case PerformanceTier.medium:
        return (desiredCount * 0.75).round().clamp(6, 16);
      case PerformanceTier.high:
        return desiredCount.clamp(8, 24);
    }
  }
  
  /// Reduce shadow complexity for low-end devices
  static List<BoxShadow> optimizeShadows(List<BoxShadow> shadows) {
    final tier = getDevicePerformanceTier();
    
    switch (tier) {
      case PerformanceTier.low:
        // Keep only every 3rd shadow
        return shadows.where((s) => shadows.indexOf(s) % 3 == 0).toList();
      
      case PerformanceTier.medium:
        // Keep every 2nd shadow
        return shadows.where((s) => shadows.indexOf(s) % 2 == 0).toList();
      
      case PerformanceTier.high:
        return shadows;
    }
  }
  
  /// Create cached shadow key
  static String createShadowKey({
    required String componentType,
    required double depth,
    bool isPressed = false,
    bool isHovered = false,
  }) {
    return '$componentType-$depth-$isPressed-$isHovered';
  }
}

/// Device performance tier
enum PerformanceTier {
  low,    // < 4GB RAM, older GPUs
  medium, // 4-8GB RAM, mid-range GPUs
  high,   // > 8GB RAM, high-end GPUs
}

/// Pre-computed shadow configurations for common components
class ShadowPrecomputed {
  // Button shadows
  static final Map<String, List<BoxShadow>> buttons = {};
  
  // Card shadows
  static final Map<String, List<BoxShadow>> cards = {};
  
  // Input shadows
  static final Map<String, List<BoxShadow>> inputs = {};
  
  // Navigation shadows
  static final Map<String, List<BoxShadow>> navigation = {};
  
  /// Initialize all precomputed shadows
  static void initialize() {
    // This would be called on app startup to precompute
    // common shadow configurations
    // For now, we'll compute them on-demand
  }
  
  /// Clear all precomputed shadows
  static void clear() {
    buttons.clear();
    cards.clear();
    inputs.clear();
    navigation.clear();
  }
}

/// Performance monitoring
class PerformanceMonitor {
  static final List<double> _frameRates = [];
  static const int _maxSamples = 60; // Track last 60 frames
  
  /// Record frame render time
  static void recordFrame(Duration duration) {
    final fps = 1000 / duration.inMilliseconds;
    _frameRates.add(fps);
    
    if (_frameRates.length > _maxSamples) {
      _frameRates.removeAt(0);
    }
  }
  
  /// Get average FPS
  static double getAverageFPS() {
    if (_frameRates.isEmpty) return 60.0;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }
  
  /// Check if performance is acceptable
  static bool isPerformanceAcceptable({double threshold = 55.0}) {
    return getAverageFPS() >= threshold;
  }
  
  /// Get performance report
  static PerformanceReport getReport() {
    if (_frameRates.isEmpty) {
      return PerformanceReport(
        averageFPS: 60.0,
        minFPS: 60.0,
        maxFPS: 60.0,
        isAcceptable: true,
      );
    }
    
    final avg = getAverageFPS();
    final min = _frameRates.reduce((a, b) => a < b ? a : b);
    final max = _frameRates.reduce((a, b) => a > b ? a : b);
    
    return PerformanceReport(
      averageFPS: avg,
      minFPS: min,
      maxFPS: max,
      isAcceptable: avg >= 55.0,
    );
  }
  
  /// Clear performance data
  static void clear() {
    _frameRates.clear();
  }
}

/// Performance report data
class PerformanceReport {
  final double averageFPS;
  final double minFPS;
  final double maxFPS;
  final bool isAcceptable;
  
  const PerformanceReport({
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.isAcceptable,
  });
  
  @override
  String toString() {
    return 'PerformanceReport(\n'
        '  Average FPS: ${averageFPS.toStringAsFixed(1)}\n'
        '  Min FPS: ${minFPS.toStringAsFixed(1)}\n'
        '  Max FPS: ${maxFPS.toStringAsFixed(1)}\n'
        '  Acceptable: $isAcceptable\n'
        ')';
  }
}
