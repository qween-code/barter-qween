import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/repositories/item_repository.dart';
import '../../../core/error/failures.dart';

@injectable
class GetRecentItemsUseCase {
  final ItemRepository repository;

  GetRecentItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call() async {
    return await repository.getRecentItems();
  }
}