import 'package:equatable/equatable.dart';
import '../../../domain/entities/barter_condition_entity.dart';

abstract class BarterEvent extends Equatable {
  const BarterEvent();

  @override
  List<Object?> get props => [];
}

/// Get matching items for barter condition
class GetMatchingItems extends BarterEvent {
  final BarterConditionEntity condition;
  final String currentItemId;

  const GetMatchingItems({
    required this.condition,
    required this.currentItemId,
  });

  @override
  List<Object?> get props => [condition, currentItemId];
}

/// Validate barter match between two items
class ValidateBarterMatch extends BarterEvent {
  final String offeredItemId;
  final String requestedItemId;

  const ValidateBarterMatch({
    required this.offeredItemId,
    required this.requestedItemId,
  });

  @override
  List<Object?> get props => [offeredItemId, requestedItemId];
}

/// Calculate cash differential between items
class CalculateCashDifferential extends BarterEvent {
  final String item1Id;
  final String item2Id;

  const CalculateCashDifferential({
    required this.item1Id,
    required this.item2Id,
  });

  @override
  List<Object?> get props => [item1Id, item2Id];
}

/// Suggest cash differential based on values
class SuggestCashDifferential extends BarterEvent {
  final double item1Value;
  final double item2Value;

  const SuggestCashDifferential({
    required this.item1Value,
    required this.item2Value,
  });

  @override
  List<Object?> get props => [item1Value, item2Value];
}

/// Clear barter state
class ClearBarterState extends BarterEvent {
  const ClearBarterState();
}
