import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';

/// Notifications page displaying user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationEntity> _notifications = []; // local cache for optimistic UI

@override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationBloc>()..add(_initialEvent(context)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            if (_notifications.isNotEmpty)
              TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'Mark all read',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete_all') {
                  _deleteAll();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete_all',
                  child: Text('Delete all'),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final notifications = state is NotificationsLoaded
                ? state.notifications
                : state is NotificationsStreaming
                    ? state.notifications
                    : _notifications; // fallback

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll show up here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

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
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(notification.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.grey[500],
                          onPressed: () => _deleteNotification(notification.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newTradeOffer:
        return Icons.swap_horiz;
      case NotificationType.tradeAccepted:
        return Icons.check_circle;
      case NotificationType.tradeRejected:
        return Icons.cancel;
      case NotificationType.tradeCancelled:
        return Icons.block;
      case NotificationType.tradeCompleted:
        return Icons.done_all;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.itemSold:
        return Icons.sell;
      case NotificationType.itemLiked:
        return Icons.favorite;
      case NotificationType.followReceived:
        return Icons.person_add;
      case NotificationType.newMatch:
        return Icons.handshake;
      case NotificationType.priceDropMatch:
        return Icons.trending_down;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newTradeOffer:
      case NotificationType.tradeAccepted:
        return AppColors.primary;
      case NotificationType.tradeRejected:
      case NotificationType.tradeCancelled:
        return AppColors.error;
      case NotificationType.tradeCompleted:
        return AppColors.success;
      case NotificationType.newMessage:
        return AppColors.secondary;
      case NotificationType.itemSold:
      case NotificationType.itemLiked:
        return AppColors.accent;
      case NotificationType.followReceived:
        return Colors.purple;
      case NotificationType.newMatch:
        return const Color(0xFF4CAF50); // Green
      case NotificationType.priceDropMatch:
        return const Color(0xFFFF9800); // Orange
      case NotificationType.system:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on type
    // TODO: Implement navigation
    print('Navigate to ${notification.type} - ${notification.relatedEntityId}');
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
      }
    });
  }

  void _markAllAsRead() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<NotificationBloc>().add(MarkAllNotificationsAsRead(auth.user.uid));
    }
    setState(() {
      _notifications.replaceRange(
        0,
        _notifications.length,
        _notifications.map((n) => n.markAsRead()).toList(),
      );
    });
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  void _deleteAll() {
    final auth = context.read<AuthBloc>().state;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (auth is AuthAuthenticated) {
                context.read<NotificationBloc>().add(DeleteAllNotifications(auth.user.uid));
              }
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  NotificationEvent _initialEvent(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      return WatchNotifications(auth.user.uid);
    }
    return const LoadNotifications('');
  }
}
