import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/rating_entity.dart';

abstract class RatingRemoteDataSource {
  Future<RatingEntity> create({
    required String fromUserId,
    required String toUserId,
    required String tradeId,
    required int rating,
    String? comment,
  });

  Future<List<RatingEntity>> getUserRatings(String userId);
  Future<UserRatingStats> getUserRatingStats(String userId);
}

@LazySingleton(as: RatingRemoteDataSource)
class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final FirebaseFirestore _firestore;
  RatingRemoteDataSourceImpl(this._firestore);

  @override
  Future<RatingEntity> create({
    required String fromUserId,
    required String toUserId,
    required String tradeId,
    required int rating,
    String? comment,
  }) async {
    final ref = _firestore.collection('ratings').doc();
    final data = {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'tradeId': tradeId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.set(data);
    final snap = await ref.get();
    final d = snap.data()!;
    return RatingEntity(
      id: snap.id,
      fromUserId: d['fromUserId'] as String,
      toUserId: d['toUserId'] as String,
      tradeId: d['tradeId'] as String,
      rating: d['rating'] as int,
      comment: d['comment'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  RatingEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RatingEntity(
      id: doc.id,
      fromUserId: d['fromUserId'] as String,
      toUserId: d['toUserId'] as String,
      tradeId: d['tradeId'] as String,
      rating: d['rating'] as int,
      comment: d['comment'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<List<RatingEntity>> getUserRatings(String userId) async {
    final snap = await _firestore
        .collection('ratings')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<UserRatingStats> getUserRatingStats(String userId) async {
    final snap = await _firestore
        .collection('ratings')
        .where('toUserId', isEqualTo: userId)
        .get();
    int total = snap.size;
    if (total == 0) {
      return UserRatingStats(userId: userId, averageRating: 0.0, totalRatings: 0, ratingDistribution: const {});
    }
    final dist = <int, int>{1:0,2:0,3:0,4:0,5:0};
    int sum = 0;
    for (final doc in snap.docs) {
      final r = (doc.data()['rating'] as int);
      sum += r;
      dist[r] = (dist[r] ?? 0) + 1;
    }
    final avg = sum / total;
    return UserRatingStats(userId: userId, averageRating: avg, totalRatings: total, ratingDistribution: dist);
  }
}