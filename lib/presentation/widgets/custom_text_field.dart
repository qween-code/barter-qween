import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/minimal_design_system.dart';

/// Ultra Advanced Neumorphism Search Bar & Text Field System
/// Pinterest seviyesi gömülü nöromorfik tasarım ve dinamik efektler

enum TextFieldSize {
  ultraSmall(AppDimensions.inputHeight2, AppDimensions.inputPadding6),
  small(AppDimensions.inputHeight4, AppDimensions.inputPadding8),
  medium(AppDimensions.inputHeight8, AppDimensions.inputPadding10),
  large(AppDimensions.inputHeight12, AppDimensions.inputPadding12),
  ultra(AppDimensions.inputHeight16, AppDimensions.inputPadding16),
  cinematic(AppDimensions.inputHeightCinematic, AppDimensions.inputPadding20),
  mega(AppDimensions.inputHeightUltra, AppDimensions.inputPadding24);

  const TextFieldSize(this.height, this.padding);
  final double height;
  final double padding;
}

enum TextFieldState {
  normal,
  focused,
  error,
  disabled,
  loading,
  success,
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextFieldSize size;
  final bool enableUltraEffects;
  final bool enableCinematicMode;
  final bool isSearchBar;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.size = TextFieldSize.medium,
    this.enableUltraEffects = true,
    this.enableCinematicMode = false,
    this.isSearchBar = false,
    this.onFocus,
    this.onBlur,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with TickerProviderStateMixin {
  // late AnimationController _focusController;
  // late AnimationController _hoverController;
  late AnimationController _loadingController;
  late AnimationController _shakeController;

  late Animation<double> _focusScaleAnimation;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _borderAnimation;
  late Animation<List<BoxShadow>> _shadowAnimation;
  late Animation<double> _shakeAnimation;

  final FocusNode _focusNode = FocusNode();
  TextFieldState _currentState = TextFieldState.normal;
  bool _isHovered = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusNode();
  }

