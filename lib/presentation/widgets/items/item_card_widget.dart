import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import 'tier_badge.dart';

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

  bool get _isQuickActionsVisible => _showQuickActions && mounted;

  @override
  Widget build(BuildContext context) {
    final isNew = DateTime.now().difference(widget.item.createdAt).inDays <= 7;

    final hoverEnabled = _supportsHover(context);
    Widget card = GestureDetector(
      onTap: widget.onTap ?? () => _navigateToDetail(context),
      onLongPress: !hoverEnabled && widget.enableLongPressPreview
          ? () => setState(() => _showQuickActions = !_showQuickActions)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 240),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 0.64,
            child: Column(
              children: [
                Expanded(
                  flex: 12,
                  child: _buildImageSection(context, isNew),
                ),
                Expanded(
                  flex: 10,
                  child: _buildInfoSection(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (hoverEnabled) {
      card = MouseRegion(
        onEnter: (_) => _setHoverState(true),
        onExit: (_) => _setHoverState(false),
        child: card,
      );
    }

    return card;
  }

  bool _supportsHover(BuildContext context) {
    if (kIsWeb) return true;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.fuchsia;
  }

  void _setHoverState(bool hovering) {
    if (!mounted) return;
    setState(() {
      _isHovered = hovering;
      _showQuickActions = hovering;
    });
  }

  Widget _buildImageSection(BuildContext context, bool isNew) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMainImage(),
        Positioned(
          top: 8,
          left: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNew)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              if (widget.item.tier != null) ...[
                if (isNew) const SizedBox(height: 8),
                TierBadge(tier: widget.item.tier!, size: 20),
              ],
            ],
          ),
        ),
        if (widget.item.condition != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (widget.showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
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
                      color:
                          isFavorited ? Colors.red : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        AnimatedOpacity(
          opacity: _isQuickActionsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: IgnorePointer(
            ignoring: !_isQuickActionsVisible,
            child: Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
        ),
      ],
    );
  }

  Widget _buildMainImage() {
    if (widget.item.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.item.images.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final hasBrand =
        widget.item.brand != null && widget.item.brand!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final baseSpacing = (height / 130).clamp(3.0, 6.0);
          final showLocation = height >= 80;
          final showCondition =
              widget.item.condition?.isNotEmpty == true && height >= 96;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBrand) ...[
                Text(
                  widget.item.brand!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: baseSpacing * 0.6),
              ],
              Text(
                widget.item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: baseSpacing),
              if (showLocation)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        widget.item.city?.isNotEmpty == true
                            ? widget.item.city!
                            : 'Unknown',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (showCondition) ...[
                SizedBox(height: baseSpacing * 0.8),
                _buildConditionChip(),
              ],
              const Spacer(),
              _buildPriceRow(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConditionChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _getConditionColor(widget.item.condition!).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.item.condition!,
        style: AppTextStyles.labelSmall.copyWith(
          color: _getConditionColor(widget.item.condition!),
          fontWeight: FontWeight.w600,
          fontSize: 9.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPriceRow() {
    final hasDiscount =
        widget.item.originalPrice != null &&
        widget.item.price != null &&
        widget.item.originalPrice! > widget.item.price!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: widget.item.price != null
              ? Text(
                  '₺${widget.item.price!.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Trade Only',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
        if (hasDiscount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _showQuickActions = false);
        onTap();
      },
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
    AppRouter.toItemDetail(context, widget.item.id);
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
            wasFavorited ? 'Removed from favorites' : 'Added to favorites',
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
            mainAxisSize: MainAxisSize.min,
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

              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image
                      if (widget.item.images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.item.images.first,
                            height: 200,
                            width: double.infinity,
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
                        runSpacing: 8,
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
