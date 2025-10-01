import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/item_entity.dart';
import '../../core/error/failures.dart';

abstract class ItemRepository {
  /// Create a new item
  Future<Either<Failure, ItemEntity>> createItem(ItemEntity item);

  /// Update an existing item
  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item);

  /// Delete an item
  Future<Either<Failure, void>> deleteItem(String itemId);

  /// Get a single item by ID
  Future<Either<Failure, ItemEntity>> getItem(String itemId);

  /// Get all items (with optional filters)
  Future<Either<Failure, List<ItemEntity>>> getAllItems({
    String? category,
    String? city,
    int? limit,
  });

  /// Get items by owner ID
  Future<Either<Failure, List<ItemEntity>>> getUserItems(String userId);

  /// Upload item images
  Future<Either<Failure, List<String>>> uploadItemImages(
    String itemId,
    List<File> images,
  );

  /// Delete item image
  Future<Either<Failure, void>> deleteItemImage(String imageUrl);

  /// Search items
  Future<Either<Failure, List<ItemEntity>>> searchItems(String query);

  /// Increment view count
  Future<Either<Failure, void>> incrementViewCount(String itemId);

  /// Get featured items
  Future<Either<Failure, List<ItemEntity>>> getFeaturedItems({int limit = 10});
}
