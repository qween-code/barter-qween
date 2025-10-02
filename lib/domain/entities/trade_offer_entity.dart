import 'package:equatable/equatable.dart';

/// Trade Offer Entity representing a barter trade between two users
class TradeOfferEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhotoUrl;
  final String toUserId;
  final String toUserName;
  final String? toUserPhotoUrl;
  final String offeredItemId;
  final String offeredItemTitle;
  final List<String> offeredItemImages;
  final String requestedItemId;
  final String requestedItemTitle;
  final List<String> requestedItemImages;
  final TradeStatus status;
  final String? message;
  final String? responseMessage;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  const TradeOfferEntity({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhotoUrl,
    required this.toUserId,
    required this.toUserName,
    this.toUserPhotoUrl,
    required this.offeredItemId,
    required this.offeredItemTitle,
    required this.offeredItemImages,
    required this.requestedItemId,
    required this.requestedItemTitle,
    required this.requestedItemImages,
    required this.status,
    this.message,
    this.responseMessage,
    required this.createdAt,
    this.respondedAt,
    this.completedAt,
    this.rejectionReason,
  });

  /// Create a copy with modified fields
  TradeOfferEntity copyWith({
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
  }) {
    return TradeOfferEntity(
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
    );
  }

  /// Check if current user is the sender of the offer
  bool isSender(String userId) => fromUserId == userId;

  /// Check if current user is the receiver of the offer
  bool isReceiver(String userId) => toUserId == userId;

  /// Get the other user's ID based on current user
  String getOtherUserId(String currentUserId) {
    return currentUserId == fromUserId ? toUserId : fromUserId;
  }

  /// Get the other user's name based on current user
  String getOtherUserName(String currentUserId) {
    return currentUserId == fromUserId ? toUserName : fromUserName;
  }

  /// Get the other user's photo URL based on current user
  String? getOtherUserPhotoUrl(String currentUserId) {
    return currentUserId == fromUserId ? toUserPhotoUrl : fromUserPhotoUrl;
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        fromUserName,
        fromUserPhotoUrl,
        toUserId,
        toUserName,
        toUserPhotoUrl,
        offeredItemId,
        offeredItemTitle,
        offeredItemImages,
        requestedItemId,
        requestedItemTitle,
        requestedItemImages,
        status,
        message,
        responseMessage,
        createdAt,
        respondedAt,
        completedAt,
        rejectionReason,
      ];
}

/// Trade Status Enum
enum TradeStatus {
  pending,    // Waiting for response
  accepted,   // Offer accepted, trade in progress
  rejected,   // Offer rejected
  completed,  // Trade completed successfully
  cancelled,  // Cancelled by sender
  expired,    // Expired after 7 days of no response
}

/// Extension for TradeStatus display
extension TradeStatusExtension on TradeStatus {
  String get displayName {
    switch (this) {
      case TradeStatus.pending:
        return 'Pending';
      case TradeStatus.accepted:
        return 'Accepted';
      case TradeStatus.rejected:
        return 'Rejected';
      case TradeStatus.completed:
        return 'Completed';
      case TradeStatus.cancelled:
        return 'Cancelled';
      case TradeStatus.expired:
        return 'Expired';
    }
  }

  String get description {
    switch (this) {
      case TradeStatus.pending:
        return 'Waiting for response';
      case TradeStatus.accepted:
        return 'Trade offer accepted';
      case TradeStatus.rejected:
        return 'Trade offer rejected';
      case TradeStatus.completed:
        return 'Trade completed successfully';
      case TradeStatus.cancelled:
        return 'Trade offer cancelled';
      case TradeStatus.expired:
        return 'Trade offer expired';
    }
  }

  bool get isActive => this == TradeStatus.pending || this == TradeStatus.accepted;
  bool get isPending => this == TradeStatus.pending;
  bool get isAccepted => this == TradeStatus.accepted;
  bool get isRejected => this == TradeStatus.rejected;
  bool get isCompleted => this == TradeStatus.completed;
  bool get isCancelled => this == TradeStatus.cancelled;
  bool get isExpired => this == TradeStatus.expired;
}
