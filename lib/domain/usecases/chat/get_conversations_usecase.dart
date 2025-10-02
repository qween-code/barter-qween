import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/conversation_entity.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';

/// Use case for getting all conversations for a user
@lazySingleton
class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  /// Execute the use case - returns stream for real-time updates
  Stream<Either<Failure, List<ConversationEntity>>> call(String userId) {
    return repository.getConversations(userId);
  }
}
