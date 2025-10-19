import 'package:equatable/equatable.dart';

enum CounterOfferType { cash, terms, itemSwap, location, time, full }

enum CounterOfferStatus { pending, accepted, rejected, expired }

class CounterOfferEntity extends Equatable {
  final String id;
  final String offerId;
  final String negotiationId;
  final String offererId;
  final String targetUserId;
  final String sourceItemId;
  final String targetItemId;
  final CounterOfferType type;
  final CounterOfferType offerType;
  final double? offeredAmount;
  final double? proposedCash;
  final String? terms;
  final String? offeredItemId;
  final String? requestedItemId;
  final String? proposedPaymentDirection;
  final String? proposedMeetupLocation;
  final DateTime? proposedMeetupTime;
  final String? message;
  final CounterOfferStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? responseMessage;
  final bool isAccepted;
  final bool isRejected;
  final bool isExpired;

  const CounterOfferEntity({
    required this.id,
    required this.offerId,
    required this.negotiationId,
    required this.offererId,
    required this.targetUserId,
    required this.sourceItemId,
    required this.targetItemId,
    required this.type,
    required this.offerType,
    this.offeredAmount,
    this.proposedCash,
    this.terms,
    this.offeredItemId,
    this.requestedItemId,
    this.proposedPaymentDirection,
    this.proposedMeetupLocation,
    this.proposedMeetupTime,
    this.message,
    this.status = CounterOfferStatus.pending,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
    this.responseMessage,
    this.isAccepted = false,
    this.isRejected = false,
    this.isExpired = false,
  });

  @override
  List<Object?> get props => [
    id,
    offerId,
    negotiationId,
    offererId,
    targetUserId,
    sourceItemId,
    targetItemId,
    type,
    offerType,
    offeredAmount,
    proposedCash,
    terms,
    offeredItemId,
    requestedItemId,
    proposedPaymentDirection,
    proposedMeetupLocation,
    proposedMeetupTime,
    message,
    status,
    createdAt,
    expiresAt,
    respondedAt,
    responseMessage,
    isAccepted,
    isRejected,
    isExpired,
  ];

  CounterOfferEntity copyWith({
    String? id,
    String? offerId,
    String? negotiationId,
    String? offererId,
    String? targetUserId,
    String? sourceItemId,
    String? targetItemId,
    CounterOfferType? type,
    CounterOfferType? offerType,
    double? offeredAmount,
    double? proposedCash,
    String? terms,
    String? offeredItemId,
    String? requestedItemId,
    String? proposedPaymentDirection,
    String? proposedMeetupLocation,
    DateTime? proposedMeetupTime,
    String? message,
    CounterOfferStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    String? responseMessage,
    bool? isAccepted,
    bool? isRejected,
    bool? isExpired,
  }) {
    return CounterOfferEntity(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      negotiationId: negotiationId ?? this.negotiationId,
      offererId: offererId ?? this.offererId,
      targetUserId: targetUserId ?? this.targetUserId,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      targetItemId: targetItemId ?? this.targetItemId,
      type: type ?? this.type,
      offerType: offerType ?? this.offerType,
      offeredAmount: offeredAmount ?? this.offeredAmount,
      proposedCash: proposedCash ?? this.proposedCash,
      terms: terms ?? this.terms,
      offeredItemId: offeredItemId ?? this.offeredItemId,
      requestedItemId: requestedItemId ?? this.requestedItemId,
      proposedPaymentDirection:
          proposedPaymentDirection ?? this.proposedPaymentDirection,
      proposedMeetupLocation:
          proposedMeetupLocation ?? this.proposedMeetupLocation,
      proposedMeetupTime: proposedMeetupTime ?? this.proposedMeetupTime,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}
