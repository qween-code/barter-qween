import 'package:flutter/material.dart';

/// Nöromorfik tasarım standartları ve sabitleri
/// Pinterest seviyesi ultra derin nöromorfik efektler için gelişmiş sistem
class NeumorphismStandards {
  // Temel nöromorfik renkler
  static const Color lightSource = Color(0xFFFFFFFF);
  static const Color darkSource = Color(0xFF3A3A3A);
  static const Color baseColor = Color(0xFFE0E5EC);

  // Gelişmiş renk paleti
  static const Color ultraLight = Color(0xFFFFFFFF);
  static const Color extraLight = Color(0xFFF8F9FA);
  static const Color softLight = Color(0xFFF1F3F4);
  static const Color mediumLight = Color(0xFFE8EAED);
  static const Color neutral = Color(0xFFE0E5EC);
  static const Color mediumDark = Color(0xFFD1D5DB);
  static const Color softDark = Color(0xFF9CA3AF);
  static const Color extraDark = Color(0xFF6B7280);
  static const Color ultraDark = Color(0xFF374151);

  /// Dinamik Işık Kaynağı Sistemi
  /// Pinterest seviyesi gerçek zamanlı ışık hesaplaması
  static final DynamicLightSystem lightSystem = DynamicLightSystem();

  /// Standart nöromorfik gölge (outset)
  static List<BoxShadow> get neumorphismOutsetShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.2),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Standart nöromorfik gölge (inset)
  static List<BoxShadow> get neumorphismInsetShadow => [
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.2),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Yumuşak nöromorfik gölge
  static List<BoxShadow> get neumorphismSoftShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.15),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Derin nöromorfik gölge
  static List<BoxShadow> get neumorphismDeepShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-12, -12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.25),
      offset: const Offset(12, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Ultra derinlikli nöromorfik gölge (Pinterest seviyesi)
  static List<BoxShadow> get neumorphismUltraOutsetShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      blurRadius: 20,
      offset: const Offset(-8, -8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.8),
      blurRadius: 20,
      offset: const Offset(8, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.6),
      blurRadius: 40,
      offset: const Offset(-12, -12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.4),
      blurRadius: 40,
      offset: const Offset(12, 12),
      spreadRadius: 0,
    ),
  ];

  /// Çok katmanlı ultra derinlikli gölge sistemi (16 katman)
  static List<BoxShadow> get neumorphismUltraDeepShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-20, -20),
      blurRadius: 40,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.8),
      offset: const Offset(20, 20),
      blurRadius: 40,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      offset: const Offset(-16, -16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.6),
      offset: const Offset(16, 16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      offset: const Offset(-12, -12),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.45),
      offset: const Offset(12, 12),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      offset: const Offset(-10, -10),
      blurRadius: 20,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.35),
      offset: const Offset(10, 10),
      blurRadius: 20,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.3),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.25),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      offset: const Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.2),
      offset: const Offset(4, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.7),
      offset: const Offset(-2, -2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.1),
      offset: const Offset(2, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  /// Ultra derin inset gölge sistemi
  static List<BoxShadow> get neumorphismUltraInsetShadow => [
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.8),
      offset: const Offset(20, 20),
      blurRadius: 40,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-20, -20),
      blurRadius: 40,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.6),
      offset: const Offset(16, 16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      offset: const Offset(-16, -16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.45),
      offset: const Offset(12, 12),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      offset: const Offset(-12, -12),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.35),
      offset: const Offset(10, 10),
      blurRadius: 20,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      offset: const Offset(-10, -10),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  /// Yüzen nöromorfik gölge (floating effect)
  static List<BoxShadow> get neumorphismFloatingShadow => [
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.3),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.15),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      offset: const Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Hover durumunda nöromorfik gölge
  static List<BoxShadow> get neumorphismHoverShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-10, -10),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.25),
      offset: const Offset(10, 10),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.7),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.15),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Basılı durum (pressed) nöromorfik gölge
  static List<BoxShadow> get neumorphismPressedShadow => [
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.3),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Focus durumunda nöromorfik gölge
  static List<BoxShadow> get neumorphismFocusShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.2),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.blue.withOpacity(0.3),
      offset: const Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  ];

  /// Pasif durum (disabled) nöromorfik gölge
  static List<BoxShadow> get neumorphismDisabledShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      offset: const Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      offset: const Offset(4, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Glassmorphism + Neumorphism kombinasyonu
  static List<BoxShadow> get neumorphismGlassShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.5),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x00000000).withOpacity(0.2),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.1),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Border radius standartları
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;
  static const double extraLargeRadius = 32.0;
  static const double ultraLargeRadius = 48.0;

  /// Spacing standartları
  static const double xsSpacing = 4.0;
  static const double smSpacing = 8.0;
  static const double mdSpacing = 16.0;
  static const double lgSpacing = 24.0;
  static const double xlSpacing = 32.0;
  static const double xxlSpacing = 48.0;
  static const double ultraSpacing = 64.0;

  /// Animasyon süreleri
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);
  static const Duration ultraSlowAnimation = Duration(milliseconds: 600);

  /// Nöromorfik dekorasyonlar
  static BoxDecoration getNeumorphismDecoration({
    List<BoxShadow>? shadows,
    Color? color,
    double borderRadius = mediumRadius,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? neumorphismOutsetShadow,
      gradient: gradient,
    );
  }

  /// İçbükey nöromorfik dekorasyon
  static BoxDecoration getNeumorphismInsetDecoration({
    List<BoxShadow>? shadows,
    Color? color,
    double borderRadius = mediumRadius,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? neumorphismInsetShadow,
      gradient: gradient,
    );
  }

  /// Glassmorphism dekorasyon
  static BoxDecoration getGlassmorphismDecoration({
    List<BoxShadow>? shadows,
    Color? color,
    double borderRadius = mediumRadius,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? neumorphismGlassShadow,
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  /// Dinamik gölge oluştur (ışık kaynağına göre)
  static List<BoxShadow> createDynamicShadow({
    required Offset lightPosition,
    double intensity = 1.0,
    int layers = 8,
  }) {
    final List<BoxShadow> shadows = [];

    for (int i = 0; i < layers; i++) {
      final double layerIntensity = (layers - i) / layers;
      final double blurRadius = 4.0 + (i * 2.0);
      final Offset offset = Offset(
        -lightPosition.dx * layerIntensity * intensity,
        -lightPosition.dy * layerIntensity * intensity,
      );

      shadows.add(BoxShadow(
        color: lightSource.withOpacity(0.8 * layerIntensity),
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: -blurRadius * 0.25,
      ));

      shadows.add(BoxShadow(
        color: darkSource.withOpacity(0.3 * layerIntensity),
        offset: -offset,
        blurRadius: blurRadius,
        spreadRadius: -blurRadius * 0.25,
      ));
    }

    return shadows;
  }

  /// Zaman tabanlı animasyonlu gölge
  static List<BoxShadow> createAnimatedShadow({
    required double animationValue,
    double maxOffset = 20.0,
    double maxBlur = 40.0,
  }) {
    final double offset = maxOffset * animationValue;
    final double blur = maxBlur * animationValue;

    return [
      BoxShadow(
        color: lightSource.withOpacity(0.9 - animationValue * 0.3),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
        spreadRadius: -blur * 0.25,
      ),
      BoxShadow(
        color: darkSource.withOpacity(0.2 + animationValue * 0.4),
        offset: Offset(offset, offset),
        blurRadius: blur,
        spreadRadius: -blur * 0.25,
      ),
    ];
  }

  /// Morphing efekt gölgeleri
  static List<BoxShadow> createMorphingShadow({
    required double morphValue,
    List<BoxShadow>? fromShadows,
    List<BoxShadow>? toShadows,
  }) {
    final List<BoxShadow> from = fromShadows ?? neumorphismOutsetShadow;
    final List<BoxShadow> to = toShadows ?? neumorphismInsetShadow;
    final List<BoxShadow> morphed = [];

    for (int i = 0; i < from.length && i < to.length; i++) {
      final BoxShadow fromShadow = from[i];
      final BoxShadow toShadow = to[i];

      morphed.add(BoxShadow(
        color: Color.lerp(fromShadow.color, toShadow.color, morphValue)!,
        offset: Offset.lerp(fromShadow.offset, toShadow.offset, morphValue)!,
        blurRadius:
            fromShadow.blurRadius + (toShadow.blurRadius - fromShadow.blurRadius) * morphValue,
        spreadRadius:
            fromShadow.spreadRadius + (toShadow.spreadRadius - fromShadow.spreadRadius) * morphValue,
      ));
    }

    return morphed;
  }

  /// Parallax gölge efekti
  static List<BoxShadow> createParallaxShadow({
    required Offset parallaxOffset,
    double intensity = 1.0,
  }) {
    final double offsetX = parallaxOffset.dx * intensity;
    final double offsetY = parallaxOffset.dy * intensity;

    return [
      BoxShadow(
        color: lightSource.withOpacity(0.9),
        offset: Offset(-8 - offsetX, -8 - offsetY),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: darkSource.withOpacity(0.2),
        offset: Offset(8 + offsetX, 8 + offsetY),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: lightSource.withOpacity(0.6),
        offset: Offset(-4 - offsetX * 0.5, -4 - offsetY * 0.5),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: darkSource.withOpacity(0.15),
        offset: Offset(4 + offsetX * 0.5, 4 + offsetY * 0.5),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  /// 3D derinlik gölgeleri
  static List<BoxShadow> create3DShadow({
    required double depth,
    double maxDepth = 50.0,
    Color? lightColor,
    Color? darkColor,
  }) {
    final double depthRatio = (depth / maxDepth).clamp(0.0, 1.0);
    final Color lc = lightColor ?? lightSource;
    final Color dc = darkColor ?? darkSource;

    return [
      BoxShadow(
        color: lc.withOpacity(0.9),
        offset: Offset(-depth * 0.4, -depth * 0.4),
        blurRadius: depth * 0.8,
        spreadRadius: -depth * 0.2,
      ),
      BoxShadow(
        color: dc.withOpacity(0.3 + depthRatio * 0.4),
        offset: Offset(depth * 0.4, depth * 0.4),
        blurRadius: depth * 0.8,
        spreadRadius: -depth * 0.2,
      ),
      BoxShadow(
        color: lc.withOpacity(0.7),
        offset: Offset(-depth * 0.2, -depth * 0.2),
        blurRadius: depth * 0.4,
        spreadRadius: -depth * 0.1,
      ),
      BoxShadow(
        color: dc.withOpacity(0.2 + depthRatio * 0.2),
        offset: Offset(depth * 0.2, depth * 0.2),
        blurRadius: depth * 0.4,
        spreadRadius: -depth * 0.1,
      ),
    ];
  }

  /// Gradient gölgeler
  static List<BoxShadow> createGradientShadow({
    required List<Color> colors,
    required Offset direction,
    double blurRadius = 20.0,
  }) {
    final List<BoxShadow> shadows = [];

    for (int i = 0; i < colors.length; i++) {
      final double intensity = (colors.length - i) / colors.length;
      shadows.add(BoxShadow(
        color: colors[i].withOpacity(0.3 * intensity),
        offset: direction * intensity,
        blurRadius: blurRadius * intensity,
        spreadRadius: -blurRadius * 0.25,
      ));
    }

    return shadows;
  }

  /// Titreşim (vibration) gölgeleri
  static List<BoxShadow> createVibrationShadow({
    required double vibrationIntensity,
    List<BoxShadow>? baseShadows,
  }) {
    final List<BoxShadow> base = baseShadows ?? neumorphismOutsetShadow;
    final List<BoxShadow> vibrated = [];

    for (final BoxShadow shadow in base) {
      vibrated.add(BoxShadow(
        color: shadow.color,
        offset: Offset(
          shadow.offset.dx + (vibrationIntensity * (0.5 - DateTime.now().millisecond % 1000 / 1000.0)),
          shadow.offset.dy + (vibrationIntensity * (0.5 - DateTime.now().millisecond % 1000 / 1000.0)),
        ),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
      ));
    }

    return vibrated;
  }

  /// Neon glow efektli nöromorfik gölgeler
  static List<BoxShadow> createNeonShadow({
    required Color neonColor,
    double intensity = 1.0,
    List<BoxShadow>? baseShadows,
  }) {
    final List<BoxShadow> base = baseShadows ?? neumorphismOutsetShadow;
    final List<BoxShadow> neon = List.from(base);

    // Neon glow katmanları
    neon.addAll([
      BoxShadow(
        color: neonColor.withOpacity(0.6 * intensity),
        offset: Offset.zero,
        blurRadius: 20 * intensity,
        spreadRadius: 5 * intensity,
      ),
      BoxShadow(
        color: neonColor.withOpacity(0.4 * intensity),
        offset: Offset.zero,
        blurRadius: 40 * intensity,
        spreadRadius: 10 * intensity,
      ),
      BoxShadow(
        color: neonColor.withOpacity(0.2 * intensity),
        offset: Offset.zero,
        blurRadius: 60 * intensity,
        spreadRadius: 15 * intensity,
      ),
    ]);

    return neon;
  }

  /// Holografik gölge efekti
  static List<BoxShadow> createHolographicShadow({
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

    final List<BoxShadow> holographic = [];

    for (int i = 0; i < holographicColors.length; i++) {
      final double phase = (time + i * 0.2) % 1.0;
      final double intensity = (sin(phase * 2 * pi) + 1) * 0.5;

      holographic.add(BoxShadow(
        color: holographicColors[i].withOpacity(0.3 * intensity),
        offset: Offset(
          cos(phase * 2 * pi) * 10,
          sin(phase * 2 * pi) * 10,
        ),
        blurRadius: 15 + intensity * 10,
        spreadRadius: -5,
      ));
    }

    return holographic;
  }

  /// Su damlası (ripple) gölge efekti
  static List<BoxShadow> createRippleShadow({
    required double rippleProgress,
    Color? rippleColor,
    double maxRadius = 50.0,
  }) {
    final Color rc = rippleColor ?? Colors.blue;
    final double radius = maxRadius * rippleProgress;
    final double opacity = (1.0 - rippleProgress) * 0.5;

    return [
      BoxShadow(
        color: rc.withOpacity(opacity),
        offset: Offset.zero,
        blurRadius: radius,
        spreadRadius: radius * 0.5,
      ),
    ];
  }

  /// Ateş (fire) gölge efekti
  static List<BoxShadow> createFireShadow({
    required double flickerIntensity,
    List<Color>? fireColors,
  }) {
    final List<Color> colors = fireColors ?? [
      Colors.red,
      Colors.orange,
      Colors.yellow,
    ];

    final List<BoxShadow> fire = [];

    for (int i = 0; i < colors.length; i++) {
      final double flicker = (sin(DateTime.now().millisecondsSinceEpoch * 0.01 + i) + 1) * 0.5;
      final double intensity = flickerIntensity * flicker;

      fire.add(BoxShadow(
        color: colors[i].withOpacity(0.4 * intensity),
        offset: Offset(0, -5 - i * 3),
        blurRadius: 10 + i * 5,
        spreadRadius: -2,
      ));
    }

    return fire;
  }

  /// Buz (ice) gölge efekti
  static List<BoxShadow> createIceShadow({
    required double crystallinity,
    Color? iceColor,
  }) {
    final Color ic = iceColor ?? Colors.cyan;
    final List<BoxShadow> ice = [];

    // Kristal katmanları
    for (int i = 0; i < 6; i++) {
      ice.add(BoxShadow(
        color: ic.withOpacity(0.3 * crystallinity * (1 - i * 0.15)),
        offset: Offset(-i * 2, -i * 2),
        blurRadius: 4 + i * 2,
        spreadRadius: -1,
      ));
      ice.add(BoxShadow(
        color: ic.withOpacity(0.2 * crystallinity * (1 - i * 0.15)),
        offset: Offset(i * 2, i * 2),
        blurRadius: 4 + i * 2,
        spreadRadius: -1,
      ));
    }

    return ice;
  }

  /// Toprak (earth) gölge efekti
  static List<BoxShadow> createEarthShadow({
    required double textureDepth,
    Color? earthColor,
  }) {
    final Color ec = earthColor ?? Colors.brown;
    final List<BoxShadow> earth = [];

    // Doku katmanları
    for (int i = 0; i < 8; i++) {
      final double depth = textureDepth * (1 - i * 0.1);
      earth.add(BoxShadow(
        color: ec.withOpacity(0.2 * depth),
        offset: Offset(
          (i % 2 == 0 ? -1 : 1) * i * 1.5,
          (i % 3 == 0 ? -1 : 1) * i * 1.5,
        ),
        blurRadius: 3 + i,
        spreadRadius: -1,
      ));
    }

    return earth;
  }

  /// Metalik gölge efekti
  static List<BoxShadow> createMetallicShadow({
    required double metallicness,
    Color? metalColor,
  }) {
    final Color mc = metalColor ?? Colors.grey;
    final List<BoxShadow> metallic = [];

    // Metalik parlaklık katmanları
    for (int i = 0; i < 5; i++) {
      final double shine = (sin(DateTime.now().millisecondsSinceEpoch * 0.005 + i) + 1) * 0.5;
      metallic.add(BoxShadow(
        color: mc.withOpacity(0.6 * metallicness * shine),
        offset: Offset(-i * 3, -i * 3),
        blurRadius: 6 + i * 2,
        spreadRadius: -2,
      ));
      metallic.add(BoxShadow(
        color: mc.withOpacity(0.3 * metallicness * (1 - shine)),
        offset: Offset(i * 3, i * 3),
        blurRadius: 6 + i * 2,
        spreadRadius: -2,
      ));
    }

    return metallic;
  }

  /// Kozmik (cosmic) gölge efekti
  static List<BoxShadow> createCosmicShadow({
    required double cosmicEnergy,
    List<Color>? cosmicColors,
  }) {
    final List<Color> colors = cosmicColors ?? [
      Colors.purple,
      Colors.blue,
      Colors.indigo,
      Colors.pink,
    ];

    final List<BoxShadow> cosmic = [];

    // Kozmik enerji katmanları
    for (int i = 0; i < colors.length; i++) {
      final double energy = cosmicEnergy * (sin(DateTime.now().millisecondsSinceEpoch * 0.002 + i * 0.5) + 1) * 0.5;
      final double angle = (i * 2 * pi) / colors.length;

      cosmic.add(BoxShadow(
        color: colors[i].withOpacity(0.4 * energy),
        offset: Offset(
          cos(angle) * 15 * energy,
          sin(angle) * 15 * energy,
        ),
        blurRadius: 20 + energy * 10,
        spreadRadius: -5,
      ));
    }

    return cosmic;
  }

  /// Rüya (dream) gölge efekti
  static List<BoxShadow> createDreamShadow({
    required double dreaminess,
    List<Color>? dreamColors,
  }) {
    final List<Color> colors = dreamColors ?? [
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
    ];

    final List<BoxShadow> dream = [];

    // Rüya katmanları
    for (int i = 0; i < colors.length; i++) {
      final double wave = sin(DateTime.now().millisecondsSinceEpoch * 0.001 + i * 0.8) * dreaminess;
      dream.add(BoxShadow(
        color: colors[i].withOpacity(0.2 * dreaminess),
        offset: Offset(
          wave * 10,
          cos(i * 0.5) * wave * 8,
        ),
        blurRadius: 15 + abs(wave) * 10,
        spreadRadius: -3,
      ));
    }

    return dream;
  }

  /// Aurora gölge efekti
  static List<BoxShadow> createAuroraShadow({
    required double auroraIntensity,
    List<Color>? auroraColors,
  }) {
    final List<Color> colors = auroraColors ?? [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    final List<BoxShadow> aurora = [];

    // Aurora dalga katmanları
    for (int i = 0; i < colors.length; i++) {
      final double wave = sin(DateTime.now().millisecondsSinceEpoch * 0.0005 + i * 0.3) * auroraIntensity;
      aurora.add(BoxShadow(
        color: colors[i].withOpacity(0.3 * auroraIntensity),
        offset: Offset(
          wave * 20,
          sin(i * 0.7) * wave * 15,
        ),
        blurRadius: 25 + abs(wave) * 15,
        spreadRadius: -5,
      ));
    }

    return aurora;
  }

  /// Kristal (crystal) gölge efekti
  static List<BoxShadow> createCrystalShadow({
    required double clarity,
    Color? crystalColor,
  }) {
    final Color cc = crystalColor ?? Colors.white;
    final List<BoxShadow> crystal = [];

    // Kristal yüzey katmanları
    for (int i = 0; i < 12; i++) {
      final double facet = clarity * (1 - i * 0.08);
      final double angle = (i * 2 * pi) / 12;

      crystal.add(BoxShadow(
        color: cc.withOpacity(0.4 * facet),
        offset: Offset(
          cos(angle) * i * 2,
          sin(angle) * i * 2,
        ),
        blurRadius: 3 + i,
        spreadRadius: -1,
      ));
    }

    return crystal;
  }

  /// Lazer (laser) gölge efekti
  static List<BoxShadow> createLaserShadow({
    required Color laserColor,
    required double intensity,
    required double angle,
  }) {
    final List<BoxShadow> laser = [];

    // Lazer ışını katmanları
    for (int i = 0; i < 5; i++) {
      laser.add(BoxShadow(
        color: laserColor.withOpacity(0.8 * intensity * (1 - i * 0.2)),
        offset: Offset(
          cos(angle) * i * 8,
          sin(angle) * i * 8,
        ),
        blurRadius: 2 + i * 3,
        spreadRadius: -1,
      ));
    }

    return laser;
  }

  /// Plazma (plasma) gölge efekti
  static List<BoxShadow> createPlasmaShadow({
    required double plasmaEnergy,
    List<Color>? plasmaColors,
  }) {
    final List<Color> colors = plasmaColors ?? [
      Colors.cyan,
      Colors.magenta,
      Colors.yellow,
    ];

    final List<BoxShadow> plasma = [];

    // Plazma enerji katmanları
    for (int i = 0; i < colors.length; i++) {
      final double energy = plasmaEnergy * (sin(DateTime.now().millisecondsSinceEpoch * 0.01 + i * 2) + 1) * 0.5;
      plasma.add(BoxShadow(
        color: colors[i].withOpacity(0.5 * energy),
        offset: Offset(
          (i - 1) * 10 * energy,
          (i % 2 == 0 ? -1 : 1) * 8 * energy,
        ),
        blurRadius: 15 + energy * 20,
        spreadRadius: -3,
      ));
    }

    return plasma;
  }

  /// Kuantum (quantum) gölge efekti
  static List<BoxShadow> createQuantumShadow({
    required double quantumState,
    Color? quantumColor,
  }) {
    final Color qc = quantumColor ?? Colors.blue;
    final List<BoxShadow> quantum = [];

    // Kuantum durum katmanları
    for (int i = 0; i < 8; i++) {
      final double probability = quantumState * (sin(DateTime.now().millisecondsSinceEpoch * 0.02 + i * pi / 4) + 1) * 0.5;
      quantum.add(BoxShadow(
        color: qc.withOpacity(0.3 * probability),
        offset: Offset(
          (i % 2 == 0 ? -1 : 1) * i * 4 * probability,
          (i % 3 == 0 ? -1 : 1) * i * 4 * probability,
        ),
        blurRadius: 8 + i * 2,
        spreadRadius: -2,
      ));
    }

    return quantum;
  }

  /// Zaman (temporal) gölge efekti
  static List<BoxShadow> createTemporalShadow({
    required double timeFlow,
    List<Color>? timeColors,
  }) {
    final List<Color> colors = timeColors ?? [
      Colors.white,
      Colors.grey,
      Colors.black,
    ];

    final List<BoxShadow> temporal = [];

    // Zaman akışı katmanları
    for (int i = 0; i < colors.length; i++) {
      final double flow = timeFlow * (i + 1) / colors.length;
      temporal.add(BoxShadow(
        color: colors[i].withOpacity(0.3 * flow),
        offset: Offset(
          -i * 5 * flow,
          -i * 5 * flow,
        ),
        blurRadius: 10 + i * 5,
        spreadRadius: -3,
      ));
    }

    return temporal;
  }

  /// Boyutlar arası (interdimensional) gölge efekti
  static List<BoxShadow> createInterdimensionalShadow({
    required double dimensionalShift,
    List<Color>? dimensionColors,
  }) {
    final List<Color> colors = dimensionColors ?? [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.red,
    ];

    final List<BoxShadow> interdimensional = [];

    // Boyutlar arası katmanlar
    for (int i = 0; i < colors.length; i++) {
      final double shift = dimensionalShift * (sin(DateTime.now().millisecondsSinceEpoch * 0.003 + i * pi / 2) + 1) * 0.5;
      interdimensional.add(BoxShadow(
        color: colors[i].withOpacity(0.4 * shift),
        offset: Offset(
          (i - colors.length / 2) * 12 * shift,
          cos(i * pi / 3) * 10 * shift,
        ),
        blurRadius: 20 + shift * 15,
        spreadRadius: -5,
      ));
    }

    return interdimensional;
  }
}

/// Dinamik Işık Kaynağı Sistemi
/// Pinterest seviyesi gerçek zamanlı ışık hesaplaması
class DynamicLightSystem {
  /// Geçerli ışık pozisyonu (-1, -1) sol üst, (1, 1) sağ alt
  static Offset _currentLightPosition = const Offset(-0.5, -0.5);
  static double _lightIntensity = 1.0;
  static double _lightTemperature = 6500; // Kelvin
  static Color _lightColor = Colors.white;
  static bool _isTimeBased = false;
  static double _timeSpeed = 0.001;

  /// Sistem dinleyicileri
  static final List<VoidCallback> _listeners = [];

  /// Işık pozisyonunu güncelle
  static void updateLightPosition(Offset position) {
    _currentLightPosition = Offset(
      position.dx.clamp(-1.0, 1.0),
      position.dy.clamp(-1.0, 1.0),
    );
    _notifyListeners();
  }

  /// Işık şiddetini güncelle
  static void updateLightIntensity(double intensity) {
    _lightIntensity = intensity.clamp(0.0, 2.0);
    _notifyListeners();
  }

  /// Zaman tabanlı modu aç/kapat
  static void setTimeBasedMode(bool enabled, {double speed = 0.001}) {
    _isTimeBased = enabled;
    _timeSpeed = speed;
    if (enabled) {
      _startTimeBasedUpdates();
    }
  }

  /// Zaman tabanlı güncellemeleri başlat
  static void _startTimeBasedUpdates() {
    // Bu gerçek uygulamada Timer veya AnimationController kullanılacak
    // Şimdilik simüle edilmiş
  }

  /// Dinamik gölge oluştur (gerçek zamanlı)
  static List<BoxShadow> createRealTimeShadow({
    required BuildContext context,
    int layers = 12,
    double intensity = 1.0,
    Color? customLightColor,
    Color? customDarkColor,
  }) {
    final lightColor = customLightColor ?? _calculateLightColor();
    final darkColor = customDarkColor ?? _calculateDarkColor();

    final List<BoxShadow> shadows = [];

    for (int i = 0; i < layers; i++) {
      final layerIntensity = (layers - i) / layers * _lightIntensity * intensity;
      final blurRadius = 4.0 + (i * 3.0);
      final spreadRadius = -blurRadius * 0.3;

      // Işık yönüne göre offset hesapla
      final lightOffset = Offset(
        -_currentLightPosition.dx * layerIntensity * 15,
        -_currentLightPosition.dy * layerIntensity * 15,
      );

      // Aydınlık gölge
      shadows.add(BoxShadow(
        color: lightColor.withOpacity(0.9 * layerIntensity),
        offset: lightOffset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ));

      // Koyu gölge (ters yönde)
      shadows.add(BoxShadow(
        color: darkColor.withOpacity(0.4 * layerIntensity),
        offset: -lightOffset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ));
    }

    return shadows;
  }

  /// Dinamik gradyan oluştur
  static LinearGradient createDynamicGradient({
    required List<Color> baseColors,
    double intensity = 1.0,
  }) {
    final adjustedColors = baseColors.map((color) {
      return Color.lerp(
        color,
        _calculateLightColor(),
        _lightIntensity * intensity * 0.3,
      )!;
    }).toList();

    return LinearGradient(
      begin: Alignment(
        _currentLightPosition.dx,
        _currentLightPosition.dy,
      ),
      end: Alignment(
        -_currentLightPosition.dx,
        -_currentLightPosition.dy,
      ),
      colors: adjustedColors,
    );
  }

  /// Işık rengini hesapla (sıcaklık bazlı)
  static Color _calculateLightColor() {
    if (_lightTemperature < 3000) {
      // Sıcak ışık (kırmızımsı)
      return Color.lerp(Colors.orange, Colors.red, (_lightTemperature - 2000) / 1000)!;
    } else if (_lightTemperature < 5000) {
      // Nötr ışık
      return Color.lerp(Colors.yellow, Colors.white, (_lightTemperature - 3000) / 2000)!;
    } else {
      // Soğuk ışık (mavimsi)
      return Color.lerp(Colors.white, Colors.blue.shade50, (_lightTemperature - 5000) / 3000)!;
    }
  }

  /// Koyu rengi hesapla
  static Color _calculateDarkColor() {
    return Color.lerp(
      const Color(0xFF374151),
      const Color(0xFF1F2937),
      _lightIntensity,
    )!;
  }

  /// Dinleyici ekle
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Dinleyici kaldır
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Tüm dinleyicileri bilgilendir
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Geçerli ışık pozisyonunu al
  static Offset get currentLightPosition => _currentLightPosition;

  /// Geçerli ışık şiddetini al
  static double get lightIntensity => _lightIntensity;

  /// Zaman bazlı modu kontrol et
  static bool get isTimeBased => _isTimeBased;
}