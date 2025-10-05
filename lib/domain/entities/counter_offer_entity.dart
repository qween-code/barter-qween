import 'package:equatable/equatable.dart';

/// Counter Offer Entity
/// 
/// Represents a counter-offer made during negotiation.
/// This is a lightweight entity for quick counter-offer actions.
class CounterOfferEntity extends Equatable {
  final String id;
  final String negotiationId; // Parent negotiation
  final String offerId; // Original offer ID
  final String offererId; // User making counter-offer
  final String targetUserId; // User receiving counter-offer

  // Offer terms
  final CounterOfferType type; // What is being countered
  final double? proposedCash; // New cash offer
  final String? proposedPaymentDirection; // New payment direction
  final String? proposedMeetupLocation; // New location
  final DateTime? proposedMeetupTime; // New time
  final String? message; // Explanation/message with counter

  // Status
  final CounterOfferStatus status;
  final DateTime? respondedAt;
  final String? responseMessage;

  // Metadata
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isExpired;

  const CounterOfferEntity({
    required this.id,
    required this.negotiationId,
    required this.offerId,
    required this.offererId,
    required this.targetUserId,
    required this.type,
    this.proposedCash,
    this.proposedPaymentDirection,
    this.proposedMeetupLocation,
    this.proposedMeetupTime,
    this.message,
    required this.status,
    this.respondedAt,
    this.responseMessage,
    required this.createdAt,
    this.expiresAt,
    this.isExpired = false,
  });

  /// Check if user can respond to this counter-offer
  bool canRespond(String userId) {
    return userId == targetUserId &&
        status == CounterOfferStatus.pending &&
        !isExpired;
  }

  /// Check if counter-offer is still valid
  bool get isValid =>
      status == CounterOfferStatus.pending &&
      !isExpired &&
      (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// Get summary of what changed
  String get changesSummary {
    List<String> changes = [];
    if (proposedCash != null) changes.add('Para teklifi değişti');
    if (proposedMeetupLocation != null) changes.add('Buluşma yeri değişti');
    if (proposedMeetupTime != null) changes.add('Buluşma zamanı değişti');
    if (changes.isEmpty) return 'Şartlar değiştirildi';
    return changes.join(', ');
  }

  CounterOfferEntity copyWith({
    String? id,
    String? negotiationId,
    String? offerId,
    String? offererId,
    String? targetUserId,
    CounterOfferType? type,
    double? proposedCash,
    String? proposedPaymentDirection,
    String? proposedMeetupLocation,
    DateTime? proposedMeetupTime,
    String? message,
    CounterOfferStatus? status,
    DateTime? respondedAt,
    String? responseMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isExpired,
  }) {
    return CounterOfferEntity(
      id: id ?? this.id,
      negotiationId: negotiationId ?? this.negotiationId,
      offerId: offerId ?? this.offerId,
      offererId: offererId ?? this.offererId,
      targetUserId: targetUserId ?? this.targetUserId,
      type: type ?? this.type,
      proposedCash: proposedCash ?? this.proposedCash,
      proposedPaymentDirection:
          proposedPaymentDirection ?? this.proposedPaymentDirection,
      proposedMeetupLocation:
          proposedMeetupLocation ?? this.proposedMeetupLocation,
      proposedMeetupTime: proposedMeetupTime ?? this.proposedMeetupTime,
      message: message ?? this.message,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  @override
  List<Object?> get props => [
        id,
        negotiationId,
        offerId,
        offererId,
        targetUserId,
        type,
        proposedCash,
        proposedPaymentDirection,
        proposedMeetupLocation,
        proposedMeetupTime,
        message,
        status,
        respondedAt,
        responseMessage,
        createdAt,
        expiresAt,
        isExpired,
      ];

  @override
  String toString() {
    return 'CounterOffer(id: $id, type: $type, status: $status)';
  }
}

/// Counter-offer type
enum CounterOfferType {
  cash, // Countering cash amount
  location, // Countering meetup location
  time, // Countering meetup time
  terms, // Countering general terms
  full, // Complete counter-offer (all terms)
}

/// Counter-offer status
enum CounterOfferStatus {
  pending, // Waiting for response
  accepted, // Counter-offer accepted
  rejected, // Counter-offer rejected
  superseded, // New counter-offer made (this one obsolete)
  expired, // Time expired
}

/// Extensions
extension CounterOfferTypeExtension on CounterOfferType {
  String get displayName {
    switch (this) {
      case CounterOfferType.cash:
        return 'Para Teklifi';
      case CounterOfferType.location:
        return 'Buluşma Yeri';
      case CounterOfferType.time:
        return 'Buluşma Zamanı';
      case CounterOfferType.terms:
        return 'Şartlar';
      case CounterOfferType.full:
        return 'Tam Teklif';
    }
  }

  String get icon {
    switch (this) {
      case CounterOfferType.cash:
        return '💰';
      case CounterOfferType.location:
        return '📍';
      case CounterOfferType.time:
        return '🕐';
      case CounterOfferType.terms:
        return '📋';
      case CounterOfferType.full:
        return '🔄';
    }
  }
}

extension CounterOfferStatusExtension on CounterOfferStatus {
  String get displayName {
    switch (this) {
      case CounterOfferStatus.pending:
        return 'Bekliyor';
      case CounterOfferStatus.accepted:
        return 'Kabul Edildi';
      case CounterOfferStatus.rejected:
        return 'Reddedildi';
      case CounterOfferStatus.superseded:
        return 'Geçersiz';
      case CounterOfferStatus.expired:
        return 'Süresi Doldu';
    }
  }

  bool get isFinal =>
      this == CounterOfferStatus.accepted ||
      this == CounterOfferStatus.rejected ||
      this == CounterOfferStatus.superseded ||
      this == CounterOfferStatus.expired;
}
