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

  Future<Either<Failure, ItemEntity>> call(ItemEntity item, [List<File>? newImages]) async {
    // First upload new images if provided
    if (newImages != null && newImages.isNotEmpty) {
      final uploadResult = await repository.uploadItemImages(item.id, newImages);
      
      return uploadResult.fold(
        (failure) => Left(failure),
        (newImageUrls) async {
          // Combine existing images with new uploaded image URLs
          final allImages = [...item.images, ...newImageUrls];
          final itemWithImages = item.copyWith(images: allImages);
          return await repository.updateItem(itemWithImages);
        },
      );
    }
    
    // Update item without new images
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
    // TODO: View count should be handled by Cloud Functions to avoid permission issues
    // Increment view count when getting item (silently fail if permission denied)
    try {
      await repository.incrementViewCount(itemId);
    } catch (e) {
      // Ignore permission errors - view count is not critical
    }
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
