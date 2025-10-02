import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/item_entity.dart';
import '../../repositories/favorite_repository.dart';

@injectable
class GetFavoriteItemsUseCase {
  final FavoriteRepository repository;

  GetFavoriteItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call(String userId) async {
    return await repository.getFavoriteItems(userId);
  }
}
