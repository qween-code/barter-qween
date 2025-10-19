import 'package:flutter/material.dart';

/// Safe Text Widget that automatically handles overflow
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;
  final bool softWrap;
  final double? minWidth;
  final double? maxWidth;
  final bool enableAutoSizing;

  const SafeText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.semanticLabel,
    this.softWrap = true,
    this.minWidth,
    this.maxWidth,
    this.enableAutoSizing = false,
  }) : super(key: key);

  factory SafeText.heading(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    String? semanticLabel,
  }) {
    return SafeText(
      text: text,
      style: (style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      textAlign: textAlign,
      maxLines: 2,
    );
  }

  factory SafeText.body(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    String? semanticLabel,
  }) {
    return SafeText(
      text: text,
      style: (style ?? const TextStyle(fontSize: 14)),
      textAlign: textAlign,
      maxLines: 3,
    );
  }

  factory SafeText.caption(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    String? semanticLabel,
  }) {
    return SafeText(
      text: text,
      style: (style ?? const TextStyle(fontSize: 12)),
      textAlign: textAlign,
      maxLines: 2,
    );
  }

  factory SafeText.label(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    String? semanticLabel,
  }) {
    return SafeText(
      text: text,
      style: (style ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      textAlign: textAlign,
      maxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      
    );

    if (enableAutoSizing || minWidth != null || maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? 0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (enableAutoSizing) {
              return _buildAutoSizedText(textWidget, constraints);
            }
            return textWidget;
          },
        ),
      );
    }

    return textWidget;
  }

  Widget _buildAutoSizedText(Text textWidget, BoxConstraints constraints) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: textWidget,
    );
  }
}

/// Safe Text Field Widget for input fields
class SafeTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextAlign textAlign;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? semanticLabel;

  const SafeTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.style,
    this.hintStyle,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.disabledBorder,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48,
        maxHeight: 200,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          border: border,
          focusedBorder: focusedBorder,
          enabledBorder: enabledBorder,
          errorBorder: errorBorder,
          disabledBorder: disabledBorder,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          isDense: true,
        ),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onTap: onTap,
        onEditingComplete: onEditingComplete,
        validator: validator,
        enabled: enabled,
        autofocus: autofocus,
        focusNode: focusNode,
        
      ),
    );
  }
}

/// Enhanced text widget with overflow detection and smart resizing
class SmartText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool enableScroll;
  final bool enableTooltip;
  final String? tooltipText;
  final Widget? loadingWidget;

  const SmartText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.enableScroll = false,
    this.enableTooltip = true,
    this.tooltipText,
    this.loadingWidget,
  }) : super(key: key);

  @override
  State<SmartText> createState() => _SmartTextState();
}

class _SmartTextState extends State<SmartText> {
  bool _isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );

    if (widget.enableTooltip && widget.enableTooltip) {
      return Tooltip(
        message: widget.tooltipText ?? widget.text,
        child: widget.enableScroll
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: _isOverflowing ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                child: textWidget,
              )
            : textWidget,
      );
    }

    return widget.enableScroll
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: _isOverflowing ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: textWidget,
          )
        : textWidget;
  }
}
