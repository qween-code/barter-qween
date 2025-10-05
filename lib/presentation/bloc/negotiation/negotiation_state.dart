part of 'negotiation_cubit.dart';

/// Base state for negotiation
abstract class NegotiationState extends Equatable {
  const NegotiationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NegotiationInitial extends NegotiationState {}

/// Loading negotiation
class NegotiationLoading extends NegotiationState {}

/// Processing action (accept/reject/send)
class NegotiationProcessing extends NegotiationState {
  final NegotiationEntity negotiation;

  const NegotiationProcessing(this.negotiation);

  @override
  List<Object?> get props => [negotiation];
}

/// Negotiation active
class NegotiationActive extends NegotiationState {
  final NegotiationEntity negotiation;

  const NegotiationActive(this.negotiation);

  /// Is it user's turn?
  bool isUserTurn(String userId) => negotiation.currentOfferer != userId;

  /// Can user send counter-offer?
  bool canCounterOffer(String userId) => negotiation.canCounterOffer(userId);

  /// Can user accept current offer?
  bool canAccept(String userId) => negotiation.canAccept(userId);

  @override
  List<Object?> get props => [negotiation];
}

/// Sending counter-offer
class NegotiationSendingOffer extends NegotiationState {
  final NegotiationEntity negotiation;

  const NegotiationSendingOffer(this.negotiation);

  @override
  List<Object?> get props => [negotiation];
}

/// Counter-offer sent successfully
class NegotiationCounterOfferSent extends NegotiationState {
  final NegotiationEntity negotiation;
  final CounterOfferEntity counterOffer;

  const NegotiationCounterOfferSent(this.negotiation, this.counterOffer);

  @override
  List<Object?> get props => [negotiation, counterOffer];
}

/// Counter-offer accepted
class NegotiationCounterOfferAccepted extends NegotiationState {
  final NegotiationEntity negotiation;
  final String counterOfferId;

  const NegotiationCounterOfferAccepted(this.negotiation, this.counterOfferId);

  @override
  List<Object?> get props => [negotiation, counterOfferId];
}

/// Counter-offer rejected
class NegotiationCounterOfferRejected extends NegotiationState {
  final NegotiationEntity negotiation;
  final String counterOfferId;

  const NegotiationCounterOfferRejected(this.negotiation, this.counterOfferId);

  @override
  List<Object?> get props => [negotiation, counterOfferId];
}

/// Negotiation completed (agreement reached)
class NegotiationCompleted extends NegotiationState {
  final NegotiationEntity negotiation;
  final String message;
  final dynamic trade; // TradeEntity

  const NegotiationCompleted(
    this.negotiation,
    this.message, {
    this.trade,
  });

  @override
  List<Object?> get props => [negotiation, message, trade];
}

/// Negotiation ended (cancelled/expired)
class NegotiationEnded extends NegotiationState {
  final NegotiationEntity negotiation;
  final String reason;

  const NegotiationEnded(this.negotiation, this.reason);

  @override
  List<Object?> get props => [negotiation, reason];
}

/// Error state
class NegotiationError extends NegotiationState {
  final String message;

  const NegotiationError(this.message);

  @override
  List<Object?> get props => [message];
}
