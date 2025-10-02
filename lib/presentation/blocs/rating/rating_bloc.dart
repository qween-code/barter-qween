import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/rating/create_rating_usecase.dart';
import 'rating_event.dart';
import 'rating_state.dart';

@injectable
class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final CreateRatingUseCase createRatingUseCase;
  RatingBloc(this.createRatingUseCase) : super(const RatingInitial()) {
    on<SubmitRating>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitRating e, Emitter<RatingState> emit) async {
    emit(const RatingSubmitting());
    final res = await createRatingUseCase(
      fromUserId: e.fromUserId,
      toUserId: e.toUserId,
      tradeId: e.tradeId,
      rating: e.rating,
      comment: e.comment,
    );
    res.fold(
      (f) => emit(RatingError(f.message)),
      (r) => emit(RatingSubmitted(r)),
    );
  }
}