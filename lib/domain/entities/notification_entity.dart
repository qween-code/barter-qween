import 'package:equatable/equatable.dart';

/// Types of notifications in the app
enum NotificationType {
  newTradeOffer,     // New trade offer received
  tradeAccepted,     // Your trade offer was accepted
  tradeRejected,     // Your trade offer was rejected
  tradeCancelled,    // Trade offer was cancelled
  tradeCompleted,    // Trade completed successfully
  newMessage,        // New chat message
  itemSold,          // Your item was marked as sold
  itemLiked,         // Someone liked your item
  followReceived,    // Someone followed you
  newMatch,          // New barter match found (Sprint 3)
  priceDropMatch,    // Price dropped on potential match (Sprint 3)
  system,            // System notification
}

/// Extension for NotificationType
extension NotificationTypeExtension on NotificationType {
  String toValue() {
    switch (this) {
      case NotificationType.newTradeOffer:
        return 'new_trade_offer';
      case NotificationType.tradeAccepted:
        return 'trade_accepted';
      case NotificationType.tradeRejected:
        return 'trade_rejected';
      case NotificationType.tradeCancelled:
        return 'trade_cancelled';
      case NotificationType.tradeCompleted:
        return 'trade_completed';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.itemSold:
        return 'item_sold';
      case NotificationType.itemLiked:
        return 'item_liked';
      case NotificationType.followReceived:
        return 'follow_received';
      case NotificationType.newMatch:
        return 'new_match';
      case NotificationType.priceDropMatch:
        return 'price_drop_match';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromValue(String value) {
    switch (value) {
      case 'new_trade_offer':
        return NotificationType.newTradeOffer;
      case 'trade_accepted':
        return NotificationType.tradeAccepted;
      case 'trade_rejected':
        return NotificationType.tradeRejected;
      case 'trade_cancelled':
        return NotificationType.tradeCancelled;
      case 'trade_completed':
        return NotificationType.tradeCompleted;
      case 'new_message':
        return NotificationType.newMessage;
      case 'item_sold':
        return NotificationType.itemSold;
      case 'item_liked':
        return NotificationType.itemLiked;
      case 'follow_received':
        return NotificationType.followReceived;
      case 'new_match':
        return NotificationType.newMatch;
      case 'price_drop_match':
        return NotificationType.priceDropMatch;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  String get displayTitle {
    switch (this) {
      case NotificationType.newTradeOffer:
        return 'New Trade Offer';
      case NotificationType.tradeAccepted:
        return 'Trade Accepted';
      case NotificationType.tradeRejected:
        return 'Trade Rejected';
      case NotificationType.tradeCancelled:
        return 'Trade Cancelled';
      case NotificationType.tradeCompleted:
        return 'Trade Completed';
      case NotificationType.newMessage:
        return 'New Message';
      case NotificationType.itemSold:
        return 'Item Sold';
      case NotificationType.itemLiked:
        return 'Item Liked';
      case NotificationType.followReceived:
        return 'New Follower';
      case NotificationType.newMatch:
        return 'Yeni Eşleşme';
      case NotificationType.priceDropMatch:
        return 'Fiyat Düştü';
      case NotificationType.system:
        return 'System Notification';
    }
  }
}

/// Represents a notification entity
class NotificationEntity extends Equatable {
  /// Unique identifier for the notification
  final String id;

  /// User ID who will receive the notification
  final String userId;

  /// Type of notification
  final NotificationType type;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Optional image URL
  final String? imageUrl;

  /// Whether the notification has been read
  final bool isRead;

  /// Related entity ID (e.g., tradeId, itemId, messageId)
  final String? relatedEntityId;

  /// Additional data as JSON string
  final Map<String, dynamic>? data;

  /// When the notification was created
  final DateTime createdAt;

  /// When the notification was read (if read)
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.isRead,
    this.relatedEntityId,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  /// Copy with method
  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    bool? isRead,
    String? relatedEntityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Mark as read
  NotificationEntity markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        imageUrl,
        isRead,
        relatedEntityId,
        data,
        createdAt,
        readAt,
      ];

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}
