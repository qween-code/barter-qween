part of 'barter_match_cubit.dart';

/// Base state for barter matching
abstract class BarterMatchState extends Equatable {
  const BarterMatchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BarterMatchInitial extends BarterMatchState {}

/// Loading matches
class BarterMatchLoading extends BarterMatchState {}

/// Refreshing matches (keeping old data)
class BarterMatchRefreshing extends BarterMatchState {
  final List<BarterMatchEntity> previousMatches;

  const BarterMatchRefreshing(this.previousMatches);

  @override
  List<Object?> get props => [previousMatches];
}

/// Matches loaded successfully
class BarterMatchLoaded extends BarterMatchState {
  final List<BarterMatchEntity> matches;
  final String itemId;
  final MatchQuality? filteredQuality;

  const BarterMatchLoaded({
    required this.matches,
    required this.itemId,
    this.filteredQuality,
  });

  /// Get only unseen matches
  List<BarterMatchEntity> get unseenMatches =>
      matches.where((m) => !m.isSeen && !m.isDismissed).toList();

  /// Get high quality matches (score >= 80)
  List<BarterMatchEntity> get highQualityMatches =>
      matches.where((m) => m.isHighQuality && !m.isDismissed).toList();

  /// Get active matches (not dismissed)
  List<BarterMatchEntity> get activeMatches =>
      matches.where((m) => !m.isDismissed).toList();

  /// Count of high quality matches
  int get highQualityCount => highQualityMatches.length;

  /// Count of unseen matches
  int get unseenCount => unseenMatches.length;

  BarterMatchLoaded copyWith({
    List<BarterMatchEntity>? matches,
    String? itemId,
    MatchQuality? filteredQuality,
  }) {
    return BarterMatchLoaded(
      matches: matches ?? this.matches,
      itemId: itemId ?? this.itemId,
      filteredQuality: filteredQuality ?? this.filteredQuality,
    );
  }

  @override
  List<Object?> get props => [matches, itemId, filteredQuality];
}

/// No matches found
class BarterMatchEmpty extends BarterMatchState {
  final String message;

  const BarterMatchEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error loading matches
class BarterMatchError extends BarterMatchState {
  final String message;

  const BarterMatchError(this.message);

  @override
  List<Object?> get props => [message];
}
