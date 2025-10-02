import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;
  NotificationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(String userId) async {
    try {
      final list = await _remote.getNotifications(userId);
      return Right(list);
    } catch (e) {
      return Left(UnknownFailure('Failed to get notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final count = await _remote.getUnreadCount(userId);
      return Right(count);
    } catch (e) {
      return Left(UnknownFailure('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId) async {
    // userId must be known to address the subcollection; expose via method param in domain, but keep interface as-is
    return Left(UnknownFailure('markAsRead requires userId in this implementation'));
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      await _remote.markAllAsRead(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to mark all as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    return Left(UnknownFailure('deleteNotification requires userId in this implementation'));
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications(String userId) async {
    try {
      await _remote.deleteAllNotifications(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to delete all: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications(String userId) {
    return _remote
        .watchNotifications(userId)
        .map((list) => Right<Failure, List<NotificationEntity>>(list));
  }

  @override
  Stream<Either<Failure, int>> watchUnreadCount(String userId) {
    return _remote
        .watchUnreadCount(userId)
        .map((c) => Right<Failure, int>(c));
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(String userId, String token) async {
    // Saving token handled in main for now; can be moved here later
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteFcmToken(String userId) async {
    // Not implemented
    return const Right(null);
  }
}