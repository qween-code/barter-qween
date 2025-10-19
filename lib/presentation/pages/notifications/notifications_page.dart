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
import '../../../core/routes/app_router.dart';
import '../../pages/trades/trade_deeplink_page.dart';
import '../../pages/trades/trades_page.dart';

/// Notifications page displaying user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationEntity> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationBloc>()..add(_initialEvent(context)),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Bildirimler'),
            actions: [
              if (_notifications.isNotEmpty)
                TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Tümünü okundu yap',
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
                    child: Text('Hepsini sil'),
                  ),
                ],
              ),
            ],
            bottom: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Takas & Teklif'),
                Tab(text: 'Mesajlar'),
                Tab(text: 'Diğer'),
              ],
            ),
          ),
          body: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded) {
                _notifications
                  ..clear()
                  ..addAll(state.notifications);
              } else if (state is NotificationsStreaming) {
                _notifications
                  ..clear()
                  ..addAll(state.notifications);
              }

              final notifications = state is NotificationsLoaded
                  ? state.notifications
                  : state is NotificationsStreaming
                  ? state.notifications
                  : _notifications;

              final tradeNotifications = notifications
                  .where((n) => _tradeTypes.contains(n.type))
                  .toList();
              final messageNotifications = notifications
                  .where((n) => n.type == NotificationType.newMessage)
                  .toList();
              final otherNotifications = notifications
                  .where(
                    (n) =>
                        !_tradeTypes.contains(n.type) &&
                        n.type != NotificationType.newMessage,
                  )
                  .toList();

              return TabBarView(
                children: [
                  _buildNotificationList(
                    tradeNotifications,
                    emptyLabel: 'Henüz takas veya teklif bildiriminiz yok.',
                  ),
                  _buildNotificationList(
                    messageNotifications,
                    emptyLabel: 'Yeni mesaj bildiriminiz bulunmuyor.',
                  ),
                  _buildNotificationList(
                    otherNotifications,
                    emptyLabel: 'Diğer bildirimler burada listelenecek.',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationEntity> notifications, {
    required String emptyLabel,
  }) {
    if (notifications.isEmpty) {
      return _buildEmptyState(emptyLabel);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(notifications[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Bildirim yok',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
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
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withOpacity(0.05),
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
                  color: _getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
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
      case NotificationType.newItemFromVendor:
        return Icons.shopping_bag;
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
      case NotificationType.newItemFromVendor:
        return const Color(0xFF673AB7); // Purple
      case NotificationType.system:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    final entityId = notification.relatedEntityId;
    switch (notification.type) {
      case NotificationType.newTradeOffer:
      case NotificationType.tradeAccepted:
      case NotificationType.tradeRejected:
      case NotificationType.tradeCancelled:
      case NotificationType.tradeCompleted:
        if (entityId != null && entityId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TradeDeepLinkPage(tradeId: entityId),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TradesPage()),
          );
        }
        break;
      case NotificationType.newMessage:
        AppRouter.toMessages(context);
        break;
      case NotificationType.itemSold:
      case NotificationType.itemLiked:
      case NotificationType.newMatch:
      case NotificationType.priceDropMatch:
      case NotificationType.newItemFromVendor:
        if (entityId != null && entityId.isNotEmpty) {
          AppRouter.toItemDetail(context, entityId);
        }
        break;
      case NotificationType.followReceived:
      case NotificationType.system:
        break;
    }
  }

  void _markAsRead(String notificationId) {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsRead(
          userId: auth.user.uid,
          notificationId: notificationId,
        ),
      );
    }
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
      context.read<NotificationBloc>().add(
        MarkAllNotificationsAsRead(auth.user.uid),
      );
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
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        DeleteNotification(
          userId: auth.user.uid,
          notificationId: notificationId,
        ),
      );
    }
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bildirim silindi')));
  }

  void _deleteAll() {
    final auth = context.read<AuthBloc>().state;
    final notificationBloc = context.read<NotificationBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm bildirimleri silmek istiyor musunuz?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              if (auth is AuthAuthenticated) {
                notificationBloc.add(DeleteAllNotifications(auth.user.uid));
              }
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm bildirimler silindi')),
              );
            },
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
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

  static const _tradeTypes = {
    NotificationType.newTradeOffer,
    NotificationType.tradeAccepted,
    NotificationType.tradeRejected,
    NotificationType.tradeCancelled,
    NotificationType.tradeCompleted,
  };
}
