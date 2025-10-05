import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/barter_match_entity.dart';
import '../../../domain/usecases/find_barter_matches_usecase.dart';
import '../../../domain/usecases/calculate_match_score_usecase.dart';

part 'barter_match_state.dart';

/// Cubit for managing barter match discovery and scoring
@injectable
class BarterMatchCubit extends Cubit<BarterMatchState> {
  final FindBarterMatchesUsecase _findMatchesUsecase;
  final CalculateMatchScoreUsecase _calculateScoreUsecase;

  BarterMatchCubit(
    this._findMatchesUsecase,
    this._calculateScoreUsecase,
  ) : super(BarterMatchInitial());

  /// Find matches for an item
  Future<void> findMatches({
    required String itemId,
    int limit = 20,
    double minScore = 50.0,
  }) async {
    emit(BarterMatchLoading());

    final result = await _findMatchesUsecase(
      FindMatchesParams(
        itemId: itemId,
        limit: limit,
        minScore: minScore,
      ),
    );

    result.fold(
      (failure) => emit(BarterMatchError(failure.message)),
      (matches) {
        if (matches.isEmpty) {
          emit(const BarterMatchEmpty('Henüz uygun eşleşme bulunamadı'));
        } else {
          emit(BarterMatchLoaded(
            matches: matches,
            itemId: itemId,
          ));
        }
      },
    );
  }

  /// Refresh matches
  Future<void> refreshMatches(String itemId) async {
    final currentState = state;
    if (currentState is BarterMatchLoaded) {
      // Keep current data while refreshing
      emit(BarterMatchRefreshing(currentState.matches));
      await findMatches(itemId: itemId);
    } else {
      await findMatches(itemId: itemId);
    }
  }

  /// Mark match as seen
  void markAsSeen(String matchId) {
    final currentState = state;
    if (currentState is BarterMatchLoaded) {
      final updatedMatches = currentState.matches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(
            isSeen: true,
            seenAt: DateTime.now(),
            viewCount: match.viewCount + 1,
          );
        }
        return match;
      }).toList();

      emit(currentState.copyWith(matches: updatedMatches));
    }
  }

  /// Dismiss match (user not interested)
  void dismissMatch(String matchId) {
    final currentState = state;
    if (currentState is BarterMatchLoaded) {
      final updatedMatches = currentState.matches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(
            isDismissed: true,
            dismissedAt: DateTime.now(),
          );
        }
        return match;
      }).toList();

      emit(currentState.copyWith(matches: updatedMatches));
    }
  }

  /// Filter matches by quality
  void filterByQuality(MatchQuality minQuality) {
    final currentState = state;
    if (currentState is BarterMatchLoaded) {
      emit(currentState.copyWith(
        filteredQuality: minQuality,
      ));
    }
  }

  /// Get filtered matches based on current state
  List<BarterMatchEntity> getFilteredMatches() {
    final currentState = state;
    if (currentState is BarterMatchLoaded) {
      var matches = currentState.matches
          .where((m) => !m.isDismissed)
          .toList();

      if (currentState.filteredQuality != null) {
        final minScore = _getMinScoreForQuality(currentState.filteredQuality!);
        matches = matches
            .where((m) => m.matchScore >= minScore)
            .toList();
      }

      return matches;
    }
    return [];
  }

  /// Get min score for quality level
  double _getMinScoreForQuality(MatchQuality quality) {
    switch (quality) {
      case MatchQuality.excellent:
        return 90.0;
      case MatchQuality.veryGood:
        return 80.0;
      case MatchQuality.good:
        return 70.0;
      case MatchQuality.fair:
        return 50.0;
      case MatchQuality.poor:
        return 0.0;
    }
  }

  /// Reset state
  void reset() {
    emit(BarterMatchInitial());
  }
}
