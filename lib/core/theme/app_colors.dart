import 'package:flutter/material.dart';

/// Barter Qween Ultra Neumorphism Color Palette
/// Pinterest seviyesi ultra derin nöromorfik tasarım için gelişmiş renk sistemi
class AppColors {
  AppColors._();

  // ============================================
  // NEUMORPHISM PRIMARY - Doğal Yeşil (Trust, Nature)
  // ============================================
  static const Color primary = Color(0xFF3E7E55);    // Koyu doğal yeşil
  static const Color primaryLight = Color(0xFF7ABD87); // Orta yeşil
  static const Color primaryDark = Color(0xFF2D5A3D);  // Koyu yeşil
  static const Color primaryUltraLight = Color(0xFFA8D5B0); // Ultra açık yeşil
  static const Color primaryUltraDark = Color(0xFF1F3D28); // Ultra koyu yeşil

  // ============================================
  // NEUMORPHISM SECONDARY - Açık Yeşil (Growth)
  // ============================================
  static const Color secondary = Color(0xFFAADC86);   // Açık yeşil
  static const Color secondaryLight = Color(0xFFCADECB); // Çok açık yeşil
  static const Color secondaryDark = Color(0xFF8BC34A); // Orta koyu yeşil
  static const Color secondaryUltraLight = Color(0xFFE8F5E0); // Ultra açık yeşil
  static const Color secondaryUltraDark = Color(0xFF689F38); // Ultra koyu yeşil

  // ============================================
  // NEUMORPHISM ACCENT - Canlı Yeşil (Energy)
  // ============================================
  static const Color accent = Color(0xFFEAEEE5);     // Çok açık doğal
  static const Color accentLight = Color(0xFFF5F7F3); // Beyaz yeşil
  static const Color accentDark = Color(0xFFD4E0C5);  // Açık gri yeşil
  static const Color accentUltraLight = Color(0xFFFAFCF8); // Ultra açık
  static const Color accentUltraDark = Color(0xFFC5D5B0); // Ultra koyu
  
  // ============================================
  // NEUMORPHISM NEUTRAL - Doğal Arkaplanlar
  // ============================================
  static const Color background = Color(0xFFEAEEE5);     // Açık doğal yeşil
  static const Color surface = Color(0xFFF5F7F3);        // Çok açık yeşil beyaz
  static const Color surfaceVariant = Color(0xFFCADECB);  // Orta açık yeşil
  static const Color backgroundVariant = Color(0xFFE0E6D8); // Alternatif arkaplan
  static const Color surfaceDark = Color(0xFFD4E0C5);    // Koyu yüzey
  static const Color surfaceLight = Color(0xFFFAFCF8);   // Çok açık yüzey
  
