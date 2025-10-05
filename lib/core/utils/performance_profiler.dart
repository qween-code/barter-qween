import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Advanced Performance Profiler for Neuromorphic Design
/// Monitors FPS, frame build times, shadow rendering performance

class PerformanceProfiler {
  static final PerformanceProfiler _instance = PerformanceProfiler._internal();
  factory PerformanceProfiler() => _instance;
  PerformanceProfiler._internal();

  final List<FrameMetrics> _frameMetrics = [];
  final List<ShadowRenderMetrics> _shadowMetrics = [];
  final List<MemorySnapshot> _memorySnapshots = [];
  
  Timer? _memoryTimer;
  bool _isEnabled = false;
  int _maxSamples = 300; // 5 seconds at 60fps

  /// Start profiling
  void start() {
    if (_isEnabled) return;
    
    _isEnabled = true;
    _frameMetrics.clear();
    _shadowMetrics.clear();
    _memorySnapshots.clear();
    
    // Monitor frames
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
    
    // Monitor memory every second
    _memoryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _captureMemorySnapshot();
    });
    
    debugPrint('🎯 Performance Profiler STARTED');
  }

  /// Stop profiling
  void stop() {
    if (!_isEnabled) return;
    
    _isEnabled = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
    _memoryTimer?.cancel();
    
    debugPrint('🛑 Performance Profiler STOPPED');
  }

  /// Handle frame timing
  void _onFrameTiming(List<FrameTiming> timings) {
    if (!_isEnabled) return;

    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMicroseconds / 1000.0;
      final rasterDuration = timing.rasterDuration.inMicroseconds / 1000.0;
      final totalDuration = timing.totalSpan.inMicroseconds / 1000.0;
      
      final metrics = FrameMetrics(
        buildTime: buildDuration,
        rasterTime: rasterDuration,
        totalTime: totalDuration,
        timestamp: DateTime.now(),
      );
      
      _frameMetrics.add(metrics);
      
      if (_frameMetrics.length > _maxSamples) {
        _frameMetrics.removeAt(0);
      }
    }
  }

  /// Record shadow rendering time
  void recordShadowRender({
    required String componentType,
    required int shadowCount,
    required Duration renderTime,
  }) {
    if (!_isEnabled) return;

    final metrics = ShadowRenderMetrics(
      componentType: componentType,
      shadowCount: shadowCount,
      renderTime: renderTime.inMicroseconds / 1000.0,
      timestamp: DateTime.now(),
    );

    _shadowMetrics.add(metrics);

    if (_shadowMetrics.length > _maxSamples) {
      _shadowMetrics.removeAt(0);
    }
  }

  /// Capture memory snapshot
  void _captureMemorySnapshot() {
    // In a real implementation, you would use:
    // - dart:developer's Timeline API
    // - DevTools memory profiler
    // For now, we'll track basic metrics
    
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      // These would come from actual memory profiling
      usedMemoryMB: 0, // Placeholder
      frameMetricsCount: _frameMetrics.length,
      shadowMetricsCount: _shadowMetrics.length,
    );

    _memorySnapshots.add(snapshot);

    if (_memorySnapshots.length > 300) {
      _memorySnapshots.removeAt(0);
    }
  }

  /// Get current FPS
  double getCurrentFPS() {
    if (_frameMetrics.isEmpty) return 60.0;
    
    final recentFrames = _frameMetrics.length > 60 
        ? _frameMetrics.sublist(_frameMetrics.length - 60)
        : _frameMetrics;
    
    final avgFrameTime = recentFrames.map((f) => f.totalTime).reduce((a, b) => a + b) / recentFrames.length;
    
    return 1000.0 / avgFrameTime;
  }

  /// Get average build time
  double getAverageBuildTime() {
    if (_frameMetrics.isEmpty) return 0.0;
    return _frameMetrics.map((f) => f.buildTime).reduce((a, b) => a + b) / _frameMetrics.length;
  }

  /// Get average raster time
  double getAverageRasterTime() {
    if (_frameMetrics.isEmpty) return 0.0;
    return _frameMetrics.map((f) => f.rasterTime).reduce((a, b) => a + b) / _frameMetrics.length;
  }

  /// Get jank count (frames > 16ms)
  int getJankCount() {
    return _frameMetrics.where((f) => f.totalTime > 16.67).length;
  }

  /// Get jank percentage
  double getJankPercentage() {
    if (_frameMetrics.isEmpty) return 0.0;
    return (getJankCount() / _frameMetrics.length) * 100;
  }

  /// Get shadow performance report
  ShadowPerformanceReport getShadowReport() {
    if (_shadowMetrics.isEmpty) {
      return ShadowPerformanceReport(
        averageRenderTime: 0.0,
        maxRenderTime: 0.0,
        componentBreakdown: {},
      );
    }

    final avgRenderTime = _shadowMetrics.map((m) => m.renderTime).reduce((a, b) => a + b) / _shadowMetrics.length;
    final maxRenderTime = _shadowMetrics.map((m) => m.renderTime).reduce((a, b) => a > b ? a : b);

    // Group by component type
    final breakdown = <String, List<double>>{};
    for (final metric in _shadowMetrics) {
      breakdown.putIfAbsent(metric.componentType, () => []).add(metric.renderTime);
    }

    final componentAverages = breakdown.map((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, avg);
    });

    return ShadowPerformanceReport(
      averageRenderTime: avgRenderTime,
      maxRenderTime: maxRenderTime,
      componentBreakdown: componentAverages,
    );
  }

  /// Get comprehensive performance report
  PerformanceReport getReport() {
    return PerformanceReport(
      fps: getCurrentFPS(),
      averageBuildTime: getAverageBuildTime(),
      averageRasterTime: getAverageRasterTime(),
      jankCount: getJankCount(),
      jankPercentage: getJankPercentage(),
      frameCount: _frameMetrics.length,
      shadowReport: getShadowReport(),
      timestamp: DateTime.now(),
    );
  }

  /// Export data for analysis
  Map<String, dynamic> exportData() {
    return {
      'frameMetrics': _frameMetrics.map((f) => f.toJson()).toList(),
      'shadowMetrics': _shadowMetrics.map((s) => s.toJson()).toList(),
      'memorySnapshots': _memorySnapshots.map((m) => m.toJson()).toList(),
      'report': getReport().toJson(),
    };
  }

  /// Clear all data
  void clear() {
    _frameMetrics.clear();
    _shadowMetrics.clear();
    _memorySnapshots.clear();
  }

  bool get isEnabled => _isEnabled;
}

