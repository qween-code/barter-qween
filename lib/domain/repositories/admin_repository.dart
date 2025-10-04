import 'package:dartz/dartz.dart';
import '../entities/admin_user_entity.dart';
import '../entities/moderation_request_entity.dart';
import '../../core/error/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<ModerationRequestEntity>>> getPendingItems({
    int page,
    int limit,
    ModerationPriority? priority,
  });

  Future<Either<Failure, void>> approveItem({
    required String itemId,
    required ItemTier tier,
    String? notes,
  });

  Future<Either<Failure, void>> rejectItem({
    required String itemId,
    required String reason,
  });

  Future<Either<Failure, AdminDashboardStats>> getDashboardStats();

  Future<Either<Failure, List<UserReportEntity>>> getUserReports();

  Future<Either<Failure, AdminUserEntity>> getCurrentAdmin();
}

class AdminDashboardStats {
  final int pendingItemsCount;
  final int approvedTodayCount;
  final int rejectedTodayCount;
  final double averageReviewTime;
  final int userReportsCount;

  const AdminDashboardStats({
    required this.pendingItemsCount,
    required this.approvedTodayCount,
    required this.rejectedTodayCount,
    required this.averageReviewTime,
    required this.userReportsCount,
  });
}

class UserReportEntity {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final DateTime createdAt;
  final String status;

  const UserReportEntity({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.createdAt,
    required this.status,
  });
}