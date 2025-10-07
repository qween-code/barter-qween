import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../repositories/favorite_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class ToggleFavoriteUseCase {
  final FavoriteRepository repository;
  final FirebaseAuth auth;

  ToggleFavoriteUseCase(this.repository, this.auth);

  Future<Either<Failure, void>> call(String itemId) async {
    final user = auth.currentUser;
    if (user == null) {
      return Left(AuthFailure('User not authenticated'));
    }
    
    // Check if already favorited
    final isFavResult = await repository.isFavorite(user.uid, itemId);
    
    return isFavResult.fold(
      (failure) => Left(failure),
      (isFavorite) async {
        if (isFavorite) {
          // Remove from favorites
          return await repository.removeFavorite(user.uid, itemId);
        } else {
          // Add to favorites
          final result = await repository.addFavorite(user.uid, itemId);
          return result.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }
      },
    );
  }
}
