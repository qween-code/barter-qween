import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'neumorphism_standards.dart';

/// Pinterest Seviyesi Ultra Derin Typography Sistemi
/// 16+ katmanlı gölge efektleri ve dinamik ışık entegrasyonu

class UltraDeepTypography {
  UltraDeepTypography._();

  static const String _fontFamily = 'System';

  // ============================================
  // PINTEREST ULTRA DEEP DISPLAY STYLES
  // ============================================

  /// Pinterest Ultra Deep Display - 16 katmanlı gölge sistemi
  static TextStyle get pinterestUltraDeepDisplay => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 52,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    height: 1.0,
    color: AppColors.textPrimary,
    shadows: [
      // Ana derinlik katmanları
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 30,
        offset: Offset(-15, -15),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.9),
        blurRadius: 30,
        offset: Offset(15, 15),
      ),
      // İkinci derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.8),
        blurRadius: 50,
        offset: Offset(-20, -20),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.7),
        blurRadius: 50,
        offset: Offset(20, 20),
      ),
      // Üçüncü derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.6),
        blurRadius: 70,
        offset: Offset(-25, -25),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.5),
        blurRadius: 70,
        offset: Offset(25, 25),
      ),
      // Dördüncü derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.4),
        blurRadius: 90,
        offset: Offset(-30, -30),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.3),
        blurRadius: 90,
        offset: Offset(30, 30),
      ),
      // Beşinci derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.2),
        blurRadius: 110,
        offset: Offset(-35, -35),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.15),
        blurRadius: 110,
        offset: Offset(35, 35),
      ),
      // Altıncı derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.1),
        blurRadius: 130,
        offset: Offset(-40, -40),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.08),
        blurRadius: 130,
        offset: Offset(40, 40),
      ),
      // Yedinci derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.05),
        blurRadius: 150,
        offset: Offset(-45, -45),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.04),
        blurRadius: 150,
        offset: Offset(45, 45),
      ),
      // Sekizinci derinlik katmanı
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.02),
        blurRadius: 170,
        offset: Offset(-50, -50),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.02),
        blurRadius: 170,
        offset: Offset(50, 50),
      ),
    ],
  );

  /// Pinterest Ultra Deep Title - Card başlıkları için
  static TextStyle get pinterestUltraDeepTitle => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 15,
        offset: Offset(-8, -8),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.8),
        blurRadius: 15,
        offset: Offset(8, 8),
      ),
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.7),
        blurRadius: 25,
        offset: Offset(-12, -12),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.5),
        blurRadius: 25,
        offset: Offset(12, 12),
      ),
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.4),
        blurRadius: 35,
        offset: Offset(-16, -16),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.3),
        blurRadius: 35,
        offset: Offset(16, 16),
      ),
    ],
  );

  /// Pinterest Ultra Deep Body - Ana içerik için
  static TextStyle get pinterestUltraDeepBody => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.6,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.9),
        blurRadius: 8,
        offset: Offset(-4, -4),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.6),
        blurRadius: 8,
        offset: Offset(4, 4),
      ),
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.6),
        blurRadius: 12,
        offset: Offset(-6, -6),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.4),
        blurRadius: 12,
        offset: Offset(6, 6),
      ),
    ],
  );

  /// Pinterest Ultra Deep Button - Butonlar için
  static TextStyle get pinterestUltraDeepButton => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.1,
    color: AppColors.textOnPrimary,
    shadows: [
      Shadow(
        color: Color(0x00000000).withOpacity(0.8),
        blurRadius: 6,
        offset: Offset(3, 3),
      ),
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.9),
        blurRadius: 6,
        offset: Offset(-3, -3),
      ),
      Shadow(
        color: Color(0x00000000).withOpacity(0.5),
        blurRadius: 10,
        offset: Offset(5, 5),
      ),
      Shadow(
        color: Color(0xFFFFFFFF).withOpacity(0.7),
        blurRadius: 10,
        offset: Offset(-5, -5),
      ),
    ],
  );

  // ============================================
  // DINAMIK IŞIK KAYNAĞI TYPOGRAPHY
  // ============================================

  /// Dinamik Işık Kaynağı Typography - Gerçek zamanlı güncelleme
  static TextStyle createDynamicTypography({
    required TextStyle baseStyle,
    required BuildContext context,
    double intensity = 1.0,
  }) {
    final lightPosition = NeumorphismStandards.lightSystem.currentLightPosition;
    final lightIntensity = NeumorphismStandards.lightSystem.lightIntensity;

    return baseStyle.copyWith(
      shadows: [
        Shadow(
          color: const Color(0xFFFFFFFF).withOpacity(0.8 * lightIntensity * intensity),
          blurRadius: 12 * lightIntensity,
          offset: Offset(
            -lightPosition.dx * 8 * lightIntensity,
            -lightPosition.dy * 8 * lightIntensity,
          ),
        ),
        Shadow(
          color: const Color(0x00000000).withOpacity(0.5 * lightIntensity * intensity),
          blurRadius: 12 * lightIntensity,
          offset: Offset(
            lightPosition.dx * 8 * lightIntensity,
            lightPosition.dy * 8 * lightIntensity,
          ),
        ),
        Shadow(
          color: const Color(0xFFFFFFFF).withOpacity(0.4 * lightIntensity * intensity),
          blurRadius: 20 * lightIntensity,
          offset: Offset(
            -lightPosition.dx * 12 * lightIntensity,
            -lightPosition.dy * 12 * lightIntensity,
          ),
        ),
        Shadow(
          color: const Color(0x00000000).withOpacity(0.3 * lightIntensity * intensity),
          blurRadius: 20 * lightIntensity,
          offset: Offset(
            lightPosition.dx * 12 * lightIntensity,
            lightPosition.dy * 12 * lightIntensity,
          ),
        ),
      ],
    );
  }

  // ============================================
  // MORPHING TYPOGRAPHY
  // ============================================

  /// Morphing Typography - Geçiş animasyonları için
  static TextStyle createMorphingTypography({
    required TextStyle fromStyle,
    required TextStyle toStyle,
    required double morphValue,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fromStyle.fontSize! + (toStyle.fontSize! - fromStyle.fontSize!) * morphValue,
      fontWeight: FontWeight.lerp(fromStyle.fontWeight, toStyle.fontWeight, morphValue),
      letterSpacing: fromStyle.letterSpacing! + (toStyle.letterSpacing! - fromStyle.letterSpacing!) * morphValue,
      height: fromStyle.height! + (toStyle.height! - fromStyle.height!) * morphValue,
      color: Color.lerp(fromStyle.color, toStyle.color, morphValue),
      shadows: _morphShadows(fromStyle.shadows ?? [], toStyle.shadows ?? [], morphValue),
    );
  }

  /// Gölge morphing helper
  static List<Shadow> _morphShadows(List<Shadow> from, List<Shadow> to, double morphValue) {
    final List<Shadow> morphed = [];
    final maxLength = from.length > to.length ? from.length : to.length;

    for (int i = 0; i < maxLength; i++) {
      final fromShadow = i < from.length ? from[i] : from.last;
      final toShadow = i < to.length ? to[i] : to.last;

      morphed.add(Shadow(
        color: Color.lerp(fromShadow.color, toShadow.color, morphValue)!,
        offset: Offset.lerp(fromShadow.offset, toShadow.offset, morphValue)!,
        blurRadius: fromShadow.blurRadius + (toShadow.blurRadius - fromShadow.blurRadius) * morphValue,
      ));
    }

    return morphed;
  }

  // ============================================
  // 3D TYPOGRAPHY EFEKTLERI
  // ============================================

  /// 3D Typography Efekti - Derinlik simülasyonu
  static TextStyle create3DTypography({
    required TextStyle baseStyle,
    required double depth,
    double maxDepth = 20.0,
  }) {
    final depthRatio = (depth / maxDepth).clamp(0.0, 1.0);
    final List<Shadow> shadows = [];

    for (int i = 0; i < 8; i++) {
      final layerDepth = depthRatio * (8 - i) / 8;
      shadows.add(Shadow(
        color: const Color(0xFFFFFFFF).withOpacity(0.9 * layerDepth),
        blurRadius: 2 + i * 2.0,
        offset: Offset(-i * 1.5 * depthRatio, -i * 1.5 * depthRatio),
      ));
      shadows.add(Shadow(
        color: const Color(0x00000000).withOpacity(0.4 * layerDepth),
        blurRadius: 2 + i * 2.0,
        offset: Offset(i * 1.5 * depthRatio, i * 1.5 * depthRatio),
      ));
    }

    return baseStyle.copyWith(shadows: shadows);
  }

  // ============================================
  // ÖZEL EFEKT TYPOGRAPHY
  // ============================================

  /// Neon Glow Typography
  static TextStyle createNeonTypography({
    required TextStyle baseStyle,
    required Color neonColor,
    double intensity = 1.0,
  }) {
    return baseStyle.copyWith(
      shadows: [
        ...?baseStyle.shadows,
        Shadow(
          color: neonColor.withOpacity(0.8 * intensity),
          blurRadius: 15 * intensity,
          offset: Offset.zero,
        ),
        Shadow(
          color: neonColor.withOpacity(0.6 * intensity),
          blurRadius: 25 * intensity,
          offset: Offset.zero,
        ),
        Shadow(
          color: neonColor.withOpacity(0.4 * intensity),
          blurRadius: 35 * intensity,
          offset: Offset.zero,
        ),
      ],
    );
  }

  /// Holographic Typography
  static TextStyle createHolographicTypography({
    required TextStyle baseStyle,
    required double time,
    List<Color>? colors,
  }) {
    final List<Color> holographicColors = colors ?? [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
    ];

    final List<Shadow> holographicShadows = [];

    for (int i = 0; i < holographicColors.length; i++) {
      final double phase = (time + i * 0.2) % 1.0;
      final double intensity = (sin(phase * 2 * pi) + 1) * 0.5;

      holographicShadows.add(Shadow(
        color: holographicColors[i].withOpacity(0.4 * intensity),
        blurRadius: 12 + intensity * 8,
        offset: Offset(
          cos(phase * 2 * pi) * 8,
          sin(phase * 2 * pi) * 8,
        ),
      ));
    }

    return baseStyle.copyWith(shadows: holographicShadows);
  }

  /// Liquid Typography - Sıvı efekti
  static TextStyle createLiquidTypography({
    required TextStyle baseStyle,
    required double flowIntensity,
    Color? liquidColor,
  }) {
    final Color lc = liquidColor ?? Colors.blue;
    final List<Shadow> liquidShadows = [];

    for (int i = 0; i < 6; i++) {
      final double wave = sin(DateTime.now().millisecondsSinceEpoch * 0.003 + i * 0.5) * flowIntensity;
      liquidShadows.add(Shadow(
        color: lc.withOpacity(0.3 * flowIntensity),
        blurRadius: 8 + abs(wave) * 6,
        offset: Offset(
          wave * 6,
          cos(i * 0.8) * wave * 4,
        ),
      ));
    }

    return baseStyle.copyWith(shadows: liquidShadows);
  }

  /// Crystal Typography - Kristal efekti
  static TextStyle createCrystalTypography({
    required TextStyle baseStyle,
    required double clarity,
    Color? crystalColor,
  }) {
    final Color cc = crystalColor ?? Colors.white;
    final List<Shadow> crystalShadows = [];

    for (int i = 0; i < 10; i++) {
      final double facet = clarity * (1 - i * 0.09);
      final double angle = (i * 2 * pi) / 10;

      crystalShadows.add(Shadow(
        color: cc.withOpacity(0.5 * facet),
        blurRadius: 2 + i,
        offset: Offset(
          cos(angle) * i * 1.5,
          sin(angle) * i * 1.5,
        ),
      ));
    }

    return baseStyle.copyWith(shadows: crystalShadows);
  }
}