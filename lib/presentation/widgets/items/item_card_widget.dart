import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
// TODO: Neuromorphic effects will be added in Phase 3 UI Enhancement
// import '../../../core/theme/neuromorphic_effects.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../pages/items/item_detail_page.dart';
import 'tier_badge.dart';
import '../barter/barter_condition_badge.dart';

/// Ultra-Deep Neuromorphic Item Card Widget
/// Pinterest-level 16-layer shadows with hover effects
class ItemCardWidget extends StatefulWidget {
  final ItemEntity item;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool enableLongPressPreview;

  const ItemCardWidget({
    super.key,
    required this.item,
    this.onTap,
    this.showFavoriteButton = true,
    this.enableLongPressPreview = true,
  });

  @override
  State<ItemCardWidget> createState() => _ItemCardWidgetState();
}

class _ItemCardWidgetState extends State<ItemCardWidget> {
  bool _isHovered = false;
  bool _showQuickActions = false;

  @override
  Widget build(BuildContext context) {
    final isNew = widget.item.createdAt != null &&
        DateTime.now().difference(widget.item.createdAt!).inDays <= 7;
    
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
        _showQuickActions = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
        _showQuickActions = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap ?? () => _navigateToDetail(context),
        onLongPress: widget.enableLongPressPreview ? () {
          setState(() => _showQuickActions = !_showQuickActions);
        } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges and quick actions
              Expanded(
                child: Stack(
                  children: [
                    // Main Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radius16),
                      ),
                      child: widget.item.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.item.images.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                    
                    // NEW Badge (top-left)
                    if (isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'NEW',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    
                    // Tier Badge (top-left, below NEW badge if exists)
                    if (widget.item.tier != null)
                      Positioned(
                        top: isNew ? 32 : 8,
                        left: 8,
                        child: TierBadge(tier: widget.item.tier!, size: 20),
                      ),
                    
                    // Condition Badge (bottom-left)
                    if (widget.item.condition != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(widget.item.condition!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.item.condition!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    
                    // Favorite button (top-right)
                    if (widget.showFavoriteButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: BlocBuilder<FavoriteBloc, FavoriteState>(
                          builder: (context, favoriteState) {
                            final favoriteBloc = context.read<FavoriteBloc>();
                            final isFavorited = favoriteBloc.isFavorited(widget.item.id);
                            
                            return GestureDetector(
                              onTap: () => _toggleFavorite(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isFavorited
                                          ? Colors.red.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: isFavorited ? 12 : 8,
                                      spreadRadius: isFavorited ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isFavorited ? Colors.red : AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Quick Actions (center overlay, shows on hover/long press)
                    if (_showQuickActions)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppDimensions.radius16),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildQuickActionButton(
                                  icon: Icons.visibility_outlined,
                                  label: 'Quick View',
                                  onTap: () => _showQuickPreview(context),
                                ),
                                const SizedBox(width: 12),
                                _buildQuickActionButton(
                                  icon: Icons.swap_horiz_rounded,
                                  label: 'Trade',
                                  onTap: () => _navigateToDetail(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content with enhanced info
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand (if available)
                    if (widget.item.brand != null) ...[
                      Text(
                        widget.item.brand!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    
                    // Title
                    Text(
                      widget.item.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    // Location and distance
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.item.city ?? 'Unknown',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // TODO: Show distance in Phase 3 (requires distance calculation)
                        // if (widget.item.distance != null) ...[
                        //   const SizedBox(width: 4),
                        //   Text(
                        //     '• ${widget.item.distance!.toStringAsFixed(1)} km',
                        //     style: AppTextStyles.labelSmall.copyWith(
                        //       color: AppColors.textTertiary,
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    // Price or Trade info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.item.price != null)
                          Text(
                            '₺${widget.item.price!.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Trade Only',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        
                        // Show discount badge if original price available
                        if (widget.item.originalPrice != null && 
                            widget.item.price != null &&
                            widget.item.originalPrice! > widget.item.price!)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${((1 - (widget.item.price! / widget.item.originalPrice!)) * 100).toInt()}%',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'brand new':
      case 'new':
        return AppColors.success;
      case 'like new':
        return Colors.green.shade400;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailPage(itemId: widget.item.id),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final favoriteBloc = context.read<FavoriteBloc>();
      final wasFavorited = favoriteBloc.isFavorited(widget.item.id);
      
      favoriteBloc.add(ToggleFavorite(widget.item.id));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorited
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showQuickPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Image
                    if (widget.item.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.item.images.first,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category and location
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(widget.item.category),
                          backgroundColor: AppColors.primaryLight,
                        ),
                        if (widget.item.city != null)
                          Chip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 14),
                                const SizedBox(width: 4),
                                Text(widget.item.city!),
                              ],
                            ),
                            backgroundColor: Colors.grey.shade200,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // View full details button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToDetail(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('View Full Details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
