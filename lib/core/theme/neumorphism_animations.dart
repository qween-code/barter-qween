import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neumorphism Animation Utilities
/// Doğal yeşil efektli geçiş animasyonları

/// Neumorphism buton tıklama animasyonu
class NeumorphismAnimations {
  /// Buton tıklama animasyonu
  static AnimationController createButtonAnimation(
    TickerProvider vsync,
    VoidCallback onPressed,
  ) {
    return AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: vsync,
    )..addListener(() {
        // Animasyon sırasında görsel geri bildirim
      });
  }

  /// Kart hover efekti animasyonu
  static Animation<double> createHoverAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  /// Neumorphism shadow geçiş animasyonu
  static Animation<List<BoxShadow>> createShadowAnimation(
    AnimationController controller,
    bool isPressed,
  ) {
    return TweenSequence<List<BoxShadow>>([
      TweenSequenceItem(
        tween: ConstantTween<List<BoxShadow>>(AppColors.neumorphismOutsetShadow),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ConstantTween<List<BoxShadow>>(AppColors.neumorphismInsetShadow),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Sayfa geçiş animasyonu
  static PageRouteBuilder<T> createNeumorphismPageTransition<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation.drive(
                Tween<double>(begin: 0.95, end: 1.0).chain(
                  CurveTween(curve: curve),
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Modal bottom sheet neumorphism animasyonu
  static Future<T?> showNeumorphismModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double? elevation,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? 32.0),
        ),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius ?? 32.0),
          ),
          boxShadow: AppColors.neumorphismInsetShadow,
        ),
        child: Builder(builder: builder),
      ),
    );
  }

  /// Neumorphism loading animasyonu
  static Widget createLoadingAnimation({
    double size = 40.0,
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppColors.neumorphismOutsetShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Neumorphism shimmer efekti
  static Widget createShimmerEffect({
    required double width,
    required double height,
    double borderRadius = 16.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppColors.neumorphismOutsetShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.surfaceVariant.withOpacity(0.5),
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Neumorphism animasyonlu widget'lar için extension
extension NeumorphismAnimationExtension on Widget {
  /// Fade in animasyonu ile sarmalama
  Widget withFadeInAnimation({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: Curves.easeIn,
        ),
      ),
      child: this,
    );
  }

  /// Scale animasyonu ile sarmalama
  Widget withScaleAnimation({
    Duration duration = const Duration(milliseconds: 200),
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: beginScale, end: endScale).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: Curves.elasticOut,
        ),
      ),
      child: this,
    );
  }

  /// Slide animasyonu ile sarmalama
  Widget withSlideAnimation({
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: Curves.easeOut,
        ),
      ),
      child: this,
    );
  }
}