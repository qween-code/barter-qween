import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/notifications/get_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  NotificationBloc(this.repository) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<WatchNotifications>(_onWatch);
    on<LoadUnreadCount>(_onLoadUnread);
    on<WatchUnreadCount>(_onWatchUnread);
    on<MarkNotificationAsRead>(_onMarkRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllRead);
    on<DeleteAllNotifications>(_onDeleteAll);
  }

  Future<void> _onLoad(LoadNotifications e, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    final res = await repository.getNotifications(e.userId);
    res.fold(
      (f) => emit(NotificationError(f.message)),
      (list) => emit(NotificationsLoaded(list)),
    );
  }

  Future<void> _onWatch(WatchNotifications e, Emitter<NotificationState> emit) async {
    await emit.forEach(
      repository.watchNotifications(e.userId),
      onData: (data) => data.fold(
        (f) => NotificationError(f.message),
        (list) => NotificationsStreaming(list),
      ),
      onError: (error, st) => NotificationError('Failed to stream notifications: $error'),
    );
  }

  Future<void> _onLoadUnread(LoadUnreadCount e, Emitter<NotificationState> emit) async {
    final res = await repository.getUnreadCount(e.userId);
    res.fold(
      (f) => emit(NotificationError(f.message)),
      (count) => emit(UnreadCountLoaded(count)),
    );
  }

  Future<void> _onWatchUnread(WatchUnreadCount e, Emitter<NotificationState> emit) async {
    await emit.forEach(
      repository.watchUnreadCount(e.userId),
      onData: (data) => data.fold(
        (f) => NotificationError(f.message),
        (count) => UnreadCountStreaming(count),
      ),
      onError: (error, st) => NotificationError('Failed to stream unread count: $error'),
    );
  }

  Future<void> _onMarkRead(MarkNotificationAsRead e, Emitter<NotificationState> emit) async {
    // Interface mismatch here (userId needed); leave as TODO and no-op for now
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsAsRead e, Emitter<NotificationState> emit) async {
    final res = await repository.markAllAsRead(e.userId);
    res.fold(
      (f) => emit(NotificationError(f.message)),
      (_) => emit(const AllNotificationsMarkedAsRead()),
    );
  }

  Future<void> _onDeleteAll(DeleteAllNotifications e, Emitter<NotificationState> emit) async {
    final res = await repository.deleteAllNotifications(e.userId);
    res.fold(
      (f) => emit(NotificationError(f.message)),
      (_) => emit(const AllNotificationsDeleted()),
    );
  }
}