import 'package:flutter/material.dart';
import '../../../domain/entities/user_entity_world_class.dart';

/// Trust Score Widget
/// Displays algorithmic trust score (custom feature)
class TrustScoreWidget extends StatelessWidget {
  final TrustScore trustScore;
  final bool showDetails;
  final VoidCallback? onTap;

  const TrustScoreWidget({
    Key? key,
    required this.trustScore,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showDetails) {
      return _buildDetailedView();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            // Trust score circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColor().withOpacity(0.1),
                border: Border.all(color: _getColor(), width: 3),
              ),
              child: Center(
                child: Text(
                  _getScoreText(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getColor(),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Score info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust Score',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreLabel(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDescription(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            if (onTap != null)
              Icon(Icons.info_outline, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.shield, color: _getColor(), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Trust Score Explained',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Score circle (large)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor().withOpacity(0.1),
              border: Border.all(color: _getColor(), width: 4),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getScoreText(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getColor(),
                    ),
                  ),
                  Text(
                    _getScoreLabel(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            _getDescription(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Factors
          const Text(
            'Score Based On:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildFactorItem(Icons.verified, 'Identity Verification', '40%'),
          _buildFactorItem(Icons.shopping_bag, 'Sales History', '20%'),
          _buildFactorItem(Icons.star, 'Ratings & Reviews', '20%'),
          _buildFactorItem(Icons.speed, 'Response & Shipping', '10%'),
          _buildFactorItem(Icons.badge, 'Badges & Achievements', '10%'),
        ],
      ),
    );
  }

  Widget _buildFactorItem(IconData icon, String label, String weight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            weight,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreText() {
    switch (trustScore) {
      case TrustScore.excellent:
        return '95+';
      case TrustScore.verygood:
        return '85';
      case TrustScore.good:
        return '70';
      case TrustScore.fair:
        return '50';
      case TrustScore.new_:
        return 'NEW';
    }
  }

  String _getScoreLabel() {
    switch (trustScore) {
      case TrustScore.excellent:
        return 'Excellent';
      case TrustScore.verygood:
        return 'Very Good';
      case TrustScore.good:
        return 'Good';
      case TrustScore.fair:
        return 'Fair';
      case TrustScore.new_:
        return 'New User';
    }
  }

  String _getDescription() {
    switch (trustScore) {
      case TrustScore.excellent:
        return 'This seller has an excellent track record with verified identity, great ratings, and fast responses.';
      case TrustScore.verygood:
        return 'This seller has a very good reputation with verified identity and positive reviews.';
      case TrustScore.good:
        return 'This seller has a good history with positive feedback from buyers.';
      case TrustScore.fair:
        return 'This seller is building their reputation. Check reviews before purchasing.';
      case TrustScore.new_:
        return 'This is a new seller without sales history. Exercise normal caution.';
    }
  }

  Color _getColor() {
    switch (trustScore) {
      case TrustScore.excellent:
        return Colors.green;
      case TrustScore.verygood:
        return Colors.lightGreen;
      case TrustScore.good:
        return Colors.blue;
      case TrustScore.fair:
        return Colors.orange;
      case TrustScore.new_:
        return Colors.grey;
    }
  }
}
