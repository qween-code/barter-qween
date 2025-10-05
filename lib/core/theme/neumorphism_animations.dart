import 'package:flutter/material.dart';
import 'dart:math';
import 'app_colors.dart';
import 'neumorphism_standards.dart';

/// Ultra Advanced Neumorphism Animation System
/// Pinterest seviyesi sinematik geçişler ve dinamik efektler

/// Ultra gelişmiş nöromorfik animasyon sistemi
class NeumorphismAnimations {
  /// Ultra buton tıklama animasyonu - Çok katmanlı efekt
  static AnimationController createUltraButtonAnimation(
    TickerProvider vsync,
    VoidCallback onPressed,
  ) {
    return AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    )..addListener(() {
        // Çok katmanlı görsel geri bildirim
      });
  }

  /// Sinematik hover efekti animasyonu
  static Animation<double> createCinematicHoverAnimation(
    AnimationController controller,
  ) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.02)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(controller);
  }

  /// Ultra gölge geçiş animasyonu - Dinamik ışık kaynağı
  static Animation<List<BoxShadow>> createUltraShadowAnimation(
    AnimationController controller,
    bool isPressed,
  ) {
    return TweenSequence<List<BoxShadow>>([
      TweenSequenceItem(
        tween: Tween<List<BoxShadow>>(
          begin: NeumorphismStandards.neumorphismUltraOutsetShadow,
          end: NeumorphismStandards.neumorphismUltraInsetShadow,
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<List<BoxShadow>>(
          begin: NeumorphismStandards.neumorphismUltraInsetShadow,
          end: NeumorphismStandards.neumorphismUltraOutsetShadow,
        ),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  /// Sinematik sayfa geçiş animasyonu
  static PageRouteBuilder<T> createCinematicPageTransition<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation.drive(
              Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            ),
            child: ScaleTransition(
              scale: animation.drive(
                Tween<double>(begin: 0.9, end: 1.0).chain(
                  CurveTween(curve: curve),
                ),
              ),
              child: RotationTransition(
                turns: animation.drive(
                  Tween<double>(begin: 0.02, end: 0.0).chain(
                    CurveTween(curve: curve),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  /// Ultra modal bottom sheet animasyonu
  static Future<T?> showUltraNeumorphismModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double? elevation,
    Color? backgroundColor,
    double? borderRadius,
    bool isFloating = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      elevation: elevation ?? 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? 32.0),
        ),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius ?? 32.0),
          ),
          boxShadow: isFloating
              ? NeumorphismStandards.neumorphismFloatingShadow
              : NeumorphismStandards.neumorphismUltraOutsetShadow,
        ),
        child: Builder(builder: builder),
      ),
    );
  }

  /// Sinematik loading animasyonu
  static Widget createCinematicLoadingAnimation({
    double size = 60.0,
    Color? color,
    bool showShadow = true,
  }) {
    return AnimatedContainer(
      duration: NeumorphismStandards.animationMedium,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? NeumorphismStandards.neumorphismUltraOutsetShadow
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Ultra shimmer efekti - Çok katmanlı
  static Widget createUltraShimmerEffect({
    required double width,
    required double height,
    double borderRadius = 16.0,
    bool isCinematic = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isCinematic
            ? NeumorphismStandards.neumorphismCinematicShadow
            : NeumorphismStandards.neumorphismUltraOutsetShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: isCinematic
                ? AppColors.cinematicGradient
                : AppColors.ultraShimmerGradient,
          ),
        ),
      ),
    );
  }

  /// Yüzen nöromorfik animasyon
  static Widget createFloatingNeumorphismAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double floatDistance = 10.0,
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: duration,
        vsync: WidgetsBinding.instance,
      )..repeat(reverse: true),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            sin(DateTime.now().millisecondsSinceEpoch / 1000) * floatDistance,
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: NeumorphismStandards.neumorphismFloatingShadow,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Dinamik ışık kaynağı animasyonu
  static Widget createDynamicLightAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 5),
    double lightAngle = 45.0,
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: duration,
        vsync: WidgetsBinding.instance,
      )..repeat(),
      builder: (context, child) {
        final angle = (DateTime.now().millisecondsSinceEpoch / 100) % 360;
        return Container(
          decoration: BoxDecoration(
            boxShadow: AppColors.getDynamicLightShadow(
              angle: angle,
              intensity: 0.8,
              distance: 15.0,
            ),
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Parallax nöromorfik efekt
  static Widget createParallaxNeumorphismEffect({
    required Widget child,
    required ScrollController scrollController,
    double parallaxFactor = 0.1,
  }) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final offset = scrollController.offset * parallaxFactor;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: NeumorphismStandards.neumorphismUltraOutsetShadow,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Morphing nöromorfik animasyon
  static Widget createMorphingNeumorphismAnimation({
    required Widget child,
    bool isActive = false,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          isActive ? NeumorphismStandards.radiusLarge : NeumorphismStandards.radiusMedium,
        ),
        boxShadow: isActive
            ? NeumorphismStandards.neumorphismHoverShadow
            : NeumorphismStandards.neumorphismUltraOutsetShadow,
      ),
      child: child,
    );
  }

  /// Pulse nöromorfik efekt
  static Widget createPulseNeumorphismEffect({
    required Widget child,
    Duration pulseDuration = const Duration(milliseconds: 2000),
    double pulseScale = 1.05,
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: pulseDuration,
        vsync: WidgetsBinding.instance,
      )..repeat(reverse: true),
      builder: (context, child) {
        final scale = 1.0 + (sin(DateTime.now().millisecondsSinceEpoch / 1000) * 0.05);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: NeumorphismStandards.neumorphismUltraOutsetShadow,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Breathing nöromorfik animasyon
  static Widget createBreathingNeumorphismAnimation({
    required Widget child,
    Duration breathDuration = const Duration(seconds: 4),
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: breathDuration,
        vsync: WidgetsBinding.instance,
      )..repeat(reverse: true),
      builder: (context, child) {
        final breath = sin(DateTime.now().millisecondsSinceEpoch / 2000);
        final opacity = 0.5 + (breath * 0.3);
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              ...NeumorphismStandards.neumorphismUltraOutsetShadow.map(
                (shadow) => shadow.copyWith(
                  color: shadow.color?.withOpacity(shadow.color!.opacity * opacity),
                ),
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Ultra gelişmiş nöromorfik animasyonlu widget'lar için extension
extension UltraNeumorphismAnimationExtension on Widget {
  /// Sinematik fade in animasyonu ile sarmalama
  Widget withCinematicFadeInAnimation({
    Duration duration = const Duration(milliseconds: 800),
    double beginOpacity = 0.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: beginOpacity, end: 1.0).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: Curves.easeInOutCubic,
        ),
      ),
      child: this,
    );
  }

  /// Ultra scale animasyonu ile sarmalama
  Widget withUltraScaleAnimation({
    Duration duration = const Duration(milliseconds: 400),
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.elasticOut,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: beginScale, end: endScale).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: curve,
        ),
      ),
      child: this,
    );
  }

  /// Parallax slide animasyonu ile sarmalama
  Widget withParallaxSlideAnimation({
    Duration duration = const Duration(milliseconds: 600),
    Offset begin = const Offset(1.0, 0.0),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: curve,
        ),
      ),
      child: this,
    );
  }

  /// Rotation animasyonu ile sarmalama
  Widget withRotationAnimation({
    Duration duration = const Duration(milliseconds: 500),
    double beginRotation = 0.1,
    double endRotation = 0.0,
  }) {
    return RotationTransition(
      turns: Tween<double>(begin: beginRotation, end: endRotation).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: duration,
            vsync: WidgetsBinding.instance,
          )..forward(),
          curve: Curves.easeInOutCubic,
        ),
      ),
      child: this,
    );
  }

  /// Bounce animasyonu ile sarmalama
  Widget withBounceAnimation({
    Duration duration = const Duration(milliseconds: 600),
    double bounceHeight = 20.0,
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: duration,
        vsync: WidgetsBinding.instance,
      )..repeat(reverse: true),
      builder: (context, child) {
        final bounce = sin(DateTime.now().millisecondsSinceEpoch / 300);
        return Transform.translate(
          offset: Offset(0, -bounce * bounceHeight),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Stagger animasyonu ile sarmalama (list items için)
  Widget withStaggerAnimation({
    required int index,
    Duration duration = const Duration(milliseconds: 300),
    double staggerDelay = 0.1,
  }) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: duration,
        vsync: WidgetsBinding.instance,
      )..forward(),
      builder: (context, child) {
        final delay = staggerDelay * index;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: AnimationController(
              duration: duration,
              vsync: WidgetsBinding.instance,
            )..forward(),
            curve: Interval(delay, 1.0, curve: Curves.easeOut),
          ),
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: this,
    );
  }
}

