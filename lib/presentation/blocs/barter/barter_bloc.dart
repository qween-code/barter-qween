import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/barter/barter_usecases.dart';
import 'barter_event.dart';
import 'barter_state.dart';

@injectable
class BarterBloc extends Bloc<BarterEvent, BarterState> {
  final GetMatchingItemsUseCase getMatchingItemsUseCase;
  final ValidateBarterMatchUseCase validateBarterMatchUseCase;
  final CalculateCashDifferentialUseCase calculateCashDifferentialUseCase;
  final SuggestCashDifferentialUseCase suggestCashDifferentialUseCase;

  BarterBloc({
    required this.getMatchingItemsUseCase,
    required this.validateBarterMatchUseCase,
    required this.calculateCashDifferentialUseCase,
    required this.suggestCashDifferentialUseCase,
  }) : super(const BarterInitial()) {
    on<GetMatchingItems>(_onGetMatchingItems);
    on<ValidateBarterMatch>(_onValidateBarterMatch);
    on<CalculateCashDifferential>(_onCalculateCashDifferential);
    on<SuggestCashDifferential>(_onSuggestCashDifferential);
    on<ClearBarterState>(_onClearBarterState);
  }

  Future<void> _onGetMatchingItems(
    GetMatchingItems event,
    Emitter<BarterState> emit,
  ) async {
    emit(const BarterLoading());

    final result = await getMatchingItemsUseCase(
      event.condition,
      event.currentItemId,
    );

    result.fold(
      (failure) => emit(BarterError(failure.message)),
      (items) => emit(MatchingItemsLoaded(items)),
    );
  }

  Future<void> _onValidateBarterMatch(
    ValidateBarterMatch event,
    Emitter<BarterState> emit,
  ) async {
    emit(const BarterLoading());

    final result = await validateBarterMatchUseCase(
      event.offeredItemId,
      event.requestedItemId,
    );

    result.fold(
      (failure) => emit(BarterError(failure.message)),
      (matchResult) => emit(BarterMatchValidated(matchResult)),
    );
  }

  Future<void> _onCalculateCashDifferential(
    CalculateCashDifferential event,
    Emitter<BarterState> emit,
  ) async {
    emit(const BarterLoading());

    final result = await calculateCashDifferentialUseCase(
      event.item1Id,
      event.item2Id,
    );

    result.fold(
      (failure) => emit(BarterError(failure.message)),
      (differential) => emit(CashDifferentialCalculated(differential)),
    );
  }

  Future<void> _onSuggestCashDifferential(
    SuggestCashDifferential event,
    Emitter<BarterState> emit,
  ) async {
    emit(const BarterLoading());

    final result = await suggestCashDifferentialUseCase(
      event.item1Value,
      event.item2Value,
    );

    result.fold(
      (failure) => emit(BarterError(failure.message)),
      (suggestion) => emit(CashDifferentialSuggested(suggestion)),
    );
  }

  Future<void> _onClearBarterState(
    ClearBarterState event,
    Emitter<BarterState> emit,
  ) async {
    emit(const BarterInitial());
  }
}
