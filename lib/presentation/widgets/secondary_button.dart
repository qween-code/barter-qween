import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/neuromorphic_effects.dart';

/// Ultra-Deep Neuromorphic Secondary Button
/// 8-layer medium depth shadows for secondary actions

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool enableUltraEffects;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height,
    this.enableUltraEffects = true,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isHovered = true);
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: RepaintBoundary(
            child: Container(
              width: widget.isFullWidth
                  ? double.infinity
                  : (widget.width ?? AppDimensions.buttonHeight8 * 3),
              height: widget.height ?? AppDimensions.buttonHeight8,
              decoration: BoxDecoration(
                color: isDisabled ? AppColors.surfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                border: Border.all(
                  color: isDisabled
                      ? AppColors.border
                      : (_isHovered ? AppColors.primary : AppColors.borderNeumorphism),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: isDisabled
                    ? []
                    : (widget.enableUltraEffects
                        ? NeuromorphicPresets.ButtonPresets.secondary(
                            isPressed: _isPressed,
                            isHovered: _isHovered,
                          )
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.buttonPadding6,
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    size: 20,
                                    color: isDisabled
                                        ? AppColors.textDisabled
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.text,
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: isDisabled
                                          ? AppColors.textDisabled
                                          : AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
}
