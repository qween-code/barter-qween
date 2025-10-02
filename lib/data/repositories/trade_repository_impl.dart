import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/trade_offer_entity.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/remote/trade_remote_datasource.dart';
import '../models/trade_offer_model.dart';

@LazySingleton(as: TradeRepository)
class TradeRepositoryImpl implements TradeRepository {
  final TradeRemoteDataSource remoteDataSource;

  TradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TradeOfferEntity>> sendTradeOffer(TradeOfferEntity offer) async {
    try {
      final model = TradeOfferModel.fromEntity(offer);
      final result = await remoteDataSource.sendTradeOffer(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeOfferEntity>> acceptTradeOffer(
    String offerId,
    String? responseMessage,
  ) async {
    try {
      final result = await remoteDataSource.acceptTradeOffer(offerId, responseMessage);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeOfferEntity>> rejectTradeOffer(
    String offerId,
    String? rejectionReason,
  ) async {
    try {
      final result = await remoteDataSource.rejectTradeOffer(offerId, rejectionReason);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTradeOffer(String offerId) async {
    try {
      await remoteDataSource.cancelTradeOffer(offerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeOfferEntity>> completeTrade(String offerId) async {
    try {
      final result = await remoteDataSource.completeTrade(offerId);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeOfferEntity>> getTradeOffer(String offerId) async {
    try {
      final result = await remoteDataSource.getTradeOffer(offerId);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOfferEntity>>> getUserTradeOffers(String userId) async {
    try {
      final result = await remoteDataSource.getUserTradeOffers(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOfferEntity>>> getSentTradeOffers(String userId) async {
    try {
      final result = await remoteDataSource.getSentTradeOffers(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOfferEntity>>> getReceivedTradeOffers(String userId) async {
    try {
      final result = await remoteDataSource.getReceivedTradeOffers(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOfferEntity>>> getTradeOffersByStatus(
    String userId,
    TradeStatus status,
  ) async {
    try {
      final result = await remoteDataSource.getTradeOffersByStatus(userId, status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOfferEntity>>> getItemTradeHistory(String itemId) async {
    try {
      final result = await remoteDataSource.getItemTradeHistory(itemId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkExistingOffer(
    String fromUserId,
    String offeredItemId,
    String requestedItemId,
  ) async {
    try {
      final result = await remoteDataSource.checkExistingOffer(
        fromUserId,
        offeredItemId,
        requestedItemId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingReceivedCount(String userId) async {
    try {
      final result = await remoteDataSource.getPendingReceivedCount(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
