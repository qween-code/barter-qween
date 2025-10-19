import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/barter_match_entity.dart';
import '../../../domain/usecases/get_barter_matches_usecase.dart';
import '../../../domain/usecases/dismiss_barter_match_usecase.dart';

part 'barter_match_event.dart';
part 'barter_match_state.dart';

/// Cubit for managing barter matches
@injectable
class BarterMatchCubit extends Cubit<BarterMatchState> {
  final GetBarterMatchesUsecase _getBarterMatchesUsecase;
  final DismissBarterMatchUsecase _dismissBarterMatchUsecase;

  BarterMatchCubit(
    this._getBarterMatchesUsecase,
    this._dismissBarterMatchUsecase,
  ) : super(BarterMatchInitial());

  /// Load barter matches for an item
  Future<void> loadBarterMatches(String itemId) async {
    emit(BarterMatchLoading());

    final result = await _getBarterMatchesUsecase(
      GetBarterMatchesParams(itemId: itemId),
    );

    result.fold(
      (failure) => emit(BarterMatchError(failure.message)),
      (matches) => emit(BarterMatchLoaded(matches)),
    );
  }

  /// Dismiss a barter match
  Future<void> dismissBarterMatch(String matchId) async {
    final currentState = state;
    if (currentState is! BarterMatchLoaded) return;

    final result = await _dismissBarterMatchUsecase(
      DismissBarterMatchParams(matchId: matchId),
    );

    result.fold((failure) => emit(BarterMatchError(failure.message)), (_) {
      final updatedMatches = currentState.matches
          .where((match) => match.id != matchId)
          .toList();
      emit(BarterMatchLoaded(updatedMatches));
    });
  }

  /// Add event handler for BLoC compatibility
  void add(BarterMatchEvent event) {
    if (event is LoadBarterMatches) {
      loadBarterMatches(event.itemId);
    } else if (event is DismissBarterMatch) {
      dismissBarterMatch(event.matchId);
    }
  }
}
