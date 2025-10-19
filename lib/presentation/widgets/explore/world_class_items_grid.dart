import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../domain/entities/item_entity.dart';
import '../items/item_card_widget.dart';

/// 🌟 WORLD-CLASS ITEMS GRID
///
/// Features:
/// - Responsive grid layout (2-4 columns)
/// - Modern item cards with quick actions
/// - Infinite scroll pagination
/// - Loading states
/// - Empty states
/// - Smooth animations
class WorldClassItemsGrid extends StatefulWidget {
  final List<ItemEntity> items;
  final Function(ItemEntity) onItemTap;
  final VoidCallback onLoadMore;
  final bool showLoadingIndicator;

  const WorldClassItemsGrid({
    Key? key,
    required this.items,
    required this.onItemTap,
    required this.onLoadMore,
    this.showLoadingIndicator = false,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    const cardAspectRatio = 0.64;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = WorldClassDesignSystem.spacingM * 2;
        final spacing = WorldClassDesignSystem.spacingM;
        final availableWidth = (constraints.maxWidth - horizontalPadding).clamp(
          0.0,
          double.infinity,
        );
        final itemWidth = crossAxisCount > 0
            ? (availableWidth - (crossAxisCount - 1) * spacing) / crossAxisCount
            : availableWidth;
        final itemHeight = itemWidth / cardAspectRatio;

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          itemCount:
              widget.items.length +
              (_isLoadingMore || widget.showLoadingIndicator ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == widget.items.length) {
              return _buildLoadingIndicator();
            }

            final item = widget.items[index];
            return ItemCardWidget(
              item: item,
              onTap: () => widget.onItemTap(item),
              showFavoriteButton: true,
              enableLongPressPreview: true,
            );
          },
        );
      },
    );
  }

  /// Calculate responsive column count based on screen width
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 4; // Desktop/Large tablet - 4 columns
    } else if (screenWidth > 900) {
      return 3; // Tablet landscape - 3 columns
    } else if (screenWidth > 600) {
      return 3; // Tablet portrait - 3 columns
    } else {
      return 2; // Mobile - 2 columns
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: WorldClassDesignSystem.cardDecoration,
      child: const Center(child: CircularProgressIndicator()),
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
