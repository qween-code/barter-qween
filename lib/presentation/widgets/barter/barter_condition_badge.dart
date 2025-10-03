import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/barter_condition_entity.dart';

/// Barter Condition Type Badge
/// Compact badge showing the barter condition type
class BarterConditionBadge extends StatelessWidget {
  final BarterConditionType type;
  final bool compact;
  final bool showIcon;
  final bool showLabel;

  const BarterConditionBadge({
    super.key,
    required this.type,
    this.compact = false,
    this.showIcon = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);
    final label = type.displayName;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, size: 12, color: color),
              if (showLabel) const SizedBox(width: 3),
            ],
            if (showLabel)
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 16, color: color),
            if (showLabel) const SizedBox(width: 6),
          ],
          if (showLabel)
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForType(BarterConditionType type) {
    switch (type) {
      case BarterConditionType.directSwap:
        return const Color(0xFF2196F3); // Blue
      case BarterConditionType.cashPlus:
        return const Color(0xFFFF9800); // Orange
      case BarterConditionType.cashMinus:
        return const Color(0xFF4CAF50); // Green
      case BarterConditionType.categorySpecific:
        return const Color(0xFF9C27B0); // Purple
      case BarterConditionType.flexible:
        return const Color(0xFF00BCD4); // Cyan
      case BarterConditionType.specificItem:
        return const Color(0xFFE91E63); // Pink
      case BarterConditionType.valueRange:
        return const Color(0xFFFF5722); // Deep Orange
    }
  }

  IconData _getIconForType(BarterConditionType type) {
    switch (type) {
      case BarterConditionType.directSwap:
        return Icons.swap_horiz;
      case BarterConditionType.cashPlus:
        return Icons.add_circle_outline;
      case BarterConditionType.cashMinus:
        return Icons.remove_circle_outline;
      case BarterConditionType.categorySpecific:
        return Icons.category_outlined;
      case BarterConditionType.flexible:
        return Icons.done_all;
      case BarterConditionType.specificItem:
        return Icons.search;
      case BarterConditionType.valueRange:
        return Icons.trending_up;
    }
  }
}
