import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS SORT OPTIONS
///
/// Features:
/// - Sort dropdown
/// - Sort options (relevance, price, distance, newest)
/// - Visual feedback
class WorldClassSortOptions extends StatelessWidget {
  final String sortBy;
  final Function(String) onSortChanged;

  const WorldClassSortOptions({
    Key? key,
    required this.sortBy,
    required this.onSortChanged,
  }) : super(key: key);

  final Map<String, String> _sortOptions = const {
    'relevance': 'Most Relevant',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'distance': 'Distance',
    'newest': 'Newest First',
    'oldest': 'Oldest First',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: WorldClassDesignSystem.spacingM,
      ),
      child: Row(
        children: [
          Icon(
            Icons.sort_rounded,
            size: WorldClassDesignSystem.iconS,
            color: WorldClassDesignSystem.secondaryText,
          ),

          const SizedBox(width: WorldClassDesignSystem.spacingS),

          Text(
            'Sort by:',
            style: WorldClassDesignSystem.labelMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),

          const SizedBox(width: WorldClassDesignSystem.spacingS),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sortBy,
                isExpanded: true,
                style: WorldClassDesignSystem.labelMedium.copyWith(
                  color: WorldClassDesignSystem.primaryText,
                  fontWeight: FontWeight.w600,
                ),
                items: _sortOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
