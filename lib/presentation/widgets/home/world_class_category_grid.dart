import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS CATEGORY GRID
///
/// Features:
/// - Category icons
/// - Grid layout
/// - Tap callbacks
/// - Visual feedback
class WorldClassCategoryGrid extends StatelessWidget {
  final Function(String) onCategoryTap;

  const WorldClassCategoryGrid({super.key, required this.onCategoryTap});

  static const _categories = <CategoryItem>[
    CategoryItem(
      id: 'Elektronik',
      label: 'Elektronik',
      icon: Icons.devices_other_rounded,
      color: Color(0xFF3B82F6),
    ),
    CategoryItem(
      id: 'Moda',
      label: 'Moda',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFEC4899),
    ),
    CategoryItem(
      id: 'Ev & Yaşam',
      label: 'Ev & Yaşam',
      icon: Icons.chair_alt_rounded,
      color: Color(0xFF10B981),
    ),
    CategoryItem(
      id: 'Kozmetik',
      label: 'Kozmetik',
      icon: Icons.brush_rounded,
      color: Color(0xFFF97316),
    ),
    CategoryItem(
      id: 'Spor & Outdoor',
      label: 'Spor & Outdoor',
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFF6366F1),
    ),
    CategoryItem(
      id: 'Anne & Bebek',
      label: 'Anne & Bebek',
      icon: Icons.child_friendly_rounded,
      color: Color(0xFFFF6584),
    ),
    CategoryItem(
      id: 'Süpermarket',
      label: 'Süpermarket',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFF22C55E),
    ),
    CategoryItem(
      id: 'Otomotiv',
      label: 'Otomotiv',
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFF94A3B8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: WorldClassDesignSystem.spacingM,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryPill(
            category: category,
            onTap: () => onCategoryTap(category.id),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(
          width: WorldClassDesignSystem.spacingM,
        ),
        itemCount: _categories.length,
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryPill({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: category.color.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: WorldClassDesignSystem.primaryWhite,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: WorldClassDesignSystem.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: WorldClassDesignSystem.primaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}
