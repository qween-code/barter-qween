import 'package:equatable/equatable.dart';

/// Represents the status of a barter offer
enum OfferStatus {
  pending,   // Offer sent, waiting for response
  accepted,  // Offer accepted by recipient
  rejected,  // Offer rejected by recipient
  cancelled, // Offer cancelled by sender
  expired,   // Offer expired (24 hours passed)
  completed, // Barter completed
}

/// Extension for OfferStatus enum to/from string conversion
extension OfferStatusExtension on OfferStatus {
  String toValue() {
    switch (this) {
      case OfferStatus.pending:
        return 'pending';
      case OfferStatus.accepted:
        return 'accepted';
      case OfferStatus.rejected:
        return 'rejected';
      case OfferStatus.cancelled:
        return 'cancelled';
      case OfferStatus.expired:
        return 'expired';
      case OfferStatus.completed:
        return 'completed';
    }
  }

  static OfferStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OfferStatus.pending;
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
        return OfferStatus.rejected;
      case 'cancelled':
        return OfferStatus.cancelled;
      case 'expired':
        return OfferStatus.expired;
      case 'completed':
        return OfferStatus.completed;
      default:
        return OfferStatus.pending;
    }
  }
}

/// Represents a barter offer between two users
/// 
/// This entity contains all information about a barter offer including:
/// - Sender and recipient information
/// - Items being offered and requested
/// - Offer status and timestamps
/// - Optional message from sender
class BarterOfferEntity extends Equatable {
  /// Unique identifier for the offer
  final String id;

  /// ID of the user sending the offer
  final String senderId;

  /// Display name of the sender
  final String? senderName;

  /// Avatar URL of the sender
  final String? senderAvatar;

  /// ID of the user receiving the offer
  final String recipientId;

  /// Display name of the recipient
  final String? recipientName;

  /// Avatar URL of the recipient
  final String? recipientAvatar;

  /// ID of the item being offered by sender
  final String offeredItemId;

  /// Title of the offered item
  final String? offeredItemTitle;

  /// Primary image URL of the offered item
  final String? offeredItemImage;

  /// ID of the item being requested from recipient
  final String requestedItemId;

  /// Title of the requested item
  final String? requestedItemTitle;

  /// Primary image URL of the requested item
  final String? requestedItemImage;

  /// Optional message from sender explaining the offer
  final String? message;

  /// Current status of the offer
  final OfferStatus status;

  /// When the offer was created
  final DateTime createdAt;

  /// When the offer was last updated
  final DateTime updatedAt;

  /// When the offer expires (24 hours from creation)
  final DateTime? expiresAt;

  /// When the offer was responded to (accepted/rejected)
  final DateTime? respondedAt;

  const BarterOfferEntity({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.recipientId,
    this.recipientName,
    this.recipientAvatar,
    required this.offeredItemId,
    this.offeredItemTitle,
    this.offeredItemImage,
    required this.requestedItemId,
    this.requestedItemTitle,
    this.requestedItemImage,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.respondedAt,
  });

  /// Check if the offer is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if the offer is pending
  bool get isPending => status == OfferStatus.pending;

  /// Check if the offer is accepted
  bool get isAccepted => status == OfferStatus.accepted;

  /// Check if the offer is rejected
  bool get isRejected => status == OfferStatus.rejected;

  /// Check if the offer is cancelled
  bool get isCancelled => status == OfferStatus.cancelled;

  /// Check if the offer is completed
  bool get isCompleted => status == OfferStatus.completed;

  /// Check if the offer can be cancelled (only pending offers)
  bool get canCancel => status == OfferStatus.pending && !isExpired;

  /// Check if the offer can be accepted/rejected (only pending, not expired)
  bool get canRespond => status == OfferStatus.pending && !isExpired;

  /// Copy with method for immutability
  BarterOfferEntity copyWith({
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
    return BarterOfferEntity(
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

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderAvatar,
        recipientId,
        recipientName,
        recipientAvatar,
        offeredItemId,
        offeredItemTitle,
        offeredItemImage,
        requestedItemId,
        requestedItemTitle,
        requestedItemImage,
        message,
        status,
        createdAt,
        updatedAt,
        expiresAt,
        respondedAt,
      ];

  @override
  String toString() {
    return 'BarterOfferEntity(id: $id, sender: $senderId -> recipient: $recipientId, status: $status, offered: $offeredItemId, requested: $requestedItemId)';
  }
}
