import 'package:equatable/equatable.dart';

/// Domain entity representing a conversation between users
class ConversationEntity extends Equatable {
  final String id;
  final List<String> participants; // User IDs
  final String? listingId; // Optional - if conversation is about a specific item
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // userId -> unread count
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    this.listingId,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the other participant's ID (for 1-on-1 conversations)
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
  }

  /// Get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Check if conversation has unread messages for user
  bool hasUnreadMessages(String userId) {
    return getUnreadCountForUser(userId) > 0;
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        listingId,
        lastMessage,
        lastMessageSenderId,
        lastMessageTime,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}
