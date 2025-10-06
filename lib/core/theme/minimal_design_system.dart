import 'package:flutter/material.dart';

/// Minimalist Design System - Tesla Inspired
/// Clean, simple, and functional design language
class MinimalDesignSystem {
  // Color Palette - Tesla Inspired
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color secondaryGray = Color(0xFF9CA3AF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFFE5E7EB);
  static const Color darkGray = Color(0xFF374151);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Additional colors for compatibility
  static const Color primaryColor = primaryBlack;
  static const Color baseColor = primaryWhite;
  static const Color softDark = darkGray;
  static const Color ultraDark = primaryBlack;
  static const Color lightShadow = lightGray;
  static const Color successColor = accentGreen;
  static const Color errorColor = accentRed;
  static const Color warningColor = Color(0xFFF59E0B);

  // Typography
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: primaryBlack,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryBlack,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryBlack,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryBlack,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryBlack,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: secondaryGray,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryWhite,
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Shadows - Minimal
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Additional shadows for compatibility
  static List<BoxShadow> get neumorphismOutsetShadow => cardShadow;
  static List<BoxShadow> get neumorphismInsetShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get neumorphismUltraOutsetShadow => cardShadow;
  static List<BoxShadow> get neumorphismHoverShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> get neumorphismFloatingShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get neumorphismPressedShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  static List<BoxShadow> get neumorphismDisabledShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  static List<BoxShadow> get neumorphismCinematicShadow => [
    BoxShadow(
      color: primaryBlack.withOpacity(0.25),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  // Animations - Subtle
  static const Duration fastTransition = Duration(milliseconds: 200);
  static const Duration normalTransition = Duration(milliseconds: 300);
  static const Duration slowTransition = Duration(milliseconds: 500);

  // Page Transitions
  static Route<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: normalTransition,
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryBlack,
    foregroundColor: primaryWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: buttonText,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: lightGray,
    foregroundColor: primaryBlack,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: buttonText.copyWith(color: primaryBlack),
  );

  // Card Style
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: cardShadow,
  );

  // Input Field Style
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: lightGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: const BorderSide(color: primaryBlack, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingM,
      vertical: spacingM,
    ),
  );
}
