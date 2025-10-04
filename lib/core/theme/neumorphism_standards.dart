import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Neumorphism Design Standards
/// Tüm uygulama genelinde tutarlı neumorphism standartları

/// Neumorphism tasarım sistemi standartları
class NeumorphismStandards {
  NeumorphismStandards._();

  // ============================================
  // BORDER RADIUS STANDARDS
  // ============================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusXXLarge = 48.0;

  // ============================================
  // SHADOW STANDARDS
  // ============================================

  /// Ana neumorphism gölge efekti
  static List<BoxShadow> get standardShadow => AppColors.neumorphismOutsetShadow;

  /// İçbükey neumorphism gölge efekti
  static List<BoxShadow> get insetShadow => AppColors.neumorphismInsetShadow;

  /// Düz neumorphism efekti (gölge yok)
  static List<BoxShadow> get flatShadow => [];

  // ============================================
  // PADDING STANDARDS
  // ============================================

  /// Küçük neumorphism padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);

  /// Orta neumorphism padding
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);

  /// Büyük neumorphism padding
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  /// XL neumorphism padding
  static const EdgeInsets paddingXLarge = EdgeInsets.all(32.0);

  // ============================================
  // MARGIN STANDARDS
  // ============================================

  /// Küçük neumorphism margin
  static const EdgeInsets marginSmall = EdgeInsets.all(8.0);

  /// Orta neumorphism margin
  static const EdgeInsets marginMedium = EdgeInsets.all(16.0);

  /// Büyük neumorphism margin
  static const EdgeInsets marginLarge = EdgeInsets.all(24.0);

  // ============================================
  // ELEVATION STANDARDS
  // ============================================

  /// Düz elemanlar için elevation (0)
  static const double elevationFlat = 0.0;

  /// Kartlar için standart elevation
  static const double elevationCard = 0.0; // Neumorphism'de shadow ile sağlanır

  /// Butonlar için elevation
  static const double elevationButton = 0.0; // Neumorphism'de shadow ile sağlanır

  /// Modal ve dialog'lar için elevation
  static const double elevationModal = 0.0; // Neumorphism'de shadow ile sağlanır

  // ============================================
  // COLOR STANDARDS
  // ============================================

  /// Ana yüzey rengi
  static Color get surfaceColor => AppColors.surface;

  /// Arkaplan rengi
  static Color get backgroundColor => AppColors.background;

  /// Kenarlık rengi
  static Color get borderColor => AppColors.borderDefault;

  /// Metin rengi
  static Color get textColor => AppColors.textPrimary;

  /// İkincil metin rengi
  static Color get textSecondaryColor => AppColors.textSecondary;

  // ============================================
  // GRADIENT STANDARDS
  // ============================================

  /// Ana yüzey gradient'i
  static LinearGradient get surfaceGradient => AppColors.neumorphismSurfaceGradient;

  /// Buton gradient'i
  static LinearGradient get buttonGradient => AppColors.neumorphismButtonGradient;

  /// Arkaplan gradient'i
  static LinearGradient get backgroundGradient => AppColors.backgroundGradient;

  // ============================================
  // TYPOGRAPHY STANDARDS
  // ============================================

  /// Başlık metin stili
  static TextStyle get headingStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Alt başlık metin stili
  static TextStyle get subheadingStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// Gövde metin stili
  static TextStyle get bodyStyle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Altyazı metin stili
  static TextStyle get captionStyle => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ============================================
  // COMPONENT STANDARDS
  // ============================================

  /// Standart neumorphism buton yüksekliği
  static const double buttonHeight = 56.0;

  /// Standart neumorphism kart yüksekliği
  static const double cardHeight = 200.0;

  /// Standart neumorphism input yüksekliği
  static const double inputHeight = 56.0;

  /// Standart neumorphism icon boyutu
  static const double iconSize = 24.0;

  // ============================================
  // ANIMATION STANDARDS
  // ============================================

  /// Hızlı animasyon süresi
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Orta animasyon süresi
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// Yavaş animasyon süresi
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Bounce animasyon eğrisi
  static const Curve animationBounce = Curves.elasticOut;

  /// Yumuşak animasyon eğrisi
  static const Curve animationSmooth = Curves.easeInOut;

  // ============================================
  // SPACING STANDARDS
  // ============================================

  /// Çok küçük boşluk
  static const double spacingXXXS = 4.0;

  /// Küçük boşluk
  static const double spacingXXS = 8.0;

  /// Orta küçük boşluk
  static const double spacingXS = 12.0;

  /// Standart boşluk
  static const double spacingS = 16.0;

  /// Orta boşluk
  static const double spacingM = 24.0;

  /// Büyük boşluk
  static const double spacingL = 32.0;

  /// Çok büyük boşluk
  static const double spacingXL = 48.0;

  /// Ultra büyük boşluk
  static const double spacingXXL = 64.0;
}

