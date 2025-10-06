import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../core/services/analytics_service.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../widgets/home/world_class_hero_section.dart';
import '../../widgets/home/world_class_featured_carousel.dart';
import '../../widgets/home/world_class_category_grid.dart';
import '../../widgets/home/world_class_recent_items.dart';
import '../../widgets/home/world_class_quick_actions.dart';
import '../items/item_detail_page.dart';

/// 🌟 WORLD-CLASS HOME PAGE
/// 
/// Features:
/// - Personalized feed
/// - Trending items carousel
/// - Quick actions
/// - Category grid
/// - Recent items
/// - Real-time updates
/// - Analytics tracking
class WorldClassHomePage extends StatefulWidget {
  const WorldClassHomePage({Key? key}) : super(key: key);

  @override
  State<WorldClassHomePage> createState() => _WorldClassHomePageState();
}

class _WorldClassHomePageState extends State<WorldClassHomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _loadData() {
    // Load featured items
    context.read<ItemBloc>().add(LoadFeaturedItems());
    
    // Load recent items
    context.read<ItemBloc>().add(LoadRecentItems());
    
    // Load trending items
    context.read<ItemBloc>().add(LoadTrendingItems());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: WorldClassDesignSystem.surfaceColor,
                elevation: 0,
                floating: true,
                snap: true,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            WorldClassDesignSystem.primaryColor,
                            WorldClassDesignSystem.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusS),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: WorldClassDesignSystem.primaryWhite,
                      ),
                    ),
                    const SizedBox(width: WorldClassDesignSystem.spacingM),
                    Text(
                      'Barter Queen',
                      style: WorldClassDesignSystem.heading5.copyWith(
                        color: WorldClassDesignSystem.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: WorldClassDesignSystem.primaryText,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: WorldClassDesignSystem.errorColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement search
                    },
                    icon: Icon(
                      Icons.search_rounded,
                      color: WorldClassDesignSystem.primaryText,
                    ),
                  ),
                ],
              ),
              
              // Hero Section
              SliverToBoxAdapter(
                child: WorldClassHeroSection(
                  onActionTap: (action) {
                    // TODO: Handle hero actions
                  },
                ),
              ),
              
              // Quick Actions
              SliverToBoxAdapter(
                child: WorldClassQuickActions(
                  onActionTap: (action) {
                    // TODO: Handle quick actions
                  },
                ),
              ),
              
              // Featured Items
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Items',
                        style: WorldClassDesignSystem.heading4.copyWith(
                          color: WorldClassDesignSystem.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all featured items
                        },
                        child: Text(
                          'See All',
                          style: WorldClassDesignSystem.labelLarge.copyWith(
                            color: WorldClassDesignSystem.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Featured Carousel
              BlocBuilder<ItemBloc, ItemState>(
                builder: (context, state) {
                  if (state is ItemLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ItemError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Error loading featured items',
                          style: WorldClassDesignSystem.bodyMedium.copyWith(
                            color: WorldClassDesignSystem.errorColor,
                          ),
                        ),
                      ),
                    );
                  } else if (state is ItemsLoaded) {
                    return SliverToBoxAdapter(
                      child: WorldClassFeaturedCarousel(
                        items: state.items,
                        onItemTap: (item) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              
              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: WorldClassDesignSystem.heading4.copyWith(
                          color: WorldClassDesignSystem.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all categories
                        },
                        child: Text(
                          'See All',
                          style: WorldClassDesignSystem.labelLarge.copyWith(
                            color: WorldClassDesignSystem.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Category Grid
              SliverToBoxAdapter(
                child: WorldClassCategoryGrid(
                  onCategoryTap: (category) {
                    // TODO: Navigate to category page
                  },
                ),
              ),
              
              // Recent Items
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Items',
                        style: WorldClassDesignSystem.heading4.copyWith(
                          color: WorldClassDesignSystem.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all recent items
                        },
                        child: Text(
                          'See All',
                          style: WorldClassDesignSystem.labelLarge.copyWith(
                            color: WorldClassDesignSystem.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Recent Items List
              BlocBuilder<ItemBloc, ItemState>(
                builder: (context, state) {
                  if (state is ItemLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ItemError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Error loading recent items',
                          style: WorldClassDesignSystem.bodyMedium.copyWith(
                            color: WorldClassDesignSystem.errorColor,
                          ),
                        ),
                      ),
                    );
                  } else if (state is ItemsLoaded) {
                    return SliverToBoxAdapter(
                      child: WorldClassRecentItems(
                        items: state.items,
                        onItemTap: (item) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: WorldClassDesignSystem.spacingXXL),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
