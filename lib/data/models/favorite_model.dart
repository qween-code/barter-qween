import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.itemId,
    required super.createdAt,
  });

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FavoriteEntity toEntity() {
    return FavoriteEntity(
      id: id,
      userId: userId,
      itemId: itemId,
      createdAt: createdAt,
    );
  }
}
