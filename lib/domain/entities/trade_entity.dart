import 'package:equatable/equatable.dart';

/// Trade entity representing a completed or ongoing barter trade
/// 
/// A trade is created when both parties agree to exchange items.
/// It tracks the full lifecycle from agreement to completion.
class TradeEntity extends Equatable {
  final String id;
  final String offerId; // Reference to TradeOfferEntity that initiated this trade
  
  // Parties involved
  final String initiatorId; // User who made the offer
  final String initiatorItemId; // Item offered by initiator
  final String receiverId; // User who accepted the offer
  final String receiverItemId; // Item offered by receiver
  
  // Trade details
  final TradeStatus status;
  final double? cashDifferential; // If one party pays extra cash
  final CashPaymentDirection? paymentDirection; // Who pays the cash
  final String? paymentMethod; // How cash is paid (if applicable)
  
  // Meetup details
  final String? meetupLocation; // Agreed meetup location
  final String? meetupAddress; // Full address
  final double? meetupLatitude;
  final double? meetupLongitude;
  final DateTime? scheduledMeetupTime;
  final String? meetupNotes; // Additional meetup instructions
  
  // Trade progression
  final DateTime agreedAt; // When both parties agreed
  final DateTime? completedAt; // When trade was marked complete
  final DateTime? cancelledAt; // When trade was cancelled
  final String? cancellationReason;
  final String? cancelledBy; // User ID who cancelled
  
  // Verification
  final bool initiatorConfirmed; // Initiator confirmed receiving item
  final bool receiverConfirmed; // Receiver confirmed receiving item
  final DateTime? initiatorConfirmedAt;
  final DateTime? receiverConfirmedAt;
  
  // Ratings (after completion)
  final double? initiatorRating; // Rating given to receiver
  final double? receiverRating; // Rating given to initiator
  final String? initiatorReview;
  final String? receiverReview;
  
  // Issues & disputes
  final bool hasIssues; // If there are any reported issues
  final String? issueDescription;
  final DateTime? issueReportedAt;
  final String? issueReportedBy;
  final DisputeStatus? disputeStatus;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata; // Additional flexible data

