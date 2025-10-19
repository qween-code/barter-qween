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
import '../../blocs/favorite/favorite_state.dart';

/// Modern, Trendy Home Page
/// Inspired by: Trendyol, Shein, AliExpress best practices
/// Features: Smooth scrolling categories, modern cards, great UX
class ModernHomePage extends StatefulWidget {
  const ModernHomePage({Key? key}) : super(key: key);

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with SingleTickerProviderStateMixin {
  late PageController _bannerController;
  late AnimationController _animationController;
  int _currentBannerIndex = 0;
  late ItemBloc _trendingBloc;
  late ItemBloc _recommendedBloc;

  // Categories
  final List<CategoryItem> _categories = [
    CategoryItem(icon: '📱', label: 'Elektronik', color: Colors.blue),
    CategoryItem(icon: '👗', label: 'Moda', color: Colors.pink),
    CategoryItem(icon: '👟', label: 'Ayakkabı', color: Colors.orange),
    CategoryItem(icon: '🏠', label: 'Ev', color: Colors.green),
    CategoryItem(icon: '📚', label: 'Kitap', color: Colors.purple),
    CategoryItem(icon: '🎮', label: 'Oyun', color: Colors.indigo),
    CategoryItem(icon: '⌚', label: 'Aksesuar', color: Colors.teal),
    CategoryItem(icon: '🚗', label: 'Otomotiv', color: Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.95);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _trendingBloc = getIt<ItemBloc>()..add(const LoadTrendingItems());
    _recommendedBloc = getIt<ItemBloc>()..add(const LoadRecentItems());

    // Auto-scroll banners
    Future.delayed(const Duration(seconds: 5), _autoScrollBanners);
  }

  void _autoScrollBanners() {
    if (!mounted) return;
    final nextPage = (_currentBannerIndex + 1) % 5;
    _bannerController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 5), _autoScrollBanners);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<FavoriteBloc>().add(const LoadFavorites());
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              _buildHeader(context),

              // BANNER CAROUSEL
              _buildBannerCarousel(),

              const SizedBox(height: 24),

              // SEARCH BAR
              _buildSearchBar(context),

              const SizedBox(height: 24),

              // CATEGORIES SECTION
              _buildCategoriesSection(context),

              const SizedBox(height: 32),

              // TRENDING SECTION
              _buildTrendingSection(context),

              const SizedBox(height: 32),

              // RECOMMENDED SECTION
              _buildRecommendedSection(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar height offset
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Header content
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba 👋',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barter Qween',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      context.pushNamed(AppRouter.notifications);
                    },
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          colors[index],
                          colors[index].withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors[index].withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Özel Teklif',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Keşfet →',
                                  style: TextStyle(
                                    color: colors[index],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          const SizedBox(height: 12),
          // Indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBannerIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentBannerIndex == index
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onTap: () => context.pushNamed(AppRouter.search),
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintText: 'Ara...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategoriler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(AppRouter.explore),
                child: const Text('Tümü →'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // SCROLLABLE ROUNDED CATEGORIES
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category
      },
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color,
              category.color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trend Olanlar 🔥',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ItemBloc, ItemState>(
          bloc: _trendingBloc,
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ItemsLoaded) {
              final items = state.items.take(6).toList();
              return SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildProductCard(context, items[index]),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sana Özel ⭐',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ItemBloc, ItemState>(
          bloc: _recommendedBloc,
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ItemsLoaded) {
              final items = state.items.take(6).toList();
              return SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildProductCard(context, items[index]),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ItemEntity item) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.itemDetail, extra: item.id);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[200],
                    image: item.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₺${item.price}',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                      if (isFavorited) {
                        context.read<FavoriteBloc>().add(
                          RemoveFavorite(item.id),
                        );
                      } else {
                        context.read<FavoriteBloc>().add(
                          AddFavorite(item.id),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
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
}

class CategoryItem {
  final String icon;
  final String label;
  final Color color;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
