// 🏠 ENHANCED HOME PAGE V2
// World-class design inspired by: Trendyol, Dolap, AliExpress

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/world_class_components.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/item/item_bloc.dart';

class EnhancedHomePageV2 extends StatefulWidget {
  const EnhancedHomePageV2({Key? key}) : super(key: key);

  @override
  State<EnhancedHomePageV2> createState() => _EnhancedHomePageV2State();
}

class _EnhancedHomePageV2State extends State<EnhancedHomePageV2> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll banners
    Future.delayed(const Duration(seconds: 3), _autoScrollBanners);
  }

  void _autoScrollBanners() {
    if (!mounted) return;
    
    final nextPage = (_currentBannerIndex + 1) % 5;
    _bannerController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    Future.delayed(const Duration(seconds: 3), _autoScrollBanners);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load trending items on init
    context.read<ItemBloc>().add(LoadTrendingItems());
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(context),
          
          // Hero Banner Carousel
          SliverToBoxAdapter(child: _buildHeroBanner()),
          
          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActions()),
          
          // Gamification Status (Coins + Streak)
          SliverToBoxAdapter(child: _buildGamificationStatus()),
          
          // Category Grid
          SliverToBoxAdapter(child: _buildCategoryGrid()),
          
          // Trending Items
          SliverToBoxAdapter(child: _buildTrendingSection()),
          
          // Smart Recommendations
          SliverToBoxAdapter(child: _buildRecommendationsSection()),
          
          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Floating Action Button (Add Item)
      floatingActionButton: PulsingFAB(
        icon: Icons.add,
        onPressed: () {
          Navigator.pushNamed(context, '/add-item');
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Bebek Campus',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Text(
            'Hey, Trader! 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        // Notifications
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        
        // Profile
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    final banners = [
      _BannerData(
        image: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
        title: 'Flash Barter Weekend',
        subtitle: 'Trade faster, earn more coins!',
        badge: 'HOT 🔥',
        color: Colors.orange,
      ),
      _BannerData(
        image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
        title: 'New: AR Try-On',
        subtitle: 'See items before trading',
        badge: 'NEW ✨',
        color: Colors.blue,
      ),
      _BannerData(
        image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        title: 'Campus Champions',
        subtitle: 'Top traders this week',
        badge: 'TRENDING 📈',
        color: Colors.purple,
      ),
      _BannerData(
        image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        title: 'Electronics Fair',
        subtitle: '200+ tech items available',
        badge: 'POPULAR 💻',
        color: Colors.green,
      ),
      _BannerData(
        image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
        title: 'Fashion Exchange',
        subtitle: 'Refresh your wardrobe',
        badge: 'FASHION 👗',
        color: Colors.pink,
      ),
    ];

    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedItemCard(
                  imageUrl: banner.image,
                  title: banner.title,
                  subtitle: banner.subtitle,
                  badge: banner.badge,
                  accentColor: banner.color,
                  onTap: () {
                    // Navigate to featured section
                  },
                ),
              );
            },
          ),
          
          // Page Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => Container(
                  width: _currentBannerIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            color: Colors.blue,
            onTap: () {
              // Open QR scanner
            },
          ),
          _buildQuickActionItem(
            icon: Icons.camera_alt,
            label: 'Upload',
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, '/add-item');
            },
          ),
          _buildQuickActionItem(
            icon: Icons.near_me,
            label: 'Near Me',
            color: Colors.green,
            onTap: () {
              // Open map view
            },
          ),
          _buildQuickActionItem(
            icon: Icons.favorite,
            label: 'Saved',
            color: Colors.red,
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.orange[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Coins
          Expanded(
            child: _buildStatItem(
              icon: '🪙',
              value: '1,250',
              label: 'Barter Coins',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildStatItem(
              icon: '🔥',
              value: '5 Days',
              label: 'Streak',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildStatItem(
              icon: '⭐',
              value: 'Level 8',
              label: 'Pro Trader',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      _CategoryData('Electronics', Icons.phone_android, '432', Colors.blue),
      _CategoryData('Fashion', Icons.checkroom, '891', Colors.pink),
      _CategoryData('Books', Icons.menu_book, '234', Colors.green),
      _CategoryData('Gaming', Icons.sports_esports, '156', Colors.purple),
      _CategoryData('Home', Icons.home, '89', Colors.orange),
      _CategoryData('Art', Icons.palette, '67', Colors.red),
      _CategoryData('Sports', Icons.sports_soccer, '145', Colors.teal),
      _CategoryData('Music', Icons.music_note, '78', Colors.indigo),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(_CategoryData category) {
    return InkWell(
      onTap: () {
        // Navigate to category
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              category.count,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Now 🔥',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: PremiumItemCard(
                  imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
                  title: 'Nike Air Max 90',
                  username: 'sneaker_head',
                  price: 1200,
                  condition: 'Like New',
                  distance: '2.3 km',
                  viewCount: 47,
                  isVerified: true,
                  badges: index == 0 ? ['HOT'] : index == 1 ? ['NEW'] : null,
                  onTap: () {
                    Navigator.pushNamed(context, '/item-detail');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return PremiumItemCard(
                imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
                title: 'MacBook Air M1',
                username: 'tech_trader',
                price: 12000,
                condition: 'Excellent',
                distance: '1.5 km',
                viewCount: 89,
                isVerified: true,
                matchScore: 92,
                onTap: () {
                  Navigator.pushNamed(context, '/item-detail');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String image;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;

  _BannerData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
  });
}

class _CategoryData {
  final String name;
  final IconData icon;
  final String count;
  final Color color;

  _CategoryData(this.name, this.icon, this.count, this.color);
}
