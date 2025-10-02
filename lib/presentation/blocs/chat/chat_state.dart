import 'package:equatable/equatable.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/message_entity.dart';

/// Base class for all chat states
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Conversations loaded successfully
class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;
  final int totalUnreadCount;

  const ConversationsLoaded({
    required this.conversations,
    this.totalUnreadCount = 0,
  });

  @override
  List<Object?> get props => [conversations, totalUnreadCount];
}

/// Single conversation loaded successfully
class ConversationLoaded extends ChatState {
  final ConversationEntity conversation;

  const ConversationLoaded(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

/// Messages loaded for a conversation
class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<MessageEntity> messages;
  final ConversationEntity? conversation;

  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.conversation,
  });

  @override
  List<Object?> get props => [conversationId, messages, conversation];
}

/// Message sent successfully
class MessageSent extends ChatState {
  final MessageEntity message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Messages marked as read
class MessagesMarkedAsRead extends ChatState {
  final String conversationId;

  const MessagesMarkedAsRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Conversation created/retrieved successfully
class ConversationRetrieved extends ChatState {
  final ConversationEntity conversation;

  const ConversationRetrieved(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

/// Conversation deleted successfully
class ConversationDeleted extends ChatState {
  final String conversationId;

  const ConversationDeleted(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Unread count retrieved
class UnreadCountRetrieved extends ChatState {
  final int count;

  const UnreadCountRetrieved(this.count);

  @override
  List<Object?> get props => [count];
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sending message (optimistic update)
class SendingMessage extends ChatState {
  final String conversationId;
  final String text;

  const SendingMessage({
    required this.conversationId,
    required this.text,
  });

  @override
  List<Object?> get props => [conversationId, text];
}
