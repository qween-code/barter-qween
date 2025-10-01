import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

// Create Item Use Case
@injectable
class CreateItemUseCase {
  final ItemRepository repository;

  CreateItemUseCase(this.repository);

  Future<Either<Failure, ItemEntity>> call(ItemEntity item, List<File>? images) async {
    // First upload images if provided
    if (images != null && images.isNotEmpty) {
      final uploadResult = await repository.uploadItemImages(item.id, images);
      
      return uploadResult.fold(
        (failure) => Left(failure),
        (imageUrls) async {
          // Create item with uploaded image URLs
          final itemWithImages = item.copyWith(images: imageUrls);
          return await repository.createItem(itemWithImages);
        },
      );
    }
    
    // Create item without images
    return await repository.createItem(item);
  }
}

// Update Item Use Case
@injectable
class UpdateItemUseCase {
  final ItemRepository repository;

  UpdateItemUseCase(this.repository);

  Future<Either<Failure, ItemEntity>> call(ItemEntity item) async {
    return await repository.updateItem(item);
  }
}

// Delete Item Use Case
@injectable
class DeleteItemUseCase {
  final ItemRepository repository;

  DeleteItemUseCase(this.repository);

  Future<Either<Failure, void>> call(String itemId) async {
    return await repository.deleteItem(itemId);
  }
}

// Get Item Use Case
@injectable
class GetItemUseCase {
  final ItemRepository repository;

  GetItemUseCase(this.repository);

  Future<Either<Failure, ItemEntity>> call(String itemId) async {
    // Increment view count when getting item
    await repository.incrementViewCount(itemId);
    return await repository.getItem(itemId);
  }
}

// Get All Items Use Case
@injectable
class GetAllItemsUseCase {
  final ItemRepository repository;

  GetAllItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call({
    String? category,
    String? city,
    int? limit,
  }) async {
    return await repository.getAllItems(
      category: category,
      city: city,
      limit: limit,
    );
  }
}

// Get User Items Use Case
@injectable
class GetUserItemsUseCase {
  final ItemRepository repository;

  GetUserItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call(String userId) async {
    return await repository.getUserItems(userId);
  }
}

// Search Items Use Case
@injectable
class SearchItemsUseCase {
  final ItemRepository repository;

  SearchItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call(String query) async {
    return await repository.searchItems(query);
  }
}

// Get Featured Items Use Case
@injectable
class GetFeaturedItemsUseCase {
  final ItemRepository repository;

  GetFeaturedItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call({int limit = 10}) async {
    return await repository.getFeaturedItems(limit: limit);
  }
}

// Upload Item Images Use Case
@injectable
class UploadItemImagesUseCase {
  final ItemRepository repository;

  UploadItemImagesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(String itemId, List<File> images) async {
    return await repository.uploadItemImages(itemId, images);
  }
}
