import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS BOTTOM NAVIGATION
///
/// Features:
/// - 5-tab navigation
/// - Smooth animations
/// - Badge support
/// - Accessibility
/// - Modern design
class WorldClassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? messagesBadgeCount;

  const WorldClassBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.messagesBadgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WorldClassDesignSystem.surfaceColor,
        boxShadow: WorldClassDesignSystem.shadowM,
        border: Border(
          top: BorderSide(color: WorldClassDesignSystem.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WorldClassDesignSystem.spacingM,
            vertical: WorldClassDesignSystem.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.explore_rounded,
                label: 'Explore',
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_circle_rounded,
                label: 'Add',
                isSelected: currentIndex == 2,
                isSpecial: true,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.chat_bubble_rounded,
                label: 'Messages',
                isSelected: currentIndex == 3,
                badgeCount: messagesBadgeCount,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isSpecial = false,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WorldClassDesignSystem.spacingS,
          vertical: WorldClassDesignSystem.spacingXS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container
            Container(
              width: isSpecial ? 56 : 48,
              height: isSpecial ? 56 : 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? WorldClassDesignSystem.primaryColor
                    : isSpecial
                    ? WorldClassDesignSystem.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  isSpecial ? 28 : WorldClassDesignSystem.radiusM,
                ),
                boxShadow: isSpecial ? WorldClassDesignSystem.shadowM : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      icon,
                      size: isSpecial ? 28 : 24,
                      color: isSelected || isSpecial
                          ? WorldClassDesignSystem.primaryWhite
                          : WorldClassDesignSystem.secondaryText,
                    ),
                  ),

                  // Badge
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: WorldClassDesignSystem.errorColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: WorldClassDesignSystem.labelSmall.copyWith(
                            color: WorldClassDesignSystem.primaryWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: WorldClassDesignSystem.spacingXS),

            // Label
            Text(
              label,
              style: WorldClassDesignSystem.labelSmall.copyWith(
                color: isSelected
                    ? WorldClassDesignSystem.primaryColor
                    : WorldClassDesignSystem.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
