import 'package:equatable/equatable.dart';
import '../../../domain/entities/rating_entity.dart';

abstract class RatingState extends Equatable {
  const RatingState();
  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState { const RatingInitial(); }
class RatingSubmitting extends RatingState { const RatingSubmitting(); }
class RatingSubmitted extends RatingState { final RatingEntity rating; const RatingSubmitted(this.rating); @override List<Object?> get props => [rating]; }
class RatingError extends RatingState { final String message; const RatingError(this.message); @override List<Object?> get props => [message]; }