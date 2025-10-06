import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/world_class_design_system.dart';
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
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildImageGallery(item),
        _buildItemInfo(item),
        _buildOwnerInfo(item),
        _buildDescription(item),
        _buildSimilarItems(),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Bottom padding for fixed button
        ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(WorldClassDesignSystem.radiusMedium),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item['image'],
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
                      item['title'],
                      style: WorldClassDesignSystem.bodySmall.copyWith(
                        color: WorldClassDesignSystem.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₺${item['price'].toStringAsFixed(0)}',
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

  Widget _buildFixedButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
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
          child: ElevatedButton(
            onPressed: _makeOffer,
            style: ElevatedButton.styleFrom(
              backgroundColor: WorldClassDesignSystem.primaryColor,
              foregroundColor: WorldClassDesignSystem.primaryWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              ),
            ),
            child: Text(
              'Make an Offer',
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
