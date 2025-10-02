import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';

/// Parameters for sending a message
class SendMessageParams {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;

  SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
  });
}

/// Use case for sending a message
@lazySingleton
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    // Validate message text
    if (params.text.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure('Message cannot be empty')),
      );
    }

    if (params.text.length > 1000) {
      return Future.value(
        Left(ValidationFailure('Message is too long (max 1000 characters)')),
      );
    }

    return repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      senderName: params.senderName,
      text: params.text.trim(),
    );
  }
}
