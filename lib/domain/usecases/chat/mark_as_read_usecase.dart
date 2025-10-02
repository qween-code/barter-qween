import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';

/// Parameters for marking messages as read
class MarkAsReadParams {
  final String conversationId;
  final String userId;

  MarkAsReadParams({
    required this.conversationId,
    required this.userId,
  });
}

/// Use case for marking messages as read
@lazySingleton
class MarkAsReadUseCase {
  final ChatRepository repository;

  MarkAsReadUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return repository.markMessagesAsRead(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}
