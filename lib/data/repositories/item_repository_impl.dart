import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/remote/item_remote_datasource.dart';
import '../models/item_model.dart';

@LazySingleton(as: ItemRepository)
class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ItemEntity>> createItem(ItemEntity item) async {
    try {
      final itemModel = ItemModel.fromEntity(item);
      final result = await remoteDataSource.createItem(itemModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item) async {
    try {
      final itemModel = ItemModel.fromEntity(item);
      final result = await remoteDataSource.updateItem(itemModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItem(String itemId) async {
    try {
      final result = await remoteDataSource.getItem(itemId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getAllItems({
    String? category,
    String? city,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getAllItems(
        category: category,
        city: city,
        limit: limit,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getUserItems(String userId) async {
    try {
      final result = await remoteDataSource.getUserItems(userId);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadItemImages(
    String itemId,
    List<File> images,
  ) async {
    try {
      final result = await remoteDataSource.uploadImages(itemId, images);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItemImage(String imageUrl) async {
    try {
      await remoteDataSource.deleteImage(imageUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> searchItems(String query) async {
    try {
      final result = await remoteDataSource.searchItems(query);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String itemId) async {
    try {
      await remoteDataSource.incrementViewCount(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getFeaturedItems({int limit = 10}) async {
    try {
      final result = await remoteDataSource.getFeaturedItems(limit: limit);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
