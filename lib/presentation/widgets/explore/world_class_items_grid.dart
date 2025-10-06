import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../domain/entities/item_entity.dart';

/// 🌟 WORLD-CLASS ITEMS GRID
/// 
/// Features:
/// - Grid layout
/// - Item cards
/// - Infinite scroll
/// - Loading states
/// - Empty states
class WorldClassItemsGrid extends StatefulWidget {
  final List<ItemEntity> items;
  final Function(ItemEntity) onItemTap;
  final VoidCallback onLoadMore;

  const WorldClassItemsGrid({
    Key? key,
    required this.items,
    required this.onItemTap,
    required this.onLoadMore,
  }) : super(key: key);

  @override
  State<WorldClassItemsGrid> createState() => _WorldClassItemsGridState();
}

class _WorldClassItemsGridState extends State<WorldClassItemsGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        widget.onLoadMore();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: WorldClassDesignSystem.spacingM,
        mainAxisSpacing: WorldClassDesignSystem.spacingM,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return _buildLoadingIndicator();
        }
        
        final item = widget.items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ItemEntity item) {
    return GestureDetector(
      onTap: () => widget.onItemTap(item),
      child: Container(
        decoration: WorldClassDesignSystem.elevatedCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(WorldClassDesignSystem.radiusL),
                    topRight: Radius.circular(WorldClassDesignSystem.radiusL),
                  ),
                  color: WorldClassDesignSystem.borderLight,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(WorldClassDesignSystem.radiusL),
                    topRight: Radius.circular(WorldClassDesignSystem.radiusL),
                  ),
                  child: item.images.isNotEmpty
                      ? Image.network(
                          item.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: WorldClassDesignSystem.secondaryText,
                            );
                          },
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(WorldClassDesignSystem.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: WorldClassDesignSystem.labelMedium.copyWith(
                        color: WorldClassDesignSystem.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: WorldClassDesignSystem.spacingXS),
                    
                    // Category
                    Text(
                      item.category,
                      style: WorldClassDesignSystem.labelSmall.copyWith(
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Price and Favorite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price?.toStringAsFixed(0) ?? '0'} TL',
                          style: WorldClassDesignSystem.labelMedium.copyWith(
                            color: WorldClassDesignSystem.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ],
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

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: WorldClassDesignSystem.cardDecoration,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: WorldClassDesignSystem.secondaryText,
          ),
          const SizedBox(height: WorldClassDesignSystem.spacingL),
          Text(
            'No items found',
            style: WorldClassDesignSystem.heading5.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: WorldClassDesignSystem.spacingS),
          Text(
            'Try adjusting your search or filters',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
