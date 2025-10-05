import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'neumorphism_standards.dart';
import 'app_colors.dart';

/// Ultra-Deep Neuromorphic Effects System
/// Pinterest-level atmospheric lighting, depth calculation, and shadow animation
class NeuromorphicEffects {
  NeuromorphicEffects._();

  /// Atmospheric Lighting - Ambient glow effects
  static AtmosphericLighting lighting = AtmosphericLighting();

  /// Depth Calculator - Dynamic depth based on context
  static DepthCalculator depth = DepthCalculator();

  /// Shadow Animator - Smooth shadow transitions
  static ShadowAnimator animator = ShadowAnimator();
}

/// Atmospheric Lighting System
/// Creates ambient glow and environmental lighting effects
class AtmosphericLighting {
  /// Creates atmospheric glow around elements
  List<BoxShadow> createAmbientGlow({
    required Color glowColor,
    double intensity = 1.0,
    double radius = 30.0,
  }) {
    return [
      BoxShadow(
        color: glowColor.withOpacity(0.4 * intensity),
        offset: Offset.zero,
        blurRadius: radius,
        spreadRadius: radius * 0.3,
      ),
      BoxShadow(
        color: glowColor.withOpacity(0.2 * intensity),
        offset: Offset.zero,
        blurRadius: radius * 1.5,
        spreadRadius: radius * 0.5,
      ),
      BoxShadow(
        color: glowColor.withOpacity(0.1 * intensity),
        offset: Offset.zero,
        blurRadius: radius * 2,
        spreadRadius: radius * 0.7,
      ),
    ];
  }

  /// Creates volumetric lighting effect
  List<BoxShadow> createVolumetricLight({
    required Offset lightDirection,
    double intensity = 1.0,
    Color? lightColor,
  }) {
    final color = lightColor ?? AppColors.primary;
    final shadows = <BoxShadow>[];

    for (int i = 0; i < 6; i++) {
      final layerIntensity = (6 - i) / 6 * intensity;
      final offset = lightDirection * (i * 2.0);

      shadows.add(BoxShadow(
        color: color.withOpacity(0.15 * layerIntensity),
        offset: offset,
        blurRadius: 10.0 + i * 5.0,
        spreadRadius: -2.0,
      ));
    }

    return shadows;
  }

  /// Creates soft inner glow (for borders)
  BoxShadow createInnerGlow({
    Color? color,
    double intensity = 0.5,
  }) {
    return BoxShadow(
      color: (color ?? Colors.white).withOpacity(intensity),
      offset: const Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    );
  }

  /// Creates rim lighting effect
  List<BoxShadow> createRimLight({
    required double angle,
    double intensity = 1.0,
    Color? lightColor,
  }) {
    final color = lightColor ?? Colors.white;
    final radians = angle * (math.pi / 180);
    final offsetX = math.cos(radians) * 8;
    final offsetY = math.sin(radians) * 8;

    return [
      BoxShadow(
        color: color.withOpacity(0.8 * intensity),
        offset: Offset(offsetX, offsetY),
        blurRadius: 12,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: color.withOpacity(0.4 * intensity),
        offset: Offset(offsetX * 1.5, offsetY * 1.5),
        blurRadius: 20,
        spreadRadius: -6,
      ),
    ];
  }

  /// Creates subsurface scattering effect
  List<BoxShadow> createSubsurfaceScattering({
    required Color surfaceColor,
    double thickness = 1.0,
    double intensity = 1.0,
  }) {
    return [
      BoxShadow(
        color: surfaceColor.withOpacity(0.3 * intensity),
        offset: const Offset(0, 2),
        blurRadius: 8 * thickness,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: surfaceColor.withOpacity(0.15 * intensity),
        offset: const Offset(0, 4),
        blurRadius: 16 * thickness,
        spreadRadius: -4,
      ),
    ];
  }
}

/// Depth Calculator System
/// Calculates dynamic depth values based on various contexts
class DepthCalculator {
  /// Calculate depth based on scroll position
  double calculateScrollDepth({
    required double scrollOffset,
    double baseDepth = 1.0,
    double maxDepth = 5.0,
    double sensitivity = 0.001,
  }) {
    final depth = baseDepth + (scrollOffset * sensitivity);
    return depth.clamp(baseDepth, maxDepth);
  }

