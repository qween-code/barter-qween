import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/trade/trade_usecases.dart';
import 'trade_event.dart';
import 'trade_state.dart';

@injectable
class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final SendTradeOfferUseCase sendTradeOfferUseCase;
  final AcceptTradeOfferUseCase acceptTradeOfferUseCase;
  final RejectTradeOfferUseCase rejectTradeOfferUseCase;
  final CancelTradeOfferUseCase cancelTradeOfferUseCase;
  final CompleteTradeUseCase completeTradeUseCase;
  final GetTradeOfferUseCase getTradeOfferUseCase;
  final GetUserTradeOffersUseCase getUserTradeOffersUseCase;
  final GetSentTradeOffersUseCase getSentTradeOffersUseCase;
  final GetReceivedTradeOffersUseCase getReceivedTradeOffersUseCase;
  final GetTradeOffersByStatusUseCase getTradeOffersByStatusUseCase;
  final GetItemTradeHistoryUseCase getItemTradeHistoryUseCase;
  final GetPendingReceivedCountUseCase getPendingReceivedCountUseCase;

  TradeBloc({
    required this.sendTradeOfferUseCase,
    required this.acceptTradeOfferUseCase,
    required this.rejectTradeOfferUseCase,
    required this.cancelTradeOfferUseCase,
    required this.completeTradeUseCase,
    required this.getTradeOfferUseCase,
    required this.getUserTradeOffersUseCase,
    required this.getSentTradeOffersUseCase,
    required this.getReceivedTradeOffersUseCase,
    required this.getTradeOffersByStatusUseCase,
    required this.getItemTradeHistoryUseCase,
    required this.getPendingReceivedCountUseCase,
  }) : super(const TradeInitial()) {
    on<SendTradeOffer>(_onSendTradeOffer);
    on<AcceptTradeOffer>(_onAcceptTradeOffer);
    on<RejectTradeOffer>(_onRejectTradeOffer);
    on<CancelTradeOffer>(_onCancelTradeOffer);
    on<CompleteTrade>(_onCompleteTrade);
    on<LoadTradeOffer>(_onLoadTradeOffer);
    on<LoadUserTradeOffers>(_onLoadUserTradeOffers);
    on<LoadSentTradeOffers>(_onLoadSentTradeOffers);
    on<LoadReceivedTradeOffers>(_onLoadReceivedTradeOffers);
    on<LoadTradeOffersByStatus>(_onLoadTradeOffersByStatus);
    on<LoadItemTradeHistory>(_onLoadItemTradeHistory);
    on<LoadPendingReceivedCount>(_onLoadPendingReceivedCount);
    on<RefreshTradeOffers>(_onRefreshTradeOffers);
  }

  Future<void> _onSendTradeOffer(
    SendTradeOffer event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await sendTradeOfferUseCase(event.offer);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offer) => emit(TradeOfferSent(offer)),
    );
  }

  Future<void> _onAcceptTradeOffer(
    AcceptTradeOffer event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeActionInProgress('accepting'));
    final result = await acceptTradeOfferUseCase(event.offerId, event.responseMessage);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offer) => emit(TradeOfferAccepted(offer)),
    );
  }

  Future<void> _onRejectTradeOffer(
    RejectTradeOffer event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeActionInProgress('rejecting'));
    final result = await rejectTradeOfferUseCase(event.offerId, event.rejectionReason);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offer) => emit(TradeOfferRejected(offer)),
    );
  }

  Future<void> _onCancelTradeOffer(
    CancelTradeOffer event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeActionInProgress('cancelling'));
    final result = await cancelTradeOfferUseCase(event.offerId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (_) => emit(const TradeOfferCancelled()),
    );
  }

  Future<void> _onCompleteTrade(
    CompleteTrade event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeActionInProgress('completing'));
    final result = await completeTradeUseCase(event.offerId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offer) => emit(TradeCompleted(offer)),
    );
  }

  Future<void> _onLoadTradeOffer(
    LoadTradeOffer event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getTradeOfferUseCase(event.offerId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offer) => emit(TradeOfferLoaded(offer)),
    );
  }

  Future<void> _onLoadUserTradeOffers(
    LoadUserTradeOffers event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getUserTradeOffersUseCase(event.userId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) => emit(TradeOffersLoaded(offers)),
    );
  }

  Future<void> _onLoadSentTradeOffers(
    LoadSentTradeOffers event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getSentTradeOffersUseCase(event.userId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) => emit(FilteredTradeOffersLoaded(offers, TradeOfferFilter.sent)),
    );
  }

  Future<void> _onLoadReceivedTradeOffers(
    LoadReceivedTradeOffers event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getReceivedTradeOffersUseCase(event.userId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) => emit(FilteredTradeOffersLoaded(offers, TradeOfferFilter.received)),
    );
  }

  Future<void> _onLoadTradeOffersByStatus(
    LoadTradeOffersByStatus event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getTradeOffersByStatusUseCase(event.userId, event.status);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) {
        final filter = _mapStatusToFilter(event.status);
        emit(FilteredTradeOffersLoaded(offers, filter));
      },
    );
  }

  Future<void> _onLoadItemTradeHistory(
    LoadItemTradeHistory event,
    Emitter<TradeState> emit,
  ) async {
    emit(const TradeLoading());
    final result = await getItemTradeHistoryUseCase(event.itemId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) => emit(TradeOffersLoaded(offers)),
    );
  }

  Future<void> _onLoadPendingReceivedCount(
    LoadPendingReceivedCount event,
    Emitter<TradeState> emit,
  ) async {
    final result = await getPendingReceivedCountUseCase(event.userId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (count) => emit(PendingCountLoaded(count)),
    );
  }

  Future<void> _onRefreshTradeOffers(
    RefreshTradeOffers event,
    Emitter<TradeState> emit,
  ) async {
    // Don't emit loading for refresh (better UX)
    final result = await getUserTradeOffersUseCase(event.userId);
    result.fold(
      (failure) => emit(TradeError(failure.message)),
      (offers) => emit(TradeOffersLoaded(offers)),
    );
  }

  TradeOfferFilter _mapStatusToFilter(dynamic status) {
    final statusString = status.toString().split('.').last;
    switch (statusString) {
      case 'pending':
        return TradeOfferFilter.pending;
      case 'accepted':
        return TradeOfferFilter.accepted;
      case 'rejected':
        return TradeOfferFilter.rejected;
      case 'completed':
        return TradeOfferFilter.completed;
      case 'cancelled':
        return TradeOfferFilter.cancelled;
      default:
        return TradeOfferFilter.all;
    }
  }
}
