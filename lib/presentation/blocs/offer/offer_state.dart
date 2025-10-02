import 'package:equatable/equatable.dart';
import '../../../domain/entities/barter_offer_entity.dart';

/// Base class for all offer states
abstract class OfferState extends Equatable {
  const OfferState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OfferInitial extends OfferState {
  const OfferInitial();
}

/// Loading state
class OfferLoading extends OfferState {
  const OfferLoading();
}

/// State when a single offer is loaded
class OfferLoaded extends OfferState {
  final BarterOfferEntity offer;

  const OfferLoaded(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State when multiple offers are loaded
class OffersLoaded extends OfferState {
  final List<BarterOfferEntity> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

/// State when an offer is successfully created
class OfferCreated extends OfferState {
  final BarterOfferEntity offer;

  const OfferCreated(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State when an offer is successfully accepted
class OfferAccepted extends OfferState {
  final BarterOfferEntity offer;

  const OfferAccepted(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State when an offer is successfully rejected
class OfferRejected extends OfferState {
  final BarterOfferEntity offer;

  const OfferRejected(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State when an offer is successfully cancelled
class OfferCancelled extends OfferState {
  final BarterOfferEntity offer;

  const OfferCancelled(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State when an offer is successfully completed
class OfferCompleted extends OfferState {
  final BarterOfferEntity offer;

  const OfferCompleted(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// State with pending offers count
class PendingOffersCountLoaded extends OfferState {
  final int count;

  const PendingOffersCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

/// Error state
class OfferError extends OfferState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for streaming offers (real-time updates)
class OffersStreaming extends OfferState {
  final List<BarterOfferEntity> offers;

  const OffersStreaming(this.offers);

  @override
  List<Object?> get props => [offers];
}