  /// Calculate depth based on element hierarchy
  double calculateHierarchyDepth({
    required int level,
    double baseDepth = 1.0,
    double increment = 0.5,
  }) {
    return baseDepth + (level * increment);
  }

  /// Calculate depth based on importance
  double calculateImportanceDepth({
    required double importance,
    double minDepth = 1.0,
    double maxDepth = 5.0,
  }) {
    return minDepth + (importance * (maxDepth - minDepth));
  }

  /// Calculate parallax offset based on scroll
  Offset calculateParallaxOffset({
    required double scrollOffset,
    required double depth,
    double factor = 0.1,
  }) {
    final parallaxAmount = scrollOffset * factor * depth;
    return Offset(0, parallaxAmount);
  }

  /// Get depth tier level
  int getDepthTier(double depth) {
    if (depth <= 1.5) return 1; // Shallow
    if (depth <= 2.5) return 2; // Medium
    if (depth <= 3.5) return 3; // Deep
    if (depth <= 4.5) return 4; // Ultra
    if (depth <= 5.5) return 5; // Cinematic
    return 6; // Mega
  }

  /// Calculate optimal shadow count for depth
  int calculateOptimalShadowCount(double depth) {
    final tier = getDepthTier(depth);
    switch (tier) {
      case 1:
        return 4; // Shallow: 4 shadows
      case 2:
        return 8; // Medium: 8 shadows
      case 3:
        return 12; // Deep: 12 shadows
      case 4:
        return 16; // Ultra: 16 shadows
      case 5:
        return 20; // Cinematic: 20 shadows
      case 6:
        return 24; // Mega: 24 shadows
      default:
        return 8;
    }
  }

  /// Create depth-aware shadow system
  List<BoxShadow> createDepthAwareShadows({
    required double depth,
    bool isPressed = false,
    bool isHovered = false,
    Color? lightColor,
    Color? darkColor,
  }) {
    final shadowCount = calculateOptimalShadowCount(depth);
    final shadows = <BoxShadow>[];

    final light = lightColor ?? Colors.white;
    final dark = darkColor ?? Colors.black;

    // Pressed state: inset effect
    if (isPressed) {
      depth *= 0.5;
    }

    // Hovered state: increased depth
    if (isHovered) {
      depth *= 1.3;
    }

    for (int i = 0; i < shadowCount ~/ 2; i++) {
      final layerIntensity = (shadowCount ~/ 2 - i) / (shadowCount ~/ 2);
      final offset = 4.0 + (i * 4.0 * depth);
      final blur = 8.0 + (i * 4.0);
      final spread = -blur * 0.25;

      // Light shadow
      shadows.add(BoxShadow(
        color: light.withOpacity(0.95 * layerIntensity),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
        spreadRadius: spread,
      ));

      // Dark shadow
      shadows.add(BoxShadow(
        color: dark.withOpacity(0.15 + (0.15 * layerIntensity)),
        offset: Offset(offset, offset),
        blurRadius: blur,
        spreadRadius: spread,
      ));
    }

    return shadows;
  }
}

