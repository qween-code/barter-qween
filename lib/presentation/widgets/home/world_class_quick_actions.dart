import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS QUICK ACTIONS
///
/// Features:
/// - Quick access buttons
/// - Icon animations
/// - Action callbacks
class WorldClassQuickActions extends StatelessWidget {
  final Function(String) onActionTap;

  const WorldClassQuickActions({Key? key, required this.onActionTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: WorldClassDesignSystem.spacingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR',
              color: WorldClassDesignSystem.primaryColor,
              onTap: () => onActionTap('scan_qr'),
            ),
          ),
          const SizedBox(width: WorldClassDesignSystem.spacingM),
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_photo_alternate_rounded,
              label: 'Quick Add',
              color: WorldClassDesignSystem.secondaryColor,
              onTap: () => onActionTap('quick_add'),
            ),
          ),
          const SizedBox(width: WorldClassDesignSystem.spacingM),
          Expanded(
            child: _buildActionButton(
              icon: Icons.location_on_rounded,
              label: 'Nearby',
              color: WorldClassDesignSystem.accentColor,
              onTap: () => onActionTap('nearby'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusL),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: WorldClassDesignSystem.iconL),
            const SizedBox(height: WorldClassDesignSystem.spacingXS),
            Text(
              label,
              style: WorldClassDesignSystem.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
