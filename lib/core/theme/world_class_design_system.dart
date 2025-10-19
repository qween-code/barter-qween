import 'package:flutter/material.dart';

/// 🌟 WORLD-CLASS DESIGN SYSTEM
///
/// Inspired by:
/// - Apple Human Interface Guidelines
/// - Material Design 3
/// - Tesla UI/UX
/// - Modern E-commerce Apps (Alibaba, Temu, AliExpress)
///
/// Features:
/// - Consistent color palette
/// - Typography scale
/// - Spacing system
/// - Component standards
/// - Animation guidelines
class WorldClassDesignSystem {
  // ========================================
  // COLORS
  // ========================================

  // Primary Colors
  static const Color primaryColor = Color(0xFF2563EB); // Modern Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF10B981); // Success Green
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);

  // Accent Colors
  static const Color accentColor = Color(0xFFF59E0B); // Warning Orange
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFBBF24);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryBackground = Color(0xFFFAFAFA);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color tertiaryText = Color(0xFF9CA3AF);
  static const Color disabledText = Color(0xFFD1D5DB);

  // Border Colors
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);

  // ========================================
  // TYPOGRAPHY
  // ========================================

  // Font Family
  static const String fontFamily = 'Inter';

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.44,
  );

  static const TextStyle heading6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Aliases for compatibility
  static TextStyle get headingLarge => heading1.copyWith(color: primaryText);
  static TextStyle get headingMedium => heading3.copyWith(color: primaryText);
  static TextStyle get headingSmall => heading5.copyWith(color: primaryText);
  static TextStyle get headingXLarge =>
      displaySmall.copyWith(color: primaryText);
  static TextStyle get headingXXLarge =>
      displayMedium.copyWith(color: primaryText);

  // ========================================
  // SPACING
  // ========================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // ========================================
  // BORDER RADIUS
  // ========================================

  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Aliases for compatibility
  static double get radiusSmall => radiusS;
  static double get radiusMedium => radiusM;
  static double get radiusLarge => radiusL;

  // ========================================
  // ELEVATION & SHADOWS
  // ========================================

  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  static List<BoxShadow> get shadowXS => [
    BoxShadow(color: shadowLight, blurRadius: 2, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowS => [
    BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowM => [
    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get shadowL => [
    BoxShadow(color: shadowColor, blurRadius: 16, offset: const Offset(0, 8)),
  ];

  // Individual shadow properties for compatibility
  static BoxShadow get cardShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 8.0,
    offset: const Offset(0, 2),
  );

  static BoxShadow get subtleShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 4.0,
    offset: const Offset(0, 1),
  );

  static List<BoxShadow> get shadowXL => [
    BoxShadow(color: shadowDark, blurRadius: 24, offset: const Offset(0, 12)),
  ];

  // ========================================
  // ANIMATION DURATIONS
  // ========================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // ========================================
  // COMPONENT STYLES
  // ========================================

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: primaryWhite,
    elevation: elevationS,
    shadowColor: shadowColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    textStyle: labelLarge,
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    textStyle: labelLarge,
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    textStyle: labelLarge,
  );

  // Card Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: shadowS,
    border: Border.all(color: borderColor),
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: shadowM,
  );

  // Input Styles
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: secondaryBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusM),
      borderSide: const BorderSide(color: errorColor),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingM,
      vertical: spacingM,
    ),
  );

  // ========================================
  // BREAKPOINTS
  // ========================================

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ========================================
  // ICON SIZES
  // ========================================

  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // ========================================
  // APP BAR STYLES
  // ========================================

  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: surfaceColor,
    foregroundColor: primaryText,
    elevation: elevationS,
    shadowColor: shadowColor,
    titleTextStyle: heading6,
    centerTitle: false,
    titleSpacing: spacingM,
  );

  // ========================================
  // BOTTOM NAVIGATION STYLES
  // ========================================

  static BottomNavigationBarThemeData get bottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: elevationM,
        selectedLabelStyle: labelSmall,
        unselectedLabelStyle: labelSmall,
      );
}
