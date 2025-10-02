import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String tradeId;
  final int rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.tradeId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        tradeId,
        rating,
        comment,
        createdAt,
      ];
}

class UserRatingStats extends Equatable {
  final String userId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star -> count

  const UserRatingStats({
    required this.userId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  @override
  List<Object?> get props => [
        userId,
        averageRating,
        totalRatings,
        ratingDistribution,
      ];
}
