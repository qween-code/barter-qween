import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/repositories/barter_repository.dart';

abstract class BarterState extends Equatable {
  const BarterState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BarterInitial extends BarterState {
  const BarterInitial();
}

/// Loading state
class BarterLoading extends BarterState {
  const BarterLoading();
}

/// Matching items loaded
class MatchingItemsLoaded extends BarterState {
  final List<ItemEntity> items;

  const MatchingItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Match validation result
class BarterMatchValidated extends BarterState {
  final BarterMatchResult result;

  const BarterMatchValidated(this.result);

  @override
  List<Object?> get props => [result];
}

/// Cash differential calculated
class CashDifferentialCalculated extends BarterState {
  final double differential;

  const CashDifferentialCalculated(this.differential);

  @override
  List<Object?> get props => [differential];
}

/// Cash differential suggestion
class CashDifferentialSuggested extends BarterState {
  final CashDifferentialSuggestion suggestion;

  const CashDifferentialSuggested(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

/// Error state
class BarterError extends BarterState {
  final String message;

  const BarterError(this.message);

  @override
  List<Object?> get props => [message];
}
