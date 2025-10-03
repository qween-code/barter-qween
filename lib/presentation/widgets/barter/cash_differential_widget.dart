import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/barter_condition_entity.dart';

/// Cash Differential Widget
/// Shows payment direction and amount
class CashDifferentialWidget extends StatelessWidget {
  final double amount;
  final CashPaymentDirection direction;
  final bool compact;

  const CashDifferentialWidget({
    super.key,
    required this.amount,
    required this.direction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isReceiving = direction == CashPaymentDirection.toMe;
    final color = isReceiving ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    final icon = isReceiving ? Icons.arrow_downward : Icons.arrow_upward;
    final label = isReceiving ? 'Alacağınız' : 'Ödeyeceğiniz';

    if (compact) {
      return _buildCompactView(color, icon);
    }

    return _buildFullView(color, icon, label);
  }

  Widget _buildCompactView(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '₺${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₺${_formatAmount(amount)} TL',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Cash Differential Card with Details
class CashDifferentialCard extends StatelessWidget {
  final double myItemValue;
  final double theirItemValue;
  final double? suggestedCash;

  const CashDifferentialCard({
    super.key,
    required this.myItemValue,
    required this.theirItemValue,
    this.suggestedCash,
  });

  @override
  Widget build(BuildContext context) {
    final differential = (myItemValue - theirItemValue).abs();
    final iNeedToPay = myItemValue < theirItemValue;
    final direction = iNeedToPay
        ? CashPaymentDirection.fromMe
        : CashPaymentDirection.toMe;

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
          Text(
            'Değer Farkı',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          
          // Item values comparison
          Row(
            children: [
              Expanded(
                child: _buildValueBox(
                  'Sizin Ürününüz',
                  myItemValue,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              const Icon(Icons.swap_horiz, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _buildValueBox(
                  'Diğer Ürün',
                  theirItemValue,
                  AppColors.accent,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          const Divider(),
          const SizedBox(height: AppDimensions.spacing16),
          
          // Cash differential
          CashDifferentialWidget(
            amount: suggestedCash ?? differential,
            direction: direction,
          ),
          
          if (suggestedCash != null && suggestedCash != differential) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Önerilen tutar: ₺${suggestedCash!.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₺${value.toStringAsFixed(0)}',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
