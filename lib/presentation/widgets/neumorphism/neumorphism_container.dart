import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Neumorphism Container Widget
/// Doğal yeşil efektli özel container widget'ı
enum NeumorphismType {
  outset,  // Dışbükey efekt
  inset,   // İçbükey efekt
  flat,    // Düz efekt
}

/// Özel neumorphism efektli container widget'ı
class NeumorphismContainer extends StatelessWidget {
  final Widget child;
  final NeumorphismType type;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool isPressed;
  final VoidCallback? onTap;

  const NeumorphismContainer({
    super.key,
    required this.child,
    this.type = NeumorphismType.outset,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.isPressed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _getShadowForType(type, isPressed),
        ),
        child: child,
      ),
    );
  }

  List<BoxShadow> _getShadowForType(NeumorphismType type, bool isPressed) {
    switch (type) {
      case NeumorphismType.outset:
        return isPressed
            ? AppColors.neumorphismInsetShadow
            : AppColors.neumorphismOutsetShadow;
      case NeumorphismType.inset:
        return AppColors.neumorphismInsetShadow;
      case NeumorphismType.flat:
        return [];
    }
  }
}

/// Neumorphism buton widget'ı
class NeumorphismButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final NeumorphismType type;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const NeumorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.type = NeumorphismType.outset,
    this.borderRadius = 16.0,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<NeumorphismButton> createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: NeumorphismContainer(
        type: widget.type,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        isPressed: _isPressed,
        backgroundColor: AppColors.surface,
        child: widget.child,
      ),
    );
  }
}

/// Neumorphism card widget'ı
class NeumorphismCard extends StatelessWidget {
  final Widget child;
  final NeumorphismType type;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const NeumorphismCard({
    super.key,
    required this.child,
    this.type = NeumorphismType.outset,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _getShadowForType(type),
        ),
        child: child,
      ),
    );
  }

  List<BoxShadow> _getShadowForType(NeumorphismType type) {
    switch (type) {
      case NeumorphismType.outset:
        return AppColors.neumorphismOutsetShadow;
      case NeumorphismType.inset:
        return AppColors.neumorphismInsetShadow;
      case NeumorphismType.flat:
        return [];
    }
  }
}

/// Neumorphism input field widget'ı
class NeumorphismTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPressed;

  const NeumorphismTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPressed = false,
  });

  @override
  State<NeumorphismTextField> createState() => _NeumorphismTextFieldState();
}

class _NeumorphismTextFieldState extends State<NeumorphismTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphismContainer(
      type: _isFocused ? NeumorphismType.inset : NeumorphismType.outset,
      borderRadius: 16.0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
              : null,
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}