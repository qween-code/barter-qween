import 'package:flutter/material.dart';

/// Barter Qween Color Palette
/// Premium marketplace design system colors
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS - Deep Teal (Trust, Premium)
  // ============================================
  static const Color primary = Color(0xFF006B7D);
  static const Color primaryLight = Color(0xFF4A9BAA);
  static const Color primaryDark = Color(0xFF004853);
  
  // ============================================
  // ACCENT COLORS - Coral (Energy, Exchange)
  // ============================================
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9494);
  static const Color accentDark = Color(0xFFCC5555);
  
  // ============================================
  // NEUTRAL PALETTE - Backgrounds & Surfaces
  // ============================================
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  
  // ============================================
  // TEXT COLORS - Hierarchy
  // ============================================
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textDisabled = Color(0xFFCED4DA);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  
  // ============================================
  // SEMANTIC COLORS - Status & Feedback
  // ============================================
  static const Color success = Color(0xFF51CF66);
  static const Color successLight = Color(0xFF8CE99A);
  static const Color successDark = Color(0xFF37B24D);
  
  static const Color warning = Color(0xFFFFD43B);
  static const Color warningLight = Color(0xFFFFE066);
  static const Color warningDark = Color(0xFFFAB005);
  
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF9494);
  static const Color errorDark = Color(0xFFFA5252);
  
  static const Color info = Color(0xFF4DABF7);
  static const Color infoLight = Color(0xFF74C0FC);
  static const Color infoDark = Color(0xFF339AF0);
  
  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDefault = Color(0xFFDEE2E6);
  static const Color borderDark = Color(0xFFCED4DA);
  
  // ============================================
  // OVERLAY COLORS
  // ============================================
  static Color overlay = const Color(0xFF000000).withOpacity(0.5);
  static Color overlayLight = const Color(0xFF000000).withOpacity(0.3);
  static Color overlayHeavy = const Color(0xFF000000).withOpacity(0.7);
  
  // ============================================
  // GRADIENTS - Premium Effects
  // ============================================
  
  /// Primary gradient - Deep teal to light teal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient - Coral energy
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient - Green growth
  static const LinearGradient successGradient = LinearGradient(
    colors: [successDark, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Glass gradient - Glassmorphism effect
  static LinearGradient get glassGradient => LinearGradient(
    colors: [
      surface.withOpacity(0.8),
      surface.withOpacity(0.4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Shimmer gradient - Loading effect
  static LinearGradient get shimmerGradient => LinearGradient(
    colors: [
      surfaceVariant,
      surface,
      surfaceVariant,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Background gradient - Subtle premium feel
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============================================
  // SHADOW COLORS
  // ============================================
  static Color get shadowColor => const Color(0xFF000000).withOpacity(0.08);
  static Color get shadowColorLight => const Color(0xFF000000).withOpacity(0.04);
  static Color get shadowColorDark => const Color(0xFF000000).withOpacity(0.12);
}
