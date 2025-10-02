import 'package:equatable/equatable.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();
  @override
  List<Object?> get props => [];
}

class SubmitRating extends RatingEvent {
  final String fromUserId;
  final String toUserId;
  final String tradeId;
  final int rating;
  final String? comment;
  const SubmitRating({
    required this.fromUserId,
    required this.toUserId,
    required this.tradeId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, tradeId, rating, comment];
}