import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/minimal_design_system.dart';

/// Ultra Advanced Neumorphism Primary Button
/// Pinterest seviyesi çok katmanlı nöromorfik efektler ve sinematik geçişler

enum ButtonSize {
  ultraSmall(AppDimensions.buttonHeight2, AppDimensions.buttonPadding2),
  small(AppDimensions.buttonHeight4, AppDimensions.buttonPadding4),
  medium(AppDimensions.buttonHeight8, AppDimensions.buttonPadding6),
  large(AppDimensions.buttonHeight12, AppDimensions.buttonPadding8),
  ultra(AppDimensions.buttonHeight16, AppDimensions.buttonPadding12),
  cinematic(AppDimensions.buttonHeightCinematic, AppDimensions.buttonPadding16),
  mega(AppDimensions.buttonHeightMega, AppDimensions.buttonPadding20);

  const ButtonSize(this.height, this.padding);
  final double height;
  final double padding;
}

enum ButtonState { normal, hover, pressed, loading, disabled, focused }

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final ButtonSize size;
  final bool enableUltraEffects;
  final bool enableCinematicMode;
  final VoidCallback? onHover;
  final VoidCallback? onFocus;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.enableUltraEffects = true,
    this.enableCinematicMode = false,
    this.onHover,
    this.onFocus,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with TickerProviderStateMixin {
  ButtonState _currentState = ButtonState.normal;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  void _updateState(ButtonState newState) {
    if (_currentState != newState) {
      setState(() => _currentState = newState);
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _updateState(ButtonState.pressed);
      // _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_currentState == ButtonState.pressed) {
      // _pressController.reverse();
      _updateState(_isHovered ? ButtonState.hover : ButtonState.normal);
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (_currentState == ButtonState.pressed) {
      // _pressController.reverse();
      _updateState(_isHovered ? ButtonState.hover : ButtonState.normal);
    }
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (widget.onPressed != null && !widget.isLoading) {
      _isHovered = true;
      _updateState(ButtonState.hover);
      // _hoverController.forward();
      widget.onHover?.call();
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    _isHovered = false;
    if (_currentState != ButtonState.pressed) {
      _updateState(ButtonState.normal);
      // _hoverController.reverse();
    }
  }

  void _onFocusChange(bool hasFocus) {
    if (hasFocus && widget.onPressed != null && !widget.isLoading) {
      _updateState(ButtonState.focused);
      // _focusController.forward();
      widget.onFocus?.call();
    } else if (!hasFocus && _currentState == ButtonState.focused) {
      _updateState(_isHovered ? ButtonState.hover : ButtonState.normal);
      // _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;
    final ButtonSize buttonSize = widget.size;

    if (isDisabled) {
      _updateState(ButtonState.disabled);
    }

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: Focus(
        onFocusChange: _onFocusChange,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedScale(
            scale: _getCurrentScale(),
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: widget.isFullWidth
                  ? double.infinity
                  : (widget.width ?? buttonSize.height * 3),
              height: widget.height ?? buttonSize.height,
              decoration: BoxDecoration(
                gradient: _getCurrentGradient(isDisabled),
                borderRadius: BorderRadius.circular(
                  widget.enableCinematicMode
                      ? AppDimensions.radiusCinematic
                      : AppDimensions.radius16,
                ),
                boxShadow: _getCurrentShadow(isDisabled),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(
                    widget.enableCinematicMode
                        ? AppDimensions.radiusCinematic
                        : AppDimensions.radius16,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonSize.padding,
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? _buildLoadingIndicator()
                          : _buildButtonContent(isDisabled),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getCurrentScale() {
    switch (_currentState) {
      case ButtonState.hover:
        return 1.02;
      case ButtonState.pressed:
        return 0.97;
      case ButtonState.focused:
        return 1.01;
      default:
        return 1.0;
    }
  }

  LinearGradient? _getCurrentGradient(bool isDisabled) {
    if (isDisabled) return null;

    if (widget.enableUltraEffects) {
      return AppColors.ultraNeumorphismButtonGradient;
    }

    if (widget.enableCinematicMode) {
      return AppColors.cinematicGradient;
    }

    return AppColors.primaryGradient;
  }

  List<BoxShadow> _getCurrentShadow(bool isDisabled) {
    if (isDisabled) return MinimalDesignSystem.neumorphismDisabledShadow;

    if (widget.enableUltraEffects) {
      // Use new ButtonPresets with 12-layer ultra-deep shadows
      switch (_currentState) {
        case ButtonState.hover:
          return MinimalDesignSystem.cardShadow;
        case ButtonState.pressed:
          return MinimalDesignSystem.cardShadow;
        case ButtonState.focused:
          return [
            ...MinimalDesignSystem.cardShadow,
            ...MinimalDesignSystem.cardShadow,
          ];
        default:
          return MinimalDesignSystem.cardShadow;
      }
    }

    if (widget.enableCinematicMode) {
      return [
        ...MinimalDesignSystem.neumorphismCinematicShadow,
        ...MinimalDesignSystem.cardShadow,
      ];
    }

    return AppColors.neumorphismOutsetShadow;
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: AppDimensions.icon20,
      height: AppDimensions.icon20,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isDisabled) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          AnimatedSwitcher(
            duration: AppDimensions.animation6,
            child: Icon(
              widget.icon,
              key: ValueKey(widget.icon),
              color: _getIconColor(isDisabled),
              size: _getIconSize(),
            ),
          ),
          SizedBox(width: AppDimensions.spacing8),
        ],
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: AppDimensions.animation4,
            style: _getTextStyle(isDisabled),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Color _getIconColor(bool isDisabled) {
    if (isDisabled) return AppColors.textDisabled;
    return AppColors.textOnPrimary;
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.ultraSmall:
        return AppDimensions.icon12;
      case ButtonSize.small:
        return AppDimensions.icon16;
      case ButtonSize.medium:
        return AppDimensions.icon20;
      case ButtonSize.large:
        return AppDimensions.icon24;
      case ButtonSize.ultra:
        return AppDimensions.icon28;
      case ButtonSize.cinematic:
        return AppDimensions.icon32;
      case ButtonSize.mega:
        return AppDimensions.icon36;
    }
  }

  TextStyle _getTextStyle(bool isDisabled) {
    if (isDisabled) {
      return AppTextStyles.buttonLarge.copyWith(color: AppColors.textDisabled);
    }

    if (widget.enableUltraEffects) {
      return AppTextStyles.ultraButtonLarge;
    }

    if (widget.enableCinematicMode) {
      return AppTextStyles.ultraButtonLarge.copyWith(
        fontSize: 20,
        shadows: [
          Shadow(
            color: const Color(0x00000000).withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
          Shadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.9),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      );
    }

    return AppTextStyles.buttonLarge;
  }
}

/// Ultra gelişmiş nöromorfik buton koleksiyonu
class NeumorphismButtonCollection {
  /// Hero buton - Ana sayfalar için
  static Widget heroButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      size: ButtonSize.cinematic,
      enableCinematicMode: true,
      enableUltraEffects: true,
    );
  }

  /// Floating action buton - Yüzen eylem butonu
  static Widget floatingButton({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return Container(
      width: AppDimensions.fabSizeCinematic,
      height: AppDimensions.fabSizeCinematic,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.floatingGradient,
        boxShadow: MinimalDesignSystem.neumorphismFloatingShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(
            AppDimensions.fabSizeCinematic / 2,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppDimensions.icon32,
          ),
        ),
      ),
    );
  }

  /// Ghost buton - Şeffaf arkaplanlı
  static Widget ghostButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary,
          width: AppDimensions.buttonBorderWidth2,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: MinimalDesignSystem.neumorphismUltraOutsetShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPadding8,
              vertical: AppDimensions.buttonHeight8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary),
                  SizedBox(width: AppDimensions.spacing8),
                ],
                Text(text, style: AppTextStyles.buttonMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Icon sadece buton - Minimal tasarım için
  static Widget iconButton({
    required VoidCallback onPressed,
    required IconData icon,
    bool isLoading = false,
    double size = 48.0,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        boxShadow: MinimalDesignSystem.neumorphismUltraOutsetShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          child: Icon(icon, color: AppColors.primary, size: size * 0.5),
        ),
      ),
    );
  }
}