/// Özel nöromorfik animasyon controller'ları
class NeumorphismAnimationController {
  static AnimationController createHoverController(TickerProvider vsync) {
    return AnimationController(
      duration: NeumorphismStandards.animationFast,
      vsync: vsync,
    );
  }

  static AnimationController createPressController(TickerProvider vsync) {
    return AnimationController(
      duration: NeumorphismStandards.animationFast,
      vsync: vsync,
    );
  }

  static AnimationController createFocusController(TickerProvider vsync) {
    return AnimationController(
      duration: NeumorphismStandards.animationMedium,
      vsync: vsync,
    );
  }

  static AnimationController createLoadingController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    )..repeat();
  }
}

/// Nöromorfik animasyon utility fonksiyonları
class NeumorphismAnimationUtils {
  /// Animasyon eğrilerini birleştir
  static Curve combineCurves(Curve first, Curve second) {
    return CurveTween(curve: first).chain(CurveTween(curve: second));
  }

  /// Özel nöromorfik eğri oluştur
  static Curve createNeumorphismCurve({
    double bounciness = 0.3,
    double speed = 0.8,
  }) {
    return Curves.easeInOut.transform(
      Curves.elasticOut.transform(Curves.easeInOut),
    );
  }

  /// Zaman tabanlı animasyon değeri hesapla
  static double calculateTimeBasedValue({
    required Duration time,
    required double frequency,
    required double amplitude,
  }) {
    return sin(time.inMilliseconds * frequency / 1000) * amplitude;
  }

  /// Parallax değeri hesapla
  static double calculateParallaxValue({
    required double scrollOffset,
    required double parallaxFactor,
    required double maxOffset,
  }) {
    return (scrollOffset * parallaxFactor).clamp(-maxOffset, maxOffset);
  }
}