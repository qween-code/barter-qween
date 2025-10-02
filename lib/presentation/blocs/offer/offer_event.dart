import 'package:equatable/equatable.dart';
import '../../../domain/entities/barter_offer_entity.dart';

/// Base class for all offer events
abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new offer
class CreateOffer extends OfferEvent {
  final BarterOfferEntity offer;

  const CreateOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Event to load a specific offer
class LoadOffer extends OfferEvent {
  final String offerId;

  const LoadOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Event to load sent offers for current user
class LoadSentOffers extends OfferEvent {
  final String userId;

  const LoadSentOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load received offers for current user
class LoadReceivedOffers extends OfferEvent {
  final String userId;

  const LoadReceivedOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load offers for a specific item
class LoadOffersForItem extends OfferEvent {
  final String itemId;

  const LoadOffersForItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Event to accept an offer
class AcceptOffer extends OfferEvent {
  final String offerId;

  const AcceptOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Event to reject an offer
class RejectOffer extends OfferEvent {
  final String offerId;

  const RejectOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Event to cancel an offer
class CancelOffer extends OfferEvent {
  final String offerId;

  const CancelOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Event to complete an offer
class CompleteOffer extends OfferEvent {
  final String offerId;

  const CompleteOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Event to get pending offers count
class LoadPendingOffersCount extends OfferEvent {
  final String userId;

  const LoadPendingOffersCount(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to watch sent offers (real-time)
class WatchSentOffers extends OfferEvent {
  final String userId;

  const WatchSentOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to watch received offers (real-time)
class WatchReceivedOffers extends OfferEvent {
  final String userId;

  const WatchReceivedOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}
