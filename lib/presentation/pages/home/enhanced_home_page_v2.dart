// 🏠 ENHANCED HOME PAGE V2
// World-class design inspired by: Trendyol, Dolap, AliExpress

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/theme/world_class_components.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../pages/maps/map_view_page.dart';

const _placeholderImage =
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop';

class EnhancedHomePageV2 extends StatefulWidget {
  const EnhancedHomePageV2({Key? key}) : super(key: key);

  @override
  State<EnhancedHomePageV2> createState() => _EnhancedHomePageV2State();
}

class _EnhancedHomePageV2State extends State<EnhancedHomePageV2> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  late final ItemBloc _trendingBloc;
  late final ItemBloc _recommendedBloc;
  late final RecommendationService _recommendationService;
  List<_CategoryTileData> _categoryTiles = [];
  bool _isCategoryLoading = true;
  UserEntity? _currentUser;
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _userSocial;
  String? _lastUserId;
  bool _hasRequestedRecommendations = false;

  @override
  void initState() {
    super.initState();
    _recommendationService = getIt<RecommendationService>();
    _trendingBloc = getIt<ItemBloc>()..add(const LoadTrendingItems());
    _recommendedBloc = getIt<ItemBloc>()..add(const LoadRecentItems());
    _loadCategories();
    // Auto-scroll banners
    Future.delayed(const Duration(seconds: 3), _autoScrollBanners);
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final userChanged = state.user.uid != _lastUserId;
      if (userChanged) {
        context.read<FavoriteBloc>().add(const LoadFavorites());
      }
      setState(() {
        _currentUser = state.user;
        _userStats =
            state.stats ??
            (state.profileData?['stats'] as Map?)?.cast<String, dynamic>();
        _userSocial =
            state.social ??
            (state.profileData?['social'] as Map?)?.cast<String, dynamic>();
        _lastUserId = state.user.uid;
      });
      if (userChanged || !_hasRequestedRecommendations) {
        _loadRecommendations(force: true);
      }
    } else if (state is AuthUnauthenticated) {
      setState(() {
        _currentUser = null;
        _userStats = null;
        _userSocial = null;
        _lastUserId = null;
        _hasRequestedRecommendations = false;
      });
      _recommendedBloc.add(const LoadRecentItems());
    }
  }

  void _loadRecommendations({bool force = false}) {
    if (_currentUser != null) {
      if (_hasRequestedRecommendations && !force) return;
      _hasRequestedRecommendations = true;
      _recommendedBloc.add(
        LoadRecommendedItems(
          userId: _currentUser!.uid,
          city: _currentUser!.city ?? _currentUser!.location,
          latitude: _currentUser!.latitude,
          longitude: _currentUser!.longitude,
        ),
      );
    } else {
      _recommendedBloc.add(const LoadRecentItems());
    }
  }

  List<ItemEntity> _excludeCurrentUserItems(List<ItemEntity> items) {
    final currentId = _currentUser?.uid;
    if (currentId == null || currentId.isEmpty) {
      return items;
    }
    return items
        .where((item) => (item.ownerId.isNotEmpty && item.ownerId != currentId))
        .toList();
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

  Future<void> _loadCategories() async {
    setState(() => _isCategoryLoading = true);

    try {
      final summaries = await _recommendationService.getTopCategories(limit: 8);
      if (!mounted) return;

      if (summaries.isEmpty) {
        setState(() {
          _categoryTiles = _fallbackCategoryTiles.toList();
          _isCategoryLoading = false;
        });
        return;
      }

      final tiles = <_CategoryTileData>[];
      for (var i = 0; i < summaries.length; i++) {
        final summary = summaries[i];
        tiles.add(
          _CategoryTileData(
            name: summary.category,
            count: summary.count,
            icon: _resolveCategoryIcon(summary.category),
            color: _resolveCategoryColor(summary.category, i),
          ),
        );
      }

      setState(() {
        _categoryTiles = tiles;
        _isCategoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoryTiles = _fallbackCategoryTiles.toList();
        _isCategoryLoading = false;
      });
    }
  }

  IconData _resolveCategoryIcon(String category) {
    return _categoryIconMap[category] ?? Icons.category_outlined;
  }

  Color _resolveCategoryColor(String category, int index) {
    return _categoryColorMap[category] ??
        _categoryPalette[index % _categoryPalette.length];
  }

  @override
  void dispose() {
    _trendingBloc.close();
    _recommendedBloc.close();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
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
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // Floating Action Button (Add Item)
        floatingActionButton: PulsingFAB(
          icon: Icons.add,
          heroTag: 'home-fab',
          onPressed: () {
            AppRouter.toAddItem(context);
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final locationLabel = _resolveLocationLabel();
    final greeting = _resolveGreeting();
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
                locationLabel,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Text(
            greeting,
            style: const TextStyle(
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
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
              ),
              onPressed: () => AppRouter.toNotifications(context),
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
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => AppRouter.toProfile(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildProfileAvatar(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    final banners = [
      _BannerData(
        image:
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
        title: 'Flash Barter Weekend',
        subtitle: 'Trade faster, earn more coins!',
        badge: 'HOT 🔥',
        color: Colors.orange,
      ),
      _BannerData(
        image:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
        title: 'New: AR Try-On',
        subtitle: 'See items before trading',
        badge: 'NEW ✨',
        color: Colors.blue,
      ),
      _BannerData(
        image:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        title: 'Campus Champions',
        subtitle: 'Top traders this week',
        badge: 'TRENDING 📈',
        color: Colors.purple,
      ),
      _BannerData(
        image:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        title: 'Electronics Fair',
        subtitle: '200+ tech items available',
        badge: 'POPULAR 💻',
        color: Colors.green,
      ),
      _BannerData(
        image:
            'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            color: Colors.blue,
            onTap: _handleScanQr,
          ),
          _buildQuickActionItem(
            icon: Icons.camera_alt,
            label: 'Upload',
            color: Colors.purple,
            onTap: () => AppRouter.toAddItem(context),
          ),
          _buildQuickActionItem(
            icon: Icons.near_me,
            label: 'Near Me',
            color: Colors.green,
            onTap: _openNearbyItems,
          ),
          _buildQuickActionItem(
            icon: Icons.favorite,
            label: 'Saved',
            color: Colors.red,
            onTap: _openFavorites,
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _handleScanQr() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2, size: 28, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'QR kod tarat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kamera entegrasyonu yakında geliyor. Şimdilik ilan kodunu girerek devam edebilirsin.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'İlan ID / QR kodu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final code = controller.text.trim();
                  if (code.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir kod girin'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  Navigator.of(sheetContext).pop();
                  AppRouter.toItemDetail(context, code);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('İlana git'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  AppRouter.toAddItem(context);
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Yeni ilan yükle'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _openNearbyItems() {
    final itemBloc = context.read<ItemBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) =>
            BlocProvider.value(value: itemBloc, child: const MapViewPage()),
      ),
    );
  }

  void _openFavorites() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteBloc>().add(const LoadFavorites());
      AppRouter.toFavorites(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favoriler için önce giriş yapmalısınız'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildGamificationStatus() {
    final coins =
        _asNum(_userStats?['coinBalance']) ??
        _asNum(_userStats?['barterCoins']);
    final completedTrades = _asNum(_userStats?['completedTrades']) ?? 0;
    final listingCount = _asNum(_userStats?['listingCount']) ?? 0;
    final streak =
        _asNum(_userStats?['activityStreak']) ??
        _asNum(_userStats?['streakDays']) ??
        0;
    final trustScore =
        _currentUser?.trustScore ??
        _asNum(_userStats?['trustScore'])?.toDouble();

    final coinsValue = coins != null
        ? _formatNumber(coins)
        : _formatNumber((completedTrades * 120) + (listingCount * 25));
    final streakValue = streak > 0 ? '${streak.toInt()} Days' : 'Start today';
    final tierValue = trustScore != null
        ? '${trustScore.toStringAsFixed(1)} ★'
        : 'Build trust';
    final tierLabel = _resolveTierLabel(trustScore);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.orange[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          // Coins
          Expanded(
            child: _buildStatItem(
              icon: '🪙',
              value: coinsValue,
              label: 'Barter Coins',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildStatItem(
              icon: '🔥',
              value: streakValue,
              label: 'Active Streak',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildStatItem(
              icon: '⭐',
              value: tierValue,
              label: tierLabel,
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
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final tiles = _categoryTiles.isNotEmpty
        ? _categoryTiles
        : (_isCategoryLoading
              ? const <_CategoryTileData>[]
              : _fallbackCategoryTiles);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isCategoryLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (tiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No categories available yet. Start listing items to see insights.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, index) {
                final category = tiles[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryCard(_CategoryTileData category) {
    return InkWell(
      onTap: () => AppRouter.toExplore(context, category: category.name),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _formatNumber(category.count),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => AppRouter.toExplore(context),
                child: const Text('Tümünü gör'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 390,
          child: BlocBuilder<ItemBloc, ItemState>(
            bloc: _trendingBloc,
            builder: (context, state) {
              if (state is ItemLoading || state is ItemInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ItemError) {
                return _buildErrorPlaceholder(
                  message: state.message,
                  onRetry: () => _trendingBloc.add(const LoadTrendingItems()),
                );
              }

              if (state is ItemsLoaded) {
                final items = _excludeCurrentUserItems(
                  state.items,
                ).take(10).toList();
                if (items.isEmpty) {
                  return _buildEmptyPlaceholder(
                    'Trend ürün bulunamadı. Kendi ilanların gizlendi.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(
                      width: 190,
                      child: _buildItemCard(
                        context,
                        item,
                        badges: index < 3 ? const ['TRENDING'] : null,
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
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
              Text(
                _currentUser != null
                    ? 'Recommended for You'
                    : 'Discover Something New',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_currentUser != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _currentUser?.city != null && _currentUser!.city!.isNotEmpty
                  ? '${_currentUser!.city} & nearby picks tailored to you'
                  : 'Personalized using your trade history',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        BlocBuilder<ItemBloc, ItemState>(
          bloc: _recommendedBloc,
          builder: (context, state) {
            if (state is ItemLoading || state is ItemInitial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ItemError) {
              return _buildErrorPlaceholder(
                message: state.message,
                onRetry: () => _loadRecommendations(force: true),
              );
            }

            if (state is ItemsLoaded) {
              final items = _excludeCurrentUserItems(
                state.items,
              ).take(6).toList();
              if (items.isEmpty) {
                return _buildEmptyPlaceholder(
                  'Size uygun yeni öneri yok. Kendi ilanlarınız gizlendi.',
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(
                      context,
                      item,
                      badges: index == 0 ? const ['NEW'] : null,
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trading Tips & News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                title: 'How to negotiate smarter trades',
                description:
                    'Use AI suggestions to propose balanced deals and increase acceptance rates.',
                icon: Icons.psychology_alt,
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                title: 'Boost your seller score',
                description:
                    'Complete trades fast and request reviews to build trust badges.',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ItemEntity item, {
    List<String>? badges,
  }) {
    final imageUrl = item.images.isNotEmpty
        ? item.images.first
        : _placeholderImage;
    final locationLabel = _locationLabel(item);

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final favoriteBloc = context.read<FavoriteBloc>();
        final isFavorited = favoriteBloc.isFavorited(item.id);

        return PremiumItemCard(
          imageUrl: imageUrl,
          title: item.title,
          username: _sellerLabel(item),
          price: item.price,
          condition: item.condition ?? 'Belirtilmedi',
          distance: locationLabel,
          viewCount: item.viewCount,
          isVerified: false,
          isFavorited: isFavorited,
          badges: badges,
          onTap: () => AppRouter.toItemDetail(context, item.id),
          onFavorite: () => _toggleFavorite(item),
          onQuickView: () => _showQuickPreview(item),
        );
      },
    );
  }

  void _toggleFavorite(ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final favoriteBloc = context.read<FavoriteBloc>();
      final wasFavorited = favoriteBloc.isFavorited(item.id);
      favoriteBloc.add(ToggleFavorite(item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorited ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapmalısınız'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQuickPreview(ItemEntity item) {
    final description = item.description.trim();
    final imageUrl = item.images.isNotEmpty
        ? item.images.first
        : _placeholderImage;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.55,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.category, size: 16),
                          label: Text(item.category),
                        ),
                        if ((item.city ?? '').isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.location_on, size: 16),
                            label: Text(item.city!),
                          ),
                        if ((item.condition ?? '').isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.inventory_2, size: 16),
                            label: Text(item.condition!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (item.price != null)
                      Text(
                        '₺${item.price!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    else
                      Text(
                        'Takasa uygun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Açıklama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'Bu ürün için henüz açıklama eklenmemiş.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        AppRouter.toItemDetail(context, item.id);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Detaylı incele'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _locationLabel(ItemEntity item) {
    if (item.city != null && item.city!.isNotEmpty) {
      return item.city;
    }
    if (item.fullAddress != null && item.fullAddress!.isNotEmpty) {
      return item.fullAddress;
    }
    if (item.location != null && item.location!.isNotEmpty) {
      return item.location;
    }
    if (item.district != null && item.district!.isNotEmpty) {
      return item.district;
    }
    return null;
  }

  String _resolveLocationLabel() {
    if (_currentUser?.city != null && _currentUser!.city!.isNotEmpty) {
      return _currentUser!.city!;
    }
    if (_currentUser?.location != null && _currentUser!.location!.isNotEmpty) {
      return _currentUser!.location!;
    }
    return 'Konum seçilmedi';
  }

  String _resolveGreeting() {
    final userEmail = _currentUser?.email;
    final emailPrefix = userEmail?.split('@').first;
    final candidates = <String?>[
      _userSocial?['displayName'] as String?,
      _userSocial?['fullName'] as String?,
      _userSocial?['username'] as String?,
      _currentUser?.displayName,
      emailPrefix,
      userEmail,
    ];

    final raw = candidates
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => 'Misafir');

    final first = _firstName(raw);
    return 'Merhaba, $first 👋';
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final photoUrl = (_currentUser?.photoUrl?.isNotEmpty ?? false)
        ? _currentUser!.photoUrl
        : (_userSocial?['photoUrl'] as String?) ??
              (_userSocial?['avatarUrl'] as String?);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: Colors.transparent,
      );
    }

    final fallback = _currentUser?.displayName ?? _currentUser?.email ?? 'U';
    final initials = _initialsFromName(fallback);
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String _initialsFromName(String value) {
    final sanitized = value.trim();
    if (sanitized.isEmpty) return 'U';
    final parts = sanitized.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return sanitized.substring(0, 1).toUpperCase();
  }

  String _firstName(String value) {
    final sanitized = value.trim();
    if (sanitized.contains(' ')) {
      return sanitized.split(' ').first;
    }
    if (sanitized.contains('@')) {
      return sanitized.split('@').first;
    }
    return sanitized;
  }

  num? _asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  String _formatNumber(num value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  String _resolveTierLabel(double? trustScore) {
    if (trustScore == null) {
      return 'Build Trust';
    }
    if (trustScore >= 4.5) {
      return 'Elite Trader';
    }
    if (trustScore >= 4) {
      return 'Pro Trader';
    }
    if (trustScore >= 3) {
      return 'Rising Star';
    }
    return 'Newcomer';
  }

  Widget _buildTipCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _sellerLabel(ItemEntity item) {
    final name = item.ownerName.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'unknown') {
      return name;
    }

    final fallback = item.ownerId.trim();
    if (fallback.isEmpty) return null;
    return fallback;
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

class _CategoryTileData {
  final String name;
  final IconData icon;
  final int count;
  final Color color;

  const _CategoryTileData({
    required this.name,
    required this.icon,
    required this.count,
    required this.color,
  });
}

const Map<String, IconData> _categoryIconMap = {
  'Electronics': Icons.phone_android,
  'Fashion': Icons.checkroom,
  'Luxury': Icons.watch,
  'Books': Icons.menu_book,
  'Gaming': Icons.sports_esports,
  'Home': Icons.home,
  'Art': Icons.palette,
  'Sports': Icons.sports_soccer,
  'Music': Icons.music_note,
  'Automotive': Icons.directions_car,
  'Beauty': Icons.brush,
  'Toys': Icons.toys,
};

const Map<String, Color> _categoryColorMap = {
  'Electronics': Color(0xFF3B82F6),
  'Fashion': Color(0xFFEC4899),
  'Luxury': Color(0xFFd97706),
  'Books': Color(0xFF10B981),
  'Gaming': Color(0xFF8B5CF6),
  'Home': Color(0xFFF97316),
  'Art': Color(0xFFEF4444),
  'Sports': Color(0xFF22C55E),
  'Music': Color(0xFF6366F1),
  'Automotive': Color(0xFF6B7280),
  'Beauty': Color(0xFFFF6B81),
  'Toys': Color(0xFFf97316),
};

const List<Color> _categoryPalette = [
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF10B981),
  Color(0xFFF97316),
  Color(0xFF8B5CF6),
  Color(0xFF22C55E),
  Color(0xFF6366F1),
  Color(0xFF6B7280),
];

const List<_CategoryTileData> _fallbackCategoryTiles = [
  _CategoryTileData(
    name: 'Electronics',
    icon: Icons.phone_android,
    count: 432,
    color: Color(0xFF3B82F6),
  ),
  _CategoryTileData(
    name: 'Fashion',
    icon: Icons.checkroom,
    count: 891,
    color: Color(0xFFEC4899),
  ),
  _CategoryTileData(
    name: 'Books',
    icon: Icons.menu_book,
    count: 234,
    color: Color(0xFF10B981),
  ),
  _CategoryTileData(
    name: 'Gaming',
    icon: Icons.sports_esports,
    count: 156,
    color: Color(0xFF8B5CF6),
  ),
  _CategoryTileData(
    name: 'Home',
    icon: Icons.home,
    count: 89,
    color: Color(0xFFF97316),
  ),
  _CategoryTileData(
    name: 'Art',
    icon: Icons.palette,
    count: 67,
    color: Color(0xFFEF4444),
  ),
  _CategoryTileData(
    name: 'Sports',
    icon: Icons.sports_soccer,
    count: 145,
    color: Color(0xFF22C55E),
  ),
  _CategoryTileData(
    name: 'Music',
    icon: Icons.music_note,
    count: 78,
    color: Color(0xFF6366F1),
  ),
];