  // ============================================
  // TEXT COLORS - Hierarchy
  // ============================================
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textDisabled = Color(0xFFCED4DA);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF2D5A3D); // Yüzey üzerindeki metin
  static const Color textOnBackground = Color(0xFF3E7E55); // Arkaplan üzerindeki metin
  
  // ============================================
  // SEMANTIC COLORS - Status & Feedback
  // ============================================
  static const Color success = Color(0xFF51CF66);
  static const Color successLight = Color(0xFF8CE99A);
  static const Color successDark = Color(0xFF37B24D);
  static const Color successUltraLight = Color(0xFFB2F2BB);
  static const Color successUltraDark = Color(0xFF2F9E44);
  
  static const Color warning = Color(0xFFFFD43B);
  static const Color warningLight = Color(0xFFFFE066);
  static const Color warningDark = Color(0xFFFAB005);
  static const Color warningUltraLight = Color(0xFFFFF3BF);
  static const Color warningUltraDark = Color(0xFFE67700);
  
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF9494);
  static const Color errorDark = Color(0xFFFA5252);
  static const Color errorUltraLight = Color(0xFFFFCCC7);
  static const Color errorUltraDark = Color(0xFFE03131);
  
  static const Color info = Color(0xFF4DABF7);
  static const Color infoLight = Color(0xFF74C0FC);
  static const Color infoDark = Color(0xFF339AF0);
  static const Color infoUltraLight = Color(0xFFA5D8FF);
  static const Color infoUltraDark = Color(0xFF1C7ED6);
  
  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDefault = Color(0xFFDEE2E6);
  static const Color borderDark = Color(0xFFCED4DA);
  static const Color borderUltraLight = Color(0xFFF8F9FA);
  static const Color borderUltraDark = Color(0xFFADB5BD);
  static const Color borderNeumorphism = Color(0xFFD4E0C5); // Nöromorfik kenarlık
  
  // ============================================
  // OVERLAY COLORS
  // ============================================
  static Color overlay = const Color(0xFF000000).withOpacity(0.5);
  static Color overlayLight = const Color(0xFF000000).withOpacity(0.3);
  static Color overlayHeavy = const Color(0xFF000000).withOpacity(0.7);
  static Color overlayUltraLight = const Color(0xFF000000).withOpacity(0.1);
  static Color overlayUltraHeavy = const Color(0xFF000000).withOpacity(0.9);
  
  // ============================================
  // GRADIENTS - Premium Effects
  // ============================================
  
  /// Primary gradient - Deep teal to light teal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ultra primary gradient - Multi-layer premium effect
  static LinearGradient get ultraPrimaryGradient => LinearGradient(
    colors: [
      primaryUltraDark,
      primary,
      primaryLight,
      primaryUltraLight,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient - Coral energy
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ultra accent gradient - Premium multi-layer
  static LinearGradient get ultraAccentGradient => LinearGradient(
    colors: [
      accentUltraDark,
      accent,
      accentLight,
      accentUltraLight,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient - Green growth
  static const LinearGradient successGradient = LinearGradient(
    colors: [successDark, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ultra success gradient - Premium success
  static LinearGradient get ultraSuccessGradient => LinearGradient(
    colors: [
      successUltraDark,
      successDark,
      success,
      successLight,
    ],
    stops: const [0.0, 0.25, 0.75, 1.0],
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
  
  /// Ultra glass gradient - Premium glassmorphism
  static LinearGradient get ultraGlassGradient => LinearGradient(
    colors: [
      surfaceLight.withOpacity(0.9),
      surface.withOpacity(0.6),
      surfaceVariant.withOpacity(0.3),
    ],
    stops: const [0.0, 0.5, 1.0],
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
  
  /// Ultra shimmer gradient - Premium loading
  static LinearGradient get ultraShimmerGradient => LinearGradient(
    colors: [
      surfaceVariant,
      surfaceLight,
      surface,
      surfaceLight,
      surfaceVariant,
    ],
    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
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
  
  /// Ultra background gradient - Premium seamless
  static LinearGradient get ultraBackgroundGradient => LinearGradient(
    colors: [
      background,
      surfaceLight,
      surface,
      surfaceVariant,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Neumorphism surface gradient
  static const LinearGradient neumorphismSurfaceGradient = LinearGradient(
    colors: [
      Color(0xFFF5F7F3),
      Color(0xFFEAEEE5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ultra neumorphism surface gradient - Multi-layer depth
  static LinearGradient get ultraNeumorphismSurfaceGradient => LinearGradient(
    colors: [
      surfaceLight,
      surface,
      surfaceVariant,
      background,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Neumorphism button gradient
  static const LinearGradient neumorphismButtonGradient = LinearGradient(
    colors: [
      Color(0xFF3E7E55),
      Color(0xFF7ABD87),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ultra neumorphism button gradient - Premium button
  static LinearGradient get ultraNeumorphismButtonGradient => LinearGradient(
    colors: [
      primaryDark,
      primary,
      primaryLight,
      secondary,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Cinematic gradient - Hero sections için
  static LinearGradient get cinematicGradient => LinearGradient(
    colors: [
      primaryUltraDark.withOpacity(0.8),
      primary.withOpacity(0.6),
      secondary.withOpacity(0.4),
      surfaceLight.withOpacity(0.2),
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Floating gradient - Navigasyon için
  static LinearGradient get floatingGradient => LinearGradient(
    colors: [
      surfaceLight.withOpacity(0.95),
      surface.withOpacity(0.85),
      secondary.withOpacity(0.75),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============================================
  // SHADOW COLORS
  // ============================================
  static Color get shadowColor => const Color(0xFF000000).withOpacity(0.08);
  static Color get shadowColorLight => const Color(0xFF000000).withOpacity(0.04);
  static Color get shadowColorDark => const Color(0xFF000000).withOpacity(0.12);
  static Color get shadowColorUltraLight => const Color(0xFF000000).withOpacity(0.02);
  static Color get shadowColorUltraDark => const Color(0xFF000000).withOpacity(0.20);
  
  /// Dinamik gölge renkleri - Işık kaynağına göre
  static Color get lightShadowColor => const Color(0xFFFFFFFF).withOpacity(0.9);
  static Color get darkShadowColor => const Color(0xFF000000).withOpacity(0.8);
  static Color get mediumShadowColor => const Color(0xFF000000).withOpacity(0.4);
  
  // ============================================
  // NEUMORPHISM SHADOWS
  // ============================================
  
  /// Neumorphism outset shadow (dışbükey efekt)
  static List<BoxShadow> get neumorphismOutsetShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.7),
      blurRadius: 15,
      offset: const Offset(-5, -5),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(5, 5),
      spreadRadius: 0,
    ),
  ];
  
  /// Neumorphism inset shadow (içbükey efekt)
  static List<BoxShadow> get neumorphismInsetShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(3, 3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.7),
      blurRadius: 10,
      offset: const Offset(-3, -3),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // ULTRA NEUMORPHISM SHADOWS
  // ============================================

  /// Ultra derinlikli nöromorfik gölge (Pinterest seviyesi)
  static List<BoxShadow> get ultraNeumorphismOutsetShadow => [
    BoxShadow(
      color: lightShadowColor,
      blurRadius: 20,
      offset: const Offset(-8, -8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: darkShadowColor,
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
      color: mediumShadowColor,
      blurRadius: 40,
      offset: const Offset(12, 12),
      spreadRadius: 0,
    ),
  ];

  /// Ultra içbükey nöromorfik gölge
  static List<BoxShadow> get ultraNeumorphismInsetShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(6, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.8),
      blurRadius: 15,
      offset: const Offset(-6, -6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(10, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.5),
      blurRadius: 30,
      offset: const Offset(-10, -10),
      spreadRadius: 0,
    ),
  ];

  /// Hover için gelişmiş gölge efekti
  static List<BoxShadow> get hoverNeumorphismShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.95),
      blurRadius: 25,
      offset: const Offset(-10, -10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.9),
      blurRadius: 25,
      offset: const Offset(10, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  /// Basılı durum için içbükey efekt
  static List<BoxShadow> get pressedNeumorphismShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.4),
      blurRadius: 12,
      offset: const Offset(4, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.9),
      blurRadius: 12,
      offset: const Offset(-4, -4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(6, 6),
      spreadRadius: 0,
    ),
  ];

  /// Sinematik gölge efekti (carousel ve hero section için)
  static List<BoxShadow> get cinematicNeumorphismShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.95),
      blurRadius: 30,
      offset: const Offset(-15, -15),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.85),
      blurRadius: 30,
      offset: const Offset(15, 15),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.7),
      blurRadius: 60,
      offset: const Offset(-20, -20),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.5),
      blurRadius: 60,
      offset: const Offset(20, 20),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 80,
      offset: const Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  /// Yüzen nöromorfik efekt (navigasyon için)
  static List<BoxShadow> get floatingNeumorphismShadow => [
    BoxShadow(
      color: const Color(0xFFFFFFFF).withOpacity(0.98),
      blurRadius: 35,
      offset: const Offset(-12, -12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.95),
      blurRadius: 35,
      offset: const Offset(12, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: secondary.withOpacity(0.25),
      blurRadius: 45,
      offset: const Offset(0, -5),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // DYNAMIC LIGHT SOURCE SYSTEM
  // ============================================

  /// Dinamik ışık kaynağı gölgeleri - Açıya göre hesaplanır
  static List<BoxShadow> getDynamicLightShadow({
    required double angle,
    required double intensity,
    required double distance,
    Color? lightColor,
    Color? darkColor,
  }) {
    final radians = angle * (3.14159265359 / 180);
    final lightOffset = Offset(
      -distance * cos(radians),
      -distance * sin(radians),
    );
    final darkOffset = Offset(
      distance * cos(radians),
      distance * sin(radians),
    );

    return [
      BoxShadow(
        color: (lightColor ?? const Color(0xFFFFFFFF)).withOpacity(intensity),
        blurRadius: distance * 0.8,
        offset: lightOffset,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: (darkColor ?? const Color(0xFF000000)).withOpacity(intensity * 0.8),
        blurRadius: distance * 0.8,
        offset: darkOffset,
        spreadRadius: 0,
      ),
    ];
  }

  /// Zamanla değişen dinamik ışık gölgeleri
  static List<BoxShadow> getAnimatedLightShadow({
    required Duration time,
    required double baseIntensity,
  }) {
    final milliseconds = time.inMilliseconds;
    final angle = (milliseconds / 50) % 360; // 360 derece döner
    final intensity = baseIntensity + (sin(milliseconds / 1000) * 0.1);
    
    return getDynamicLightShadow(
      angle: angle,
      intensity: intensity.clamp(0.0, 1.0),
      distance: 15.0,
    );
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Renk parlaklığını ayarla
  static Color adjustBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Renk doygunluğunu ayarla
  static Color adjustSaturation(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Renk tonunu ayarla
  static Color adjustHue(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + amount) % 360).toColor();
  }

  /// Şeffaflığı ayarla
  static Color adjustOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  /// Kontrast rengi al
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Renk paleti oluştur
  static Map<String, Color> createColorPalette({
    required Color baseColor,
    int variations = 5,
  }) {
    final palette = <String, Color>{};
    final hsl = HSLColor.fromColor(baseColor);
    
    for (int i = 0; i < variations; i++) {
      final factor = (i - variations ~/ 2) * 0.2;
      final adjustedColor = hsl.withLightness((hsl.lightness + factor).clamp(0.0, 1.0)).toColor();
      palette['variation_$i'] = adjustedColor;
    }
    
    return palette;
  }
}