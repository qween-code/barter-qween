// 🎨 WORLD-CLASS COMPONENT LIBRARY
// Based on: Dolap, Trendyol, Hepsiburada, AliExpress, Temu, N11

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/safe_text_widget.dart';
import '../widgets/item_card_frame.dart';
import '../widgets/fallback_network_image.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1. ENHANCED CARDS
// ═══════════════════════════════════════════════════════════════════════════

/// Premium Item Card (Grid View)
/// Features: Match score, view counter, quick actions, trust badges
class PremiumItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? username; // Made nullable for flexibility
  final double? price;
  final String condition;
  final String? distance;
  final int viewCount;
  final bool isVerified;
  final bool isFavorited;
  final bool showFavoriteButton;
  final bool showQuickViewButton;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onQuickView;
  final double? matchScore;
  final List<String>? badges; // "NEW", "HOT", "ENDING"

  const PremiumItemCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.username, // Optional now
    this.price,
    required this.condition,
    this.distance,
    this.viewCount = 0,
    this.isVerified = false,
    this.isFavorited = false,
    this.showFavoriteButton = true,
    this.showQuickViewButton = true,
    this.onTap,
    this.onFavorite,
    this.onQuickView,
    this.matchScore,
    this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedUsername = _normalizedUsername();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ItemCardFrame(
        image: _buildMainImage(),
        imageOverlays: _buildImageOverlays(context),
        contentBuilder: (ctx, layout) =>
            _buildContent(ctx, formattedUsername, layout),
        backgroundColor: Colors.white,
        borderRadius: 16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String? formattedUsername,
    ItemCardContentLayout layout,
  ) {
    final locationLabel = distance != null && distance!.trim().isNotEmpty
        ? distance!.trim()
        : null;
    final hasCondition = condition.trim().isNotEmpty;
    final isCompact = layout.isCompact;
    final spacing = isCompact ? 4.0 : 6.0;
    final isUltraCompact = layout.isUltraCompact;
    final bodyHeight = layout.bodyHeight;

    if (isUltraCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeText(
            text: title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildPriceSection(context),
        ],
      );
    }

    if (isCompact) {
      final hasTightSpace = bodyHeight < 92;
      final showLocation = locationLabel != null && !hasTightSpace;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matchScore != null) ...[
            _buildMatchScore(),
            const SizedBox(height: 3),
          ],
          SafeText(
            text: title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showLocation) ...[
            const SizedBox(height: 3),
            _buildLocationRow(locationLabel!),
          ],
          SizedBox(height: showLocation ? 6 : 4),
          _buildPriceSection(context),
        ],
      );
    }

    final showMatchScore = matchScore != null && bodyHeight >= 120;
    final showUsername = formattedUsername != null && bodyHeight >= 112;
    final showLocation = locationLabel != null && bodyHeight >= 96;
    final showCondition = hasCondition && bodyHeight >= 132;

    final double spacingUnit = (bodyHeight / 140).clamp(3.0, 6.0);
    final double primarySpacing = spacingUnit;
    final double secondarySpacing = spacingUnit * 0.75;
    final double tertiarySpacing = spacingUnit * 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMatchScore) ...[
          _buildMatchScore(),
          SizedBox(height: tertiarySpacing),
        ],
        SafeText(
          text: title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (showUsername) ...[
          SizedBox(height: secondarySpacing),
          _buildUsernameRow(formattedUsername!),
        ],
        if (showLocation) ...[
          SizedBox(height: tertiarySpacing),
          _buildLocationRow(locationLabel!),
        ],
        if (showCondition) ...[
          SizedBox(height: tertiarySpacing),
          _buildConditionBadge(),
        ],
        SizedBox(height: (showLocation || showCondition) ? secondarySpacing : tertiarySpacing),
        _buildPriceSection(context),
      ],
    );
  }

  Widget _buildMainImage() {
    return FallbackNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
    );
  }

  List<Widget> _buildImageOverlays(BuildContext context) {
    return [
      if (badges != null && badges!.isNotEmpty)
        Positioned(top: 8, left: 8, child: _buildBadges()),
      if (showFavoriteButton)
        Positioned(top: 8, right: 8, child: _buildFavoriteButton()),
      if (showQuickViewButton && onQuickView != null)
        Positioned(bottom: 8, left: 8, child: _buildQuickViewButton()),
      if (viewCount > 0)
        Positioned(bottom: 8, right: 8, child: _buildViewCounter()),
    ];
  }

  Widget _buildUsernameRow(String usernameValue) {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: SafeText.label(
            '@$usernameValue',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 4),
          Icon(Icons.verified, size: 14, color: Colors.blue[600]),
        ],
      ],
    );
  }

  Widget _buildLocationRow(String label) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: SafeText.label(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SafeText.label(
        condition,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    if (price != null) {
      return Text(
        '${price!.toStringAsFixed(0)}₺',
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Trade Only',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: badges!.map((badge) {
        Color color;
        Color bgColor;

        switch (badge.toUpperCase()) {
          case 'NEW':
            color = Colors.green[700]!;
            bgColor = Colors.green[50]!;
            break;
          case 'HOT':
            color = Colors.red[700]!;
            bgColor = Colors.red[50]!;
            break;
          case 'ENDING':
            color = Colors.orange[700]!;
            bgColor = Colors.orange[50]!;
            break;
          default:
            color = Colors.blue[700]!;
            bgColor = Colors.blue[50]!;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFavoriteButton() {
    if (onFavorite == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onFavorite,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isFavorited ? Colors.red : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildViewCounter() {
    if (viewCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            viewCount.toString(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickViewButton() {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onQuickView,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.visibility_outlined, size: 16, color: Colors.black87),
              SizedBox(width: 6),
              Text(
                'Quick View',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchScore() {
    final score = matchScore!;
    Color color;
    String emoji;

    if (score >= 90) {
      color = Colors.green[600]!;
      emoji = '🔥';
    } else if (score >= 75) {
      color = Colors.blue[600]!;
      emoji = '⭐';
    } else {
      color = Colors.orange[600]!;
      emoji = '✨';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '${score.toStringAsFixed(0)}% Match',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String? _normalizedUsername() {
    if (username == null) return null;
    final raw = username!.trim();
    if (raw.isEmpty) return null;

    final condensed = raw.replaceAll(RegExp(r'\s+'), '');
    final candidate = condensed.isNotEmpty ? condensed : raw;
    final sanitized = candidate.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
    final value = sanitized.isNotEmpty ? sanitized : candidate;
    return value.length > 18 ? value.substring(0, 18) : value;
  }
}

/// Featured Item Card (Horizontal / Large)
/// Used in: Home hero section, featured deals
class FeaturedItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final Color? accentColor;

  const FeaturedItemCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.badge,
    this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FallbackNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor ?? Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Match Card (Barter Matches Page)
/// Shows two items side-by-side with match score
class MatchCard extends StatelessWidget {
  final String yourItemImage;
  final String yourItemTitle;
  final String theirItemImage;
  final String theirItemTitle;
  final double matchScore;
  final List<String> matchReasons;
  final String distance;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMakeOffer;

  const MatchCard({
    Key? key,
    required this.yourItemImage,
    required this.yourItemTitle,
    required this.theirItemImage,
    required this.theirItemTitle,
    required this.matchScore,
    required this.matchReasons,
    required this.distance,
    this.onViewDetails,
    this.onMakeOffer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExcellentMatch = matchScore >= 90;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isExcellentMatch
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isExcellentMatch
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match Score Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExcellentMatch
                    ? [Colors.amber[400]!, Colors.orange[400]!]
                    : [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExcellentMatch ? '🔥' : '⭐',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${matchScore.toStringAsFixed(0)}% Match',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Items Comparison
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Your Item
                Expanded(
                  child: _buildItemPreview(
                    yourItemImage,
                    yourItemTitle,
                    'Your Item',
                  ),
                ),

                // Swap Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.swap_horiz,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                ),

                // Their Item
                Expanded(
                  child: _buildItemPreview(
                    theirItemImage,
                    theirItemTitle,
                    'Their Item',
                  ),
                ),
              ],
            ),
          ),

          // Match Reasons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why it\'s a great match:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...matchReasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(distance, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onMakeOffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Make Offer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(String image, String title, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: FallbackNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. PREMIUM BUTTONS
// ═══════════════════════════════════════════════════════════════════════════

/// Gradient Primary Button (Main CTAs)
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradientColors;
  final double? width;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradientColors,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withOpacity(0.8),
        ];

    return Container(
      width: width,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Floating Action Button with Pulse Animation
class PulsingFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Object? heroTag;

  const PulsingFAB({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.heroTag,
  }) : super(key: key);

  @override
  State<PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor:
                widget.backgroundColor ?? Theme.of(context).primaryColor,
            heroTag: widget.heroTag,
            child: Icon(widget.icon, color: Colors.white),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. SMART INPUTS
// ═══════════════════════════════════════════════════════════════════════════

/// Enhanced Search Bar (Voice + Camera + Auto-complete)
class SmartSearchBar extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onCameraSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const SmartSearchBar({
    Key? key,
    this.hint = 'Search or scan...',
    this.controller,
    this.onVoiceSearch,
    this.onCameraSearch,
    this.onChanged,
    this.onTap,
    this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          if (onCameraSearch != null)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
              onPressed: onCameraSearch,
              tooltip: 'Visual Search',
            ),
          if (onVoiceSearch != null)
            IconButton(
              icon: const Icon(Icons.mic_outlined, color: Colors.grey),
              onPressed: onVoiceSearch,
              tooltip: 'Voice Search',
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. FEEDBACK COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Confetti Animation (Success States)
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool show;

  const ConfettiOverlay({Key? key, required this.child, this.show = false})
    : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiPiece> _pieces = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.show) {
      _generateConfetti();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _generateConfetti();
      _controller.forward(from: 0);
    }
  }

  void _generateConfetti() {
    _pieces.clear();
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _pieces.add(
        ConfettiPiece(
          x: random.nextDouble(),
          y: -0.1,
          color: Colors.primaries[random.nextInt(Colors.primaries.length)],
          rotation: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.show)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  pieces: _pieces,
                  progress: _controller.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
      ],
    );
  }
}

class ConfettiPiece {
  final double x;
  final double y;
  final Color color;
  final double rotation;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.color,
    required this.rotation,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      final paint = Paint()..color = piece.color;
      final x = piece.x * size.width;
      final y = piece.y * size.height + (progress * size.height * 1.2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + progress * math.pi * 4);
      canvas.drawRect(const Rect.fromLTWH(-5, -5, 10, 10), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
