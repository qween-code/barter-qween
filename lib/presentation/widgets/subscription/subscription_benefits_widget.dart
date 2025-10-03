import 'package:flutter/material.dart';
import '../../../domain/entities/subscription_entity.dart';

/// Subscription Benefits Widget
/// 
/// Shows current plan benefits and upgrade prompts
/// 
/// Usage:
/// ```dart
/// SubscriptionBenefitsWidget(
///   currentPlan: SubscriptionPlan.basic,
///   onUpgradePressed: () => navigateToPremiumPlans(),
/// )
/// ```
class SubscriptionBenefitsWidget extends StatelessWidget {
  final SubscriptionPlan currentPlan;
  final VoidCallback? onUpgradePressed;
  final bool compact;
  
  const SubscriptionBenefitsWidget({
    Key? key,
    required this.currentPlan,
    this.onUpgradePressed,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = currentPlan.features;
    final isPremium = currentPlan == SubscriptionPlan.premium;
    
    if (compact) {
      return _buildCompactView(features, isPremium);
    }
    
    return _buildFullView(context, features, isPremium);
  }

  Widget _buildFullView(
    BuildContext context,
    SubscriptionFeatures features,
    bool isPremium,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              )
            : null,
        color: isPremium ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? const Color(0xFFFF6B35).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: isPremium ? Colors.white : const Color(0xFFFF6B35),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      features.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      features.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPremium
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBenefitRow(
            Icons.post_add,
            '${features.maxActiveListings} aktif ilan',
            isPremium,
          ),
          _buildBenefitRow(
            Icons.campaign,
            features.freeListingsPerMonth == 999
                ? 'Sınırsız ücretsiz ilan'
                : '${features.freeListingsPerMonth} ücretsiz ilan/ay',
            isPremium,
          ),
          if (features.premiumListingAvailable)
            _buildBenefitRow(
              Icons.star,
              '${features.premiumListingsPerMonth} premium ilan/ay',
              isPremium,
            ),
          if (features.adFree)
            _buildBenefitRow(
              Icons.block,
              'Reklamsız deneyim',
              isPremium,
            ),
          _buildBenefitRow(
            Icons.percent,
            'Trade komisyonu %${features.tradeCommissionRate.toStringAsFixed(0)}',
            isPremium,
          ),
          if (features.advancedSearch)
            _buildBenefitRow(
              Icons.search,
              'Gelişmiş arama',
              isPremium,
            ),
          if (features.prioritySupport)
            _buildBenefitRow(
              Icons.support_agent,
              'Öncelikli destek',
              isPremium,
            ),
          
          if (!isPremium && onUpgradePressed != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Premium\'a Geç',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactView(SubscriptionFeatures features, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              )
            : null,
        color: isPremium ? null : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: !isPremium ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: isPremium ? Colors.white : const Color(0xFFFF6B35),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  features.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
                Text(
                  '${features.maxActiveListings} aktif ilan • ${features.freeListingsPerMonth == 999 ? "Sınırsız" : features.freeListingsPerMonth} ücretsiz/ay',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPremium ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium && onUpgradePressed != null)
            TextButton(
              onPressed: onUpgradePressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B35),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Yükselt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isPremium ? Colors.white : const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isPremium ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 18,
            color: isPremium ? Colors.white : const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }
}

/// Plan Comparison Widget
class PlanComparisonWidget extends StatelessWidget {
  final SubscriptionPlan currentPlan;
  final VoidCallback? onUpgradePressed;
  
  const PlanComparisonWidget({
    Key? key,
    required this.currentPlan,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Karşılaştırması',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          ...SubscriptionPlans.allPlans.map((plan) {
            final isCurrent = plan.plan == currentPlan;
            return _buildPlanRow(plan, isCurrent);
          }).toList(),
          
          if (currentPlan != SubscriptionPlan.premium && onUpgradePressed != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Planları Karşılaştır',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanRow(SubscriptionFeatures plan, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFFFF6B35).withOpacity(0.1)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: const Color(0xFFFF6B35), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: isCurrent ? const Color(0xFFFF6B35) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plan.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? const Color(0xFFFF6B35) : const Color(0xFF2D3142),
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mevcut',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.plan == SubscriptionPlan.free
                      ? 'Ücretsiz'
                      : '₺${plan.monthlyPriceTRY}/ay',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent && plan.plan != SubscriptionPlan.free)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}

/// Quick Benefits Banner - Shows on top of pages
class QuickBenefitsBanner extends StatelessWidget {
  final SubscriptionPlan currentPlan;
  final VoidCallback onTap;
  
  const QuickBenefitsBanner({
    Key? key,
    required this.currentPlan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentPlan == SubscriptionPlan.premium) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Premium\'a Geçin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sınırsız ilan, reklamsız deneyim',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
