import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

/// Use case for getting items owned by a specific user
@lazySingleton
class GetUserItemsUseCase {
  final ItemRepository repository;

  GetUserItemsUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets all items belonging to a specific user
  /// Returns Either<Failure, List<ItemEntity>>
  Future<Either<Failure, List<ItemEntity>>> call(String userId) async {
    try {
      return await repository.getUserItems(userId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get user items: ${e.toString()}'));
    }
  }
}
