part of 'barter_match_cubit.dart';

abstract class BarterMatchState extends Equatable {
  const BarterMatchState();

  @override
  List<Object?> get props => [];
}

class BarterMatchInitial extends BarterMatchState {}

class BarterMatchLoading extends BarterMatchState {}

class BarterMatchLoaded extends BarterMatchState {
  final List<BarterMatchEntity> matches;

  const BarterMatchLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

class BarterMatchError extends BarterMatchState {
  final String message;

  const BarterMatchError(this.message);

  @override
  List<Object?> get props => [message];
}
