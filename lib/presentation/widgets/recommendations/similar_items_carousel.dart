import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../pages/items/item_detail_page.dart';

/// Similar Items Carousel Widget
/// 
/// Displays horizontally scrollable list of items similar to the current item
/// Based on: category, price range, and location proximity
class SimilarItemsCarousel extends StatefulWidget {
  final ItemEntity sourceItem;
  final int maxItems;
  final double maxDistanceKm;

  const SimilarItemsCarousel({
    super.key,
    required this.sourceItem,
    this.maxItems = 10,
    this.maxDistanceKm = 50.0,
  });

  @override
  State<SimilarItemsCarousel> createState() => _SimilarItemsCarouselState();
}

class _SimilarItemsCarouselState extends State<SimilarItemsCarousel> {
  final RecommendationService _recommendationService = getIt<RecommendationService>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  
  List<ItemEntity> _similarItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimilarItems();
  }

  Future<void> _loadSimilarItems() async {
    final items = await _recommendationService.getSimilarItems(
      sourceItem: widget.sourceItem,
      limit: widget.maxItems,
      maxDistanceKm: widget.maxDistanceKm,
    );

    if (mounted) {
      setState(() {
        _similarItems = items;
        _isLoading = false;
      });

      // Track analytics
      if (items.isNotEmpty) {
        _analytics.logSimilarItemsViewed(
          sourceItemId: widget.sourceItem.id,
          count: items.length,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_similarItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.recommend, size: 20),
              const SizedBox(width: 8),
              Text(
                'Similar Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_similarItems.length} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _similarItems.length,
            itemBuilder: (context, index) {
              final item = _similarItems[index];
              return _SimilarItemCard(
                item: item,
                onTap: () {
                  // Track click
                  _analytics.logItemClicked(
                    itemId: item.id,
                    source: 'similar_items',
                    position: index,
                  );

                  // Navigate to item detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(itemId: item.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;

  const _SimilarItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: item.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.images.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    '₺${item.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  // Location
                  if (item.city != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.city!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
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
}