/// Frame metrics data
class FrameMetrics {
  final double buildTime;
  final double rasterTime;
  final double totalTime;
  final DateTime timestamp;

  FrameMetrics({
    required this.buildTime,
    required this.rasterTime,
    required this.totalTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'buildTime': buildTime,
    'rasterTime': rasterTime,
    'totalTime': totalTime,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Shadow render metrics
class ShadowRenderMetrics {
  final String componentType;
  final int shadowCount;
  final double renderTime;
  final DateTime timestamp;

  ShadowRenderMetrics({
    required this.componentType,
    required this.shadowCount,
    required this.renderTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'componentType': componentType,
    'shadowCount': shadowCount,
    'renderTime': renderTime,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Memory snapshot
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;
  final int frameMetricsCount;
  final int shadowMetricsCount;

  MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.frameMetricsCount,
    required this.shadowMetricsCount,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'usedMemoryMB': usedMemoryMB,
    'frameMetricsCount': frameMetricsCount,
    'shadowMetricsCount': shadowMetricsCount,
  };
}

/// Shadow performance report
class ShadowPerformanceReport {
  final double averageRenderTime;
  final double maxRenderTime;
  final Map<String, double> componentBreakdown;

  ShadowPerformanceReport({
    required this.averageRenderTime,
    required this.maxRenderTime,
    required this.componentBreakdown,
  });

  Map<String, dynamic> toJson() => {
    'averageRenderTime': averageRenderTime,
    'maxRenderTime': maxRenderTime,
    'componentBreakdown': componentBreakdown,
  };
}

/// Comprehensive performance report
class PerformanceReport {
  final double fps;
  final double averageBuildTime;
  final double averageRasterTime;
  final int jankCount;
  final double jankPercentage;
  final int frameCount;
  final ShadowPerformanceReport shadowReport;
  final DateTime timestamp;

  PerformanceReport({
    required this.fps,
    required this.averageBuildTime,
    required this.averageRasterTime,
    required this.jankCount,
    required this.jankPercentage,
    required this.frameCount,
    required this.shadowReport,
    required this.timestamp,
  });

  bool get isAcceptable => fps >= 55.0 && jankPercentage < 5.0;

  String get performanceGrade {
    if (fps >= 58.0 && jankPercentage < 2.0) return 'A+ Excellent';
    if (fps >= 55.0 && jankPercentage < 5.0) return 'A Good';
    if (fps >= 50.0 && jankPercentage < 10.0) return 'B Fair';
    if (fps >= 45.0 && jankPercentage < 15.0) return 'C Poor';
    return 'D Unacceptable';
  }

  Map<String, dynamic> toJson() => {
    'fps': fps,
    'averageBuildTime': averageBuildTime,
    'averageRasterTime': averageRasterTime,
    'jankCount': jankCount,
    'jankPercentage': jankPercentage,
    'frameCount': frameCount,
    'shadowReport': shadowReport.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'isAcceptable': isAcceptable,
    'performanceGrade': performanceGrade,
  };

  @override
  String toString() {
    return '''
╔══════════════════════════════════════════════════════════╗
║           NEUROMORPHIC PERFORMANCE REPORT                ║
╠══════════════════════════════════════════════════════════╣
║ FPS:                ${fps.toStringAsFixed(1)} fps
║ Grade:              $performanceGrade
║ ─────────────────────────────────────────────────────────
║ Frame Metrics:
║   Build Time:       ${averageBuildTime.toStringAsFixed(2)} ms
║   Raster Time:      ${averageRasterTime.toStringAsFixed(2)} ms
║   Total Frames:     $frameCount
║   Jank Frames:      $jankCount (${jankPercentage.toStringAsFixed(1)}%)
║ ─────────────────────────────────────────────────────────
║ Shadow Performance:
║   Avg Render:       ${shadowReport.averageRenderTime.toStringAsFixed(2)} ms
║   Max Render:       ${shadowReport.maxRenderTime.toStringAsFixed(2)} ms
║ ─────────────────────────────────────────────────────────
║ Status:             ${isAcceptable ? '✅ ACCEPTABLE' : '❌ NEEDS OPTIMIZATION'}
╚══════════════════════════════════════════════════════════╝
''';
  }
}