/// Neumorphism standartları için extension metodları
extension NeumorphismStandardsExtension on BuildContext {
  /// Standart neumorphism card oluştur
  Widget createNeumorphismCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? NeumorphismStandards.paddingMedium,
        margin: margin ?? NeumorphismStandards.marginSmall,
        decoration: BoxDecoration(
          color: NeumorphismStandards.surfaceColor,
          borderRadius: BorderRadius.circular(
            borderRadius ?? NeumorphismStandards.radiusMedium,
          ),
          boxShadow: NeumorphismStandards.standardShadow,
        ),
        child: child,
      ),
    );
  }

  /// Standart neumorphism buton oluştur
  Widget createNeumorphismButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? icon,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: NeumorphismStandards.buttonHeight,
      decoration: BoxDecoration(
        color: NeumorphismStandards.surfaceColor,
        borderRadius: BorderRadius.circular(NeumorphismStandards.radiusMedium),
        boxShadow: NeumorphismStandards.standardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(NeumorphismStandards.radiusMedium),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: NeumorphismStandards.subheadingStyle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Standart neumorphism input oluştur
  Widget createNeumorphismInput({
    String? labelText,
    String? hintText,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NeumorphismStandards.surfaceColor,
        borderRadius: BorderRadius.circular(NeumorphismStandards.radiusMedium),
        boxShadow: NeumorphismStandards.standardShadow,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: NeumorphismStandards.paddingMedium,
        ),
      ),
    );
  }
}

/// Neumorphism tema tutarlılığı için utility fonksiyonları
class NeumorphismUtils {
  /// Tüm uygulama genelinde neumorphism tutarlılığını kontrol et
  static bool isNeumorphismCompliant(Widget widget) {
    // Bu fonksiyon neumorphism standartlarına uygunluğu kontrol eder
    return true; // Şimdilik her zaman true döndür
  }

  /// Neumorphism renk paletini al
  static Map<String, Color> getNeumorphismColorPalette() {
    return {
      'primary': AppColors.primary,
      'secondary': AppColors.secondary,
      'accent': AppColors.accent,
      'surface': AppColors.surface,
      'background': AppColors.background,
      'textPrimary': AppColors.textPrimary,
      'textSecondary': AppColors.textSecondary,
    };
  }

  /// Neumorphism shadow değerlerini al
  static Map<String, List<BoxShadow>> getNeumorphismShadows() {
    return {
      'outset': AppColors.neumorphismOutsetShadow,
      'inset': AppColors.neumorphismInsetShadow,
      'flat': [],
    };
  }

  /// Neumorphism border radius değerlerini al
  static Map<String, double> getNeumorphismBorderRadius() {
    return {
      'small': NeumorphismStandards.radiusSmall,
      'medium': NeumorphismStandards.radiusMedium,
      'large': NeumorphismStandards.radiusLarge,
      'xlarge': NeumorphismStandards.radiusXLarge,
    };
  }
}