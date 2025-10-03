import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/notification_entity.dart';
import '../../repositories/notification_repository.dart';

/// Use case to get user notifications
@injectable
class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
