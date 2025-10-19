import 'package:flutter/material.dart';

/// User Badges Widget
/// Displays verification and achievement badges
/// Based on OfferUp, Depop, Vinted badge systems
class UserBadgesWidget extends StatelessWidget {
  final bool isVerifiedSeller; // Depop blue tick
  final bool isTopSeller; // Depop Top Seller
  final bool isTrustedSeller; // Vinted Trusted Seller
  final bool hasReplyRateBadge; // OfferUp Reply Rate
  final bool hasFastShipperBadge;
  final bool hasTopRatedBadge;
  final bool isIdVerified; // TruYou verification
  final List<String> additionalBadges;
  final bool showLabels;

  const UserBadgesWidget({
    Key? key,
    this.isVerifiedSeller = false,
    this.isTopSeller = false,
    this.isTrustedSeller = false,
    this.hasReplyRateBadge = false,
    this.hasFastShipperBadge = false,
    this.hasTopRatedBadge = false,
    this.isIdVerified = false,
    this.additionalBadges = const [],
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badges = _getBadgesToDisplay();

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badge) => _buildBadge(badge)).toList(),
    );
  }

  List<BadgeData> _getBadgesToDisplay() {
    final badges = <BadgeData>[];

    if (isVerifiedSeller) {
      badges.add(
        BadgeData(
          icon: Icons.verified,
          label: 'Verified',
          color: Colors.blue,
          tooltip: 'Verified Seller - Identity confirmed',
        ),
      );
    }

    if (isTopSeller) {
      badges.add(
        BadgeData(
          icon: Icons.star,
          label: 'Top Seller',
          color: Colors.amber,
          tooltip: 'Top Seller - Exceptional performance',
        ),
      );
    }

    if (isTrustedSeller) {
      badges.add(
        BadgeData(
          icon: Icons.shield,
          label: 'Trusted',
          color: Colors.green,
          tooltip: 'Trusted Seller - Highly reliable',
        ),
      );
    }

    if (isIdVerified) {
      badges.add(
        BadgeData(
          icon: Icons.badge,
          label: 'ID Verified',
          color: Colors.indigo,
          tooltip: 'ID Verified - TruYou member',
        ),
      );
    }

    if (hasReplyRateBadge) {
      badges.add(
        BadgeData(
          icon: Icons.chat_bubble,
          label: 'Quick Reply',
          color: Colors.purple,
          tooltip: 'Quick Reply - Responds fast',
        ),
      );
    }

    if (hasFastShipperBadge) {
      badges.add(
        BadgeData(
          icon: Icons.local_shipping,
          label: 'Fast Shipper',
          color: Colors.orange,
          tooltip: 'Fast Shipper - Ships within 3 days',
        ),
      );
    }

    if (hasTopRatedBadge) {
      badges.add(
        BadgeData(
          icon: Icons.stars,
          label: 'Top Rated',
          color: Colors.pink,
          tooltip: 'Top Rated - 4.8+ rating',
        ),
      );
    }

    return badges;
  }

  Widget _buildBadge(BadgeData badge) {
    if (showLabels) {
      return Tooltip(
        message: badge.tooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badge.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badge.color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badge.icon, size: 16, color: badge.color),
              const SizedBox(width: 6),
              Text(
                badge.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badge.color,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Tooltip(
        message: badge.tooltip,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: badge.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: badge.color.withOpacity(0.3), width: 1),
          ),
          child: Icon(badge.icon, size: 20, color: badge.color),
        ),
      );
    }
  }
}

class BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  final String tooltip;

  BadgeData({
    required this.icon,
    required this.label,
    required this.color,
    required this.tooltip,
  });
}
