import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/neumorphism_standards.dart';
import '../../../core/theme/neuromorphic_effects.dart';

/// Ultra Advanced Neumorphism Container System
/// Pinterest seviyesi 3D derinlik şablonları ve çok katmanlı efektler

enum NeumorphismType {
  outset,      // Dışbükey efekt
  inset,       // İçbükey efekt
  flat,        // Düz efekt
  ultraOutset, // Ultra derinlikli dışbükey
  ultraInset,  // Ultra derinlikli içbükey
  cinematic,   // Sinematik efekt
  floating,    // Yüzen efekt
  embedded,    // Gömülü efekt
  morphing,    // Şekil değiştiren
  breathing,   // Nefes alan
}

enum CardDepth {
  shallow(1),    // Sığ derinlik
  medium(2),     // Orta derinlik
  deep(3),       // Derin
  ultra(4),      // Ultra derin
  cinematic(5),  // Sinematik
  mega(6);       // Mega derinlik

  const CardDepth(this.level);
  final int level;
}

enum CardShape {
  standard,      // Standart dikdörtgen
  rounded,       // Yuvarlatılmış
  circular,      // Dairesel
  organic,       // Organik şekil
  geometric,     // Geometrik
  fluid,         // Akışkan
}

/// Ultra gelişmiş nöromorfik container widget'ı
class NeumorphismContainer extends StatefulWidget {
  final Widget child;
  final NeumorphismType type;
  final CardDepth depth;
  final CardShape shape;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool isPressed;
  final bool isHovered;
  final bool isFocused;
  final VoidCallback? onTap;
  final VoidCallback? onHover;
  final VoidCallback? onFocus;
  final Duration animationDuration;
  final bool enableUltraEffects;
  final bool enableCinematicMode;
  final double? parallaxFactor;
  final bool enableLightTracking;
  final bool enableParallax;
  final ScrollController? scrollController;

  const NeumorphismContainer({
    super.key,
    required this.child,
    this.type = NeumorphismType.outset,
    this.depth = CardDepth.medium,
    this.shape = CardShape.standard,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.isPressed = false,
    this.isHovered = false,
    this.isFocused = false,
    this.onTap,
    this.onHover,
    this.onFocus,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableUltraEffects = true,
    this.enableCinematicMode = false,
    this.parallaxFactor,
    this.enableLightTracking = false,
    this.enableParallax = false,
    this.scrollController,
  });

  @override
  State<NeumorphismContainer> createState() => _NeumorphismContainerState();
}

