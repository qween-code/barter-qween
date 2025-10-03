import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trade_offer_entity.dart';

/// Trade Offer Model for data layer
class TradeOfferModel extends TradeOfferEntity {
  const TradeOfferModel({
    required super.id,
    required super.fromUserId,
    required super.fromUserName,
    super.fromUserPhotoUrl,
    required super.toUserId,
    required super.toUserName,
    super.toUserPhotoUrl,
    required super.offeredItemId,
    required super.offeredItemTitle,
    required super.offeredItemImages,
    required super.requestedItemId,
    required super.requestedItemTitle,
    required super.requestedItemImages,
    required super.status,
    super.message,
    super.responseMessage,
    required super.createdAt,
    super.respondedAt,
    super.completedAt,
    super.rejectionReason,
  });

  /// Create from Entity
  factory TradeOfferModel.fromEntity(TradeOfferEntity entity) {
    return TradeOfferModel(
      id: entity.id,
      fromUserId: entity.fromUserId,
      fromUserName: entity.fromUserName,
      fromUserPhotoUrl: entity.fromUserPhotoUrl,
      toUserId: entity.toUserId,
      toUserName: entity.toUserName,
      toUserPhotoUrl: entity.toUserPhotoUrl,
      offeredItemId: entity.offeredItemId,
      offeredItemTitle: entity.offeredItemTitle,
      offeredItemImages: entity.offeredItemImages,
      requestedItemId: entity.requestedItemId,
      requestedItemTitle: entity.requestedItemTitle,
      requestedItemImages: entity.requestedItemImages,
      status: entity.status,
      message: entity.message,
      responseMessage: entity.responseMessage,
      createdAt: entity.createdAt,
      respondedAt: entity.respondedAt,
      completedAt: entity.completedAt,
      rejectionReason: entity.rejectionReason,
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory TradeOfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeOfferModel(
      id: doc.id,
      fromUserId: data['fromUserId'] as String,
      fromUserName: data['fromUserName'] as String,
      fromUserPhotoUrl: data['fromUserPhotoUrl'] as String?,
      toUserId: data['toUserId'] as String,
      toUserName: data['toUserName'] as String,
      toUserPhotoUrl: data['toUserPhotoUrl'] as String?,
      offeredItemId: data['offeredItemId'] as String,
      offeredItemTitle: data['offeredItemTitle'] as String,
      offeredItemImages: List<String>.from(data['offeredItemImages'] as List),
      requestedItemId: data['requestedItemId'] as String,
      requestedItemTitle: data['requestedItemTitle'] as String,
      requestedItemImages: List<String>.from(data['requestedItemImages'] as List),
      status: _statusFromString(data['status'] as String),
      message: data['message'] as String?,
      responseMessage: data['responseMessage'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  /// Create from JSON
  factory TradeOfferModel.fromJson(Map<String, dynamic> json) {
    return TradeOfferModel(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserPhotoUrl: json['fromUserPhotoUrl'] as String?,
      toUserId: json['toUserId'] as String,
      toUserName: json['toUserName'] as String,
      toUserPhotoUrl: json['toUserPhotoUrl'] as String?,
      offeredItemId: json['offeredItemId'] as String,
      offeredItemTitle: json['offeredItemTitle'] as String,
      offeredItemImages: List<String>.from(json['offeredItemImages'] as List),
      requestedItemId: json['requestedItemId'] as String,
      requestedItemTitle: json['requestedItemTitle'] as String,
      requestedItemImages: List<String>.from(json['requestedItemImages'] as List),
      status: _statusFromString(json['status'] as String),
      message: json['message'] as String?,
      responseMessage: json['responseMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'toUserPhotoUrl': toUserPhotoUrl,
      'offeredItemId': offeredItemId,
      'offeredItemTitle': offeredItemTitle,
      'offeredItemImages': offeredItemImages,
      'requestedItemId': requestedItemId,
      'requestedItemTitle': requestedItemTitle,
      'requestedItemImages': requestedItemImages,
      'status': _statusToString(status),
      'message': message,
      'responseMessage': responseMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'toUserPhotoUrl': toUserPhotoUrl,
      'offeredItemId': offeredItemId,
      'offeredItemTitle': offeredItemTitle,
      'offeredItemImages': offeredItemImages,
      'requestedItemId': requestedItemId,
      'requestedItemTitle': requestedItemTitle,
      'requestedItemImages': requestedItemImages,
      'status': _statusToString(status),
      'message': message,
      'responseMessage': responseMessage,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  /// Convert TradeStatus to String
  static String _statusToString(TradeStatus status) {
    switch (status) {
      case TradeStatus.pending:
        return 'pending';
      case TradeStatus.accepted:
        return 'accepted';
      case TradeStatus.rejected:
        return 'rejected';
      case TradeStatus.completed:
        return 'completed';
      case TradeStatus.cancelled:
        return 'cancelled';
      case TradeStatus.expired:
        return 'expired';
    }
  }

  /// Convert String to TradeStatus
  static TradeStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return TradeStatus.pending;
      case 'accepted':
        return TradeStatus.accepted;
      case 'rejected':
        return TradeStatus.rejected;
      case 'completed':
        return TradeStatus.completed;
      case 'cancelled':
        return TradeStatus.cancelled;
      case 'expired':
        return TradeStatus.expired;
      default:
        return TradeStatus.pending;
    }
  }

  /// Copy with method
  @override
  TradeOfferModel copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserPhotoUrl,
    String? toUserId,
    String? toUserName,
    String? toUserPhotoUrl,
    String? offeredItemId,
    String? offeredItemTitle,
    List<String>? offeredItemImages,
    String? requestedItemId,
    String? requestedItemTitle,
    List<String>? requestedItemImages,
    TradeStatus? status,
    String? message,
    String? responseMessage,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? completedAt,
    String? rejectionReason,
    double? cashDifferential,
    CashPaymentDirection? paymentDirection,
    String? conditionNotes,
    bool? meetsBarterCondition,
    double? offeredItemValue,
    double? requestedItemValue,
  }) {
    return TradeOfferModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserPhotoUrl: fromUserPhotoUrl ?? this.fromUserPhotoUrl,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      toUserPhotoUrl: toUserPhotoUrl ?? this.toUserPhotoUrl,
      offeredItemId: offeredItemId ?? this.offeredItemId,
      offeredItemTitle: offeredItemTitle ?? this.offeredItemTitle,
      offeredItemImages: offeredItemImages ?? this.offeredItemImages,
      requestedItemId: requestedItemId ?? this.requestedItemId,
      requestedItemTitle: requestedItemTitle ?? this.requestedItemTitle,
      requestedItemImages: requestedItemImages ?? this.requestedItemImages,
      status: status ?? this.status,
      message: message ?? this.message,
      responseMessage: responseMessage ?? this.responseMessage,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cashDifferential: cashDifferential ?? this.cashDifferential,
      paymentDirection: paymentDirection ?? this.paymentDirection,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      meetsBarterCondition: meetsBarterCondition ?? this.meetsBarterCondition,
      offeredItemValue: offeredItemValue ?? this.offeredItemValue,
      requestedItemValue: requestedItemValue ?? this.requestedItemValue,
    );
  }
}
