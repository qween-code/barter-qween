import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/favorite_entity.dart';
import '../entities/item_entity.dart';

abstract class FavoriteRepository {
  /// Add item to favorites
  Future<Either<Failure, FavoriteEntity>> addFavorite(String userId, String itemId);
  
  /// Remove item from favorites
  Future<Either<Failure, void>> removeFavorite(String userId, String itemId);
  
  /// Get user's favorite items
  Future<Either<Failure, List<ItemEntity>>> getFavoriteItems(String userId);
  
  /// Check if item is favorited by user
  Future<Either<Failure, bool>> isFavorite(String userId, String itemId);
  
  /// Get favorite IDs for a user
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId);
}
