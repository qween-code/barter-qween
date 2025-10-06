import 'package:flutter/material.dart';
import '../../../domain/entities/barter_match_entity.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/minimal_design_system.dart';

/// World-Class Neuromorphic Barter Match Card Widget
/// 
/// Displays a potential barter match with advanced neuromorphic design,
/// smooth animations, and sophisticated visual hierarchy.
class BarterMatchCard extends StatefulWidget {
  final BarterMatchEntity match;
  final ItemEntity? targetItem;
  final VoidCallback? onTap;
  final VoidCallback? onSendOffer;
  final VoidCallback? onDismiss;

  const BarterMatchCard({
    super.key,
    required this.match,
    this.targetItem,
    this.onTap,
    this.onSendOffer,
    this.onDismiss,
  });

  @override
  State<BarterMatchCard> createState() => _BarterMatchCardState();
}

class _BarterMatchCardState extends State<BarterMatchCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Hover animation controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Pulse animation controller for score indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _trackMatchClicked() {
    getIt<AnalyticsService>().logBarterMatchClicked(
      matchId: widget.match.id,
      sourceItemId: widget.match.sourceItemId,
      targetItemId: widget.match.targetItemId,
      matchScore: widget.match.matchScore,
      matchQuality: widget.match.quality.name,
    );
  }

  void _trackOfferSent() {
    getIt<AnalyticsService>().logBarterOfferSent(
      matchId: widget.match.id,
      sourceItemId: widget.match.sourceItemId,
      targetItemId: widget.match.targetItemId,
      matchScore: widget.match.matchScore,
      cashDifferential: widget.match.suggestedCashDifferential,
    );
  }

  void _trackMatchDismissed() {
    getIt<AnalyticsService>().logBarterMatchDismissed(
      matchId: widget.match.id,
      sourceItemId: widget.match.sourceItemId,
      targetItemId: widget.match.targetItemId,
      matchScore: widget.match.matchScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_hoverAnimation.value * 0.02),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: MinimalDesignSystem.baseColor,
              boxShadow: [
                // Base neuromorphic shadow
                ...MinimalDesignSystem.neumorphismOutsetShadow,
                // Hover effect shadow
                if (_isHovered)
                  BoxShadow(
                    color: MinimalDesignSystem.primaryColor.withOpacity(0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _trackMatchClicked();
                  widget.onTap?.call();
                },
                onTapDown: (_) {
                  setState(() {
                    _isHovered = true;
                  });
                  _hoverController.forward();
                },
                onTapUp: (_) {
                  setState(() {
                    _isHovered = false;
                  });
                  _hoverController.reverse();
                },
                onTapCancel: () {
                  setState(() {
                    _isHovered = false;
                  });
                  _hoverController.reverse();
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with match score and quality
                      _buildHeader(),
                      
                      const SizedBox(height: 20),
                      
                      // Match score breakdown
                      _buildScoreBreakdown(),
                      
                      const SizedBox(height: 20),
                      
                      // Match reasons
                      if (widget.match.matchReasons.isNotEmpty)
                        _buildMatchReasons(),
                      
                      // Concerns (if any)
                      if (widget.match.concerns?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        _buildConcerns(),
                      ],
                      
                      // Cash differential info
                      if (widget.match.suggestedCashDifferential != null) ...[
                        const SizedBox(height: 16),
                        _buildCashDifferential(),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Neuromorphic Match Score Indicator
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: MinimalDesignSystem.baseColor,
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(widget.match.matchScore).withOpacity(0.3),
                      offset: const Offset(-6, -6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: _getScoreColor(widget.match.matchScore).withOpacity(0.1),
                      offset: const Offset(6, 6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.match.matchScore.round()}%',
                        style: TextStyle(
                          color: _getScoreColor(widget.match.matchScore),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MATCH',
                        style: TextStyle(
                          color: _getScoreColor(widget.match.matchScore).withOpacity(0.7),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 20),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.match.quality.name.toUpperCase()} MATCH',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getQualityColor(widget.match.quality),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.match.distanceKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: MinimalDesignSystem.baseColor,
                    boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: MinimalDesignSystem.softDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.match.distanceKm!.toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: MinimalDesignSystem.softDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Dismiss button
        if (widget.onDismiss != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
            ),
            child: IconButton(
              onPressed: () {
                _trackMatchDismissed();
                widget.onDismiss?.call();
              },
              icon: Icon(
                Icons.close,
                size: 20,
                color: MinimalDesignSystem.softDark,
              ),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildScoreBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: MinimalDesignSystem.ultraDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem('Category', widget.match.categoryScore, Icons.category),
              ),
              Expanded(
                child: _buildScoreItem('Price', widget.match.priceScore, Icons.attach_money),
              ),
              Expanded(
                child: _buildScoreItem('Location', widget.match.locationScore, Icons.location_on),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem('Trust', widget.match.trustScore, Icons.verified_user),
              ),
              Expanded(
                child: _buildScoreItem('Condition', widget.match.conditionScore, Icons.star),
              ),
              Expanded(
                child: _buildScoreItem('Compatibility', widget.match.compatibilityScore, Icons.handshake),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, double score, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: _getScoreColor(score),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MinimalDesignSystem.softDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${score.round()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchReasons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Why this is a great match',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MinimalDesignSystem.ultraDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.match.matchReasons.take(3).map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: MinimalDesignSystem.ultraDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildConcerns() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Considerations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.match.concerns!.take(2).map((concern) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    concern,
                    style: TextStyle(
                      color: MinimalDesignSystem.ultraDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCashDifferential() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: MinimalDesignSystem.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash Differential',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MinimalDesignSystem.ultraDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₺${widget.match.suggestedCashDifferential!.round()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MinimalDesignSystem.primaryColor,
                  ),
                ),
                Text(
                  _getCashDirectionText(widget.match.cashDirection ?? CashDirection.none),
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalDesignSystem.softDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _trackMatchClicked();
                  widget.onTap?.call();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 18,
                        color: MinimalDesignSystem.softDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: MinimalDesignSystem.softDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: MinimalDesignSystem.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: MinimalDesignSystem.primaryColor.withOpacity(0.3),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: MinimalDesignSystem.primaryColor.withOpacity(0.1),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _trackOfferSent();
                  widget.onSendOffer?.call();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Send Offer',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green[600]!;
    if (score >= 60) return Colors.blue[600]!;
    if (score >= 40) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getQualityColor(MatchQuality quality) {
    switch (quality) {
      case MatchQuality.excellent:
        return Colors.green[600]!;
      case MatchQuality.veryGood:
        return Colors.lightGreen[600]!;
      case MatchQuality.good:
        return Colors.blue[600]!;
      case MatchQuality.fair:
        return Colors.orange[600]!;
      case MatchQuality.poor:
        return Colors.red[600]!;
    }
  }

  String _getCashDirectionText(CashDirection direction) {
    switch (direction) {
      case CashDirection.sourceToTarget:
        return 'Source pays target';
      case CashDirection.targetToSource:
        return 'Target pays source';
      case CashDirection.fromInitiator:
        return 'You pay extra';
      case CashDirection.toInitiator:
        return 'They pay extra';
      case CashDirection.none:
        return 'No cash needed';
    }
  }
}