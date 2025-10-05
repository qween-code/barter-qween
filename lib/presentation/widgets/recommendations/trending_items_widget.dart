import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../pages/items/item_detail_page.dart';

/// Trending Items Widget
/// 
/// Displays hot/trending items based on engagement score
/// (views / days since creation)
class TrendingItemsWidget extends StatefulWidget {
  final int maxItems;
  final int daysBack;

  const TrendingItemsWidget({
    super.key,
    this.maxItems = 10,
    this.daysBack = 7,
  });

  @override
  State<TrendingItemsWidget> createState() => _TrendingItemsWidgetState();
}

class _TrendingItemsWidgetState extends State<TrendingItemsWidget> {
  final RecommendationService _recommendationService = getIt<RecommendationService>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  
  List<ItemEntity> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _recommendationService.getTrendingItems(
      limit: widget.maxItems,
      daysBack: widget.daysBack,
    );

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });

      // Track feature usage
      if (items.isNotEmpty) {
        _analytics.logFeatureUsed(
          featureName: 'trending_items',
          additionalParams: {
            'items_count': items.length,
            'days_back': widget.daysBack,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Trending Now',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'HOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Last ${widget.daysBack} days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _TrendingItemCard(
                item: item,
                rank: index + 1,
                onTap: () {
                  _analytics.logItemClicked(
                    itemId: item.id,
                    source: 'trending',
                    position: index,
                  );

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

class _TrendingItemCard extends StatelessWidget {
  final ItemEntity item;
  final int rank;
  final VoidCallback onTap;

  const _TrendingItemCard({
    required this.item,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rank <= 3 
                ? Colors.orange.withOpacity(0.5)
                : Colors.grey.shade200,
            width: rank <= 3 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: rank <= 3
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: rank <= 3 ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rank badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: item.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.images.first,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 40),
                          ),
                        )
                      : Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 40),
                        ),
                ),
                // Rank badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: rank <= 3
                          ? const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            )
                          : null,
                      color: rank > 3 ? Colors.black.withOpacity(0.7) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rank <= 3)
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 14,
                          ),
                        if (rank <= 3) const SizedBox(width: 4),
                        Text(
                          '#$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Views badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.viewCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₺${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 
                                ? Colors.orange.shade700
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      if (item.city != null)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
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
  }
}
