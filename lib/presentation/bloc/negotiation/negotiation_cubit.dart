import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/negotiation_entity.dart';
import '../../../domain/entities/counter_offer_entity.dart';
import '../../../domain/usecases/create_negotiation_usecase.dart';
import '../../../domain/usecases/send_counter_offer_usecase.dart';
import '../../../domain/usecases/accept_counter_offer_usecase.dart';
import '../../../domain/usecases/reject_counter_offer_usecase.dart';

import 'negotiation_state.dart';

/// Cubit for managing negotiation threads and counter-offers
@injectable
class NegotiationCubit extends Cubit<NegotiationState> {
  final CreateNegotiationUsecase _createNegotiationUsecase;
  final SendCounterOfferUsecase _sendCounterOfferUsecase;
  final AcceptCounterOfferUsecase _acceptCounterOfferUsecase;
  final RejectCounterOfferUsecase _rejectCounterOfferUsecase;

  NegotiationCubit(
    this._createNegotiationUsecase,
    this._sendCounterOfferUsecase,
    this._acceptCounterOfferUsecase,
    this._rejectCounterOfferUsecase,
  ) : super(NegotiationInitial());

  /// Create new negotiation
  Future<void> createNegotiation(CreateNegotiationParams params) async {
    emit(NegotiationLoading());

    final result = await _createNegotiationUsecase(params);

    result.fold(
      (failure) => emit(NegotiationError(failure.message)),
      (negotiation) => emit(NegotiationActive(negotiation)),
    );
  }

  /// Send counter-offer
  Future<void> sendCounterOffer(SendCounterOfferParams params) async {
    final currentState = state;
    if (currentState is! NegotiationActive) {
      emit(const NegotiationError('No active negotiation'));
      return;
    }

    emit(NegotiationSendingOffer(currentState.negotiation));

    final result = await _sendCounterOfferUsecase(params);

    result.fold(
      (failure) {
        emit(NegotiationError(failure.message));
        // Restore previous state after error
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      },
      (counterOffer) {
        // Update negotiation with new counter-offer
        // In real implementation, would fetch updated negotiation from repository
        emit(NegotiationCounterOfferSent(
          currentState.negotiation,
          counterOffer,
        ));
      },
    );
  }

  /// Accept counter-offer
  Future<void> acceptCounterOffer(AcceptCounterOfferParams params) async {
    final currentState = state;
    if (currentState is! NegotiationActive) {
      emit(const NegotiationError('No active negotiation'));
      return;
    }

    emit(NegotiationProcessing(currentState.negotiation));

    final result = await _acceptCounterOfferUsecase(params);

    result.fold(
      (failure) {
        emit(NegotiationError(failure.message));
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      },
      (acceptResult) {
        if (acceptResult.tradeCreated) {
          emit(NegotiationCompleted(
            currentState.negotiation,
            'Anlaşma sağlandı! Takas oluşturuldu.',
            trade: acceptResult.trade,
          ));
        } else {
          emit(NegotiationCounterOfferAccepted(
            currentState.negotiation,
            acceptResult.counterOfferId,
          ));
        }
      },
    );
  }

  /// Reject counter-offer
  Future<void> rejectCounterOffer(RejectCounterOfferParams params) async {
    final currentState = state;
    if (currentState is! NegotiationActive) {
      emit(const NegotiationError('No active negotiation'));
      return;
    }

    emit(NegotiationProcessing(currentState.negotiation));

    final result = await _rejectCounterOfferUsecase(params);

    result.fold(
      (failure) {
        emit(NegotiationError(failure.message));
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      },
      (rejectResult) {
        if (rejectResult.negotiationEnded) {
          emit(NegotiationEnded(
            currentState.negotiation,
            'Müzakere sonlandırıldı',
          ));
        } else {
          emit(NegotiationCounterOfferRejected(
            currentState.negotiation,
            rejectResult.counterOfferId,
          ));
        }
      },
    );
  }

  /// Load negotiation by ID
  Future<void> loadNegotiation(String negotiationId) async {
    emit(NegotiationLoading());
    // TODO: Implement repository call
    emit(const NegotiationError('Not implemented'));
  }

  /// Check if user needs to respond
  bool needsUserAttention(String userId) {
    final currentState = state;
    if (currentState is NegotiationActive) {
      return currentState.negotiation.needsAttention(userId);
    }
    return false;
  }

  /// Reset state
  void reset() {
    emit(NegotiationInitial());
  }
}
