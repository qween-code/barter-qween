import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/conversation_entity.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';

/// Parameters for getting or creating a conversation
class GetOrCreateConversationParams {
  final String userId;
  final String otherUserId;
  final String? listingId;

  GetOrCreateConversationParams({
    required this.userId,
    required this.otherUserId,
    this.listingId,
  });
}

/// Use case for getting or creating a conversation between two users
@lazySingleton
class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, ConversationEntity>> call(
    GetOrCreateConversationParams params,
  ) {
    // Validate user IDs
    if (params.userId == params.otherUserId) {
      return Future.value(
        Left(ValidationFailure('Cannot create conversation with yourself')),
      );
    }

    return repository.getOrCreateConversation(
      userId: params.userId,
      otherUserId: params.otherUserId,
      listingId: params.listingId,
    );
  }
}
