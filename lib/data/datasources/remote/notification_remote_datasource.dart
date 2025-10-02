import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Stream<List<NotificationEntity>> watchNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Stream<int> watchUnreadCount(String userId);
  Future<NotificationEntity> markAsRead(String userId, String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String userId, String notificationId);
  Future<void> deleteAllNotifications(String userId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  NotificationRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  NotificationEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return NotificationEntity(
      id: doc.id,
      userId: d['userId'] as String,
      type: NotificationTypeExtension.fromValue(d['type'] as String),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      isRead: d['isRead'] as bool? ?? false,
      relatedEntityId: d['relatedEntityId'] as String?,
      data: (d['data'] as Map?)?.cast<String, dynamic>(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (d['readAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final snap = await _col(userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return _col(userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snap = await _col(userId).where('isRead', isEqualTo: false).get();
    return snap.size;
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _col(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.size);
  }

  @override
  Future<NotificationEntity> markAsRead(String userId, String notificationId) async {
    await _col(userId).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
    final doc = await _col(userId).doc(notificationId).get();
    return _fromDoc(doc);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snap = await _col(userId).where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _col(userId).doc(notificationId).delete();
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final snap = await _col(userId).get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}