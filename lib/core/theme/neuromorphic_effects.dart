import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Collection of reusable neuromorphic shadow presets used across widgets.
class NeuromorphicPresets {
  NeuromorphicPresets._();

  static final iconPresets = _IconShadowPresets();
  static final buttonPresets = _ButtonShadowPresets();
}

class _IconShadowPresets {
  List<BoxShadow> standard({bool isActive = false}) {
    final activeMultiplier = isActive ? 1.2 : 1.0;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.18 * activeMultiplier),
        offset: const Offset(6, 6),
        blurRadius: 16 * activeMultiplier,
        spreadRadius: 1.5,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.85),
        offset: const Offset(-6, -6),
        blurRadius: 18 * activeMultiplier,
        spreadRadius: 1,
      ),
    ];
  }

  List<BoxShadow> circular({bool isActive = false, Color? glowColor}) {
    final baseGlow = glowColor ?? Colors.blueAccent;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isActive ? 0.22 : 0.15),
        offset: const Offset(4, 8),
        blurRadius: isActive ? 20 : 16,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: const Offset(-6, -6),
        blurRadius: 18,
        spreadRadius: 1,
      ),
      if (isActive)
        BoxShadow(
          color: baseGlow.withOpacity(0.35),
          blurRadius: 24,
          spreadRadius: 4,
        ),
    ];
  }
}

class _ButtonShadowPresets {
  List<BoxShadow> secondary({bool isPressed = false, bool isHovered = false}) {
    final hoverBoost = isHovered ? 1.1 : 1.0;
    final pressReduction = isPressed ? 0.6 : 1.0;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.16 * hoverBoost * pressReduction),
        offset: Offset(6 * pressReduction, 6 * pressReduction),
        blurRadius: 18 * hoverBoost * pressReduction,
        spreadRadius: 1.5 * pressReduction,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.85),
        offset: const Offset(-6, -6),
        blurRadius: 16 * hoverBoost,
        spreadRadius: 1,
      ),
    ];
  }
}

/// Runtime helpers for dynamic neuromorphic effects (e.g. animated shadows).
class NeuromorphicEffects {
  NeuromorphicEffects._();

  static final depth = _DepthEffects();
  static final animator = _AnimatorEffects();
}

class _DepthEffects {
  List<BoxShadow> createDepthAwareShadows({
    double depth = 1.0,
    bool isPressed = false,
    bool isHovered = false,
  }) {
    final clampedDepth = depth.clamp(0.5, 4.0);
    final hoverBoost = isHovered ? 1.15 : 1.0;
    final pressReduction = isPressed ? 0.55 : 1.0;

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.20 * hoverBoost * pressReduction),
        offset: Offset(
          8 * clampedDepth * pressReduction,
          8 * clampedDepth * pressReduction,
        ),
        blurRadius: 24 * clampedDepth * pressReduction,
        spreadRadius: 2 * pressReduction,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: Offset(-8 * clampedDepth, -8 * clampedDepth),
        blurRadius: 26 * clampedDepth,
        spreadRadius: 2,
      ),
    ];
  }
}

class _AnimatorEffects {
  List<BoxShadow> createMorphingShadows({
    required List<BoxShadow> stateShadows,
    required List<BoxShadow> targetShadows,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final results = <BoxShadow>[];
    final maxLength = math.max(stateShadows.length, targetShadows.length);

    for (var index = 0; index < maxLength; index++) {
      final from = _shadowOrFallback(stateShadows, targetShadows, index);
      final to = _shadowOrFallback(targetShadows, stateShadows, index);
      results.add(_lerpShadow(from, to, clampedProgress));
    }

    return results;
  }

  BoxShadow _lerpShadow(BoxShadow a, BoxShadow b, double t) {
    final color = Color.lerp(a.color, b.color, t) ?? a.color;
    final offset = Offset.lerp(a.offset, b.offset, t) ?? a.offset;
    final blur = lerpDouble(a.blurRadius, b.blurRadius, t) ?? a.blurRadius;
    final spread =
        lerpDouble(a.spreadRadius, b.spreadRadius, t) ?? a.spreadRadius;
    return BoxShadow(
      color: color,
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  BoxShadow _shadowOrFallback(
    List<BoxShadow> primary,
    List<BoxShadow> fallback,
    int index,
  ) {
    if (primary.isEmpty) {
      if (fallback.isEmpty) {
        return const BoxShadow();
      }
      return fallback[index % fallback.length];
    }

    final safeIndex = math.min(index, primary.length - 1);
    return primary[safeIndex];
  }
}
