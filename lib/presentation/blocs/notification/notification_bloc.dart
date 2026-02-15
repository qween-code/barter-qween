import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notifications
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  NotificationBloc({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<WatchNotifications>(_onWatchNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<WatchUnreadCount>(_onWatchUnreadCount);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await _notificationRepository.getNotifications(event.userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onWatchNotifications(
    WatchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationsSubscription?.cancel();
    await emit.forEach(
      _notificationRepository.watchNotifications(event.userId),
      onData: (result) => result.fold(
        (failure) => NotificationError(failure.message),
        (notifications) => NotificationsStreaming(notifications),
      ),
    );
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.getUnreadCount(event.userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (count) => emit(UnreadCountLoaded(count)),
    );
  }

  Future<void> _onWatchUnreadCount(
    WatchUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    await _unreadCountSubscription?.cancel();
    await emit.forEach(
      _notificationRepository.watchUnreadCount(event.userId),
      onData: (result) => result.fold(
        (failure) => NotificationError(failure.message),
        (count) => UnreadCountStreaming(count),
      ),
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.markAsRead(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notification) => emit(NotificationMarkedAsRead(notification)),
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.markAllAsRead(event.userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const AllNotificationsMarkedAsRead()),
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.deleteNotification(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationDeleted()),
    );
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.deleteAllNotifications(event.userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const AllNotificationsDeleted()),
    );
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
