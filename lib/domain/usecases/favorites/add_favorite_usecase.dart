import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/favorite_entity.dart';
import '../../repositories/favorite_repository.dart';

@injectable
class AddFavoriteUseCase {
  final FavoriteRepository repository;

  AddFavoriteUseCase(this.repository);

  Future<Either<Failure, FavoriteEntity>> call(String userId, String itemId) async {
    return await repository.addFavorite(userId, itemId);
  }
}
