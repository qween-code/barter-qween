import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trade_entity.dart';

/// Trade Model for Firestore serialization
class TradeModel {
  final String id;
  final String offerId;
  final String initiatorId;
  final String initiatorItemId;
  final String receiverId;
  final String receiverItemId;
  final String status;
  final double? cashDifferential;
  final String? paymentDirection;
  final String? paymentMethod;
  final String? meetupLocation;
  final String? meetupAddress;
  final double? meetupLatitude;
  final double? meetupLongitude;
  final DateTime? scheduledMeetupTime;
  final String? meetupNotes;
  final DateTime agreedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final bool initiatorConfirmed;
  final bool receiverConfirmed;
  final DateTime? initiatorConfirmedAt;
  final DateTime? receiverConfirmedAt;
  final double? initiatorRating;
  final double? receiverRating;
  final String? initiatorReview;
  final String? receiverReview;
  final bool hasIssues;
  final String? issueDescription;
  final DateTime? issueReportedAt;
  final String? issueReportedBy;
  final String? disputeStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  TradeModel({
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

  /// Convert from Entity to Model
  factory TradeModel.fromEntity(TradeEntity entity) {
    return TradeModel(
      id: entity.id,
      offerId: entity.offerId,
      initiatorId: entity.initiatorId,
      initiatorItemId: entity.initiatorItemId,
      receiverId: entity.receiverId,
      receiverItemId: entity.receiverItemId,
      status: entity.status.name,
      cashDifferential: entity.cashDifferential,
      paymentDirection: entity.paymentDirection?.name,
      paymentMethod: entity.paymentMethod,
      meetupLocation: entity.meetupLocation,
      meetupAddress: entity.meetupAddress,
      meetupLatitude: entity.meetupLatitude,
      meetupLongitude: entity.meetupLongitude,
      scheduledMeetupTime: entity.scheduledMeetupTime,
      meetupNotes: entity.meetupNotes,
      agreedAt: entity.agreedAt,
      completedAt: entity.completedAt,
      cancelledAt: entity.cancelledAt,
      cancellationReason: entity.cancellationReason,
      cancelledBy: entity.cancelledBy,
      initiatorConfirmed: entity.initiatorConfirmed,
      receiverConfirmed: entity.receiverConfirmed,
      initiatorConfirmedAt: entity.initiatorConfirmedAt,
      receiverConfirmedAt: entity.receiverConfirmedAt,
      initiatorRating: entity.initiatorRating,
      receiverRating: entity.receiverRating,
      initiatorReview: entity.initiatorReview,
      receiverReview: entity.receiverReview,
      hasIssues: entity.hasIssues,
      issueDescription: entity.issueDescription,
      issueReportedAt: entity.issueReportedAt,
      issueReportedBy: entity.issueReportedBy,
      disputeStatus: entity.disputeStatus?.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
    );
  }

  /// Convert from Firestore DocumentSnapshot
  factory TradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeModel(
      id: doc.id,
      offerId: data['offerId'] as String,
      initiatorId: data['initiatorId'] as String,
      initiatorItemId: data['initiatorItemId'] as String,
      receiverId: data['receiverId'] as String,
      receiverItemId: data['receiverItemId'] as String,
      status: data['status'] as String,
      cashDifferential: (data['cashDifferential'] as num?)?.toDouble(),
      paymentDirection: data['paymentDirection'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      meetupLocation: data['meetupLocation'] as String?,
      meetupAddress: data['meetupAddress'] as String?,
      meetupLatitude: (data['meetupLatitude'] as num?)?.toDouble(),
      meetupLongitude: (data['meetupLongitude'] as num?)?.toDouble(),
      scheduledMeetupTime: data['scheduledMeetupTime'] != null
          ? (data['scheduledMeetupTime'] as Timestamp).toDate()
          : null,
      meetupNotes: data['meetupNotes'] as String?,
      agreedAt: (data['agreedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'] as String?,
      cancelledBy: data['cancelledBy'] as String?,
      initiatorConfirmed: data['initiatorConfirmed'] as bool? ?? false,
      receiverConfirmed: data['receiverConfirmed'] as bool? ?? false,
      initiatorConfirmedAt: data['initiatorConfirmedAt'] != null
          ? (data['initiatorConfirmedAt'] as Timestamp).toDate()
          : null,
      receiverConfirmedAt: data['receiverConfirmedAt'] != null
          ? (data['receiverConfirmedAt'] as Timestamp).toDate()
          : null,
      initiatorRating: (data['initiatorRating'] as num?)?.toDouble(),
      receiverRating: (data['receiverRating'] as num?)?.toDouble(),
      initiatorReview: data['initiatorReview'] as String?,
      receiverReview: data['receiverReview'] as String?,
      hasIssues: data['hasIssues'] as bool? ?? false,
      issueDescription: data['issueDescription'] as String?,
      issueReportedAt: data['issueReportedAt'] != null
          ? (data['issueReportedAt'] as Timestamp).toDate()
          : null,
      issueReportedBy: data['issueReportedBy'] as String?,
      disputeStatus: data['disputeStatus'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'offerId': offerId,
      'initiatorId': initiatorId,
      'initiatorItemId': initiatorItemId,
      'receiverId': receiverId,
      'receiverItemId': receiverItemId,
      'status': status,
      'cashDifferential': cashDifferential,
      'paymentDirection': paymentDirection,
      'paymentMethod': paymentMethod,
      'meetupLocation': meetupLocation,
      'meetupAddress': meetupAddress,
      'meetupLatitude': meetupLatitude,
      'meetupLongitude': meetupLongitude,
      'scheduledMeetupTime': scheduledMeetupTime != null
          ? Timestamp.fromDate(scheduledMeetupTime!)
          : null,
      'meetupNotes': meetupNotes,
      'agreedAt': Timestamp.fromDate(agreedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'initiatorConfirmed': initiatorConfirmed,
      'receiverConfirmed': receiverConfirmed,
      'initiatorConfirmedAt': initiatorConfirmedAt != null
          ? Timestamp.fromDate(initiatorConfirmedAt!)
          : null,
      'receiverConfirmedAt': receiverConfirmedAt != null
          ? Timestamp.fromDate(receiverConfirmedAt!)
          : null,
      'initiatorRating': initiatorRating,
      'receiverRating': receiverRating,
      'initiatorReview': initiatorReview,
      'receiverReview': receiverReview,
      'hasIssues': hasIssues,
      'issueDescription': issueDescription,
      'issueReportedAt': issueReportedAt != null
          ? Timestamp.fromDate(issueReportedAt!)
          : null,
      'issueReportedBy': issueReportedBy,
      'disputeStatus': disputeStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  /// Convert to Entity
  TradeEntity toEntity() {
    return TradeEntity(
      id: id,
      offerId: offerId,
      initiatorId: initiatorId,
      initiatorItemId: initiatorItemId,
      receiverId: receiverId,
      receiverItemId: receiverItemId,
      status: TradeStatus.values.firstWhere((e) => e.name == status),
      cashDifferential: cashDifferential,
      paymentDirection: paymentDirection != null
          ? CashPaymentDirection.values
              .firstWhere((e) => e.name == paymentDirection)
          : null,
      paymentMethod: paymentMethod,
      meetupLocation: meetupLocation,
      meetupAddress: meetupAddress,
      meetupLatitude: meetupLatitude,
      meetupLongitude: meetupLongitude,
      scheduledMeetupTime: scheduledMeetupTime,
      meetupNotes: meetupNotes,
      agreedAt: agreedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
      cancelledBy: cancelledBy,
      initiatorConfirmed: initiatorConfirmed,
      receiverConfirmed: receiverConfirmed,
      initiatorConfirmedAt: initiatorConfirmedAt,
      receiverConfirmedAt: receiverConfirmedAt,
      initiatorRating: initiatorRating,
      receiverRating: receiverRating,
      initiatorReview: initiatorReview,
      receiverReview: receiverReview,
      hasIssues: hasIssues,
      issueDescription: issueDescription,
      issueReportedAt: issueReportedAt,
      issueReportedBy: issueReportedBy,
      disputeStatus: disputeStatus != null
          ? DisputeStatus.values.firstWhere((e) => e.name == disputeStatus)
          : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}
