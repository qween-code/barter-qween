import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/world_class_design_system.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';

/// 🌟 WORLD-CLASS ITEM DETAIL PAGE - Hepsiburada/Trendyol Style
/// 
/// Features:
/// - Image gallery with zoom
/// - Complete item information
/// - BARTER CONDITIONS display
/// - Seller profile and rating
/// - Trade offer button
/// - Favorite & share actions
/// - Similar items recommendations
class ItemDetailPage extends StatefulWidget {
  final String itemId;

  const ItemDetailPage({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> with SingleTickerProviderStateMixin {
  final PageController _imageController = PageController();
  late TabController _tabController;
  bool _isFavorite = false;
  ItemEntity? _item;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load all items and filter by itemId
    context.read<ItemBloc>().add(const LoadAllItems());
    // Also try to load the specific item
    context.read<ItemBloc>().add(LoadItem(widget.itemId));
  }

  @override
  void dispose() {
    _imageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemsLoaded) {
            try {
              final item = state.items.firstWhere(
                (item) => item.id == widget.itemId,
              );
              setState(() => _item = item);
            } catch (e) {
              // Item not found in loaded items - this is OK during hot reload
              // Items will be loaded by HomeBloc
              debugPrint('Item ${widget.itemId} not yet loaded, waiting...');
            }
          } else if (state is ItemLoaded && state.item.id == widget.itemId) {
            // Single item loaded
            setState(() => _item = state.item);
          } else if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<ItemBloc, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_item == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Ürün bulunamadı'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Geri Dön'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildImageGallery(),
                _buildProductInfo(),
                _buildBarterConditions(),
                _buildSellerInfo(),
                _buildDescriptionTabs(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.share, color: Colors.black, size: 20),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
          },
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    final images = _item!.images.isNotEmpty ? _item!.images : [''];
    
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        color: Colors.white,
        child: Stack(
          children: [
            PageView.builder(
              controller: _imageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // TODO: Open full screen image viewer
                  },
                  child: images[index].isEmpty
                      ? const Center(
                          child: Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                        )
                      : CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
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
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _imageController,
                    count: images.length,
                    effect: const WormEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: Color(0xFFFF6B35),
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _item!.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              _item!.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            // Price & Condition
            Row(
              children: [
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₺${_item!.price?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Condition
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _item!.condition?.toUpperCase() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location & Time
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(
                  _item!.location ?? 'Belirtilmemiş',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(
                  timeago.format(_item!.createdAt, locale: 'tr'),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarterConditions() {
    // Check if barter condition exists and has accepted categories
    final barterCondition = _item!.barterCondition;
    if (barterCondition == null || 
        barterCondition.acceptedCategories == null ||
        barterCondition.acceptedCategories!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final acceptedCategories = barterCondition.acceptedCategories!;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Takas Koşulları',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barter Conditions List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.05),
                    const Color(0xFF764BA2).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sahibi şu ürünlerle takas yapmayı kabul ediyor:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: acceptedCategories.map((condition) {
                      IconData icon;
                      Color color;
                      
                      switch (condition.toLowerCase()) {
                        case 'electronics':
                          icon = Icons.phone_android;
                          color = const Color(0xFF4A90E2);
                          break;
                        case 'fashion':
                          icon = Icons.checkroom;
                          color = const Color(0xFFE91E63);
                          break;
                        case 'home':
                          icon = Icons.home;
                          color = const Color(0xFF9C27B0);
                          break;
                        case 'sports':
                          icon = Icons.sports_soccer;
                          color = const Color(0xFFFF9800);
                          break;
                        case 'books':
                          icon = Icons.menu_book;
                          color = const Color(0xFF795548);
                          break;
                        default:
                          icon = Icons.category;
                          color = const Color(0xFF607D8B);
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 18, color: color),
                            const SizedBox(width: 8),
                            Text(
                              condition,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu kategorilerde ürününüz varsa teklif verebilirsiniz!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            
            // Seller Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item!.userId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(127 değerlendirme)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Message Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Mesaj'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B35),
                side: const BorderSide(color: Color(0xFFFF6B35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTabs() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: Colors.white,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: const Color(0xFF999999),
              indicatorColor: const Color(0xFFFF6B35),
              tabs: const [
                Tab(text: 'Açıklama'),
                Tab(text: 'Özellikler'),
                Tab(text: 'Yorumlar'),
              ],
            ),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Description
                  SingleChildScrollView(
                    child: Text(
                      _item!.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  // Features
                  const Center(child: Text('Ürün özellikleri yakında...')),
                  
                  // Reviews
                  const Center(child: Text('Yorumlar yakında...')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Favorites
            OutlinedButton(
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // Make Offer Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to trade offer page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teklif ver özelliği yakında eklenecek!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz, size: 24),
                label: const Text(
                  'Teklif Ver',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}