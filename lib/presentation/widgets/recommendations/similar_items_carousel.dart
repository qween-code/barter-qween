import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/item_card_frame.dart';

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
  final RecommendationService _recommendationService =
      getIt<RecommendationService>();
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_similarItems.length} items',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
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
                  AppRouter.toItemDetail(context, item.id);
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

  const _SimilarItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: SizedBox(
          width: 160,
          child: ItemCardFrame(
            image: _buildMainImage(),
            imageOverlays: const [],
            contentPadding: const EdgeInsets.all(8),
            backgroundColor: Colors.white,
            borderRadius: 12,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            contentBuilder: (ctx, layout) => _buildContent(ctx, layout),
          ),
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    if (item.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.images.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, size: 40),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, size: 40),
    );
  }

  Widget _buildContent(BuildContext context, ItemCardContentLayout layout) {
    final isCompact = layout.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: isCompact ? 4 : 6),
        Text(
          '₺${item.price?.toStringAsFixed(0) ?? '0'}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        if (item.city != null && item.city!.isNotEmpty) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Row(
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  item.city!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