/// Shadow Animator System
/// Provides smooth shadow transitions and animations
class ShadowAnimator {
  /// Interpolate between two shadow lists
  List<BoxShadow> lerpShadows({
    required List<BoxShadow> from,
    required List<BoxShadow> to,
    required double t,
  }) {
    final maxLength = math.max(from.length, to.length);
    final result = <BoxShadow>[];

    for (int i = 0; i < maxLength; i++) {
      final fromShadow = i < from.length ? from[i] : to[i];
      final toShadow = i < to.length ? to[i] : from[i];

      result.add(BoxShadow(
        color: Color.lerp(fromShadow.color, toShadow.color, t)!,
        offset: Offset.lerp(fromShadow.offset, toShadow.offset, t)!,
        blurRadius: _lerpDouble(fromShadow.blurRadius, toShadow.blurRadius, t),
        spreadRadius:
            _lerpDouble(fromShadow.spreadRadius, toShadow.spreadRadius, t),
      ));
    }

    return result;
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Create breathing animation shadows
  List<BoxShadow> createBreathingShadows({
    required List<BoxShadow> baseShadows,
    required double animationValue,
    double intensity = 0.2,
  }) {
    final breathe = math.sin(animationValue * 2 * math.pi) * intensity;
    return baseShadows.map((shadow) {
      return BoxShadow(
        color: shadow.color
            .withOpacity(shadow.color.opacity * (1.0 + breathe).clamp(0.0, 1.0)),
        offset: shadow.offset * (1.0 + breathe),
        blurRadius: shadow.blurRadius * (1.0 + breathe),
        spreadRadius: shadow.spreadRadius * (1.0 + breathe),
      );
    }).toList();
  }

  /// Create pulsing animation shadows
  List<BoxShadow> createPulsingShadows({
    required List<BoxShadow> baseShadows,
    required double animationValue,
    double pulseIntensity = 0.3,
  }) {
    final pulse = ((math.sin(animationValue * 4 * math.pi) + 1) / 2) * pulseIntensity;
    return baseShadows.map((shadow) {
      return BoxShadow(
        color: shadow.color.withOpacity(
            (shadow.color.opacity + pulse).clamp(0.0, 1.0)),
        offset: shadow.offset,
        blurRadius: shadow.blurRadius * (1.0 + pulse * 0.5),
        spreadRadius: shadow.spreadRadius * (1.0 + pulse * 0.5),
      );
    }).toList();
  }

  /// Create wave animation shadows
  List<BoxShadow> createWaveShadows({
    required List<BoxShadow> baseShadows,
    required double animationValue,
    double waveAmplitude = 5.0,
  }) {
    return baseShadows.asMap().entries.map((entry) {
      final index = entry.key;
      final shadow = entry.value;
      final phase = animationValue * 2 * math.pi + (index * 0.3);
      final wave = math.sin(phase) * waveAmplitude;

      return BoxShadow(
        color: shadow.color,
        offset: shadow.offset + Offset(wave, wave),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();
  }

  /// Create shimmer effect for shadows
  List<BoxShadow> createShimmerShadows({
    required List<BoxShadow> baseShadows,
    required double animationValue,
    Color? shimmerColor,
  }) {
    final shimmer = shimmerColor ?? Colors.white;
    final shimmerIntensity = ((math.sin(animationValue * 6 * math.pi) + 1) / 2);

    return [
      ...baseShadows,
      BoxShadow(
        color: shimmer.withOpacity(0.4 * shimmerIntensity),
        offset: Offset(
          math.cos(animationValue * 2 * math.pi) * 10,
          math.sin(animationValue * 2 * math.pi) * 10,
        ),
        blurRadius: 20 + shimmerIntensity * 10,
        spreadRadius: -5,
      ),
    ];
  }

  /// Create morphing animation between two shadow sets
  List<BoxShadow> createMorphingShadows({
    required List<BoxShadow> stateShadows,
    required List<BoxShadow> targetShadows,
    required double progress,
    Curve curve = Curves.easeInOutCubic,
  }) {
    final t = curve.transform(progress);
    return lerpShadows(
      from: stateShadows,
      to: targetShadows,
      t: t,
    );
  }
}

/// Neuromorphic Presets
/// Pre-configured shadow combinations for common use cases
class NeuromorphicPresets {
  /// Button presets
  static class ButtonPresets {
    /// Primary button - 12 layer ultra-deep
    static List<BoxShadow> primary({
      bool isPressed = false,
      bool isHovered = false,
    }) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isPressed ? 1.5 : (isHovered ? 3.5 : 3.0),
        isPressed: isPressed,
        isHovered: isHovered,
      );
    }

    /// Secondary button - 8 layer medium
    static List<BoxShadow> secondary({
      bool isPressed = false,
      bool isHovered = false,
    }) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isPressed ? 1.0 : (isHovered ? 2.5 : 2.0),
        isPressed: isPressed,
        isHovered: isHovered,
      );
    }

    /// Icon button - 6 layer soft
    static List<BoxShadow> icon({
      bool isPressed = false,
      bool isHovered = false,
    }) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isPressed ? 0.8 : (isHovered ? 2.0 : 1.5),
        isPressed: isPressed,
        isHovered: isHovered,
      );
    }

    /// Floating action button - 16 layer floating
    static List<BoxShadow> fab({bool isPressed = false}) {
      return [
        ...NeuromorphicEffects.depth.createDepthAwareShadows(
          depth: isPressed ? 3.0 : 4.5,
          isPressed: isPressed,
        ),
        ...NeuromorphicEffects.lighting.createAmbientGlow(
          glowColor: AppColors.primary,
          intensity: 0.6,
          radius: 25.0,
        ),
      ];
    }
  }

  /// Card presets
  static class CardPresets {
    /// Standard card - 12 layer
    static List<BoxShadow> standard({bool isHovered = false}) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isHovered ? 3.5 : 3.0,
        isHovered: isHovered,
      );
    }

    /// Hero card - 16 layer cinematic
    static List<BoxShadow> hero({bool isHovered = false}) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isHovered ? 5.5 : 5.0,
        isHovered: isHovered,
      );
    }

    /// Product card - 14 layer premium
    static List<BoxShadow> product({bool isHovered = false}) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isHovered ? 4.0 : 3.5,
        isHovered: isHovered,
      );
    }

    /// Floating card - 10 layer elevated
    static List<BoxShadow> floating() {
      return [
        ...NeuromorphicEffects.depth.createDepthAwareShadows(depth: 2.5),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];
    }
  }

  /// Input presets
  static class InputPresets {
    /// Text field - 8 layer inset
    static List<BoxShadow> textField({bool isFocused = false}) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(isFocused ? 0.15 : 0.1),
          offset: const Offset(2, 2),
          blurRadius: 8,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isFocused ? 0.1 : 0.05),
          offset: const Offset(4, 4),
          blurRadius: 12,
          spreadRadius: -3,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(isFocused ? 0.9 : 0.7),
          offset: const Offset(-2, -2),
          blurRadius: 8,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(isFocused ? 0.7 : 0.5),
          offset: const Offset(-4, -4),
          blurRadius: 12,
          spreadRadius: -3,
        ),
        if (isFocused)
          ...NeuromorphicEffects.lighting.createAmbientGlow(
            glowColor: AppColors.primary,
            intensity: 0.4,
            radius: 15.0,
          ),
      ];
    }

    /// Search bar - 10 layer embedded
    static List<BoxShadow> searchBar({bool isFocused = false}) {
      return [
        ...InputPresets.textField(isFocused: isFocused),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(6, 6),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ];
    }
  }

  /// Navigation presets
  static class NavigationPresets {
    /// Bottom navigation - 16 layer floating
    static List<BoxShadow> bottomNav() {
      return [
        ...NeuromorphicEffects.depth.createDepthAwareShadows(depth: 4.0),
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, -4),
          blurRadius: 24,
          spreadRadius: -6,
        ),
      ];
    }

    /// App bar - 12 layer elevated
    static List<BoxShadow> appBar() {
      return [
        ...NeuromorphicEffects.depth.createDepthAwareShadows(depth: 3.0),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ];
    }

    /// Tab bar - 8 layer subtle
    static List<BoxShadow> tabBar() {
      return NeuromorphicEffects.depth.createDepthAwareShadows(depth: 2.0);
    }
  }

  /// Icon presets
  static class IconPresets {
    /// Standard icon - 4 layer
    static List<BoxShadow> standard({bool isActive = false}) {
      return NeuromorphicEffects.depth.createDepthAwareShadows(
        depth: isActive ? 1.8 : 1.2,
        isHovered: isActive,
      );
    }

    /// Circular icon - 6 layer with glow
    static List<BoxShadow> circular({
      bool isActive = false,
      Color? glowColor,
    }) {
      return [
        ...NeuromorphicEffects.depth.createDepthAwareShadows(
          depth: isActive ? 2.0 : 1.5,
          isHovered: isActive,
        ),
        if (isActive)
          ...NeuromorphicEffects.lighting.createAmbientGlow(
            glowColor: glowColor ?? AppColors.primary,
            intensity: 0.5,
            radius: 20.0,
          ),
      ];
    }
  }
}
