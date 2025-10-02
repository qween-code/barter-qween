import 'package:equatable/equatable.dart';

/// Base class for all chat events
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load all conversations for current user
class LoadConversations extends ChatEvent {
  final String userId;

  const LoadConversations(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load a specific conversation by ID
class LoadConversation extends ChatEvent {
  final String conversationId;

  const LoadConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Load messages for a specific conversation
class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Send a text message
class SendMessage extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;

  const SendMessage({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
  });

  @override
  List<Object?> get props => [conversationId, senderId, senderName, text];
}

/// Mark messages as read
class MarkMessagesAsRead extends ChatEvent {
  final String conversationId;
  final String userId;

  const MarkMessagesAsRead({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}

/// Get or create conversation
class GetOrCreateConversation extends ChatEvent {
  final String userId;
  final String otherUserId;
  final String? listingId;

  const GetOrCreateConversation({
    required this.userId,
    required this.otherUserId,
    this.listingId,
  });

  @override
  List<Object?> get props => [userId, otherUserId, listingId];
}

/// Delete a conversation
class DeleteConversation extends ChatEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Get unread message count
class GetUnreadCount extends ChatEvent {
  final String userId;

  const GetUnreadCount(this.userId);

  @override
  List<Object?> get props => [userId];
}
