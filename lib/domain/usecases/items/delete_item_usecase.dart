import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/item_repository.dart';

/// Use case for deleting an item (soft delete - status update)
@lazySingleton
class DeleteItemUseCase {
  final ItemRepository repository;

  DeleteItemUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Soft deletes an item by updating its status to 'deleted'
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> call(String itemId) async {
    try {
      return await repository.deleteItem(itemId);
    } catch (e) {
      return Left(UnknownFailure('Failed to delete item: ${e.toString()}'));
    }
  }
}
