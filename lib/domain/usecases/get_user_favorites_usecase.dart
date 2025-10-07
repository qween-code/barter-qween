import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../entities/item_entity.dart';
import '../repositories/favorite_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class GetUserFavoritesUseCase {
  final FavoriteRepository repository;
  final FirebaseAuth auth;

  GetUserFavoritesUseCase(this.repository, this.auth);

  Future<Either<Failure, List<ItemEntity>>> call() async {
    final user = auth.currentUser;
    if (user == null) {
      return Left(AuthFailure('User not authenticated'));
    }
    
    return await repository.getFavoriteItems(user.uid);
  }
}
