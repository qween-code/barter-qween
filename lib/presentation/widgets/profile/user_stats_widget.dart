import 'package:flutter/material.dart';

/// User Stats Widget
/// Displays seller statistics (Poshmark Closet Stats style)
class UserStatsWidget extends StatelessWidget {
  final int totalSales;
  final int activeListings;
  final double averageRating;
  final int totalReviews;
  final int followersCount;
  final int followingCount;
  final String? responseTime;
  final double? replyRate;
  final bool compact;

  const UserStatsWidget({
    Key? key,
    required this.totalSales,
    required this.activeListings,
    required this.averageRating,
    required this.totalReviews,
    this.followersCount = 0,
    this.followingCount = 0,
    this.responseTime,
    this.replyRate,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactStats();
    }
    return _buildFullStats();
  }

  Widget _buildFullStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Seller Stats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_bag,
                  label: 'Sales',
                  value: totalSales.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.inventory,
                  label: 'Active',
                  value: activeListings.toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  label: 'Rating',
                  value: averageRating.toStringAsFixed(1),
                  subtitle: '$totalReviews reviews',
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary stats row
          Row(
            children: [
              if (responseTime != null)
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    label: 'Response',
                    value: responseTime!,
                    color: Colors.purple,
                    smallText: true,
                  ),
                ),
              if (replyRate != null && replyRate! > 0)
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Reply Rate',
                    value: '${replyRate!.round()}%',
                    color: Colors.indigo,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Social stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialStat('Followers', followersCount),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _buildSocialStat('Following', followingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactStatItem(
          icon: Icons.shopping_bag,
          value: totalSales.toString(),
          label: 'Sales',
        ),
        _buildCompactStatItem(
          icon: Icons.star,
          value: averageRating.toStringAsFixed(1),
          label: 'Rating',
        ),
        _buildCompactStatItem(
          icon: Icons.people,
          value: followersCount.toString(),
          label: 'Followers',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
    bool smallText = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: smallText ? 12 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
