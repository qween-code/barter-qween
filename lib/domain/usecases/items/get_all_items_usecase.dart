import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

@lazySingleton
class GetAllItemsUseCase implements UseCase<List<ItemEntity>, NoParams> {
  final ItemRepository repository;

  GetAllItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(NoParams params) async {
    return await repository.getAllItems();
  }
}
