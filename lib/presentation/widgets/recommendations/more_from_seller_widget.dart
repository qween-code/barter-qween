import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../pages/items/item_detail_page.dart';

/// More From Seller Widget
/// 
/// Displays other items from the same seller
class MoreFromSellerWidget extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final String? excludeItemId;
  final int maxItems;

  const MoreFromSellerWidget({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.excludeItemId,
    this.maxItems = 6,
  });

  @override
  State<MoreFromSellerWidget> createState() => _MoreFromSellerWidgetState();
}

class _MoreFromSellerWidgetState extends State<MoreFromSellerWidget> {
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
    final items = await _recommendationService.getMoreFromSeller(
      sellerId: widget.sellerId,
      excludeItemId: widget.excludeItemId,
      limit: widget.maxItems,
    );

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
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
              const Icon(Icons.store, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'More from ${widget.sellerName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_items.length} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _CompactItemCard(
                item: item,
                onTap: () {
                  _analytics.logItemClicked(
                    itemId: item.id,
                    source: 'more_from_seller',
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

class _CompactItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;

  const _CompactItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: item.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.images.first,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 30),
                      ),
                    )
                  : Container(
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 30),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₺${item.price?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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
}
