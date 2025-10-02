import 'package:equatable/equatable.dart';

/// Message type enumeration
enum MessageType {
  text,
  image,
  system, // System messages like "Trade accepted"
}

/// Domain entity representing a single message in a conversation
class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl; // For image messages

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.imageUrl,
  });

  /// Check if message is sent by current user
  bool isSentByUser(String userId) {
    return senderId == userId;
  }

  /// Get time ago string (e.g., "2 min ago")
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        text,
        type,
        createdAt,
        isRead,
        imageUrl,
      ];
}
