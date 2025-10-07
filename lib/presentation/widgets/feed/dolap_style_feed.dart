import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Dolap-style Pinterest/Masonry feed
/// Vertical staggered grid with pull-to-refresh
class DolapStyleFeed extends StatefulWidget {
  final List<FeedItem> items;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const DolapStyleFeed({
    Key? key,
    required this.items,
    this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DolapStyleFeed> createState() => _DolapStyleFeedState();
}

class _DolapStyleFeedState extends State<DolapStyleFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.all(16),
        itemCount: widget.items.length + (widget.isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return _buildShimmerCard();
          }
          
          return _DolapFeedCard(item: widget.items[index]);
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 200 + (index % 3) * 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _DolapFeedCard extends StatelessWidget {
  final FeedItem item;

  const _DolapFeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 0.75,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Brand (if exists)
                  if (item.brand != null)
                    Text(
                      item.brand!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Price & Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${item.likeCount}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // User info
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFFFF6B6B),
                        child: Text(
                          item.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.username,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
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

class FeedItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String? brand;
  final String username;
  final int likeCount;
  final int viewCount;

  const FeedItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.brand,
    required this.username,
    this.likeCount = 0,
    this.viewCount = 0,
  });

  String get formattedPrice => '₺${price.toStringAsFixed(0)}';
}
