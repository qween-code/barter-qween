import 'dart:math';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ultra Advanced Neumorphism Typography System
/// Pinterest seviyesi gölge efektli ve derinlikli yazı stilleri

class AppTextStyles {
  AppTextStyles._();

  // Base font family - system default
  static const String _fontFamily = 'System';

  // ============================================
  // DISPLAY STYLES - Hero sections, major titles
  // ============================================

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ============================================
  // ULTRA NEUROMORPHISM DISPLAY STYLES
  // ============================================

  /// Ultra derinlikli display large - Çok katmanlı gölge efekti
  static TextStyle get ultraDisplayLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 20, offset: Offset(-8, -8)),
      Shadow(color: Color(0x00000000), blurRadius: 20, offset: Offset(8, 8)),
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 40,
        offset: Offset(-12, -12),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 40, offset: Offset(12, 12)),
    ],
  );

  /// Sinematik display medium - Hero section için
  static TextStyle get cinematicDisplayMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 25,
        offset: Offset(-10, -10),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 25, offset: Offset(10, 10)),
      Shadow(color: AppColors.primary, blurRadius: 30, offset: Offset(0, 0)),
    ],
  );

  /// Yüzen display small - Navigasyon başlıkları için
  static TextStyle get floatingDisplaySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 30,
        offset: Offset(-12, -12),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 30, offset: Offset(12, 12)),
      Shadow(color: AppColors.secondary, blurRadius: 40, offset: Offset(0, -5)),
    ],
  );

  // ============================================
  // HEADLINE STYLES - Page titles, section headers
  // ============================================

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ============================================
  // ULTRA NEUROMORPHISM HEADLINE STYLES
  // ============================================

  /// Ultra headline large - Derin gölge efekti
  static TextStyle get ultraHeadlineLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 15, offset: Offset(-6, -6)),
      Shadow(color: Color(0x00000000), blurRadius: 15, offset: Offset(6, 6)),
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 30,
        offset: Offset(-10, -10),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 30, offset: Offset(10, 10)),
    ],
  );

  /// Hover headline medium - İnteraktif başlık
  static TextStyle get hoverHeadlineMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 20, offset: Offset(-8, -8)),
      Shadow(color: Color(0x00000000), blurRadius: 20, offset: Offset(8, 8)),
      Shadow(color: AppColors.primary, blurRadius: 25, offset: Offset(0, 0)),
    ],
  );

  // ============================================
  // TITLE STYLES - Card titles, list items
  // ============================================

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Legacy h6 style for backward compatibility
  static const TextStyle h6 = titleSmall;

  // ============================================
  // ULTRA NEUROMORPHISM TITLE STYLES
  // ============================================

  /// Ultra title large - Card başlıkları için derinlik
  static TextStyle get ultraTitleLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.3,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 12, offset: Offset(-4, -4)),
      Shadow(color: Color(0x00000000), blurRadius: 12, offset: Offset(4, 4)),
    ],
  );

  /// Gömülü title medium - Search bar ve input'lar için
  static TextStyle get embeddedTitleMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0x00000000), blurRadius: 8, offset: Offset(2, 2)),
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 8, offset: Offset(-2, -2)),
    ],
  );

  // ============================================
  // BODY STYLES - Regular content, descriptions
  // ============================================

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ============================================
  // ULTRA NEUROMORPHISM BODY STYLES
  // ============================================

  /// Ultra body large - Ana içerik için derinlik
  static TextStyle get ultraBodyLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.6,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 10, offset: Offset(-3, -3)),
      Shadow(color: Color(0x00000000), blurRadius: 10, offset: Offset(3, 3)),
    ],
  );

  /// İçbükey body medium - Gömülü içerik için
  static TextStyle get insetBodyMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0x00000000), blurRadius: 6, offset: Offset(2, 2)),
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 6, offset: Offset(-2, -2)),
    ],
  );

  // ============================================
  // LABEL STYLES - Buttons, chips, badges
  // ============================================

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // ============================================
  // ULTRA NEUROMORPHISM LABEL STYLES
  // ============================================

  /// Ultra label large - Butonlar için derinlikli
  static TextStyle get ultraLabelLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.1,
    color: AppColors.textOnPrimary,
    shadows: [
      Shadow(color: Color(0x00000000), blurRadius: 8, offset: Offset(2, 2)),
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 8, offset: Offset(-2, -2)),
    ],
  );

  /// Hover label medium - İnteraktif etiketler
  static TextStyle get hoverLabelMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 15, offset: Offset(-5, -5)),
      Shadow(color: Color(0x00000000), blurRadius: 15, offset: Offset(5, 5)),
      Shadow(color: AppColors.primary, blurRadius: 20, offset: Offset(0, 0)),
    ],
  );

  // ============================================
  // SPECIALIZED STYLES - Context-specific
  // ============================================

  /// Button text style - Primary buttons
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  /// Button text style - Secondary buttons
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.primary,
  );

  /// Input field label style
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Input field text style
  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Caption text - Helper text, timestamps
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// Overline - Labels above content
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  /// Price text - Emphasis on pricing
  static const TextStyle priceText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.primary,
  );

  /// Link text style
  static const TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.primary,
    decoration: TextDecoration.none,
  );

  // ============================================
  // ULTRA NEUROMORPHISM SPECIALIZED STYLES
  // ============================================

  /// Ultra button large - Çok katmanlı buton yazısı
  static TextStyle get ultraButtonLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.1,
    color: AppColors.textOnPrimary,
    shadows: [
      Shadow(color: Color(0x00000000), blurRadius: 6, offset: Offset(2, 2)),
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 6, offset: Offset(-2, -2)),
    ],
  );

  /// Sinematik price text - Hero section fiyatları için
  static TextStyle get cinematicPriceText => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.1,
    color: AppColors.primary,
    shadows: [
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 20, offset: Offset(-8, -8)),
      Shadow(color: Color(0x00000000), blurRadius: 20, offset: Offset(8, 8)),
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 40,
        offset: Offset(-12, -12),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 40, offset: Offset(12, 12)),
    ],
  );

  /// Yüzen link text - Navigasyon linkleri için
  static TextStyle get floatingLinkText => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
    color: AppColors.primary,
    decoration: TextDecoration.none,
    shadows: [
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 25,
        offset: Offset(-10, -10),
      ),
      Shadow(color: Color(0x00000000), blurRadius: 25, offset: Offset(10, 10)),
      Shadow(color: AppColors.secondary, blurRadius: 30, offset: Offset(0, -5)),
    ],
  );

  /// Gömülü input text - Search bar için
  static TextStyle get embeddedInputText => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0x00000000), blurRadius: 4, offset: Offset(1, 1)),
      Shadow(color: Color(0xFFFFFFFF), blurRadius: 4, offset: Offset(-1, -1)),
    ],
  );

  // ============================================
  // DYNAMIC TEXT STYLES - Context-aware
  // ============================================

  /// Dinamik boyutlu text style
  static TextStyle dynamicSize({
    required double baseSize,
    required BuildContext context,
    double scaleFactor = 1.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = baseSize * (screenWidth / 375) * scaleFactor;

    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: responsiveSize,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      shadows: [
        Shadow(
          color: const Color(0xFFFFFFFF).withOpacity(0.8),
          blurRadius: responsiveSize * 0.3,
          offset: Offset(-responsiveSize * 0.1, -responsiveSize * 0.1),
        ),
        Shadow(
          color: const Color(0x00000000).withOpacity(0.6),
          blurRadius: responsiveSize * 0.3,
          offset: Offset(responsiveSize * 0.1, responsiveSize * 0.1),
        ),
      ],
    );
  }

  /// Zaman tabanlı animasyonlu text style
  static TextStyle animatedTimeBased({
    required TextStyle baseStyle,
    required Duration time,
  }) {
    final intensity = 0.5 + (sin(time.inMilliseconds / 1000) * 0.3);

    return baseStyle.copyWith(
      shadows: [
        Shadow(
          color: const Color(0xFFFFFFFF).withOpacity(intensity),
          blurRadius: 15 * intensity,
          offset: Offset(-6 * intensity, -6 * intensity),
        ),
        Shadow(
          color: const Color(0x00000000).withOpacity(intensity * 0.8),
          blurRadius: 15 * intensity,
          offset: Offset(6 * intensity, 6 * intensity),
        ),
      ],
    );
  }

  // ============================================
  // COLOR VARIANTS - Quick color overrides
  // ============================================

  static TextStyle withPrimaryColor(TextStyle style) =>
      style.copyWith(color: AppColors.primary);

  static TextStyle withSecondaryColor(TextStyle style) =>
      style.copyWith(color: AppColors.textSecondary);

  static TextStyle withAccentColor(TextStyle style) =>
      style.copyWith(color: AppColors.accent);

  static TextStyle withWhiteColor(TextStyle style) =>
      style.copyWith(color: AppColors.textOnPrimary);

  static TextStyle withErrorColor(TextStyle style) =>
      style.copyWith(color: AppColors.error);

  // ============================================
  // ULTRA NEUROMORPHISM COLOR VARIANTS
  // ============================================

  /// Ultra primary color variant - Derinlikli primary renk
  static TextStyle withUltraPrimaryColor(TextStyle style) => style.copyWith(
    color: AppColors.primary,
    shadows: [
      Shadow(
        color: const Color(0xFFFFFFFF).withOpacity(0.8),
        blurRadius: 12,
        offset: const Offset(-4, -4),
      ),
      Shadow(
        color: const Color(0x00000000).withOpacity(0.6),
        blurRadius: 12,
        offset: const Offset(4, 4),
      ),
    ],
  );

  /// Hover color variant - İnteraktif renk değişimi
  static TextStyle withHoverColor(TextStyle style) => style.copyWith(
    color: AppColors.primary,
    shadows: [
      Shadow(
        color: const Color(0xFFFFFFFF).withOpacity(0.9),
        blurRadius: 20,
        offset: const Offset(-8, -8),
      ),
      Shadow(
        color: const Color(0x00000000).withOpacity(0.8),
        blurRadius: 20,
        offset: const Offset(8, 8),
      ),
      Shadow(
        color: AppColors.primary.withOpacity(0.4),
        blurRadius: 25,
        offset: const Offset(0, 0),
      ),
    ],
  );

  /// Yüzen color variant - Navigasyon için
  static TextStyle withFloatingColor(TextStyle style) => style.copyWith(
    color: AppColors.primary,
    shadows: [
      Shadow(
        color: const Color(0xFFFFFFFF).withOpacity(0.95),
        blurRadius: 30,
        offset: const Offset(-12, -12),
      ),
      Shadow(
        color: const Color(0x00000000).withOpacity(0.9),
        blurRadius: 30,
        offset: const Offset(12, 12),
      ),
      Shadow(
        color: AppColors.secondary.withOpacity(0.3),
        blurRadius: 40,
        offset: const Offset(0, -5),
      ),
    ],
  );

  /// Sinematik color variant - Hero section için
  static TextStyle withCinematicColor(TextStyle style) => style.copyWith(
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: const Color(0xFFFFFFFF).withOpacity(0.9),
        blurRadius: 25,
        offset: const Offset(-10, -10),
      ),
      Shadow(
        color: const Color(0x00000000).withOpacity(0.8),
        blurRadius: 25,
        offset: const Offset(10, 10),
      ),
      Shadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 35,
        offset: const Offset(0, 0),
      ),
    ],
  );
}
