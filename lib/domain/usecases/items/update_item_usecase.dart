import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

/// Use case for updating an existing item
@lazySingleton
class UpdateItemUseCase {
  final ItemRepository repository;

  UpdateItemUseCase(this.repository);

  /// Execute the use case
  ///
  /// Updates an item with new data.
  /// Returns an Either with a Failure on error or the updated item on success.
  Future<Either<Failure, ItemEntity>> call(ItemEntity item) async {
    try {
      return await repository.updateItem(item);
    } catch (e) {
      return Left(UnknownFailure('Failed to update item: ${e.toString()}'));
    }
  }
}
