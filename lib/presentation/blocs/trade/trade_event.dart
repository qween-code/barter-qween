import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_offer_entity.dart';

abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object?> get props => [];
}

/// Send a new trade offer
class SendTradeOffer extends TradeEvent {
  final TradeOfferEntity offer;

  const SendTradeOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Accept a trade offer
class AcceptTradeOffer extends TradeEvent {
  final String offerId;
  final String? responseMessage;

  const AcceptTradeOffer(this.offerId, {this.responseMessage});

  @override
  List<Object?> get props => [offerId, responseMessage];
}

/// Reject a trade offer
class RejectTradeOffer extends TradeEvent {
  final String offerId;
  final String? rejectionReason;

  const RejectTradeOffer(this.offerId, {this.rejectionReason});

  @override
  List<Object?> get props => [offerId, rejectionReason];
}

/// Cancel a trade offer (by sender)
class CancelTradeOffer extends TradeEvent {
  final String offerId;

  const CancelTradeOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Complete a trade
class CompleteTrade extends TradeEvent {
  final String offerId;

  const CompleteTrade(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Load a single trade offer
class LoadTradeOffer extends TradeEvent {
  final String offerId;

  const LoadTradeOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Load all trade offers for a user
class LoadUserTradeOffers extends TradeEvent {
  final String userId;

  const LoadUserTradeOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load sent trade offers
class LoadSentTradeOffers extends TradeEvent {
  final String userId;

  const LoadSentTradeOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load received trade offers
class LoadReceivedTradeOffers extends TradeEvent {
  final String userId;

  const LoadReceivedTradeOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load trade offers by status
class LoadTradeOffersByStatus extends TradeEvent {
  final String userId;
  final TradeStatus status;

  const LoadTradeOffersByStatus(this.userId, this.status);

  @override
  List<Object?> get props => [userId, status];
}

/// Load trade history for an item
class LoadItemTradeHistory extends TradeEvent {
  final String itemId;

  const LoadItemTradeHistory(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Load pending received trade count
class LoadPendingReceivedCount extends TradeEvent {
  final String userId;

  const LoadPendingReceivedCount(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Refresh trade offers
class RefreshTradeOffers extends TradeEvent {
  final String userId;

  const RefreshTradeOffers(this.userId);

  @override
  List<Object?> get props => [userId];
}
