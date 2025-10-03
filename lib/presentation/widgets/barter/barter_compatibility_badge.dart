import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Barter Compatibility Badge
/// Shows match score with color coding
class BarterCompatibilityBadge extends StatelessWidget {
  final double score; // 0-100
  final String size; // 'small', 'medium', 'large'
  final bool showPercentage;
  final bool showLabel;

  const BarterCompatibilityBadge({
    super.key,
    required this.score,
    this.size = 'medium',
    this.showPercentage = true,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForScore(score);
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == 'small' ? 6 : 8,
        vertical: size == 'small' ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForScore(score),
            size: iconSize,
            color: color,
          ),
          if (showPercentage) ...[
            const SizedBox(width: 4),
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getLabelForScore(score),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (score >= 50) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  IconData _getIconForScore(double score) {
    if (score >= 80) {
      return Icons.check_circle;
    } else if (score >= 50) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }

  String _getLabelForScore(double score) {
    if (score >= 80) {
      return 'Mükemmel';
    } else if (score >= 50) {
      return 'İyi';
    } else {
      return 'Düşük';
    }
  }

  double _getIconSize() {
    switch (size) {
      case 'small':
        return 14;
      case 'large':
        return 20;
      case 'medium':
      default:
        return 16;
    }
  }

  double _getFontSize() {
    switch (size) {
      case 'small':
        return 10;
      case 'large':
        return 14;
      case 'medium':
      default:
        return 12;
    }
  }
}

/// Extended Compatibility Badge with Progress Bar
class BarterCompatibilityCard extends StatelessWidget {
  final double score;
  final String? description;

  const BarterCompatibilityCard({
    super.key,
    required this.score,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForScore(score);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uyumluluk Skoru',
                style: AppTextStyles.titleMedium,
              ),
              BarterCompatibilityBadge(
                score: score,
                showLabel: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 80) {
      return const Color(0xFF4CAF50);
    } else if (score >= 50) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFF44336);
    }
  }
}
