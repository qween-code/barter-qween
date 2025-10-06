part of 'barter_match_cubit.dart';

abstract class BarterMatchEvent extends Equatable {
  const BarterMatchEvent();

  @override
  List<Object?> get props => [];
}

class LoadBarterMatches extends BarterMatchEvent {
  final String itemId;

  const LoadBarterMatches(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DismissBarterMatch extends BarterMatchEvent {
  final String matchId;

  const DismissBarterMatch(this.matchId);

  @override
  List<Object?> get props => [matchId];
}
