import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../widgets/cards/neumorphic_card.dart';
import '../../widgets/loading/skeleton_loader.dart';
import '../items/item_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  late AnimationController _categoryAnimController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': const Color(0xFF9C27B0)},
    {'name': 'Electronics', 'icon': Icons.devices_rounded, 'color': const Color(0xFF2196F3)},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFFE91E63)},
    {'name': 'Home', 'icon': Icons.home_rounded, 'color': const Color(0xFF4CAF50)},
    {'name': 'Books', 'icon': Icons.book_rounded, 'color': const Color(0xFFFF9800)},
    {'name': 'Sports', 'icon': Icons.sports_soccer_rounded, 'color': const Color(0xFFF44336)},
    {'name': 'Toys', 'icon': Icons.toys_rounded, 'color': const Color(0xFF9C27B0)},
    {'name': 'Music', 'icon': Icons.music_note_rounded, 'color': const Color(0xFF3F51B5)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _categoryAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    context.read<ItemBloc>().add(const LoadAllItems());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(),
          _buildInteractiveCategoryGrid(),
          _buildItemsSection(),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Discover amazing items to trade',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCategoryGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['name'] ||
                (_selectedCategory == null && category['name'] == 'All');

            return _buildCategoryCard(category, isSelected, index);
          },
          childCount: _categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isSelected, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'] == 'All' ? null : category['name'] as String;
                });
                context.read<ItemBloc>().add(LoadAllItems(category: _selectedCategory));
              },
              child: NeumorphicCard(
                isPressed: isSelected,
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                            : (category['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: isSelected ? Colors.white : category['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsSection() {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const SkeletonItemCard(),
                childCount: 6,
              ),
            ),
          );
        }

        if (state is ItemError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ItemBloc>().add(const LoadAllItems()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ItemsLoaded) {
          if (state.items.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('No items found', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildItemCard(state.items[index], index),
                childCount: state.items.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildItemCard(ItemEntity item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => getIt<ItemBloc>()),
                        BlocProvider(create: (_) => getIt<FavoriteBloc>()),
                      ],
                      child: ItemDetailPage(itemId: item.id),
                    ),
                  ),
                );
              },
              child: NeumorphicCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: item.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade400),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
                              ),
                      ),
                    ),
                    // Details
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
