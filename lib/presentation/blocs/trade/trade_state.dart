import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_offer_entity.dart';

abstract class TradeState extends Equatable {
  const TradeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TradeInitial extends TradeState {
  const TradeInitial();
}

/// Loading state
class TradeLoading extends TradeState {
  const TradeLoading();
}

/// Trade offers loaded successfully
class TradeOffersLoaded extends TradeState {
  final List<TradeOfferEntity> offers;

  const TradeOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

/// Single trade offer loaded
class TradeOfferLoaded extends TradeState {
  final TradeOfferEntity offer;

  const TradeOfferLoaded(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Trade offer sent successfully
class TradeOfferSent extends TradeState {
  final TradeOfferEntity offer;

  const TradeOfferSent(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Trade offer accepted
class TradeOfferAccepted extends TradeState {
  final TradeOfferEntity offer;

  const TradeOfferAccepted(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Trade offer rejected
class TradeOfferRejected extends TradeState {
  final TradeOfferEntity offer;

  const TradeOfferRejected(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Trade offer cancelled
class TradeOfferCancelled extends TradeState {
  const TradeOfferCancelled();
}

/// Trade completed
class TradeCompleted extends TradeState {
  final TradeOfferEntity offer;

  const TradeCompleted(this.offer);

  @override
  List<Object?> get props => [offer];
}

/// Pending count loaded
class PendingCountLoaded extends TradeState {
  final int count;

  const PendingCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

/// Error state
class TradeError extends TradeState {
  final String message;

  const TradeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action in progress (for showing loading on buttons)
class TradeActionInProgress extends TradeState {
  final String action; // 'accepting', 'rejecting', 'cancelling', 'completing'

  const TradeActionInProgress(this.action);

  @override
  List<Object?> get props => [action];
}

/// Trade offers loaded with filter info
class FilteredTradeOffersLoaded extends TradeState {
  final List<TradeOfferEntity> offers;
  final TradeOfferFilter filter;

  const FilteredTradeOffersLoaded(this.offers, this.filter);

  @override
  List<Object?> get props => [offers, filter];
}

/// Trade offer filter enum
enum TradeOfferFilter {
  all,
  sent,
  received,
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

extension TradeOfferFilterExtension on TradeOfferFilter {
  String get displayName {
    switch (this) {
      case TradeOfferFilter.all:
        return 'All Trades';
      case TradeOfferFilter.sent:
        return 'Sent Offers';
      case TradeOfferFilter.received:
        return 'Received Offers';
      case TradeOfferFilter.pending:
        return 'Pending';
      case TradeOfferFilter.accepted:
        return 'Accepted';
      case TradeOfferFilter.rejected:
        return 'Rejected';
      case TradeOfferFilter.completed:
        return 'Completed';
      case TradeOfferFilter.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case TradeOfferFilter.all:
        return '📦';
      case TradeOfferFilter.sent:
        return '📤';
      case TradeOfferFilter.received:
        return '📥';
      case TradeOfferFilter.pending:
        return '⏳';
      case TradeOfferFilter.accepted:
        return '✅';
      case TradeOfferFilter.rejected:
        return '❌';
      case TradeOfferFilter.completed:
        return '🎉';
      case TradeOfferFilter.cancelled:
        return '🚫';
    }
  }
}
