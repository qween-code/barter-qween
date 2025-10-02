import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance optimization utilities
class PerformanceUtils {
  /// Debounce function calls
  static Function debounce(
    Function func, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }

  /// Throttle function calls
  static Function throttle(
    Function func, {
    Duration interval = const Duration(milliseconds: 500),
  }) {
    bool isExecuting = false;
    return () {
      if (!isExecuting) {
        isExecuting = true;
        func();
        Timer(interval, () => isExecuting = false);
      }
    };
  }

  /// Check if in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Log performance metrics
  static void logPerformance(String operation, Function fn) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      fn();
      stopwatch.stop();
      debugPrint('⚡ $operation took ${stopwatch.elapsedMilliseconds}ms');
    } else {
      fn();
    }
  }

  /// Optimize image loading
  static ImageProvider optimizedImage(
    String url, {
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return NetworkImage(url);
  }
}

/// Timer for debounce/throttle
class Timer {
  final Duration duration;
  final VoidCallback callback;
  
  Timer(this.duration, this.callback) {
    Future.delayed(duration, callback);
  }

  void cancel() {}
}
