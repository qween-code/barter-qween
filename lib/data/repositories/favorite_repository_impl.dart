import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/remote/favorite_remote_datasource.dart';

@LazySingleton(as: FavoriteRepository)
class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FavoriteEntity>> addFavorite(String userId, String itemId) async {
    try {
      final favorite = await remoteDataSource.addFavorite(userId, itemId);
      return Right(favorite.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String userId, String itemId) async {
    try {
      await remoteDataSource.removeFavorite(userId, itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getFavoriteItems(String userId) async {
    try {
      final items = await remoteDataSource.getFavoriteItems(userId);
      return Right(items.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String userId, String itemId) async {
    try {
      final result = await remoteDataSource.isFavorite(userId, itemId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId) async {
    try {
      final ids = await remoteDataSource.getFavoriteIds(userId);
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
