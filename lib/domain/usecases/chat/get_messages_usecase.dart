import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';

/// Parameters for getting messages
class GetMessagesParams {
  final String conversationId;
  final int limit;

  GetMessagesParams({
    required this.conversationId,
    this.limit = 50,
  });
}

/// Use case for getting messages in a conversation
@lazySingleton
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  /// Execute the use case - returns stream for real-time updates
  Stream<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return repository.getMessages(
      params.conversationId,
      limit: params.limit,
    );
  }
}
