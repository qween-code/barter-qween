import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';

/// Implementation of ChatRepository
@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  ) {
    try {
      return remoteDataSource.getConversationsStream(userId).map(
            (conversations) => Right<Failure, List<ConversationEntity>>(
              conversations.map((model) => model.toEntity()).toList(),
            ),
          );
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Unknown error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(
    String conversationId,
  ) async {
    try {
      final conversation = await remoteDataSource.getConversation(conversationId);
      return Right(conversation.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String userId,
    required String otherUserId,
    String? listingId,
  }) async {
    try {
      final conversation = await remoteDataSource.getOrCreateConversation(
        userId: userId,
        otherUserId: otherUserId,
        listingId: listingId,
      );
      return Right(conversation.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = 50,
  }) {
    try {
      return remoteDataSource
          .getMessagesStream(conversationId, limit: limit)
          .map(
            (messages) => Right<Failure, List<MessageEntity>>(
              messages.map((model) => model.toEntity()).toList(),
            ),
          );
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Unknown error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        text: text,
      );
      return Right(message.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadMessageCount(String userId) async {
    try {
      final count = await remoteDataSource.getUnreadMessageCount(userId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: $e'));
    }
  }
}