  @override
  void dispose() {
    _disposeAnimations();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Simplified animations for minimal design
    _focusScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    // Border animasyonu
    _borderAnimation = Tween<double>(
      begin: AppDimensions.inputBorderWidth1,
      end: AppDimensions.inputBorderWidth3,
    ).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    // Shadow animasyonu
    _shadowAnimation = TweenSequence<List<BoxShadow>>([
      TweenSequenceItem(
        tween: Tween<List<BoxShadow>>(
          begin: MinimalDesignSystem.neumorphismUltraOutsetShadow,
          end: MinimalDesignSystem.neumorphismHoverShadow,
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<List<BoxShadow>>(
          begin: MinimalDesignSystem.neumorphismHoverShadow,
          end: MinimalDesignSystem.neumorphismUltraOutsetShadow,
        ),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    // Loading animasyonu
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Shake animasyonu (error için)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -10), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _disposeAnimations() {
    // _focusController.dispose();
    // _hoverController.dispose();
    _loadingController.dispose();
    _shakeController.dispose();
  }

  void _setupFocusNode() {
    _focusNode.addListener(() {
      setState(() {
        final hasFocus = _focusNode.hasFocus;
        if (hasFocus && widget.enabled) {
          _currentState = TextFieldState.focused;
          // _focusController.forward();
          widget.onFocus?.call();
        } else {
          _currentState = _hasError ? TextFieldState.error : TextFieldState.normal;
          // _focusController.reverse();
          widget.onBlur?.call();
        }
      });
    });
  }

  void _updateState(TextFieldState newState) {
    if (_currentState != newState) {
      setState(() => _currentState = newState);
    }
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (widget.enabled && !_focusNode.hasFocus) {
      _isHovered = true;
      _updateState(TextFieldState.normal);
      // _hoverController.forward();
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    _isHovered = false;
    if (!_focusNode.hasFocus) {
      _updateState(_hasError ? TextFieldState.error : TextFieldState.normal);
      // _hoverController.reverse();
    }
  }

  void _showError() {
    _hasError = true;
    _updateState(TextFieldState.error);
    _shakeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final TextFieldSize fieldSize = widget.size;

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          // _focusController,
          // _hoverController,
          _shakeController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Transform.scale(
              scale: _getCurrentScale(),
              child: child,
            ),
          );
        },
        child: Container(
          height: fieldSize.height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(
              widget.enableCinematicMode
                  ? AppDimensions.radiusCinematic
                  : AppDimensions.radius16,
            ),
            boxShadow: _getCurrentShadow(),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            validator: (value) {
              final error = widget.validator?.call(value);
              if (error != null) {
                _showError();
              } else {
                _hasError = false;
                if (_focusNode.hasFocus) {
                  _updateState(TextFieldState.focused);
                } else {
                  _updateState(TextFieldState.normal);
                }
              }
              return error;
            },
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            onChanged: (value) {
              if (_hasError && widget.validator?.call(value) == null) {
                _hasError = false;
                _updateState(_focusNode.hasFocus ? TextFieldState.focused : TextFieldState.normal);
              }
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            style: _getTextStyle(),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedSwitcher(
                      duration: AppDimensions.animation4,
                      child: Icon(
                        widget.prefixIcon,
                        key: ValueKey('${widget.prefixIcon}_${_currentState}'),
                        color: _getIconColor(),
                        size: _getIconSize(),
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon ?? _buildSearchSuffix(),
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: fieldSize.padding,
                vertical: (fieldSize.height - 24) / 2,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              labelStyle: _getLabelStyle(),
              hintStyle: _getHintStyle(),
              errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  double _getCurrentScale() {
    if (_currentState == TextFieldState.focused) {
      return _focusScaleAnimation.value;
    } else if (_isHovered) {
      return _hoverScaleAnimation.value;
    }
    return 1.0;
  }

  Color _getBackgroundColor() {
    if (!widget.enabled) return AppColors.surfaceVariant;

    switch (_currentState) {
      case TextFieldState.focused:
        return AppColors.surface;
      case TextFieldState.error:
        return AppColors.errorUltraLight;
      case TextFieldState.success:
        return AppColors.successUltraLight;
      default:
        return AppColors.surface;
    }
  }

  List<BoxShadow> _getCurrentShadow() {
    if (!widget.enabled) return [];

    if (widget.enableUltraEffects) {
      // Use new InputPresets with 8-layer inset neuromorphic effect
      switch (_currentState) {
        case TextFieldState.focused:
          return MinimalDesignSystem.cardShadow;
        case TextFieldState.error:
          return [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 0),
              spreadRadius: 2,
            ),
            ...MinimalDesignSystem.cardShadow,
          ];
        case TextFieldState.success:
          return [
            BoxShadow(
              color: AppColors.success.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 0),
              spreadRadius: 2,
            ),
            ...MinimalDesignSystem.cardShadow,
          ];
        default:
          return MinimalDesignSystem.cardShadow;
      }
    }

    if (widget.enableCinematicMode) {
      return [
        ...MinimalDesignSystem.cardShadow,
      ];
    }

    return AppColors.neumorphismOutsetShadow;
  }

  TextStyle _getTextStyle() {
    if (widget.enableUltraEffects) {
      return AppTextStyles.embeddedInputText;
    }

    if (widget.enableCinematicMode) {
      return AppTextStyles.ultraBodyLarge.copyWith(
        fontSize: 20,
        shadows: [
          Shadow(
            color: const Color(0x00000000).withOpacity(0.6),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
          Shadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-1, -1),
          ),
        ],
      );
    }

    return AppTextStyles.inputText;
  }

  TextStyle _getLabelStyle() {
    Color color;
    switch (_currentState) {
      case TextFieldState.focused:
        color = AppColors.primary;
        break;
      case TextFieldState.error:
        color = AppColors.error;
        break;
      case TextFieldState.success:
        color = AppColors.success;
        break;
      default:
        color = AppColors.textSecondary;
    }

    if (widget.enableUltraEffects) {
      return AppTextStyles.embeddedTitleMedium.copyWith(color: color);
    }

    return AppTextStyles.inputLabel.copyWith(color: color);
  }

  TextStyle _getHintStyle() {
    if (widget.enableUltraEffects) {
      return AppTextStyles.insetBodyMedium.copyWith(
        color: AppColors.textTertiary,
      );
    }

    return AppTextStyles.inputLabel.copyWith(color: AppColors.textTertiary);
  }

  Color _getIconColor() {
    switch (_currentState) {
      case TextFieldState.focused:
        return AppColors.primary;
      case TextFieldState.error:
        return AppColors.error;
      case TextFieldState.success:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case TextFieldSize.ultraSmall:
        return AppDimensions.icon12;
      case TextFieldSize.small:
        return AppDimensions.icon16;
      case TextFieldSize.medium:
        return AppDimensions.icon20;
      case TextFieldSize.large:
        return AppDimensions.icon24;
      case TextFieldSize.ultra:
        return AppDimensions.icon28;
      case TextFieldSize.cinematic:
        return AppDimensions.icon32;
      case TextFieldSize.mega:
        return AppDimensions.icon36;
    }
  }

  Widget? _buildSearchSuffix() {
    if (!widget.isSearchBar) return null;

    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _loadingController.value * 2 * 3.14159,
          child: IconButton(
            onPressed: widget.controller?.text.isNotEmpty == true
                ? () => widget.controller?.clear()
                : null,
            icon: Icon(
              widget.controller?.text.isNotEmpty == true
                  ? Icons.clear
                  : Icons.search,
              color: _getIconColor(),
              size: _getIconSize(),
            ),
          ),
        );
      },
    );
  }
}

/// Ultra gelişmiş nöromorfik search bar koleksiyonu
class NeumorphismSearchBarCollection {
  /// Hero search bar - Ana sayfa için
  static Widget heroSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String? hintText,
    VoidCallback? onFocus,
    VoidCallback? onBlur,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Ne arıyorsunuz?',
      prefixIcon: Icons.search,
      onSubmitted: onSearch,
      size: TextFieldSize.cinematic,
      enableCinematicMode: true,
      enableUltraEffects: true,
      isSearchBar: true,
      onFocus: onFocus,
      onBlur: onBlur,
    );
  }

  /// Floating search bar - Navigasyon için
  static Widget floatingSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius24),
        boxShadow: MinimalDesignSystem.neumorphismFloatingShadow,
      ),
      child: CustomTextField(
        controller: controller,
        hintText: hintText ?? 'Ara...',
        prefixIcon: Icons.search,
        onSubmitted: onSearch,
        size: TextFieldSize.large,
        enableUltraEffects: true,
        isSearchBar: true,
      ),
    );
  }

  /// Embedded search bar - Card'lar içinde
  static Widget embeddedSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String? hintText,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Ara...',
      prefixIcon: Icons.search,
      onSubmitted: onSearch,
      size: TextFieldSize.medium,
      enableUltraEffects: true,
      isSearchBar: true,
    );
  }

  /// Compact search bar - Toolbar için
  static Widget compactSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String? hintText,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Ara',
      prefixIcon: Icons.search,
      onSubmitted: onSearch,
      size: TextFieldSize.small,
      enableUltraEffects: true,
      isSearchBar: true,
    );
  }
}