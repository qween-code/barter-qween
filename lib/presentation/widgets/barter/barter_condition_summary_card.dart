import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/barter_condition_entity.dart';
import 'barter_condition_badge.dart';
import 'tier_badge.dart';

/// Barter Condition Summary Card
/// Comprehensive display of all barter information
class BarterConditionSummaryCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback? onFindMatches;
  final bool showMatchButton;

  const BarterConditionSummaryCard({
    super.key,
    required this.item,
    this.onFindMatches,
    this.showMatchButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final barterCondition = item.barterCondition;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMedium),
                topRight: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.handshake,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  'Takas Şartları',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier and Value
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.category,
                        label: 'Ürün Boyutu',
                        value: item.tier?.displayName ?? 'Orta',
                        badge: item.tier != null
                            ? TierBadge(tier: item.tier!, size: 20)
                            : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                // Estimated Value
                if (item.monetaryValue != null || item.price != null)
                  _buildInfoRow(
                    icon: Icons.attach_money,
                    label: 'Tahmini Değer',
                    value: '₺${(item.monetaryValue ?? item.price!).toStringAsFixed(0)} TL',
                  ),
                
                if (item.monetaryValue != null || item.price != null)
                  const SizedBox(height: AppDimensions.spacing16),
                
                const Divider(),
                const SizedBox(height: AppDimensions.spacing16),
                
                // Barter Condition Type
                if (barterCondition != null) ...[
                  Text(
                    'Takas Tipi',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  BarterConditionBadge(type: barterCondition.type),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    barterCondition.type.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Cash Differential (if applicable)
                  if (barterCondition.cashDifferential != null &&
                      barterCondition.cashDifferential! > 0) ...[
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildInfoRow(
                      icon: barterCondition.paymentDirection == CashPaymentDirection.fromMe
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      label: barterCondition.paymentDirection == CashPaymentDirection.fromMe
                          ? 'Ekstra Ödeyeceğim'
                          : 'Para Farkı Alacağım',
                      value: '₺${barterCondition.cashDifferential!.toStringAsFixed(0)} TL',
                      valueColor: barterCondition.paymentDirection == CashPaymentDirection.fromMe
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF4CAF50),
                    ),
                  ],
                  
                  // Accepted Categories
                  if (barterCondition.acceptedCategories != null &&
                      barterCondition.acceptedCategories!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacing16),
                    Text(
                      'Kabul Ettiğim Kategoriler',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: barterCondition.acceptedCategories!
                          .take(5)
                          .map((category) => Chip(
                                label: Text(
                                  category,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ],
                
                // Find Matches Button
                if (showMatchButton && onFindMatches != null) ...[
                  const SizedBox(height: AppDimensions.spacing16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onFindMatches,
                      icon: const Icon(Icons.search),
                      label: const Text('Eşleşen Ürünleri Bul'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? badge,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
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
              Row(
                children: [
                  Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    badge,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
