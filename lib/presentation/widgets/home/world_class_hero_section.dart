import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS HERO SECTION
///
/// Features:
/// - Welcome message
/// - Quick stats
/// - Action buttons
/// - Personalized content
class WorldClassHeroSection extends StatelessWidget {
  final Function(String) onActionTap;

  const WorldClassHeroSection({Key? key, required this.onActionTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
      padding: const EdgeInsets.all(WorldClassDesignSystem.spacingL),
      decoration: WorldClassDesignSystem.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message
          Text(
            'Welcome back! 👋',
            style: WorldClassDesignSystem.heading4.copyWith(
              color: WorldClassDesignSystem.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: WorldClassDesignSystem.spacingS),

          Text(
            'Discover amazing items to trade',
            style: WorldClassDesignSystem.bodyLarge.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),

          const SizedBox(height: WorldClassDesignSystem.spacingL),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'My Items',
                  value: '12',
                  color: WorldClassDesignSystem.primaryColor,
                ),
              ),
              const SizedBox(width: WorldClassDesignSystem.spacingM),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  value: '8',
                  color: WorldClassDesignSystem.secondaryColor,
                ),
              ),
              const SizedBox(width: WorldClassDesignSystem.spacingM),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.handshake_rounded,
                  label: 'Trades',
                  value: '5',
                  color: WorldClassDesignSystem.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: WorldClassDesignSystem.iconM),
          const SizedBox(height: WorldClassDesignSystem.spacingXS),
          Text(
            value,
            style: WorldClassDesignSystem.heading5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: WorldClassDesignSystem.labelSmall.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
