import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';
import '../../core/error/failures.dart';

@injectable
class SearchItemsUseCase {
  final ItemRepository _itemRepository;

  SearchItemsUseCase(this._itemRepository);

  Future<Either<Failure, List<ItemEntity>>> call(String query) async {
    return await _itemRepository.searchItems(query);
  }
}
