import 'package:flutter/material.dart';

/// Barter Qween Shadow System
/// Subtle, modern elevation with soft shadows
class AppShadows {
  AppShadows._();

  // ============================================
  // SHADOW DEFINITIONS
  // ============================================

  /// Small shadow - Subtle elevation (buttons, small cards)
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  /// Medium shadow - Standard elevation (cards, inputs)
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  /// Large shadow - High elevation (modals, bottom sheets)
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Extra large shadow - Maximum elevation (hero sections, overlays)
  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // COLORED SHADOWS - Special effects
  // ============================================

  /// Primary colored shadow - Brand emphasis
  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: const Color(0xFF006B7D).withOpacity(0.20),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Accent colored shadow - Call to action
  static List<BoxShadow> get shadowAccent => [
        BoxShadow(
          color: const Color(0xFFFF6B6B).withOpacity(0.20),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Success colored shadow - Positive feedback
  static List<BoxShadow> get shadowSuccess => [
        BoxShadow(
          color: const Color(0xFF51CF66).withOpacity(0.20),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // INNER SHADOWS (simulated with borders)
  // ============================================

  /// Inner shadow effect for pressed state
  static BoxDecoration get innerShadow => BoxDecoration(
        border: Border.all(
          color: const Color(0xFF000000).withOpacity(0.1),
          width: 1,
        ),
      );

  // ============================================
  // GLOW EFFECTS
  // ============================================

  /// Soft glow - Glassmorphism effect
  static List<BoxShadow> get glowSoft => [
        BoxShadow(
          color: const Color(0xFFFFFFFF).withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 0),
          spreadRadius: -5,
        ),
      ];

  /// Primary glow - Highlighted elements
  static List<BoxShadow> get glowPrimary => [
        BoxShadow(
          color: const Color(0xFF4A9BAA).withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 0),
          spreadRadius: 0,
        ),
      ];
}
