import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS ITEM DETAIL PAGE
/// 
/// Features:
/// - Image gallery
/// - Item information
/// - Seller profile
/// - Actions (favorite, share, contact)
/// - Similar items
class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: WorldClassDesignSystem.primaryColor,
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingL),
              Text(
                'Item Detail Page',
                style: WorldClassDesignSystem.heading2.copyWith(
                  color: WorldClassDesignSystem.primaryText,
                ),
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingM),
              Text(
                'Item ID: $itemId',
                style: WorldClassDesignSystem.bodyLarge.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingM),
              Text(
                'Coming Soon...',
                style: WorldClassDesignSystem.bodyLarge.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}