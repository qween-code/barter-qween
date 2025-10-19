import 'package:flutter/material.dart';

/// User Rating Breakdown Widget
/// Shows detailed rating distribution (Poshmark style)
class UserRatingBreakdownWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final int fiveStarReviews;
  final int fourStarReviews;
  final int threeStarReviews;
  final int twoStarReviews;
  final int oneStarReviews;

  // Review attributes (OfferUp style)
  final int timelyCount;
  final int friendlyCount;
  final int reliableCount;
  final int asDescribedCount;

  const UserRatingBreakdownWidget({
    Key? key,
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStarReviews,
    required this.fourStarReviews,
    required this.threeStarReviews,
    required this.twoStarReviews,
    required this.oneStarReviews,
    this.timelyCount = 0,
    this.friendlyCount = 0,
    this.reliableCount = 0,
    this.asDescribedCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalReviews == 0) {
      return const SizedBox.shrink();
    }

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
          // Header with average rating
          Row(
            children: [
              // Large star rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : (index < averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalReviews reviews',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Rating bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, fiveStarReviews, totalReviews),
                    _buildRatingBar(4, fourStarReviews, totalReviews),
                    _buildRatingBar(3, threeStarReviews, totalReviews),
                    _buildRatingBar(2, twoStarReviews, totalReviews),
                    _buildRatingBar(1, oneStarReviews, totalReviews),
                  ],
                ),
              ),
            ],
          ),

          // Review attributes (OfferUp style compliments)
          if (_hasAttributes()) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            const Text(
              'Buyer Compliments',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (timelyCount > 0)
                  _buildAttributeChip(
                    'Timely',
                    timelyCount,
                    Icons.schedule,
                    Colors.blue,
                  ),
                if (friendlyCount > 0)
                  _buildAttributeChip(
                    'Friendly',
                    friendlyCount,
                    Icons.sentiment_satisfied,
                    Colors.green,
                  ),
                if (reliableCount > 0)
                  _buildAttributeChip(
                    'Reliable',
                    reliableCount,
                    Icons.verified_user,
                    Colors.purple,
                  ),
                if (asDescribedCount > 0)
                  _buildAttributeChip(
                    'As Described',
                    asDescribedCount,
                    Icons.check_circle,
                    Colors.orange,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stars >= 4
                      ? Colors.green
                      : (stars >= 3 ? Colors.orange : Colors.red),
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeChip(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAttributes() {
    return timelyCount > 0 ||
        friendlyCount > 0 ||
        reliableCount > 0 ||
        asDescribedCount > 0;
  }
}
