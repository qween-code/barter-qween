import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS FILTER SECTION
///
/// Features:
/// - Category chips
/// - Filter button
/// - Map view toggle
/// - Active filter count
class WorldClassFilterSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final VoidCallback onFiltersTap;
  final VoidCallback onMapToggle;
  final bool isMapView;

  const WorldClassFilterSection({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onFiltersTap,
    required this.onMapToggle,
    required this.isMapView,
  }) : super(key: key);

  final List<String> _categories = const [
    'All',
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Books',
    'Toys',
    'Automotive',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: WorldClassDesignSystem.spacingM,
      ),
      child: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(
                    right: WorldClassDesignSystem.spacingS,
                  ),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: WorldClassDesignSystem.labelMedium.copyWith(
                        color: isSelected
                            ? WorldClassDesignSystem.primaryWhite
                            : WorldClassDesignSystem.primaryText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      onCategoryChanged(category);
                    },
                    backgroundColor: WorldClassDesignSystem.borderLight,
                    selectedColor: WorldClassDesignSystem.primaryColor,
                    checkmarkColor: WorldClassDesignSystem.primaryWhite,
                    side: BorderSide(
                      color: isSelected
                          ? WorldClassDesignSystem.primaryColor
                          : WorldClassDesignSystem.borderColor,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: WorldClassDesignSystem.spacingM),

          // Filter and Map Toggle Row
          Row(
            children: [
              // Filter Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFiltersTap,
                  icon: Icon(
                    Icons.tune_rounded,
                    size: WorldClassDesignSystem.iconS,
                    color: WorldClassDesignSystem.primaryColor,
                  ),
                  label: Text(
                    'Filters',
                    style: WorldClassDesignSystem.labelMedium.copyWith(
                      color: WorldClassDesignSystem.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: WorldClassDesignSystem.primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        WorldClassDesignSystem.radiusM,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: WorldClassDesignSystem.spacingM,
                      vertical: WorldClassDesignSystem.spacingS,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: WorldClassDesignSystem.spacingM),

              // Map Toggle Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMapToggle,
                  icon: Icon(
                    isMapView ? Icons.grid_view_rounded : Icons.map_rounded,
                    size: WorldClassDesignSystem.iconS,
                    color: isMapView
                        ? WorldClassDesignSystem.primaryWhite
                        : WorldClassDesignSystem.primaryColor,
                  ),
                  label: Text(
                    isMapView ? 'List' : 'Map',
                    style: WorldClassDesignSystem.labelMedium.copyWith(
                      color: isMapView
                          ? WorldClassDesignSystem.primaryWhite
                          : WorldClassDesignSystem.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isMapView
                        ? WorldClassDesignSystem.primaryColor
                        : Colors.transparent,
                    side: BorderSide(
                      color: WorldClassDesignSystem.primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        WorldClassDesignSystem.radiusM,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: WorldClassDesignSystem.spacingM,
                      vertical: WorldClassDesignSystem.spacingS,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
