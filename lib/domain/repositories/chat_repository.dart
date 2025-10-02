import 'package:dartz/dartz.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';
import '../../core/error/failures.dart';

/// Repository interface for chat functionality
abstract class ChatRepository {
  /// Get all conversations for current user as a stream (real-time updates)
  Stream<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  );

  /// Get a specific conversation by ID
  Future<Either<Failure, ConversationEntity>> getConversation(
    String conversationId,
  );

  /// Get or create a conversation between two users
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String userId,
    required String otherUserId,
    String? listingId,
  });

  /// Get messages for a conversation as a stream (real-time updates)
  Stream<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = 50,
  });

  /// Send a text message
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  });

  /// Mark messages as read for a user
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Get unread message count for user
  Future<Either<Failure, int>> getUnreadMessageCount(String userId);
}
