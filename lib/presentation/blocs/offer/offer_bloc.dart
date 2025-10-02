import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/barter_offer_repository.dart';
import 'offer_event.dart';
import 'offer_state.dart';

/// BLoC for managing barter offer operations
@injectable
class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final BarterOfferRepository _repository;
  StreamSubscription? _offersSubscription;

  OfferBloc(this._repository) : super(const OfferInitial()) {
    on<CreateOffer>(_onCreateOffer);
    on<LoadOffer>(_onLoadOffer);
    on<LoadSentOffers>(_onLoadSentOffers);
    on<LoadReceivedOffers>(_onLoadReceivedOffers);
    on<LoadOffersForItem>(_onLoadOffersForItem);
    on<AcceptOffer>(_onAcceptOffer);
    on<RejectOffer>(_onRejectOffer);
    on<CancelOffer>(_onCancelOffer);
    on<CompleteOffer>(_onCompleteOffer);
    on<LoadPendingOffersCount>(_onLoadPendingOffersCount);
    on<WatchSentOffers>(_onWatchSentOffers);
    on<WatchReceivedOffers>(_onWatchReceivedOffers);
  }

  /// Create a new offer
  Future<void> _onCreateOffer(
    CreateOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.createOffer(event.offer);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferCreated(offer)),
    );
  }

  /// Load a specific offer
  Future<void> _onLoadOffer(
    LoadOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.getOffer(event.offerId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferLoaded(offer)),
    );
  }

  /// Load sent offers
  Future<void> _onLoadSentOffers(
    LoadSentOffers event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.getSentOffers(event.userId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  /// Load received offers
  Future<void> _onLoadReceivedOffers(
    LoadReceivedOffers event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.getReceivedOffers(event.userId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  /// Load offers for a specific item
  Future<void> _onLoadOffersForItem(
    LoadOffersForItem event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.getOffersForItem(event.itemId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  /// Accept an offer
  Future<void> _onAcceptOffer(
    AcceptOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.acceptOffer(event.offerId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferAccepted(offer)),
    );
  }

  /// Reject an offer
  Future<void> _onRejectOffer(
    RejectOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.rejectOffer(event.offerId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferRejected(offer)),
    );
  }

  /// Cancel an offer
  Future<void> _onCancelOffer(
    CancelOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.cancelOffer(event.offerId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferCancelled(offer)),
    );
  }

  /// Complete an offer
  Future<void> _onCompleteOffer(
    CompleteOffer event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    final result = await _repository.completeOffer(event.offerId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (offer) => emit(OfferCompleted(offer)),
    );
  }

  /// Load pending offers count
  Future<void> _onLoadPendingOffersCount(
    LoadPendingOffersCount event,
    Emitter<OfferState> emit,
  ) async {
    final result = await _repository.getPendingOffersCount(event.userId);
    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (count) => emit(PendingOffersCountLoaded(count)),
    );
  }

  /// Watch sent offers (real-time)
  Future<void> _onWatchSentOffers(
    WatchSentOffers event,
    Emitter<OfferState> emit,
  ) async {
    await _offersSubscription?.cancel();
    
    _offersSubscription = _repository.watchSentOffers(event.userId).listen(
      (result) {
        result.fold(
          (failure) => emit(OfferError(failure.message)),
          (offers) => emit(OffersStreaming(offers)),
        );
      },
    );
  }

  /// Watch received offers (real-time)
  Future<void> _onWatchReceivedOffers(
    WatchReceivedOffers event,
    Emitter<OfferState> emit,
  ) async {
    await _offersSubscription?.cancel();
    
    _offersSubscription = _repository.watchReceivedOffers(event.userId).listen(
      (result) {
        result.fold(
          (failure) => emit(OfferError(failure.message)),
          (offers) => emit(OffersStreaming(offers)),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _offersSubscription?.cancel();
    return super.close();
  }
}
