import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/favorite_repository.dart';

@injectable
class RemoveFavoriteUseCase {
  final FavoriteRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String itemId) async {
    return await repository.removeFavorite(userId, itemId);
  }
}
