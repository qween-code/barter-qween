import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/barter_offer_entity.dart';
import '../../domain/repositories/barter_offer_repository.dart';
import '../datasources/barter_offer_remote_datasource.dart';
import '../models/barter_offer_model.dart';

/// Implementation of [BarterOfferRepository]
/// 
/// Handles all barter offer operations with proper error handling
@LazySingleton(as: BarterOfferRepository)
class BarterOfferRepositoryImpl implements BarterOfferRepository {
  final BarterOfferRemoteDataSource _remoteDataSource;

  BarterOfferRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BarterOfferEntity>> createOffer(
    BarterOfferEntity offer,
  ) async {
    try {
      final offerModel = BarterOfferModel.fromEntity(offer);
      final result = await _remoteDataSource.createOffer(offerModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterOfferEntity>> getOffer(String offerId) async {
    try {
      final result = await _remoteDataSource.getOffer(offerId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterOfferEntity>>> getSentOffers(
    String userId,
  ) async {
    try {
      final results = await _remoteDataSource.getSentOffers(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get sent offers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterOfferEntity>>> getReceivedOffers(
    String userId,
  ) async {
    try {
      final results = await _remoteDataSource.getReceivedOffers(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get received offers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterOfferEntity>>> getOffersForItem(
    String itemId,
  ) async {
    try {
      final results = await _remoteDataSource.getOffersForItem(itemId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get offers for item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterOfferEntity>> acceptOffer(
    String offerId,
  ) async {
    try {
      final result = await _remoteDataSource.acceptOffer(offerId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to accept offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterOfferEntity>> rejectOffer(
    String offerId,
  ) async {
    try {
      final result = await _remoteDataSource.rejectOffer(offerId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to reject offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterOfferEntity>> cancelOffer(
    String offerId,
  ) async {
    try {
      final result = await _remoteDataSource.cancelOffer(offerId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterOfferEntity>> completeOffer(
    String offerId,
  ) async {
    try {
      final result = await _remoteDataSource.completeOffer(offerId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> expireOldOffers() async {
    try {
      final count = await _remoteDataSource.expireOldOffers();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to expire old offers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingOffersCount(String userId) async {
    try {
      final count = await _remoteDataSource.getPendingOffersCount(userId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get pending offers count: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<BarterOfferEntity>>> watchSentOffers(
    String userId,
  ) {
    try {
      return _remoteDataSource.watchSentOffers(userId).map(
            (models) =>
                Right(models.map((model) => model.toEntity()).toList()),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to watch sent offers: ${e.toString()}')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<BarterOfferEntity>>> watchReceivedOffers(
    String userId,
  ) {
    try {
      return _remoteDataSource.watchReceivedOffers(userId).map(
            (models) =>
                Right(models.map((model) => model.toEntity()).toList()),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to watch received offers: ${e.toString()}')),
      );
    }
  }
}
