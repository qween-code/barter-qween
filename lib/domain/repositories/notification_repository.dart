import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/notification_entity.dart';

/// Repository interface for notifications
abstract class NotificationRepository {
  /// Get all notifications for a user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  );

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadCount(String userId);

  /// Mark notification as read
  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications(String userId);

  /// Stream of notifications (real-time)
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications(
    String userId,
  );

  /// Stream of unread count (real-time)
  Stream<Either<Failure, int>> watchUnreadCount(String userId);

  /// Save FCM token for user
  Future<Either<Failure, void>> saveFcmToken(String userId, String token);

  /// Delete FCM token for user
  Future<Either<Failure, void>> deleteFcmToken(String userId);
}
