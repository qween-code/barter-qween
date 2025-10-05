import 'package:equatable/equatable.dart';

/// Negotiation Entity
/// 
/// Represents a negotiation thread between two users
/// for a specific trade offer. Tracks counter-offers and messages.
class NegotiationEntity extends Equatable {
  final String id;
  final String tradeOfferId; // Original trade offer being negotiated
  final String initiatorId; // User who started the negotiation
  final String responderId; // User responding to negotiation

  // Negotiation state
  final NegotiationStatus status;
  final int roundCount; // Number of counter-offers exchanged
  final String currentOfferer; // Who made the current offer

  // Current offer terms
  final double? currentCashOffer; // Current cash differential offer
  final String? currentPaymentDirection; // Who pays in current offer
  final String? currentMeetupLocation; // Proposed meetup location
  final DateTime? currentMeetupTime; // Proposed meetup time
  final String? currentNotes; // Additional notes in current offer

  // History
  final List<NegotiationRound> rounds; // All counter-offers
  final int totalMessages; // Total messages exchanged

  // Outcomes
  final DateTime? agreedAt; // When both parties agreed
  final DateTime? rejectedAt; // When offer was rejected
  final String? rejectionReason;
  final String? rejectedBy; // User ID who rejected

  // Expiration
  final DateTime? expiresAt; // When negotiation expires
  final bool isExpired;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;

  const NegotiationEntity({
    required this.id,
    required this.tradeOfferId,
    required this.initiatorId,
    required this.responderId,
    required this.status,
    this.roundCount = 0,
    required this.currentOfferer,
    this.currentCashOffer,
    this.currentPaymentDirection,
    this.currentMeetupLocation,
    this.currentMeetupTime,
    this.currentNotes,
    this.rounds = const [],
    this.totalMessages = 0,
    this.agreedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.rejectedBy,
    this.expiresAt,
    this.isExpired = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivityAt,
  });

  /// Check if user can make counter-offer
  bool canCounterOffer(String userId) {
    if (status != NegotiationStatus.active) return false;
    if (isExpired) return false;
    return userId != currentOfferer; // Can only counter if it's not your turn
  }

  /// Check if user can accept current offer
  bool canAccept(String userId) {
    if (status != NegotiationStatus.active) return false;
    if (isExpired) return false;
    return userId != currentOfferer; // Can accept if it's your turn
  }

  /// Check if user can reject negotiation
  bool canReject(String userId) {
    return (userId == initiatorId || userId == responderId) &&
        status == NegotiationStatus.active &&
        !isExpired;
  }

  /// Get the other party's user ID
  String getOtherPartyId(String userId) {
    if (userId == initiatorId) return responderId;
    if (userId == responderId) return initiatorId;
    throw ArgumentError('User is not part of this negotiation');
  }

  /// Check if negotiation needs attention from user
  bool needsAttention(String userId) {
    if (status != NegotiationStatus.active) return false;
    if (isExpired) return false;
    return currentOfferer != userId; // Needs attention if it's their turn
  }

  NegotiationEntity copyWith({
    String? id,
    String? tradeOfferId,
    String? initiatorId,
    String? responderId,
    NegotiationStatus? status,
    int? roundCount,
    String? currentOfferer,
    double? currentCashOffer,
    String? currentPaymentDirection,
    String? currentMeetupLocation,
    DateTime? currentMeetupTime,
    String? currentNotes,
    List<NegotiationRound>? rounds,
    int? totalMessages,
    DateTime? agreedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? rejectedBy,
    DateTime? expiresAt,
    bool? isExpired,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
  }) {
    return NegotiationEntity(
      id: id ?? this.id,
      tradeOfferId: tradeOfferId ?? this.tradeOfferId,
      initiatorId: initiatorId ?? this.initiatorId,
      responderId: responderId ?? this.responderId,
      status: status ?? this.status,
      roundCount: roundCount ?? this.roundCount,
      currentOfferer: currentOfferer ?? this.currentOfferer,
      currentCashOffer: currentCashOffer ?? this.currentCashOffer,
      currentPaymentDirection:
          currentPaymentDirection ?? this.currentPaymentDirection,
      currentMeetupLocation:
          currentMeetupLocation ?? this.currentMeetupLocation,
      currentMeetupTime: currentMeetupTime ?? this.currentMeetupTime,
      currentNotes: currentNotes ?? this.currentNotes,
      rounds: rounds ?? this.rounds,
      totalMessages: totalMessages ?? this.totalMessages,
      agreedAt: agreedAt ?? this.agreedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tradeOfferId,
        initiatorId,
        responderId,
        status,
        roundCount,
        currentOfferer,
        currentCashOffer,
        currentPaymentDirection,
        currentMeetupLocation,
        currentMeetupTime,
        currentNotes,
        rounds,
        totalMessages,
        agreedAt,
        rejectedAt,
        rejectionReason,
        rejectedBy,
        expiresAt,
        isExpired,
        createdAt,
        updatedAt,
        lastActivityAt,
      ];

  @override
  String toString() {
    return 'Negotiation(id: $id, status: $status, rounds: $roundCount)';
  }
}

/// Negotiation Round
/// 
/// Represents a single counter-offer in the negotiation
class NegotiationRound extends Equatable {
  final int roundNumber;
  final String offererId; // Who made this offer
  final double? cashOffer;
  final String? paymentDirection;
  final String? meetupLocation;
  final DateTime? meetupTime;
  final String? notes;
  final DateTime createdAt;

  const NegotiationRound({
    required this.roundNumber,
    required this.offererId,
    this.cashOffer,
    this.paymentDirection,
    this.meetupLocation,
    this.meetupTime,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        roundNumber,
        offererId,
        cashOffer,
        paymentDirection,
        meetupLocation,
        meetupTime,
        notes,
        createdAt,
      ];
}

/// Negotiation status enum
enum NegotiationStatus {
  active, // Ongoing negotiation
  agreed, // Both parties agreed
  rejected, // One party rejected
  expired, // Time expired
  cancelled, // Cancelled by system
}

/// Extensions
extension NegotiationStatusExtension on NegotiationStatus {
  String get displayName {
    switch (this) {
      case NegotiationStatus.active:
        return 'Aktif';
      case NegotiationStatus.agreed:
        return 'Anlaşma Sağlandı';
      case NegotiationStatus.rejected:
        return 'Reddedildi';
      case NegotiationStatus.expired:
        return 'Süresi Doldu';
      case NegotiationStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get emoji {
    switch (this) {
      case NegotiationStatus.active:
        return '💬';
      case NegotiationStatus.agreed:
        return '🤝';
      case NegotiationStatus.rejected:
        return '❌';
      case NegotiationStatus.expired:
        return '⏰';
      case NegotiationStatus.cancelled:
        return '🚫';
    }
  }

  bool get isFinal =>
      this == NegotiationStatus.agreed ||
      this == NegotiationStatus.rejected ||
      this == NegotiationStatus.expired ||
      this == NegotiationStatus.cancelled;
}
