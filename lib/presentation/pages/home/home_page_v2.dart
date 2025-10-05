import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/neumorphism/neumorphism_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/neumorphism_standards.dart';
import '../../../core/theme/neumorphism_animations.dart';
import '../../../core/theme/neuromorphic_effects.dart';
import '../../widgets/neumorphism/neuromorphic_icon.dart';

/// Ultra Advanced Neumorphism Home Page
/// Pinterest seviyesi yüzen nöromorfik navigasyon ve sinematik geçişler

class HomePageV2 extends StatefulWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'all';
  bool _showSearchBar = false;

  // Ultra nöromorfik animasyon controller'ları
  late AnimationController _floatingNavController;
  late AnimationController _heroAnimationController;
  late AnimationController _parallaxController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    // Ultra nöromorfik animasyonları başlat
    _initializeNeumorphismAnimations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _disposeNeumorphismAnimations();
    super.dispose();
  }

  void _initializeNeumorphismAnimations() {
    // Yüzen navigasyon animasyonu
    _floatingNavController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Hero section animasyonu
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Parallax animasyonu
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _disposeNeumorphismAnimations() {
    _floatingNavController.dispose();
    _heroAnimationController.dispose();
    _parallaxController.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showSearchBar) {
      setState(() => _showSearchBar = true);
    } else if (_scrollController.offset <= 100 && _showSearchBar) {
      setState(() => _showSearchBar = false);
    }

    // Parallax efekt için scroll değeri güncelle
    _parallaxController.value = (_scrollController.offset / 200).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ana içerik
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Ultra nöromorfik app bar
              _buildUltraNeumorphismAppBar(),

              // Sinematik hero section
              SliverToBoxAdapter(
                child: _buildCinematicHeroSection(),
              ),

              // Yüzen nöromorfik kategoriler
              SliverToBoxAdapter(
                child: _buildFloatingCategories(),
              ),

              // Ultra derinlikli card grid'i
              _buildUltraNeumorphismGrid(),

              // Alt boşluk
              const SliverToBoxAdapter(
                child: SizedBox(height: 150),
              ),
            ],
          ),

          // Yüzen nöromorfik navigasyon
          _buildFloatingNeumorphismNavigation(),

          // Sinematik search overlay
          if (_showSearchBar) _buildCinematicSearchOverlay(),
        ],
      ),
    );
  }

  /// Ultra nöromorfik app bar
  Widget _buildUltraNeumorphismAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _heroAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.ultraBackgroundGradient,
              boxShadow: NeumorphismStandards.neumorphismUltraOutsetShadow,
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppDimensions.radius24),
                    ),
                  ),
                  child: _buildAppBarContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarContent() {
    return FlexibleSpaceBar(
      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      title: AnimatedOpacity(
        opacity: _showSearchBar ? 0.0 : 1.0,
        duration: AppDimensions.animation8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'BarterQween',
                  style: AppTextStyles.ultraHeadlineLarge.copyWith(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.ultraPrimaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ULTRA',
                    style: AppTextStyles.ultraLabelLarge.copyWith(
                      fontSize: 10,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Istanbul, Turkey',
                  style: AppTextStyles.embeddedTitleMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: AppColors.ultraNeumorphismSurfaceGradient,
        ),
      ),
    );
  }

  /// Sinematik hero section
  Widget _buildCinematicHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimationController,
      builder: (context, child) {
        return Container(
          height: 320,
          margin: const EdgeInsets.only(top: 8),
          child: PageView.builder(
            itemCount: 5,
            pageSnapping: true,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _parallaxController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _parallaxController.value * 20),
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCinematic),
                    gradient: AppColors.cinematicGradient,
                    boxShadow: [
                      ...NeuromorphicPresets.CardPresets.hero(isHovered: false),
                      ...NeuromorphicEffects.lighting.createAmbientGlow(
                        glowColor: AppColors.primary,
                        intensity: 0.7,
                        radius: 35.0,
                      ),
                    ],
                  ),
                  child: _buildHeroContent(index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeroContent(int index) {
    return Stack(
      children: [
        // Arkaplan deseni
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCinematic),
                gradient: AppColors.ultraShimmerGradient,
              ),
            ),
          ),
        ),

        // İçerik
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.surfaceLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '✨ ULTRA EXPERIENCE',
                  style: AppTextStyles.ultraLabelLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getHeroTitle(index),
                style: AppTextStyles.cinematicDisplayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                _getHeroSubtitle(index),
                style: AppTextStyles.ultraBodyLarge.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 32),
              NeumorphismButtonCollection.heroButton(
                text: 'Keşfet',
                onPressed: () {},
                icon: Icons.arrow_forward,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Yüzen nöromorfik kategoriler
  Widget _buildFloatingCategories() {
    final categories = [
      {'icon': '📱', 'name': 'Elektronik', 'color': AppColors.primary},
      {'icon': '👗', 'name': 'Moda', 'color': AppColors.secondary},
      {'icon': '🏠', 'name': 'Ev & Yaşam', 'color': AppColors.accent},
      {'icon': '🎮', 'name': 'Oyun', 'color': AppColors.success},
      {'icon': '📚', 'name': 'Kitap', 'color': AppColors.warning},
      {'icon': '⚽', 'name': 'Spor', 'color': AppColors.info},
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['name'];

          return AnimatedBuilder(
            animation: _floatingNavController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  sin(_floatingNavController.value * 2 * 3.14159 + index) * 5,
                ),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category['name'] as String);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radius24),
                  border: Border.all(
                    color: isSelected
                        ? (category['color'] as Color)
                        : AppColors.borderNeumorphism,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          ...NeuromorphicPresets.CardPresets.standard(isHovered: true),
                          ...NeuromorphicEffects.lighting.createAmbientGlow(
                            glowColor: category['color'] as Color,
                            intensity: 0.6,
                            radius: 25.0,
                          ),
                        ]
                      : NeuromorphicPresets.CardPresets.standard(isHovered: false),
                ),
                child: Row(
                  children: [
                    Text(
                      category['icon'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category['name'] as String,
                      style: AppTextStyles.ultraTitleLarge.copyWith(
                        fontSize: 16,
                        color: isSelected
                            ? (category['color'] as Color)
                            : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Ultra derinlikli nöromorfik grid
  Widget _buildUltraNeumorphismGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildUltraNeumorphismCard(index);
          },
          childCount: 8,
        ),
      ),
    );
  }

  Widget _buildUltraNeumorphismCard(int index) {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _parallaxController.value * index * 2),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {},
        child: NeumorphismContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppDimensions.radius20,
          boxShadow: NeumorphismStandards.neumorphismUltraOutsetShadow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün görseli
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radius16),
                    gradient: AppColors.ultraGlassGradient,
                    boxShadow: NeumorphismStandards.neumorphismUltraInsetShadow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Ürün bilgileri
              Text(
                'Ultra Premium Item ${index + 1}',
                style: AppTextStyles.ultraTitleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Istanbul',
                    style: AppTextStyles.insetBodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Fiyat ve takas butonu
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.ultraSuccessGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₺${(index + 1) * 500}',
                      style: AppTextStyles.ultraLabelLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: NeumorphismStandards.neumorphismUltraInsetShadow,
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yüzen nöromorfik navigasyon
  Widget _buildFloatingNeumorphismNavigation() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _floatingNavController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              sin(_floatingNavController.value * 2 * 3.14159) * 10,
            ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius32),
                boxShadow: [
                  ...NeuromorphicPresets.NavigationPresets.bottomNav(),
                  ...NeuromorphicEffects.lighting.createAmbientGlow(
                    glowColor: AppColors.primary,
                    intensity: 0.5,
                    radius: 25.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFloatingNavItem(Icons.home, 'Ana Sayfa', true),
                  _buildFloatingNavItem(Icons.explore_outlined, 'Keşfet', false),
                  const SizedBox(width: 80), // FAB için boşluk
                  _buildFloatingNavItem(Icons.chat_bubble_outline, 'Sohbet', false),
                  _buildFloatingNavItem(Icons.person_outline, 'Profil', false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuromorphicIcon(
            icon: icon,
            size: isActive ? IconSize.large : IconSize.medium,
            style: IconStyle.circular,
            isActive: isActive,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Sinematik search overlay
  Widget _buildCinematicSearchOverlay() {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _showSearchBar ? 1.0 : 0.0,
        duration: AppDimensions.animation6,
        child: NeumorphismSearchBarCollection.heroSearchBar(
          controller: TextEditingController(),
          onSearch: (query) {},
          hintText: 'Ne arıyorsunuz?',
        ),
      ),
    );
  }

  // Helper methods
  String _getHeroTitle(int index) {
    final titles = [
      'Ultra Ticaret\nDeneyimi',
      'Premium\nListeler',
      'Mükemmel\nEşleşmeler',
      'Sıfır\nKomisyon',
      'Geniş\nTopluluk',
    ];
    return titles[index % titles.length];
  }

  String _getHeroSubtitle(int index) {
    final subtitles = [
      'Binlerce ürünü keşfedin',
      'Premium ile 3x daha görünür olun',
      'AI destekli akıllı eşleştirme',
      'Premium kullanıcılar komisyon ödemez',
      'Türkiye\'de 10.000+ aktif üye',
    ];
    return subtitles[index % subtitles.length];
  }
}