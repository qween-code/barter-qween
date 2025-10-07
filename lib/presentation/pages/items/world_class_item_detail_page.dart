import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';

class WorldClassItemDetailPage extends StatefulWidget {
  final String itemId;
  
  const WorldClassItemDetailPage({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<WorldClassItemDetailPage> createState() => _WorldClassItemDetailPageState();
}

class _WorldClassItemDetailPageState extends State<WorldClassItemDetailPage>
    with TickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  int _selectedTabIndex = 0; // 0: Description, 1: Specs, 2: Seller

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadItem();
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

  void _loadItem() {
    context.read<ItemBloc>().add(LoadItem(widget.itemId));
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    context.read<FavoriteBloc>().add(ToggleFavorite(widget.itemId));
  }

  void _makeOffer() {
    // TODO: Implement make offer
    _showOfferDialog();
  }

  void _showOfferDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfferBottomSheet(),
    );
  }

  Widget _buildOfferBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WorldClassDesignSystem.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: WorldClassDesignSystem.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Make an Offer',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement cash offer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WorldClassDesignSystem.primaryColor,
                    foregroundColor: WorldClassDesignSystem.primaryWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                    ),
                  ),
                  child: Text('Cash Offer'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement trade offer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WorldClassDesignSystem.cardBackground,
                    foregroundColor: WorldClassDesignSystem.primaryText,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                    ),
                  ),
                  child: Text('Trade Offer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemLoading) {
                return _buildLoadingState();
              } else if (state is ItemLoaded) {
                return _buildItemContent(state.item);
              } else if (state is ItemError) {
                return _buildErrorState(state.message);
              } else {
                return _buildDefaultContent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: WorldClassDesignSystem.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: WorldClassDesignSystem.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading item',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: WorldClassDesignSystem.primaryColor,
              foregroundColor: WorldClassDesignSystem.primaryWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    // Mock item data for demonstration
    final item = {
      'id': widget.itemId,
      'title': 'iPhone 13 Pro',
      'description': 'Excellent condition iPhone 13 Pro with 256GB storage. No scratches or damages.',
      'price': 25000.0,
      'category': 'Electronics',
      'condition': 'excellent',
      'location': 'Istanbul, Turkey',
      'images': [
        'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop',
      ],
      'owner': {
        'name': 'Ahmet Yılmaz',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
        'rating': 4.8,
        'totalTrades': 24,
      },
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    };

    return _buildItemContent(item);
  }

  Widget _buildItemContent(dynamic item) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildImageGallery(item),
            _buildPriceSection(item),
            _buildTitleAndBadges(item),
            _buildQuickInfo(item),
            _buildTabBar(),
            _buildTabContent(item),
            _buildLocationPreview(item),
            _buildSellerCard(item),
            _buildSimilarItems(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120), // Bottom padding for fixed buttons
            ),
          ],
        ),
        _buildFixedButtons(),
      ],
    );
  }

  Widget _buildImageGallery(dynamic item) {
    final images = item['images'] as List<String>? ?? [];
    
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: WorldClassDesignSystem.primaryText,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? WorldClassDesignSystem.errorColor : WorldClassDesignSystem.primaryText,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: WorldClassDesignSystem.primaryText,
          ),
          onPressed: () {
            // TODO: Implement share
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: WorldClassDesignSystem.cardBackground,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: WorldClassDesignSystem.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: WorldClassDesignSystem.cardBackground,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: WorldClassDesignSystem.secondaryText,
                    ),
                  ),
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? WorldClassDesignSystem.primaryWhite
                            : WorldClassDesignSystem.primaryWhite.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(dynamic item) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? 'Unknown Item',
              style: WorldClassDesignSystem.headingLarge.copyWith(
                color: WorldClassDesignSystem.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WorldClassDesignSystem.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item['category'] ?? '',
                    style: WorldClassDesignSystem.bodySmall.copyWith(
                      color: WorldClassDesignSystem.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WorldClassDesignSystem.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item['condition'] ?? '',
                    style: WorldClassDesignSystem.bodySmall.copyWith(
                      color: WorldClassDesignSystem.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '₺${(item['price'] ?? 0.0).toStringAsFixed(0)}',
                  style: WorldClassDesignSystem.headingLarge.copyWith(
                    color: WorldClassDesignSystem.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: WorldClassDesignSystem.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['location'] ?? '',
                      style: WorldClassDesignSystem.bodyMedium.copyWith(
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfo(dynamic item) {
    final owner = item['owner'] ?? {};
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          boxShadow: [WorldClassDesignSystem.cardShadow],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(owner['avatar'] ?? ''),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner['name'] ?? 'Unknown User',
                    style: WorldClassDesignSystem.bodyMedium.copyWith(
                      color: WorldClassDesignSystem.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: WorldClassDesignSystem.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${owner['rating'] ?? 0.0}',
                        style: WorldClassDesignSystem.bodySmall.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${owner['totalTrades'] ?? 0} trades',
                        style: WorldClassDesignSystem.bodySmall.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to owner profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WorldClassDesignSystem.cardBackground,
                foregroundColor: WorldClassDesignSystem.primaryText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                ),
              ),
              child: Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(dynamic item) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          boxShadow: [WorldClassDesignSystem.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: WorldClassDesignSystem.headingMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item['description'] ?? '',
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                color: WorldClassDesignSystem.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarItems() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similar Items',
              style: WorldClassDesignSystem.headingMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Mock count
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildSimilarItemCard(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarItemCard(int index) {
    final mockItems = [
      {
        'title': 'iPhone 12 Pro',
        'price': 20000.0,
        'image': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=200&h=200&fit=crop',
      },
      {
        'title': 'Samsung Galaxy S21',
        'price': 18000.0,
        'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200&h=200&fit=crop',
      },
      {
        'title': 'MacBook Air',
        'price': 35000.0,
        'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=200&h=200&fit=crop',
      },
      {
        'title': 'iPad Pro',
        'price': 28000.0,
        'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=200&h=200&fit=crop',
      },
      {
        'title': 'AirPods Pro',
        'price': 8000.0,
        'image': 'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=200&h=200&fit=crop',
      },
    ];

    final item = mockItems[index % mockItems.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to item detail
        },
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            color: WorldClassDesignSystem.cardBackground,
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
            boxShadow: [WorldClassDesignSystem.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(WorldClassDesignSystem.radiusMedium),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: (item['image'] as String?) ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: WorldClassDesignSystem.cardBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: WorldClassDesignSystem.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: WorldClassDesignSystem.cardBackground,
                      child: Icon(
                        Icons.image_not_supported,
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['title'] as String?) ?? 'Unknown',
                      style: WorldClassDesignSystem.bodySmall.copyWith(
                        color: WorldClassDesignSystem.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₺${((item['price'] as num?) ?? 0.0).toStringAsFixed(0)}',
                      style: WorldClassDesignSystem.bodySmall.copyWith(
                        color: WorldClassDesignSystem.primaryColor,
                        fontWeight: FontWeight.bold,
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

  // ========================================
  // ENHANCED SECTIONS - Trendyol/Hepsiburada Style
  // ========================================

  Widget _buildPriceSection(dynamic item) {
    final price = item is ItemEntity ? item.price : item['price'];
    final originalPrice = item is ItemEntity ? item.originalPrice : item['originalPrice'];
    final discountPercent = originalPrice != null && price != null && originalPrice > price
        ? ((1 - (price / originalPrice)) * 100).toInt()
        : null;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: WorldClassDesignSystem.primaryBackground,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Price
                  Row(
                    children: [
                      Text(
                        '₺${price?.toStringAsFixed(0) ?? 'N/A'}',
                        style: WorldClassDesignSystem.headingLarge.copyWith(
                          color: WorldClassDesignSystem.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      if (discountPercent != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: WorldClassDesignSystem.errorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: WorldClassDesignSystem.bodySmall.copyWith(
                              color: WorldClassDesignSystem.primaryWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Original Price
                  if (originalPrice != null && originalPrice > (price ?? 0)) ...[
                    const SizedBox(height: 4),
                    Text(
                      '₺${originalPrice.toStringAsFixed(0)}',
                      style: WorldClassDesignSystem.bodyMedium.copyWith(
                        color: WorldClassDesignSystem.secondaryText,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndBadges(dynamic item) {
    final title = item is ItemEntity ? item.title : item['title'];
    final brand = item is ItemEntity ? item.brand : item['brand'];
    final category = item is ItemEntity ? item.category : item['category'];
    final condition = item is ItemEntity ? item.condition : item['condition'];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand (if available)
            if (brand != null) ...[
              Text(
                brand,
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            // Title
            Text(
              title ?? 'Unknown Item',
              style: WorldClassDesignSystem.headingMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category != null)
                  _buildBadge(
                    category,
                    WorldClassDesignSystem.primaryColor.withOpacity(0.1),
                    WorldClassDesignSystem.primaryColor,
                  ),
                if (condition != null)
                  _buildBadge(
                    condition,
                    WorldClassDesignSystem.successColor.withOpacity(0.1),
                    WorldClassDesignSystem.successColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: WorldClassDesignSystem.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(dynamic item) {
    final city = item is ItemEntity ? item.city : item['location'];
    final createdAt = item is ItemEntity ? item.createdAt : item['createdAt'];
    final viewCount = item is ItemEntity ? item.viewCount : 0;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          border: Border.all(
            color: WorldClassDesignSystem.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickInfoItem(Icons.location_on, city ?? 'Unknown', 'Location'),
            _buildQuickInfoItem(
              Icons.access_time,
              createdAt != null ? _formatDate(createdAt) : 'N/A',
              'Posted',
            ),
            _buildQuickInfoItem(Icons.visibility, '${viewCount ?? 0}', 'Views'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: WorldClassDesignSystem.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: WorldClassDesignSystem.bodySmall.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: WorldClassDesignSystem.labelSmall.copyWith(
            color: WorldClassDesignSystem.secondaryText,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
        ),
        child: Row(
          children: [
            _buildTabItem('Description', 0),
            _buildTabItem('Specifications', 1),
            _buildTabItem('Seller Info', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? WorldClassDesignSystem.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: WorldClassDesignSystem.bodySmall.copyWith(
              color: isSelected
                  ? WorldClassDesignSystem.primaryWhite
                  : WorldClassDesignSystem.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(dynamic item) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          boxShadow: [WorldClassDesignSystem.cardShadow],
        ),
        child: _selectedTabIndex == 0
            ? _buildDescriptionTab(item)
            : _selectedTabIndex == 1
                ? _buildSpecificationsTab(item)
                : _buildSellerInfoTab(item),
      ),
    );
  }

  Widget _buildDescriptionTab(dynamic item) {
    final description = item is ItemEntity ? item.description : item['description'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: WorldClassDesignSystem.headingMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description ?? 'No description available.',
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.secondaryText,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsTab(dynamic item) {
    // Extract specs from ItemEntity
    final specs = <String, String>{};
    
    if (item is ItemEntity) {
      if (item.brand != null) specs['Brand'] = item.brand!;
      if (item.styleName != null) specs['Model'] = item.styleName!;
      if (item.size != null) specs['Size'] = item.size!;
      if (item.condition != null) specs['Condition'] = item.condition!;
      if (item.material != null) specs['Material'] = item.material!;
      if (item.color != null) specs['Color'] = item.color!;
      if (item.gender != null) specs['Gender'] = item.gender!;
      if (item.ageGroup != null) specs['Age Group'] = item.ageGroup!;
      if (item.wearLevel != null) specs['Wear Level'] = item.wearLevel!;
    }

    if (specs.isEmpty) {
      return Center(
        child: Text(
          'No specifications available.',
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.secondaryText,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: WorldClassDesignSystem.headingMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...specs.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: WorldClassDesignSystem.bodyMedium.copyWith(
                      color: WorldClassDesignSystem.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value,
                    style: WorldClassDesignSystem.bodyMedium.copyWith(
                      color: WorldClassDesignSystem.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSellerInfoTab(dynamic item) {
    final owner = item is ItemEntity ? null : item['owner'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Seller',
          style: WorldClassDesignSystem.headingMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Member since: ${_formatDate(DateTime.now().subtract(const Duration(days: 365)))}',
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total trades: ${owner?['totalTrades'] ?? 0}',
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: WorldClassDesignSystem.warningColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Rating: ${owner?['rating'] ?? 'N/A'}',
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                color: WorldClassDesignSystem.secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationPreview(dynamic item) {
    final city = item is ItemEntity ? item.city : item['location'];
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: WorldClassDesignSystem.headingMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: WorldClassDesignSystem.cardBackground,
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                border: Border.all(
                  color: WorldClassDesignSystem.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: WorldClassDesignSystem.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      city ?? 'Unknown Location',
                      style: WorldClassDesignSystem.bodyMedium.copyWith(
                        color: WorldClassDesignSystem.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view on map',
                      style: WorldClassDesignSystem.bodySmall.copyWith(
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerCard(dynamic item) {
    final owner = item is ItemEntity ? null : item['owner'];
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          boxShadow: [WorldClassDesignSystem.cardShadow],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: owner?['avatar'] != null
                  ? NetworkImage(owner['avatar'])
                  : null,
              backgroundColor: WorldClassDesignSystem.primaryColor.withOpacity(0.1),
              child: owner?['avatar'] == null
                  ? Icon(
                      Icons.person,
                      size: 32,
                      color: WorldClassDesignSystem.primaryColor,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner?['name'] ?? 'Unknown Seller',
                    style: WorldClassDesignSystem.bodyLarge.copyWith(
                      color: WorldClassDesignSystem.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: WorldClassDesignSystem.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${owner?['rating'] ?? 0.0}',
                        style: WorldClassDesignSystem.bodySmall.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${owner?['totalTrades'] ?? 0} trades',
                        style: WorldClassDesignSystem.bodySmall.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                // TODO: Navigate to seller profile or start chat
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: WorldClassDesignSystem.primaryColor,
                side: BorderSide(
                  color: WorldClassDesignSystem.primaryColor,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                ),
              ),
              child: Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.primaryBackground,
          boxShadow: [
            BoxShadow(
              color: WorldClassDesignSystem.primaryBlack.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Message Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Start chat
                  },
                  icon: Icon(Icons.message_outlined, size: 18),
                  label: Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WorldClassDesignSystem.primaryColor,
                    side: BorderSide(
                      color: WorldClassDesignSystem.primaryColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Make Offer Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _makeOffer,
                  icon: Icon(Icons.swap_horiz_rounded, size: 20),
                  label: Text('Make Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WorldClassDesignSystem.primaryColor,
                    foregroundColor: WorldClassDesignSystem.primaryWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
