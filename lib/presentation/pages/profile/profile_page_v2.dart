import 'package:flutter/material.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../widgets/subscription/subscription_benefits_widget.dart';

/// World-Class Profile Page V2
/// 
/// Features:
/// - Modern profile header with gradient
/// - Stats dashboard
/// - Subscription status card
/// - Quick action buttons
/// - Settings menu
/// - Logout functionality
/// 
/// Inspired by:
/// - LinkedIn profile
/// - Instagram profile
/// - Airbnb profile
class ProfilePageV2 extends StatefulWidget {
  const ProfilePageV2({Key? key}) : super(key: key);

  @override
  State<ProfilePageV2> createState() => _ProfilePageV2State();
}

class _ProfilePageV2State extends State<ProfilePageV2> {
  // Mock data - replace with actual user data
  final String userName = 'John Doe';
  final String userEmail = 'john@example.com';
  final String? userAvatar;
  final SubscriptionPlan currentPlan = SubscriptionPlan.basic;
  
  // Mock stats
  final int totalListings = 12;
  final int activeTrades = 3;
  final int completedTrades = 45;
  final double rating = 4.8;
  final int reviewCount = 38;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Profile Header
          _buildProfileHeader(),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Dashboard
                _buildStatsDashboard(),
                const SizedBox(height: 20),
                
                // Subscription Card
                _buildSubscriptionCard(),
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 20),
                
                // Settings Menu
                _buildSettingsMenu(),
                const SizedBox(height: 20),
                
                // Logout Button
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFFFF6B35),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: userAvatar != null
                      ? ClipOval(
                          child: Image.network(
                            userAvatar!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                ),
                const SizedBox(height: 16),
                
                // Name
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Email
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Edit Profile Button
                TextButton.icon(
                  onPressed: _handleEditProfile,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text(
                    'Profili Düzenle',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsDashboard() {
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
            'İstatistikler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.post_add,
                  totalListings.toString(),
                  'İlanlar',
                  const Color(0xFFFF6B35),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.swap_horiz,
                  activeTrades.toString(),
                  'Aktif Trade',
                  const Color(0xFF4285F4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.check_circle,
                  completedTrades.toString(),
                  'Tamamlanan',
                  const Color(0xFF34A853),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.star,
                  rating.toString(),
                  '$reviewCount Değerlendirme',
                  const Color(0xFFFBBC05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return SubscriptionBenefitsWidget(
      currentPlan: currentPlan,
      onUpgradePressed: _handleUpgrade,
    );
  }

  Widget _buildQuickActions() {
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
            'Hızlı Erişim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.favorite,
                'Favoriler',
                () => _handleNavigation('/favorites'),
              ),
              _buildActionButton(
                Icons.history,
                'Geçmiş',
                () => _handleNavigation('/trade-history'),
              ),
              _buildActionButton(
                Icons.notifications,
                'Bildirimler',
                () => _handleNavigation('/notifications'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF6B35),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
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
        children: [
          _buildSettingsItem(
            Icons.workspace_premium,
            'Premium Planlar',
            'Planınızı yükseltin',
            () => _handleUpgrade(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.lock,
            'Gizlilik',
            'Gizlilik ayarları',
            () => _handleNavigation('/privacy'),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.notifications_outlined,
            'Bildirimler',
            'Bildirim tercihleri',
            () => _handleNavigation('/notification-settings'),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.language,
            'Dil',
            'Türkçe',
            () => _handleLanguage(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.help_outline,
            'Yardım',
            'SSS ve destek',
            () => _handleNavigation('/help'),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.policy_outlined,
            'Hizmet Koşulları',
            'Yasal dökümanlar',
            () => _handleNavigation('/terms'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFF6B35),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.logout,
            color: Colors.red[400],
            size: 24,
          ),
        ),
        title: Text(
          'Çıkış Yap',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red[400],
          ),
        ),
        onTap: _handleLogout,
      ),
    );
  }

  void _handleEditProfile() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _handleUpgrade() {
    Navigator.pushNamed(context, '/premium-plans');
  }

  void _handleNavigation(String route) {
    // TODO: Implement navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $route')),
    );
  }

  void _handleLanguage() {
    // TODO: Show language selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Türkçe', true),
            _buildLanguageOption('English', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFFFF6B35))
          : null,
      onTap: () {
        // TODO: Change language
        Navigator.pop(context);
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
