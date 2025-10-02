import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/barter_offer_entity.dart';

/// Data model for BarterOffer with Firestore serialization
/// 
/// Extends [BarterOfferEntity] and adds methods for converting
/// to/from Firestore documents
class BarterOfferModel extends BarterOfferEntity {
  const BarterOfferModel({
    required super.id,
    required super.senderId,
    super.senderName,
    super.senderAvatar,
    required super.recipientId,
    super.recipientName,
    super.recipientAvatar,
    required super.offeredItemId,
    super.offeredItemTitle,
    super.offeredItemImage,
    required super.requestedItemId,
    super.requestedItemTitle,
    super.requestedItemImage,
    super.message,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
    super.respondedAt,
  });

  /// Create a BarterOfferModel from a Firestore document
  factory BarterOfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BarterOfferModel(
      id: doc.id,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String?,
      senderAvatar: data['senderAvatar'] as String?,
      recipientId: data['recipientId'] as String,
      recipientName: data['recipientName'] as String?,
      recipientAvatar: data['recipientAvatar'] as String?,
      offeredItemId: data['offeredItemId'] as String,
      offeredItemTitle: data['offeredItemTitle'] as String?,
      offeredItemImage: data['offeredItemImage'] as String?,
      requestedItemId: data['requestedItemId'] as String,
      requestedItemTitle: data['requestedItemTitle'] as String?,
      requestedItemImage: data['requestedItemImage'] as String?,
      message: data['message'] as String?,
      status: OfferStatusExtension.fromValue(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Create a BarterOfferModel from a Map
  factory BarterOfferModel.fromMap(Map<String, dynamic> map, String id) {
    return BarterOfferModel(
      id: id,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String?,
      senderAvatar: map['senderAvatar'] as String?,
      recipientId: map['recipientId'] as String,
      recipientName: map['recipientName'] as String?,
      recipientAvatar: map['recipientAvatar'] as String?,
      offeredItemId: map['offeredItemId'] as String,
      offeredItemTitle: map['offeredItemTitle'] as String?,
      offeredItemImage: map['offeredItemImage'] as String?,
      requestedItemId: map['requestedItemId'] as String,
      requestedItemTitle: map['requestedItemTitle'] as String?,
      requestedItemImage: map['requestedItemImage'] as String?,
      message: map['message'] as String?,
      status: OfferStatusExtension.fromValue(map['status'] as String),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      expiresAt: map['expiresAt'] != null 
          ? (map['expiresAt'] as Timestamp).toDate() 
          : null,
      respondedAt: map['respondedAt'] != null 
          ? (map['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert BarterOfferModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientAvatar': recipientAvatar,
      'offeredItemId': offeredItemId,
      'offeredItemTitle': offeredItemTitle,
      'offeredItemImage': offeredItemImage,
      'requestedItemId': requestedItemId,
      'requestedItemTitle': requestedItemTitle,
      'requestedItemImage': requestedItemImage,
      'message': message,
      'status': status.toValue(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  /// Convert BarterOfferEntity to BarterOfferModel
  factory BarterOfferModel.fromEntity(BarterOfferEntity entity) {
    return BarterOfferModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderAvatar: entity.senderAvatar,
      recipientId: entity.recipientId,
      recipientName: entity.recipientName,
      recipientAvatar: entity.recipientAvatar,
      offeredItemId: entity.offeredItemId,
      offeredItemTitle: entity.offeredItemTitle,
      offeredItemImage: entity.offeredItemImage,
      requestedItemId: entity.requestedItemId,
      requestedItemTitle: entity.requestedItemTitle,
      requestedItemImage: entity.requestedItemImage,
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
      respondedAt: entity.respondedAt,
    );
  }

  /// Convert BarterOfferModel to BarterOfferEntity
  BarterOfferEntity toEntity() {
    return BarterOfferEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      recipientId: recipientId,
      recipientName: recipientName,
      recipientAvatar: recipientAvatar,
      offeredItemId: offeredItemId,
      offeredItemTitle: offeredItemTitle,
      offeredItemImage: offeredItemImage,
      requestedItemId: requestedItemId,
      requestedItemTitle: requestedItemTitle,
      requestedItemImage: requestedItemImage,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt,
    );
  }

  @override
  BarterOfferModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? recipientId,
    String? recipientName,
    String? recipientAvatar,
    String? offeredItemId,
    String? offeredItemTitle,
    String? offeredItemImage,
    String? requestedItemId,
    String? requestedItemTitle,
    String? requestedItemImage,
    String? message,
    OfferStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
  }) {
    return BarterOfferModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientAvatar: recipientAvatar ?? this.recipientAvatar,
      offeredItemId: offeredItemId ?? this.offeredItemId,
      offeredItemTitle: offeredItemTitle ?? this.offeredItemTitle,
      offeredItemImage: offeredItemImage ?? this.offeredItemImage,
      requestedItemId: requestedItemId ?? this.requestedItemId,
      requestedItemTitle: requestedItemTitle ?? this.requestedItemTitle,
      requestedItemImage: requestedItemImage ?? this.requestedItemImage,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
