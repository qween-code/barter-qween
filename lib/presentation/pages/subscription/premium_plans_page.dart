import 'package:flutter/material.dart';
import '../../../domain/entities/subscription_entity.dart';

/// World-Class Premium Plans Page
/// 
/// Features:
/// - Modern card-based plan comparison
/// - Toggle between monthly/yearly
/// - Feature highlights with animations
/// - Current plan indicator
/// - Smooth transitions
/// 
/// Inspired by:
/// - Netflix subscription page
/// - Spotify Premium
/// - Apple One plans
class PremiumPlansPage extends StatefulWidget {
  final SubscriptionPlan? currentPlan;
  
  const PremiumPlansPage({
    Key? key,
    this.currentPlan,
  }) : super(key: key);

  @override
  State<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage>
    with SingleTickerProviderStateMixin {
  bool _isYearly = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Premium Planlar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFF8C42),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    const Text(
                      'Daha fazla özellik,\ndaha fazla fırsat',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Premium planlarla işlerini daha hızlı halledin',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Monthly/Yearly Toggle
                    _buildBillingToggle(),
                    const SizedBox(height: 32),

                    // Plans
                    ...SubscriptionPlans.allPlans.map((plan) {
                      return _buildPlanCard(plan);
                    }).toList(),

                    const SizedBox(height: 32),

                    // Feature Comparison
                    _buildFeatureComparison(),

                    const SizedBox(height: 32),

                    // FAQ Section
                    _buildFAQSection(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Aylık',
              !_isYearly,
              () {
                setState(() => _isYearly = false);
              },
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'Yıllık',
              _isYearly,
              () {
                setState(() => _isYearly = true);
              },
              badge: '%17 İndirim',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (badge != null && isSelected) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionFeatures plan) {
    final isCurrentPlan = widget.currentPlan == plan.plan;
    final isFree = plan.plan == SubscriptionPlan.free;
    final isPremium = plan.plan == SubscriptionPlan.premium;
    
    final price = _isYearly ? plan.yearlyPriceTRY : plan.monthlyPriceTRY;
    final monthlyEquivalent = _isYearly ? plan.yearlyPriceMonthlyEquivalent : price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPremium
            ? Border.all(color: const Color(0xFFFF6B35), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? const Color(0xFFFF6B35).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isPremium ? 20 : 10,
            offset: Offset(0, isPremium ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                    )
                  : null,
              color: isPremium ? null : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.displayName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPremium ? Colors.white : const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mevcut Plan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? const Color(0xFFFF6B35) : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPremium
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFree ? 'Ücretsiz' : '₺${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                    if (!isFree) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            _isYearly ? '/yıl' : '/ay',
                            style: TextStyle(
                              fontSize: 16,
                              color: isPremium
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                          if (_isYearly) ...[
                            const SizedBox(height: 4),
                            Text(
                              '₺${monthlyEquivalent.toStringAsFixed(2)}/ay',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPremium
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem(
                  Icons.post_add,
                  '${plan.maxActiveListings} aktif ilan',
                  isPremium,
                ),
                _buildFeatureItem(
                  Icons.campaign,
                  plan.freeListingsPerMonth == 999
                      ? 'Sınırsız ücretsiz ilan'
                      : '${plan.freeListingsPerMonth} ücretsiz ilan/ay',
                  isPremium,
                ),
                if (plan.premiumListingAvailable)
                  _buildFeatureItem(
                    Icons.star,
                    '${plan.premiumListingsPerMonth} premium ilan/ay',
                    isPremium,
                  ),
                if (plan.adFree)
                  _buildFeatureItem(
                    Icons.block,
                    'Reklamsız deneyim',
                    isPremium,
                  ),
                _buildFeatureItem(
                  Icons.percent,
                  'Trade komisyonu %${plan.tradeCommissionRate.toStringAsFixed(0)}',
                  isPremium,
                ),
                if (plan.advancedSearch)
                  _buildFeatureItem(
                    Icons.search,
                    'Gelişmiş arama',
                    isPremium,
                  ),
                if (plan.analyticsAccess)
                  _buildFeatureItem(
                    Icons.analytics,
                    'İstatistikler',
                    isPremium,
                  ),
                if (plan.prioritySupport)
                  _buildFeatureItem(
                    Icons.support_agent,
                    'Öncelikli destek',
                    isPremium,
                  ),
              ],
            ),
          ),

          // Button
          if (!isCurrentPlan)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFree
                      ? null
                      : () => _handleSubscribe(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFree
                        ? Colors.grey[300]
                        : const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isFree ? 'Mevcut Plan' : 'Başlat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isFree ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          _buildComparisonRow('Özellik', 'Ücretsiz', 'Temel', 'Premium', isHeader: true),
          const Divider(height: 24),
          _buildComparisonRow('Aktif İlan', '3', '10', '50'),
          _buildComparisonRow('Ücretsiz İlan/Ay', '1', '5', 'Sınırsız'),
          _buildComparisonRow('Premium İlan', '❌', '2/ay', '10/ay'),
          _buildComparisonRow('Reklamsız', '❌', '✅', '✅'),
          _buildComparisonRow('Komisyon', '%5', '%3', '%0'),
          _buildComparisonRow('Gelişmiş Arama', '❌', '✅', '✅'),
          _buildComparisonRow('İstatistikler', '❌', '✅', '✅'),
          _buildComparisonRow('Öncelikli Destek', '❌', '❌', '✅'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String free,
    String basic,
    String premium, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? const Color(0xFF2D3142) : Colors.grey[700],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: style),
          ),
          Expanded(
            child: Text(free, style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(basic, style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(premium, style: style, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            'Sıkça Sorulan Sorular',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          _buildFAQItem(
            'Aboneliğimi iptal edebilir miyim?',
            'Evet, istediğiniz zaman aboneliğinizi iptal edebilirsiniz. İptal sonrası mevcut dönem bitene kadar premium özellikleriniz devam eder.',
          ),
          _buildFAQItem(
            'Plan değiştirme nasıl yapılır?',
            'İstediğiniz planı seçip başlat butonuna tıklayın. Fark ücreti hesaplanarak yeni plana geçiş yapabilirsiniz.',
          ),
          _buildFAQItem(
            'Yıllık plan daha avantajlı mı?',
            'Evet! Yıllık planlarda %17 indirim kazanırsınız. Örneğin Premium planda 12 ay yerine ~10 ay ücreti ödersiniz.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe(SubscriptionFeatures plan) {
    // Navigate to payment page
    Navigator.pushNamed(
      context,
      '/payment-selection',
      arguments: {
        'plan': plan,
        'isYearly': _isYearly,
      },
    );
  }
}
