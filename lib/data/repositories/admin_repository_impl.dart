import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/moderation_request_entity.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Either<Failure, List<ModerationRequestEntity>>> getPendingItems({
    int page = 1,
    int limit = 20,
    ModerationPriority? priority,
  }) async {
    try {
      Query query = _firestore.collection('moderationRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt', descending: true);

      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      final snapshot = await query
          .limit(limit)
          .get();

      final requests = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final itemDoc = await _firestore
              .collection('items')
              .doc(data['itemId'])
              .get();

          if (!itemDoc.exists) {
            throw CacheException();
          }

          // TODO: Convert item document to ItemEntity
          // For now, create a basic item entity
          final itemData = itemDoc.data()!;

          return ModerationRequestEntity(
            id: doc.id,
            itemId: data['itemId'] as String,
            item: await _convertToItemEntity(itemData), // TODO: Implement this
            userId: data['userId'] as String,
            status: ModerationStatus.pending,
            priority: ModerationPriority.values.firstWhere(
              (p) => p.name == (data['priority'] ?? 'medium'),
            ),
            submittedAt: (data['submittedAt'] as Timestamp).toDate(),
            suggestedTier: data['suggestedTier'] != null
                ? ItemTier.values.firstWhere(
                    (t) => t.name == data['suggestedTier'])
                : null,
          );
        }),
      );

      return Right(requests);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> approveItem({
    required String itemId,
    required ItemTier tier,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthenticationFailure());
      }

      final batch = _firestore.batch();

      // Update item status
      final itemRef = _firestore.collection('items').doc(itemId);
      batch.update(itemRef, {
        'moderationStatus': 'approved',
        'tier': tier.name,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser.uid,
        'adminNotes': notes,
      });

      // Update moderation request
      final requestQuery = await _firestore
          .collection('moderationRequests')
          .where('itemId', isEqualTo: itemId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        final requestRef = requestQuery.docs.first.reference;
        batch.update(requestRef, {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': currentUser.uid,
          'reviewNotes': notes,
        });
      }

      await batch.commit();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rejectItem({
    required String itemId,
    required String reason,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthenticationFailure());
      }

      final batch = _firestore.batch();

      // Update item status
      final itemRef = _firestore.collection('items').doc(itemId);
      batch.update(itemRef, {
        'moderationStatus': 'rejected',
        'adminNotes': reason,
      });

      // Update moderation request
      final requestQuery = await _firestore
          .collection('moderationRequests')
          .where('itemId', isEqualTo: itemId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        final requestRef = requestQuery.docs.first.reference;
        batch.update(requestRef, {
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': currentUser.uid,
          'reviewNotes': reason,
        });
      }

      await batch.commit();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Get pending items count
      final pendingSnapshot = await _firestore
          .collection('moderationRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      // Get today's approved items
      final approvedSnapshot = await _firestore
          .collection('moderationRequests')
          .where('status', isEqualTo: 'approved')
          .where('reviewedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      // Get today's rejected items
      final rejectedSnapshot = await _firestore
          .collection('moderationRequests')
          .where('status', isEqualTo: 'rejected')
          .where('reviewedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      // Get user reports count
      final reportsSnapshot = await _firestore
          .collection('userReports')
          .where('status', isEqualTo: 'pending')
          .get();

      // Calculate average review time (simplified)
      final completedRequests = await _firestore
          .collection('moderationRequests')
          .where('status', whereIn: ['approved', 'rejected'])
          .where('reviewedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      double averageReviewTime = 0.0;
      if (completedRequests.docs.isNotEmpty) {
        // Simplified calculation - in real implementation, calculate time difference
        averageReviewTime = 2.5; // hours
      }

      final stats = AdminDashboardStats(
        pendingItemsCount: pendingSnapshot.docs.length,
        approvedTodayCount: approvedSnapshot.docs.length,
        rejectedTodayCount: rejectedSnapshot.docs.length,
        averageReviewTime: averageReviewTime,
        userReportsCount: reportsSnapshot.docs.length,
      );

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserReportEntity>>> getUserReports() async {
    try {
      final snapshot = await _firestore
          .collection('userReports')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserReportEntity(
          id: doc.id,
          reporterId: data['reporterId'] as String,
          reportedUserId: data['reportedUserId'] as String,
          reason: data['reason'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          status: data['status'] as String,
        );
      }).toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getCurrentAdmin() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthenticationFailure());
      }

      final adminDoc = await _firestore
          .collection('admins')
          .doc(currentUser.uid)
          .get();

      if (!adminDoc.exists) {
        return Left(AuthenticationFailure());
      }

      final data = adminDoc.data()!;
      final permissions = (data['permissions'] as List<dynamic>?)
          ?.map((p) => AdminPermission.values.firstWhere(
              (perm) => perm.name == p,
              orElse: () => AdminPermission.viewReports))
          .toList() ?? [AdminPermission.viewReports];

      return Right(AdminUserEntity(
        id: adminDoc.id,
        email: data['email'] as String,
        name: data['name'] as String,
        role: AdminRole.values.firstWhere(
          (role) => role.name == (data['role'] ?? 'moderator'),
        ),
        permissions: permissions,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        isActive: data['isActive'] as bool? ?? true,
      ));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  // TODO: Implement this method to convert Firestore data to ItemEntity
  Future<ItemEntity> _convertToItemEntity(Map<String, dynamic> data) async {
    // This is a placeholder - in real implementation, convert the data to proper ItemEntity
    throw UnimplementedError('ItemEntity conversion not implemented');
  }
}