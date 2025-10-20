import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';

/// 🎯 ULTRA MODERN HOME PAGE V3 - PREMIUM EDITION
/// Categories: Perfect circles, horizontal scroll, modern icons
/// Navigation: Elegant, smooth, unique
class ModernHomePageV3 extends StatefulWidget {
  const ModernHomePageV3({Key? key}) : super(key: key);

  @override
  State<ModernHomePageV3> createState() => _ModernHomePageV3State();
}

class _ModernHomePageV3State extends State<ModernHomePageV3>
    with SingleTickerProviderStateMixin {
  late PageController _bannerController;
  late AnimationController _fadeController;
  int _currentBannerIndex = 0;
  String _selectedCategory = 'Tümü';
  late ItemBloc _trendingBloc;
  late ItemBloc _recommendedBloc;

  final List<CategoryV3> _categories = [
    CategoryV3(
      icon: Icons.inbox_outlined,
      label: 'Tümü',
      color: Colors.blue,
      count: 1240,
    ),
    CategoryV3(
      icon: Icons.shopping_bag_outlined,
      label: 'Moda',
      color: Colors.pink,
      count: 580,
    ),
    CategoryV3(
      icon: Icons.grass_outlined,
      label: 'Ayakkabı',
      color: Colors.orange,
      count: 320,
    ),
    CategoryV3(
      icon: Icons.home_outlined,
      label: 'Ev',
      color: Colors.green,
      count: 450,
    ),
    CategoryV3(
      icon: Icons.book_outlined,
      label: 'Kitap',
      color: Colors.purple,
      count: 210,
    ),
    CategoryV3(
      icon: Icons.gamepad_outlined,
      label: 'Oyun',
      color: Colors.indigo,
      count: 180,
    ),
    CategoryV3(
      icon: Icons.watch_outlined,
      label: 'Aksesuar',
      color: Colors.teal,
      count: 290,
    ),
    CategoryV3(
      icon: Icons.directions_car_outlined,
      label: 'Otomotiv',
      color: Colors.red,
      count: 150,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.88);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();

    _trendingBloc = getIt<ItemBloc>()..add(const LoadTrendingItems());
    _recommendedBloc = getIt<ItemBloc>()..add(const LoadRecentItems());

    Future.delayed(const Duration(seconds: 5), _autoScrollBanners);
  }

  void _autoScrollBanners() {
    if (!mounted) return;
    final nextPage = (_currentBannerIndex + 1) % 5;
    _bannerController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(seconds: 5), _autoScrollBanners);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<FavoriteBloc>().add(const LoadFavorites());
          }
        },
        child: CustomScrollView(
          slivers: [
            // HEADER
            _buildSliverHeader(context),

            // BANNER CAROUSEL
            SliverToBoxAdapter(child: _buildBannerCarousel()),

            // SEARCH BAR
            SliverToBoxAdapter(child: _buildSearchBar(context)),

            // CATEGORY CIRCLES (NEW!)
            SliverToBoxAdapter(child: _buildCategoryCircles()),

            // TRENDING SECTION
            SliverToBoxAdapter(child: _buildTrendingSection(context)),

            // RECOMMENDED SECTION
            SliverToBoxAdapter(child: _buildRecommendedSection(context)),

            // BOTTOM SPACING
            SliverToBoxAdapter(child: const SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba 👋',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Barter Qween',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                        ),
                      ],
                    ),
                    _buildHeaderActionButtons(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.notifications_none_outlined,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.notifications),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.favorite_outline,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.favorites),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
              },
              itemCount: 5,
              itemBuilder: (context, index) {
                final colors = [
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                ];
                final color = colors[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Özel Fırsat',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sınırlı Süre',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _buildBannerIndicators(),
        ],
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () => _bannerController.animateToPage(
            index,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentBannerIndex == index ? 26 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: _currentBannerIndex == index
                  ? Colors.blue.shade600
                  : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRouter.explore),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.search_outlined, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Ara...',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 PERFECT CIRCLES - HORIZONTAL SCROLL
  Widget _buildCategoryCircles() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategoriler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: _buildCategoryCircle(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Perfect Circle Category Card
  Widget _buildCategoryCircle(CategoryV3 category) {
    final isSelected = _selectedCategory == category.label;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category.label);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Perfect Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        colors: [category.color, category.color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !isSelected ? category.color.withOpacity(0.08) : null,
                border: isSelected
                    ? Border.all(color: category.color, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category.color.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = category.label);
                  },
                  customBorder: const CircleBorder(),
                  child: Icon(
                    category.icon,
                    color: isSelected
                        ? Colors.white
                        : category.color,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? category.color
                    : Colors.grey.shade700,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            // Count
            Text(
              '${category.count}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trend Olanlar 🔥',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.explore),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<ItemBloc, ItemState>(
            bloc: _trendingBloc,
            builder: (context, state) {
              if (state is ItemLoading) {
                return _buildProductShimmer();
              }

              if (state is ItemsLoaded) {
                final items = state.items.take(6).toList();
                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: _buildProductCard(
                          context: context,
                          item: items[index],
                          index: index,
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sana Özel ⭐',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.explore),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<ItemBloc, ItemState>(
            bloc: _recommendedBloc,
            builder: (context, state) {
              if (state is ItemLoading) {
                return _buildProductShimmer();
              }

              if (state is ItemsLoaded) {
                final items = state.items.take(6).toList();
                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: _buildProductCard(
                          context: context,
                          item: items[index],
                          index: index,
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ItemEntity item,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.itemDetail,
          arguments: item.id,
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey.shade200,
                    image: item.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₺${item.price}',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (item.location.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      item.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFavorited = state is FavoritesLoaded
                      ? state.favorites.any((fav) => fav.id == item.id)
                      : false;

                  return GestureDetector(
                    onTap: () {
                      context.read<FavoriteBloc>().add(
                        ToggleFavorite(item.id),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductShimmer() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryV3 {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  CategoryV3({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });
}
