import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/item_entity.dart';

/// Tier Badge Widget
/// Displays item tier (small, medium, large) with color coding
class TierBadge extends StatelessWidget {
  final ItemTier? tier;
  final bool showLabel;
  final double? size;

  const TierBadge({
    super.key,
    required this.tier,
    this.showLabel = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size ?? 12,
        vertical: size != null ? size! * 0.4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getTierColor(tier!).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: _getTierColor(tier!),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(tier!),
            color: _getTierColor(tier!),
            size: size ?? 16,
          ),
          if (showLabel) ...[
            SizedBox(width: size != null ? size! * 0.3 : 4),
            Text(
              tier!.displayName,
              style: (size != null
                      ? AppTextStyles.bodySmall
                      : AppTextStyles.bodyMedium)
                  .copyWith(
                color: _getTierColor(tier!),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTierColor(ItemTier tier) {
    switch (tier) {
      case ItemTier.small:
        return Colors.green;
      case ItemTier.medium:
        return Colors.orange;
      case ItemTier.large:
        return Colors.red;
    }
  }

  IconData _getTierIcon(ItemTier tier) {
    switch (tier) {
      case ItemTier.small:
        return Icons.brightness_low;
      case ItemTier.medium:
        return Icons.brightness_medium;
      case ItemTier.large:
        return Icons.brightness_high;
    }
  }
}