  const TradeEntity({
    required this.id,
    required this.offerId,
    required this.initiatorId,
    required this.initiatorItemId,
    required this.receiverId,
    required this.receiverItemId,
    required this.status,
    this.cashDifferential,
    this.paymentDirection,
    this.paymentMethod,
    this.meetupLocation,
    this.meetupAddress,
    this.meetupLatitude,
    this.meetupLongitude,
    this.scheduledMeetupTime,
    this.meetupNotes,
    required this.agreedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.initiatorConfirmed = false,
    this.receiverConfirmed = false,
    this.initiatorConfirmedAt,
    this.receiverConfirmedAt,
    this.initiatorRating,
    this.receiverRating,
    this.initiatorReview,
    this.receiverReview,
    this.hasIssues = false,
    this.issueDescription,
    this.issueReportedAt,
    this.issueReportedBy,
    this.disputeStatus,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Check if trade is complete (both parties confirmed)
  bool get isComplete => initiatorConfirmed && receiverConfirmed;

  /// Check if trade can be confirmed by specific user
  bool canConfirm(String userId) {
    if (status != TradeStatus.inProgress) return false;
    if (userId == initiatorId) return !initiatorConfirmed;
    if (userId == receiverId) return !receiverConfirmed;
    return false;
  }

  /// Check if trade can be cancelled by specific user
  bool canCancel(String userId) {
    return (userId == initiatorId || userId == receiverId) &&
        status != TradeStatus.completed &&
        status != TradeStatus.cancelled;
  }

  /// Check if user can rate the other party
  bool canRate(String userId) {
    return status == TradeStatus.completed &&
        ((userId == initiatorId && initiatorRating == null) ||
            (userId == receiverId && receiverRating == null));
  }

  /// Get the other party's user ID
  String getOtherPartyId(String userId) {
    if (userId == initiatorId) return receiverId;
    if (userId == receiverId) return initiatorId;
    throw ArgumentError('User is not part of this trade');
  }

  TradeEntity copyWith({
    String? id,
    String? offerId,
    String? initiatorId,
    String? initiatorItemId,
    String? receiverId,
    String? receiverItemId,
    TradeStatus? status,
    double? cashDifferential,
    CashPaymentDirection? paymentDirection,
    String? paymentMethod,
    String? meetupLocation,
    String? meetupAddress,
    double? meetupLatitude,
    double? meetupLongitude,
    DateTime? scheduledMeetupTime,
    String? meetupNotes,
    DateTime? agreedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? cancelledBy,
    bool? initiatorConfirmed,
    bool? receiverConfirmed,
    DateTime? initiatorConfirmedAt,
    DateTime? receiverConfirmedAt,
    double? initiatorRating,
    double? receiverRating,
    String? initiatorReview,
    String? receiverReview,
    bool? hasIssues,
    String? issueDescription,
    DateTime? issueReportedAt,
    String? issueReportedBy,
    DisputeStatus? disputeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TradeEntity(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorItemId: initiatorItemId ?? this.initiatorItemId,
      receiverId: receiverId ?? this.receiverId,
      receiverItemId: receiverItemId ?? this.receiverItemId,
      status: status ?? this.status,
      cashDifferential: cashDifferential ?? this.cashDifferential,
      paymentDirection: paymentDirection ?? this.paymentDirection,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      meetupLocation: meetupLocation ?? this.meetupLocation,
      meetupAddress: meetupAddress ?? this.meetupAddress,
      meetupLatitude: meetupLatitude ?? this.meetupLatitude,
      meetupLongitude: meetupLongitude ?? this.meetupLongitude,
      scheduledMeetupTime: scheduledMeetupTime ?? this.scheduledMeetupTime,
      meetupNotes: meetupNotes ?? this.meetupNotes,
      agreedAt: agreedAt ?? this.agreedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      initiatorConfirmed: initiatorConfirmed ?? this.initiatorConfirmed,
      receiverConfirmed: receiverConfirmed ?? this.receiverConfirmed,
      initiatorConfirmedAt: initiatorConfirmedAt ?? this.initiatorConfirmedAt,
      receiverConfirmedAt: receiverConfirmedAt ?? this.receiverConfirmedAt,
      initiatorRating: initiatorRating ?? this.initiatorRating,
      receiverRating: receiverRating ?? this.receiverRating,
      initiatorReview: initiatorReview ?? this.initiatorReview,
      receiverReview: receiverReview ?? this.receiverReview,
      hasIssues: hasIssues ?? this.hasIssues,
      issueDescription: issueDescription ?? this.issueDescription,
      issueReportedAt: issueReportedAt ?? this.issueReportedAt,
      issueReportedBy: issueReportedBy ?? this.issueReportedBy,
      disputeStatus: disputeStatus ?? this.disputeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        offerId,
        initiatorId,
        initiatorItemId,
        receiverId,
        receiverItemId,
        status,
        cashDifferential,
        paymentDirection,
        paymentMethod,
        meetupLocation,
        meetupAddress,
        meetupLatitude,
        meetupLongitude,
        scheduledMeetupTime,
        meetupNotes,
        agreedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        cancelledBy,
        initiatorConfirmed,
        receiverConfirmed,
        initiatorConfirmedAt,
        receiverConfirmedAt,
        initiatorRating,
        receiverRating,
        initiatorReview,
        receiverReview,
        hasIssues,
        issueDescription,
        issueReportedAt,
        issueReportedBy,
        disputeStatus,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'TradeEntity(id: $id, status: $status, initiator: $initiatorId, receiver: $receiverId)';
  }
}

/// Trade status enum
enum TradeStatus {
  pending, // Offer accepted, awaiting final details
  scheduled, // Meetup scheduled
  inProgress, // Trade is happening
  completed, // Both parties confirmed
  cancelled, // Trade cancelled
  disputed, // Trade has dispute
}

/// Cash payment direction (reused from barter_condition_entity.dart)
enum CashPaymentDirection {
  fromInitiator, // Initiator pays cash
  fromReceiver, // Receiver pays cash
}

/// Dispute status enum
enum DisputeStatus {
  reported, // Issue reported
  underReview, // Admin reviewing
  resolved, // Dispute resolved
  escalated, // Escalated to higher support
}

/// Extensions for display
extension TradeStatusExtension on TradeStatus {
  String get displayName {
    switch (this) {
      case TradeStatus.pending:
        return 'Bekliyor';
      case TradeStatus.scheduled:
        return 'Planlandı';
      case TradeStatus.inProgress:
        return 'Devam Ediyor';
      case TradeStatus.completed:
        return 'Tamamlandı';
      case TradeStatus.cancelled:
        return 'İptal Edildi';
      case TradeStatus.disputed:
        return 'Anlaşmazlık';
    }
  }

  String get description {
    switch (this) {
      case TradeStatus.pending:
        return 'Takas kabul edildi, detaylar bekleniyor';
      case TradeStatus.scheduled:
        return 'Buluşma zamanı planlandı';
      case TradeStatus.inProgress:
        return 'Takas devam ediyor';
      case TradeStatus.completed:
        return 'Takas başarıyla tamamlandı';
      case TradeStatus.cancelled:
        return 'Takas iptal edildi';
      case TradeStatus.disputed:
        return 'Takas anlaşmazlık durumunda';
    }
  }

  bool get isActive => this == TradeStatus.inProgress || this == TradeStatus.scheduled;
  bool get isFinal => this == TradeStatus.completed || this == TradeStatus.cancelled;
}

extension DisputeStatusExtension on DisputeStatus {
  String get displayName {
    switch (this) {
      case DisputeStatus.reported:
        return 'Bildirildi';
      case DisputeStatus.underReview:
        return 'İnceleniyor';
      case DisputeStatus.resolved:
        return 'Çözüldü';
      case DisputeStatus.escalated:
        return 'Yükseltildi';
    }
  }
}
