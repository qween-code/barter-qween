import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/counter_offer_entity.dart';

/// Counter Offer Model for Firestore serialization
class CounterOfferModel {
  final String id;
  final String negotiationId;
  final String offerId;
  final String offererId;
  final String targetUserId;
  final String type;
  final double? proposedCash;
  final String? proposedPaymentDirection;
  final String? proposedMeetupLocation;
  final DateTime? proposedMeetupTime;
  final String? message;
  final String status;
  final DateTime? respondedAt;
  final String? responseMessage;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isExpired;

  CounterOfferModel({
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

  /// Convert from Entity to Model
  factory CounterOfferModel.fromEntity(CounterOfferEntity entity) {
    return CounterOfferModel(
      id: entity.id,
      negotiationId: entity.negotiationId,
      offerId: entity.offerId,
      offererId: entity.offererId,
      targetUserId: entity.targetUserId,
      type: entity.type.name,
      proposedCash: entity.proposedCash,
      proposedPaymentDirection: entity.proposedPaymentDirection,
      proposedMeetupLocation: entity.proposedMeetupLocation,
      proposedMeetupTime: entity.proposedMeetupTime,
      message: entity.message,
      status: entity.status.name,
      respondedAt: entity.respondedAt,
      responseMessage: entity.responseMessage,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      isExpired: entity.isExpired,
    );
  }

  /// Convert from Firestore DocumentSnapshot
  factory CounterOfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CounterOfferModel(
      id: doc.id,
      negotiationId: data['negotiationId'] as String,
      offerId: data['offerId'] as String,
      offererId: data['offererId'] as String,
      targetUserId: data['targetUserId'] as String,
      type: data['type'] as String,
      proposedCash: (data['proposedCash'] as num?)?.toDouble(),
      proposedPaymentDirection: data['proposedPaymentDirection'] as String?,
      proposedMeetupLocation: data['proposedMeetupLocation'] as String?,
      proposedMeetupTime: data['proposedMeetupTime'] != null
          ? (data['proposedMeetupTime'] as Timestamp).toDate()
          : null,
      message: data['message'] as String?,
      status: data['status'] as String,
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      responseMessage: data['responseMessage'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      isExpired: data['isExpired'] as bool? ?? false,
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'negotiationId': negotiationId,
      'offerId': offerId,
      'offererId': offererId,
      'targetUserId': targetUserId,
      'type': type,
      'proposedCash': proposedCash,
      'proposedPaymentDirection': proposedPaymentDirection,
      'proposedMeetupLocation': proposedMeetupLocation,
      'proposedMeetupTime': proposedMeetupTime != null
          ? Timestamp.fromDate(proposedMeetupTime!)
          : null,
      'message': message,
      'status': status,
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'responseMessage': responseMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isExpired': isExpired,
    };
  }

  /// Convert to Entity
  CounterOfferEntity toEntity() {
    return CounterOfferEntity(
      id: id,
      negotiationId: negotiationId,
      offerId: offerId,
      offererId: offererId,
      targetUserId: targetUserId,
      type: CounterOfferType.values.firstWhere((e) => e.name == type),
      proposedCash: proposedCash,
      proposedPaymentDirection: proposedPaymentDirection,
      proposedMeetupLocation: proposedMeetupLocation,
      proposedMeetupTime: proposedMeetupTime,
      message: message,
      status: CounterOfferStatus.values.firstWhere((e) => e.name == status),
      respondedAt: respondedAt,
      responseMessage: responseMessage,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isExpired: isExpired,
    );
  }
}
