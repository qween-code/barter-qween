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

  const WorldClassCategoryGrid({
    Key? key,
    required this.onCategoryTap,
  }) : super(key: key);

  final List<CategoryItem> _categories = const [
    CategoryItem(
      name: 'Electronics',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF3B82F6),
    ),
    CategoryItem(
      name: 'Fashion',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFEC4899),
    ),
    CategoryItem(
      name: 'Home',
      icon: Icons.home_rounded,
      color: Color(0xFF10B981),
    ),
    CategoryItem(
      name: 'Sports',
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFFF59E0B),
    ),
    CategoryItem(
      name: 'Books',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF8B5CF6),
    ),
    CategoryItem(
      name: 'Toys',
      icon: Icons.toys_rounded,
      color: Color(0xFFEF4444),
    ),
    CategoryItem(
      name: 'Automotive',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF6B7280),
    ),
    CategoryItem(
      name: 'More',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF9CA3AF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: WorldClassDesignSystem.spacingM),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: WorldClassDesignSystem.spacingM,
          mainAxisSpacing: WorldClassDesignSystem.spacingM,
          childAspectRatio: 0.8,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryItem(category);
        },
      ),
    );
  }

  Widget _buildCategoryItem(CategoryItem category) {
    return GestureDetector(
      onTap: () => onCategoryTap(category.name),
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusL),
          border: Border.all(
            color: category.color.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusM),
              ),
              child: Icon(
                category.icon,
                color: WorldClassDesignSystem.primaryWhite,
                size: 24,
              ),
            ),
            const SizedBox(height: WorldClassDesignSystem.spacingS),
            Text(
              category.name,
              style: WorldClassDesignSystem.labelSmall.copyWith(
                color: WorldClassDesignSystem.primaryText,
                fontWeight: FontWeight.w600,
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
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}
