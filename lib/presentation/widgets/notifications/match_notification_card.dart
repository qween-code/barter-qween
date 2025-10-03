import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/notification_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Match Notification Card (Sprint 3)
/// Dedicated card for match-related notifications with quick actions
class MatchNotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onViewMatch;
  final VoidCallback? onDismiss;

  const MatchNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onViewMatch,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isNewMatch = notification.type == NotificationType.newMatch;
    final isPriceDrop = notification.type == NotificationType.priceDropMatch;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      elevation: notification.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: notification.isRead
              ? AppColors.borderDefault
              : AppColors.primary.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Icon(
                      _getIcon(),
                      color: _getIconColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Text(
                          notification.body,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        Text(
                          timeago.format(notification.createdAt, locale: 'tr'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Image preview
                  if (notification.imageUrl != null)
                    Container(
                      margin: const EdgeInsets.only(left: AppDimensions.spacing8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        child: CachedNetworkImage(
                          imageUrl: notification.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.image_not_supported, size: 24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Quick actions
              if (onViewMatch != null || onDismiss != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spacing12),
                  child: Row(
                    children: [
                      if (onViewMatch != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewMatch,
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text('Görüntüle'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                          ),
                        ),
                      if (onViewMatch != null && onDismiss != null)
                        const SizedBox(width: AppDimensions.spacing8),
                      if (onDismiss != null)
                        Expanded(
                          child: TextButton.icon(
                            onPressed: onDismiss,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Kapat'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                          ),
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

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.newMatch:
        return Icons.handshake;
      case NotificationType.priceDropMatch:
        return Icons.trending_down;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.newMatch:
        return const Color(0xFF4CAF50); // Green
      case NotificationType.priceDropMatch:
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  Color _getBackgroundColor() {
    switch (notification.type) {
      case NotificationType.newMatch:
        return const Color(0xFF4CAF50);
      case NotificationType.priceDropMatch:
        return const Color(0xFFFF9800);
      default:
        return AppColors.primary;
    }
  }
}
