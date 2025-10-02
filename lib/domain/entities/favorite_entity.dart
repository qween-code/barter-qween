import 'package:equatable/equatable.dart';

/// Entity representing a user's favorite item
class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, itemId, createdAt];
}
