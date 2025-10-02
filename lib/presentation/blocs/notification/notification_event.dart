import 'package:equatable/equatable.dart';

/// Base notification event
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all notifications
class LoadNotifications extends NotificationEvent {
  final String userId;

  const LoadNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Watch notifications (real-time)
class WatchNotifications extends NotificationEvent {
  final String userId;

  const WatchNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load unread count
class LoadUnreadCount extends NotificationEvent {
  final String userId;

  const LoadUnreadCount(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Watch unread count (real-time)
class WatchUnreadCount extends NotificationEvent {
  final String userId;

  const WatchUnreadCount(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Mark notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Delete notification
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Delete all notifications
class DeleteAllNotifications extends NotificationEvent {
  final String userId;

  const DeleteAllNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}
