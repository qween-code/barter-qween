import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../domain/entities/item_entity.dart';

/// 🌟 WORLD-CLASS RECENT ITEMS
///
/// Features:
/// - Horizontal list
/// - Item cards
/// - Tap callbacks
/// - Loading states
class WorldClassRecentItems extends StatelessWidget {
  final List<ItemEntity> items;
  final Function(ItemEntity) onItemTap;

  const WorldClassRecentItems({
    Key? key,
    required this.items,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(
          horizontal: WorldClassDesignSystem.spacingM,
        ),
        decoration: WorldClassDesignSystem.cardDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: WorldClassDesignSystem.secondaryText,
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingM),
              Text(
                'No recent items',
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: WorldClassDesignSystem.spacingM,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(ItemEntity item) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: WorldClassDesignSystem.spacingM),
      child: GestureDetector(
        onTap: () => onItemTap(item),
        child: Container(
          decoration: WorldClassDesignSystem.elevatedCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: 80,
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

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                    WorldClassDesignSystem.spacingS,
                  ),
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

                      const Spacer(),

                      // Price
                      Text(
                        '${item.price?.toStringAsFixed(0) ?? '0'} TL',
                        style: WorldClassDesignSystem.labelSmall.copyWith(
                          color: WorldClassDesignSystem.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
