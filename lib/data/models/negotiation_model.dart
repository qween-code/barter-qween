import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/negotiation_entity.dart';

/// Negotiation Model for Firestore serialization
class NegotiationModel {
  final String id;
  final String tradeOfferId;
  final String initiatorId;
  final String responderId;
  final String status;
  final int roundCount;
  final String currentOfferer;
  final double? currentCashOffer;
  final String? currentPaymentDirection;
  final String? currentMeetupLocation;
  final DateTime? currentMeetupTime;
  final String? currentNotes;
  final List<Map<String, dynamic>> rounds;
  final int totalMessages;
  final DateTime? agreedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? rejectedBy;
  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;

  NegotiationModel({
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

  /// Convert from Entity to Model
  factory NegotiationModel.fromEntity(NegotiationEntity entity) {
    return NegotiationModel(
      id: entity.id,
      tradeOfferId: entity.tradeOfferId,
      initiatorId: entity.initiatorId,
      responderId: entity.responderId,
      status: entity.status.name,
      roundCount: entity.roundCount,
      currentOfferer: entity.currentOfferer,
      currentCashOffer: entity.currentCashOffer,
      currentPaymentDirection: entity.currentPaymentDirection,
      currentMeetupLocation: entity.currentMeetupLocation,
      currentMeetupTime: entity.currentMeetupTime,
      currentNotes: entity.currentNotes,
      rounds: entity.rounds
          .map((round) => {
                'roundNumber': round.roundNumber,
                'offererId': round.offererId,
                'cashOffer': round.cashOffer,
                'paymentDirection': round.paymentDirection,
                'meetupLocation': round.meetupLocation,
                'meetupTime': round.meetupTime,
                'notes': round.notes,
                'createdAt': round.createdAt,
              })
          .toList(),
      totalMessages: entity.totalMessages,
      agreedAt: entity.agreedAt,
      rejectedAt: entity.rejectedAt,
      rejectionReason: entity.rejectionReason,
      rejectedBy: entity.rejectedBy,
      expiresAt: entity.expiresAt,
      isExpired: entity.isExpired,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastActivityAt: entity.lastActivityAt,
    );
  }

  /// Convert from Firestore DocumentSnapshot
  factory NegotiationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NegotiationModel(
      id: doc.id,
      tradeOfferId: data['tradeOfferId'] as String,
      initiatorId: data['initiatorId'] as String,
      responderId: data['responderId'] as String,
      status: data['status'] as String,
      roundCount: data['roundCount'] as int? ?? 0,
      currentOfferer: data['currentOfferer'] as String,
      currentCashOffer: (data['currentCashOffer'] as num?)?.toDouble(),
      currentPaymentDirection: data['currentPaymentDirection'] as String?,
      currentMeetupLocation: data['currentMeetupLocation'] as String?,
      currentMeetupTime: data['currentMeetupTime'] != null
          ? (data['currentMeetupTime'] as Timestamp).toDate()
          : null,
      currentNotes: data['currentNotes'] as String?,
      rounds: data['rounds'] != null
          ? (data['rounds'] as List)
              .map((r) => Map<String, dynamic>.from(r as Map))
              .toList()
          : [],
      totalMessages: data['totalMessages'] as int? ?? 0,
      agreedAt: data['agreedAt'] != null
          ? (data['agreedAt'] as Timestamp).toDate()
          : null,
      rejectedAt: data['rejectedAt'] != null
          ? (data['rejectedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason'] as String?,
      rejectedBy: data['rejectedBy'] as String?,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      isExpired: data['isExpired'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastActivityAt: data['lastActivityAt'] != null
          ? (data['lastActivityAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'tradeOfferId': tradeOfferId,
      'initiatorId': initiatorId,
      'responderId': responderId,
      'status': status,
      'roundCount': roundCount,
      'currentOfferer': currentOfferer,
      'currentCashOffer': currentCashOffer,
      'currentPaymentDirection': currentPaymentDirection,
      'currentMeetupLocation': currentMeetupLocation,
      'currentMeetupTime': currentMeetupTime != null
          ? Timestamp.fromDate(currentMeetupTime!)
          : null,
      'currentNotes': currentNotes,
      'rounds': rounds
          .map((round) => {
                'roundNumber': round['roundNumber'],
                'offererId': round['offererId'],
                'cashOffer': round['cashOffer'],
                'paymentDirection': round['paymentDirection'],
                'meetupLocation': round['meetupLocation'],
                'meetupTime': round['meetupTime'] != null
                    ? Timestamp.fromDate(round['meetupTime'] as DateTime)
                    : null,
                'notes': round['notes'],
                'createdAt': Timestamp.fromDate(round['createdAt'] as DateTime),
              })
          .toList(),
      'totalMessages': totalMessages,
      'agreedAt': agreedAt != null ? Timestamp.fromDate(agreedAt!) : null,
      'rejectedAt':
          rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectionReason': rejectionReason,
      'rejectedBy': rejectedBy,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isExpired': isExpired,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActivityAt': lastActivityAt != null
          ? Timestamp.fromDate(lastActivityAt!)
          : null,
    };
  }

  /// Convert to Entity
  NegotiationEntity toEntity() {
    return NegotiationEntity(
      id: id,
      tradeOfferId: tradeOfferId,
      initiatorId: initiatorId,
      responderId: responderId,
      status:
          NegotiationStatus.values.firstWhere((e) => e.name == status),
      roundCount: roundCount,
      currentOfferer: currentOfferer,
      currentCashOffer: currentCashOffer,
      currentPaymentDirection: currentPaymentDirection,
      currentMeetupLocation: currentMeetupLocation,
      currentMeetupTime: currentMeetupTime,
      currentNotes: currentNotes,
      rounds: rounds
          .map((round) => NegotiationRound(
                roundNumber: round['roundNumber'] as int,
                offererId: round['offererId'] as String,
                cashOffer: (round['cashOffer'] as num?)?.toDouble(),
                paymentDirection: round['paymentDirection'] as String?,
                meetupLocation: round['meetupLocation'] as String?,
                meetupTime: round['meetupTime'] != null
                    ? (round['meetupTime'] is Timestamp
                        ? (round['meetupTime'] as Timestamp).toDate()
                        : round['meetupTime'] as DateTime)
                    : null,
                notes: round['notes'] as String?,
                createdAt: round['createdAt'] is Timestamp
                    ? (round['createdAt'] as Timestamp).toDate()
                    : round['createdAt'] as DateTime,
              ))
          .toList(),
      totalMessages: totalMessages,
      agreedAt: agreedAt,
      rejectedAt: rejectedAt,
      rejectionReason: rejectionReason,
      rejectedBy: rejectedBy,
      expiresAt: expiresAt,
      isExpired: isExpired,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActivityAt: lastActivityAt,
    );
  }
}