class _NeumorphismContainerState extends State<NeumorphismContainer>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _focusController;
  late AnimationController _breathingController;

  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _pressScaleAnimation;
  late Animation<double> _focusScaleAnimation;
  late Animation<double> _breathingAnimation;

  bool _isHovered = false;
  bool _isFocused = false;
  Offset _lightPosition = const Offset(0, 0);
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _disposeAnimations();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _setupScrollListener() {
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.enableParallax && mounted) {
      setState(() {
        _scrollOffset = widget.scrollController?.offset ?? 0.0;
      });
    }
  }

  void _initializeAnimations() {
    // Hover animasyonu
    _hoverController = AnimationController(
      duration: AppDimensions.animation6,
      vsync: this,
    );
    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOutCubic),
    );

    // Press animasyonu
    _pressController = AnimationController(
      duration: AppDimensions.animation4,
      vsync: this,
    );
    _pressScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );

    // Focus animasyonu
    _focusController = AnimationController(
      duration: AppDimensions.animation8,
      vsync: this,
    );
    _focusScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOutCubic),
    );

    // Breathing animasyonu
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  void _disposeAnimations() {
    _hoverController.dispose();
    _pressController.dispose();
    _focusController.dispose();
    _breathingController.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _onHoverEnter(PointerEnterEvent event) {
    _isHovered = true;
    if (widget.enableLightTracking) {
      _updateLightPosition(event.localPosition);
    }
    if (widget.onHover != null) {
      _hoverController.forward();
      widget.onHover?.call();
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    _isHovered = false;
    if (!_isFocused) {
      _hoverController.reverse();
    }
  }

  void _onHover(PointerHoverEvent event) {
    if (widget.enableLightTracking && mounted) {
      setState(() {
        _updateLightPosition(event.localPosition);
      });
    }
  }

  void _updateLightPosition(Offset position) {
    _lightPosition = position;
  }

  void _onFocusChange(bool hasFocus) {
    _isFocused = hasFocus;
    if (hasFocus && widget.onFocus != null) {
      _focusController.forward();
      widget.onFocus?.call();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final parallaxOffset = widget.enableParallax
        ? NeuromorphicEffects.depth.calculateParallaxOffset(
            scrollOffset: _scrollOffset,
            depth: widget.depth.level.toDouble(),
            factor: widget.parallaxFactor ?? 0.05,
          )
        : Offset.zero;

    return Transform.translate(
      offset: parallaxOffset,
      child: MouseRegion(
        onEnter: _onHoverEnter,
        onExit: _onHoverExit,
        onHover: _onHover,
        child: Focus(
        onFocusChange: _onFocusChange,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _hoverController,
              _pressController,
              _focusController,
              _breathingController,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _getCurrentScale(),
                child: child,
              );
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: _getBorderRadius(),
                boxShadow: _getCurrentShadow(),
                gradient: _getCurrentGradient(),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  double _getCurrentScale() {
    double scale = 1.0;

    if (widget.isPressed) {
      scale = _pressScaleAnimation.value;
    } else if (widget.isFocused) {
      scale = _focusScaleAnimation.value;
    } else if (widget.isHovered) {
      scale = _hoverScaleAnimation.value;
    } else if (widget.type == NeumorphismType.breathing) {
      scale = _breathingAnimation.value;
    }

    return scale;
  }

  Color _getBackgroundColor() {
    Color baseColor = widget.backgroundColor ?? AppColors.surface;

    if (widget.enableCinematicMode) {
      return baseColor.withOpacity(0.95);
    }

    return baseColor;
  }

  BorderRadius _getBorderRadius() {
    double radius = widget.borderRadius;

    if (widget.enableCinematicMode) {
      radius = AppDimensions.radiusCinematic;
    }

    switch (widget.shape) {
      case CardShape.circular:
        return BorderRadius.circular(9999);
      case CardShape.rounded:
        return BorderRadius.circular(radius);
      case CardShape.organic:
        return BorderRadius.only(
          topLeft: Radius.circular(radius * 1.5),
          topRight: Radius.circular(radius * 0.8),
          bottomLeft: Radius.circular(radius * 0.9),
          bottomRight: Radius.circular(radius * 1.2),
        );
      case CardShape.geometric:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius * 0.6),
          bottomLeft: Radius.circular(radius * 1.4),
          bottomRight: Radius.circular(radius),
        );
      case CardShape.fluid:
        return BorderRadius.circular(radius * (1 + sin(DateTime.now().millisecondsSinceEpoch / 1000) * 0.1));
      default:
        return BorderRadius.circular(radius);
    }
  }

  List<BoxShadow> _getCurrentShadow() {
    if (widget.enableUltraEffects) {
      // Use new depth-aware shadow system
      List<BoxShadow> baseShadows;

      switch (widget.type) {
        case NeumorphismType.ultraOutset:
        case NeumorphismType.outset:
          baseShadows = NeuromorphicEffects.depth.createDepthAwareShadows(
            depth: widget.depth.level.toDouble(),
            isPressed: widget.isPressed,
            isHovered: widget.isHovered || _isHovered,
          );
          break;
        case NeumorphismType.ultraInset:
        case NeumorphismType.inset:
          baseShadows = NeuromorphicPresets.InputPresets.textField(
            isFocused: widget.isFocused || _isFocused,
          );
          break;
        case NeumorphismType.cinematic:
          baseShadows = NeuromorphicPresets.CardPresets.hero(
            isHovered: widget.isHovered || _isHovered,
          );
          if (widget.enableCinematicMode) {
            baseShadows = [
              ...baseShadows,
              ...NeuromorphicEffects.lighting.createAmbientGlow(
                glowColor: AppColors.primary,
                intensity: 0.7,
                radius: 35.0,
              ),
            ];
          }
          break;
        case NeumorphismType.floating:
          baseShadows = NeuromorphicPresets.CardPresets.floating();
          break;
        case NeumorphismType.embedded:
          baseShadows = [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ];
          break;
        case NeumorphismType.morphing:
          baseShadows = NeuromorphicEffects.animator.createMorphingShadows(
            stateShadows: NeumorphismStandards.neumorphismUltraOutsetShadow,
            targetShadows: NeumorphismStandards.neumorphismHoverShadow,
            progress: (widget.isHovered || _isHovered) ? 1.0 : 0.0,
          );
          break;
        case NeumorphismType.breathing:
          baseShadows = NeuromorphicEffects.animator.createBreathingShadows(
            baseShadows: NeumorphismStandards.neumorphismUltraOutsetShadow,
            animationValue: _breathingAnimation.value,
            intensity: 0.3,
          );
          break;
        default:
          baseShadows = NeuromorphicEffects.depth.createDepthAwareShadows(
            depth: widget.depth.level.toDouble(),
            isPressed: widget.isPressed,
            isHovered: widget.isHovered || _isHovered,
          );
      }

      // Apply light tracking if enabled
      if (widget.enableLightTracking && _isHovered) {
        final lightAngle = atan2(_lightPosition.dy, _lightPosition.dx) * (180 / pi);
        baseShadows = [
          ...baseShadows,
          ...NeuromorphicEffects.lighting.createRimLight(
            angle: lightAngle,
            intensity: 0.6,
          ),
        ];
      }

      return baseShadows;
    }

    if (widget.enableCinematicMode) {
      return [
        ...NeumorphismStandards.neumorphismCinematicShadow,
        ...NeuromorphicEffects.lighting.createAmbientGlow(
          glowColor: AppColors.primary,
          intensity: 0.8,
          radius: 30.0,
        ),
      ];
    }

    return AppColors.neumorphismOutsetShadow;
  }

  LinearGradient? _getCurrentGradient() {
    if (!widget.enableUltraEffects) return null;

    switch (widget.type) {
      case NeumorphismType.cinematic:
        return AppColors.cinematicGradient;
      case NeumorphismType.floating:
        return AppColors.floatingGradient;
      case NeumorphismType.embedded:
        return AppColors.ultraGlassGradient;
      default:
        return AppColors.ultraNeumorphismSurfaceGradient;
    }
  }
}

/// Ultra gelişmiş nöromorfik card koleksiyonu
class NeumorphismCardCollection {
  /// Hero card - Ana sayfalar için
  static Widget heroCard({
    required Widget child,
    required VoidCallback onTap,
    CardDepth depth = CardDepth.cinematic,
    double height = 280,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.cinematic,
      depth: depth,
      shape: CardShape.rounded,
      borderRadius: AppDimensions.radiusCinematic,
      height: height,
      onTap: onTap,
      enableUltraEffects: true,
      enableCinematicMode: true,
    );
  }

  /// Product card - Ürün listeleri için
  static Widget productCard({
    required Widget child,
    required VoidCallback onTap,
    CardDepth depth = CardDepth.deep,
    bool isHovered = false,
    bool isFocused = false,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.ultraOutset,
      depth: depth,
      shape: CardShape.standard,
      borderRadius: AppDimensions.radius20,
      onTap: onTap,
      isHovered: isHovered,
      isFocused: isFocused,
      enableUltraEffects: true,
    );
  }

  /// Floating card - Yüzen bilgi kartları için
  static Widget floatingCard({
    required Widget child,
    CardDepth depth = CardDepth.medium,
    double width = 200,
    double height = 100,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.floating,
      depth: depth,
      shape: CardShape.rounded,
      borderRadius: AppDimensions.radius24,
      width: width,
      height: height,
      enableUltraEffects: true,
    );
  }

  /// Embedded card - Diğer kartlar içinde gömülü
  static Widget embeddedCard({
    required Widget child,
    CardDepth depth = CardDepth.shallow,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.embedded,
      depth: depth,
      shape: CardShape.standard,
      borderRadius: AppDimensions.radius12,
      enableUltraEffects: true,
    );
  }

  /// Morphing card - İnteraktif şekil değiştiren
  static Widget morphingCard({
    required Widget child,
    required bool isActive,
    CardDepth depth = CardDepth.medium,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.morphing,
      depth: depth,
      shape: isActive ? CardShape.organic : CardShape.standard,
      borderRadius: isActive ? AppDimensions.radius24 : AppDimensions.radius16,
      isHovered: isActive,
      enableUltraEffects: true,
    );
  }

  /// Breathing card - Canlı nefes efekti
  static Widget breathingCard({
    required Widget child,
    CardDepth depth = CardDepth.medium,
  }) {
    return NeumorphismContainer(
      child: child,
      type: NeumorphismType.breathing,
      depth: depth,
      shape: CardShape.standard,
      borderRadius: AppDimensions.radius20,
      enableUltraEffects: true,
    );
  }

  /// Glass card - Cam efekti
  static Widget glassCard({
    required Widget child,
    CardDepth depth = CardDepth.medium,
    double borderRadius = 20.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: AppColors.ultraGlassGradient,
        boxShadow: [
          ...NeumorphismStandards.neumorphismUltraOutsetShadow,
          BoxShadow(
            color: AppColors.surfaceLight.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Özel 3D derinlik efektleri için utility class
class NeumorphismDepthUtils {
  /// Derinlik seviyesine göre gölge hesapla
  static List<BoxShadow> calculateDepthShadow({
    required CardDepth depth,
    required NeumorphismType type,
    bool isHovered = false,
    bool isPressed = false,
  }) {
    final baseMultiplier = depth.level * 0.3;

    switch (type) {
      case NeumorphismType.ultraOutset:
        return [
          BoxShadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.9 * baseMultiplier),
            blurRadius: 20 * baseMultiplier,
            offset: Offset(-8 * baseMultiplier, -8 * baseMultiplier),
          ),
          BoxShadow(
            color: const Color(0x00000000).withOpacity(0.8 * baseMultiplier),
            blurRadius: 20 * baseMultiplier,
            offset: Offset(8 * baseMultiplier, 8 * baseMultiplier),
          ),
        ];
      case NeumorphismType.cinematic:
        return [
          BoxShadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.95 * baseMultiplier),
            blurRadius: 30 * baseMultiplier,
            offset: Offset(-15 * baseMultiplier, -15 * baseMultiplier),
          ),
          BoxShadow(
            color: const Color(0x00000000).withOpacity(0.85 * baseMultiplier),
            blurRadius: 30 * baseMultiplier,
            offset: Offset(15 * baseMultiplier, 15 * baseMultiplier),
          ),
        ];
      default:
        return NeumorphismStandards.neumorphismUltraOutsetShadow;
    }
  }

  /// Parallax derinlik efekti hesapla
  static double calculateParallaxDepth({
    required double scrollOffset,
    required CardDepth depth,
    double baseFactor = 0.1,
  }) {
    return scrollOffset * baseFactor * depth.level;
  }

  /// Zaman tabanlı derinlik animasyonu
  static double calculateTimeBasedDepth({
    required Duration time,
    required CardDepth depth,
    double baseDepth = 1.0,
  }) {
    final timeValue = sin(time.inMilliseconds / 1000) * 0.1;
    return baseDepth + (timeValue * depth.level * 0.2);
  }
}