import 'package:flutter/material.dart';
import '../../../domain/entities/search/search_filter_entity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Advanced search filter bottom sheet
class FilterBottomSheet extends StatefulWidget {
  final SearchFilterEntity? currentFilter;
  final Function(SearchFilterEntity) onApply;

  const FilterBottomSheet({
    Key? key,
    this.currentFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> selectedCategories;
  late RangeValues priceRange;
  late double radiusKm;
  late List<String> selectedConditions;
  SortOption sortBy = SortOption.createdAt;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.currentFilter?.categories ?? [];
    priceRange = RangeValues(
      widget.currentFilter?.minPrice ?? 0,
      widget.currentFilter?.maxPrice ?? 10000,
    );
    radiusKm = widget.currentFilter?.radiusKm ?? 50;
    selectedConditions = widget.currentFilter?.conditions ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Filters',
                  style: AppTextStyles.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySection(),
                  const SizedBox(height: 24),
                  _buildPriceRangeSection(),
                  const SizedBox(height: 24),
                  _buildConditionSection(),
                  const SizedBox(height: 24),
                  _buildDistanceSection(),
                  const SizedBox(height: 24),
                  _buildSortSection(),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      'Electronics',
      'Fashion',
      'Books',
      'Gaming',
      'Home & Garden',
      'Sports',
      'Toys',
      'Music',
      'Art',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedCategories.add(category);
                  } else {
                    selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '₺${priceRange.start.toInt()}',
              style: AppTextStyles.bodyMedium,
            ),
            const Spacer(),
            Text(
              '₺${priceRange.end.toInt()}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '₺${priceRange.start.toInt()}',
            '₺${priceRange.end.toInt()}',
          ),
          onChanged: (values) {
            setState(() => priceRange = values);
          },
        ),
      ],
    );
  }

  Widget _buildConditionSection() {
    final conditions = ['New', 'Like New', 'Good', 'Fair'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Condition', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: conditions.map((condition) {
            final isSelected = selectedConditions.contains(condition);
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedConditions.add(condition);
                  } else {
                    selectedConditions.remove(condition);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Distance', style: AppTextStyles.titleMedium),
            const Spacer(),
            Text(
              '${radiusKm.toInt()} km',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        Slider(
          value: radiusKm,
          min: 1,
          max: 100,
          divisions: 99,
          label: '${radiusKm.toInt()} km',
          onChanged: (value) {
            setState(() => radiusKm = value);
          },
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        ...[
          SortOption.createdAt,
          SortOption.price,
          SortOption.viewCount,
          SortOption.favoriteCount,
        ].map((sort) {
          return RadioListTile<SortOption>(
            title: Text(sort.displayName),
            value: sort,
            groupValue: sortBy,
            onChanged: (value) {
              setState(() => sortBy = value!);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      selectedCategories = [];
      priceRange = const RangeValues(0, 10000);
      radiusKm = 50;
      selectedConditions = [];
      sortBy = SortOption.createdAt;
    });
  }

  void _applyFilters() {
    final filter = SearchFilterEntity(
      categories: selectedCategories.isEmpty ? null : selectedCategories,
      minPrice: priceRange.start == 0 ? null : priceRange.start,
      maxPrice: priceRange.end == 10000 ? null : priceRange.end,
      conditions: selectedConditions.isEmpty ? null : selectedConditions,
      radiusKm: radiusKm == 50 ? null : radiusKm,
      sortBy: sortBy,
    );
    
    widget.onApply(filter);
    Navigator.pop(context);
  }
}
