import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';
import '../../core/error/failures.dart';

@injectable
class GetItemUsecase {
  final ItemRepository _repository;

  GetItemUsecase(this._repository);

  Future<Either<Failure, ItemEntity>> call(GetItemParams params) async {
    return await _repository.getItem(params.itemId);
  }
}

class GetItemParams {
  final String itemId;

  GetItemParams({required this.itemId});
}
