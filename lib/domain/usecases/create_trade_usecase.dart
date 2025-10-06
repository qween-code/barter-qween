import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/trade_entity.dart';
import '../entities/trade_offer_entity.dart' hide TradeStatus;

/// Use case for creating a confirmed trade from an accepted offer
/// 
/// This is called when both parties have agreed on terms and the trade
/// is ready to move from "offer" stage to "active trade" stage.
@lazySingleton
class CreateTradeUsecase {
  CreateTradeUsecase();

  /// Execute the use case
  /// 
  /// Takes an accepted TradeOffer and creates a Trade entity
  /// with initial status of 'pending' or 'scheduled'
  Future<Either<Failure, TradeEntity>> call(CreateTradeParams params) async {
    try {
      // Validate params
      if (params.offerId.isEmpty) {
        return Left(ValidationFailure('Offer ID is required'));
      }

      // TODO: Implement repository integration when TradeRepository is enhanced
      // For now, create a basic trade entity
      final trade = TradeEntity(
        id: '', // Firestore will generate
        offerId: params.offerId,
        initiatorId: params.initiatorId,
        initiatorItemId: params.initiatorItemId,
        receiverId: params.receiverId,
        receiverItemId: params.receiverItemId,
        status: params.scheduledMeetupTime != null 
            ? TradeStatus.scheduled 
            : TradeStatus.pending,
        cashDifferential: params.cashDifferential,
        paymentDirection: params.paymentDirection,
        paymentMethod: params.paymentMethod,
        meetupLocation: params.meetupLocation,
        meetupAddress: params.meetupAddress,
        meetupLatitude: params.meetupLatitude,
        meetupLongitude: params.meetupLongitude,
        scheduledMeetupTime: params.scheduledMeetupTime,
        meetupNotes: params.meetupNotes,
        agreedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Right(trade);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Parameters for creating a trade
class CreateTradeParams {
  final String offerId; // The accepted offer to convert
  final String initiatorId;
  final String initiatorItemId;
  final String receiverId;
  final String receiverItemId;
  final double? cashDifferential;
  final CashPaymentDirection? paymentDirection;
  final String? paymentMethod;
  final String? meetupLocation;
  final String? meetupAddress;
  final double? meetupLatitude;
  final double? meetupLongitude;
  final DateTime? scheduledMeetupTime;
  final String? meetupNotes;

  CreateTradeParams({
    required this.offerId,
    required this.initiatorId,
    required this.initiatorItemId,
    required this.receiverId,
    required this.receiverItemId,
    this.cashDifferential,
    this.paymentDirection,
    this.paymentMethod,
    this.meetupLocation,
    this.meetupAddress,
    this.meetupLatitude,
    this.meetupLongitude,
    this.scheduledMeetupTime,
    this.meetupNotes,
  });
}
