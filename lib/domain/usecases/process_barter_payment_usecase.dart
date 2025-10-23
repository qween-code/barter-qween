import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/services/enhanced_payment_service.dart';
import '../entities/payment_entity.dart';

/// Barter sistemi için ödeme işleme use case'i
@lazySingleton
class ProcessBarterPaymentUsecase {
  final EnhancedPaymentService _paymentService;

  ProcessBarterPaymentUsecase(this._paymentService);

  /// Barter para farkı ödemesi işle
  Future<Either<Failure, PaymentResult>> call(ProcessBarterPaymentParams params) async {
    try {
      // Validation
      if (params.amount <= 0) {
        return Left(ValidationFailure('Ödeme miktarı 0\'dan büyük olmalıdır'));
      }

      if (params.recipientId.isEmpty) {
        return Left(ValidationFailure('Alıcı ID gerekli'));
      }

      if (params.tradeId.isEmpty) {
        return Left(ValidationFailure('Trade ID gerekli'));
      }

      // Ödeme işlemini başlat
      final result = await _paymentService.processBarterPayment(
        amount: params.amount,
        recipientId: params.recipientId,
        description: params.description ?? 'Barter para farkı ödemesi',
        tradeId: params.tradeId,
        itemId: params.itemId,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Barter ödeme parametreleri
class ProcessBarterPaymentParams {
  final double amount;
  final String recipientId;
  final String tradeId;
  final String? itemId;
  final String? description;

  ProcessBarterPaymentParams({
    required this.amount,
    required this.recipientId,
    required this.tradeId,
    this.itemId,
    this.description,
  });
}