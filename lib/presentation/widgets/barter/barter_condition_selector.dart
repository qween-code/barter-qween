import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/barter_condition_entity.dart';
import '../../../domain/entities/item_entity.dart';

/// Barter Condition Selector Widget
/// Allows users to select barter conditions for their item
class BarterConditionSelector extends StatefulWidget {
  final BarterConditionType selectedType;
  final Function(BarterConditionType) onTypeChanged;
  final double? cashAmount;
  final Function(double?)? onCashAmountChanged;
  final List<String>? selectedCategories;
  final Function(List<String>)? onCategoriesChanged;

  const BarterConditionSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.cashAmount,
    this.onCashAmountChanged,
    this.selectedCategories,
    this.onCategoriesChanged,
  });

  @override
  State<BarterConditionSelector> createState() =>
      _BarterConditionSelectorState();
}

class _BarterConditionSelectorState extends State<BarterConditionSelector> {
  late BarterConditionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Takas Şartları',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Bu ürün için hangi takas şartlarını kabul ediyorsunuz?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),

        // Condition Type Buttons
        _buildConditionButton(
          type: BarterConditionType.directSwap,
          icon: Icons.swap_horiz,
          title: 'Direkt Takas',
          description: 'Ürünümü başka bir ürünle direkt takas ederim',
        ),
        const SizedBox(height: AppDimensions.spacing8),

        _buildConditionButton(
          type: BarterConditionType.cashPlus,
          icon: Icons.add_card,
          title: 'Ürünüm + Para',
          description: 'Ürünüme ek para ekleyerek takas yaparım',
        ),
        const SizedBox(height: AppDimensions.spacing8),

        _buildConditionButton(
          type: BarterConditionType.cashMinus,
          icon: Icons.attach_money,
          title: 'Para Farkı Alırım',
          description: 'Ürünüm daha değerli, karşı taraf para eklemeli',
        ),
        const SizedBox(height: AppDimensions.spacing8),

        _buildConditionButton(
          type: BarterConditionType.categorySpecific,
          icon: Icons.category,
          title: 'Belirli Kategoriler',
          description: 'Sadece seçtiğim kategorilerdeki ürünlerle takas',
        ),
        const SizedBox(height: AppDimensions.spacing8),

        _buildConditionButton(
          type: BarterConditionType.flexible,
          icon: Icons.done_all,
          title: 'Esnek',
          description: 'Tüm tekliflere açığım',
        ),

        // Show additional options based on selected type
        if (_selectedType == BarterConditionType.cashPlus ||
            _selectedType == BarterConditionType.cashMinus)
          _buildCashAmountInput(),

        if (_selectedType == BarterConditionType.categorySpecific)
          _buildCategorySelector(),
      ],
    );
  }

  Widget _buildConditionButton({
    required BarterConditionType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        widget.onTypeChanged(type);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashAmountInput() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para Miktarı',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          TextFormField(
            initialValue: widget.cashAmount?.toStringAsFixed(0),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              prefixText: '₺ ',
              suffixText: 'TL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (widget.onCashAmountChanged != null) {
                widget.onCashAmountChanged!(amount);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kabul Ettiğim Kategoriler',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItemCategory.all.take(6).map((category) {
              final isSelected =
                  widget.selectedCategories?.contains(category) ?? false;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (widget.onCategoriesChanged != null) {
                    List<String> newCategories =
                        List.from(widget.selectedCategories ?? []);
                    if (selected) {
                      newCategories.add(category);
                    } else {
                      newCategories.remove(category);
                    }
                    widget.onCategoriesChanged!(newCategories);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
