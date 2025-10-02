import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';

/// Base notification state
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notifications loaded
class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Unread count loaded
class UnreadCountLoaded extends NotificationState {
  final int count;

  const UnreadCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

/// Notification marked as read
class NotificationMarkedAsRead extends NotificationState {
  final NotificationEntity notification;

  const NotificationMarkedAsRead(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// All notifications marked as read
class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

/// Notification deleted
class NotificationDeleted extends NotificationState {
  const NotificationDeleted();
}

/// All notifications deleted
class AllNotificationsDeleted extends NotificationState {
  const AllNotificationsDeleted();
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Streaming state (real-time updates)
class NotificationsStreaming extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationsStreaming(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Unread count streaming
class UnreadCountStreaming extends NotificationState {
  final int count;

  const UnreadCountStreaming(this.count);

  @override
  List<Object?> get props => [count];
}
