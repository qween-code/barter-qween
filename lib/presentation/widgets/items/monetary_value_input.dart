import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Monetary Value Input Widget
/// TL currency input with formatting and validation
class MonetaryValueInput extends StatefulWidget {
  final TextEditingController? controller;
  final double? initialValue;
  final String? labelText;
  final String? hintText;
  final Function(double?)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const MonetaryValueInput({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<MonetaryValueInput> createState() => _MonetaryValueInputState();
}

class _MonetaryValueInputState extends State<MonetaryValueInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    if (widget.initialValue != null && _controller.text.isEmpty) {
      _controller.text = widget.initialValue!.toStringAsFixed(0);
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Max 10 digits
          ],
          validator: widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir değer girin';
                }
                final numValue = double.tryParse(value);
                if (numValue == null || numValue <= 0) {
                  return 'Geçerli bir değer girin';
                }
                return null;
              },
          onChanged: (value) {
            final numValue = double.tryParse(value);
            if (widget.onChanged != null) {
              widget.onChanged!(numValue);
            }
          },
          style: AppTextStyles.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? '0',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Text(
                '₺',
                style: AppTextStyles.h6.copyWith(
                  color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            suffixText: 'TL',
            suffixStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surface
                : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.borderDefault,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.borderDefault,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'Ürününüzün tahmini değerini girin',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
