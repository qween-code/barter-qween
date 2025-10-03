import 'package:dartz/dartz.dart';
import '../entities/barter_condition_entity.dart';
import '../entities/item_entity.dart';
import '../../core/error/failures.dart';

abstract class BarterRepository {
  /// Barter şartına uygun ilanları getir
  Future<Either<Failure, List<ItemEntity>>> getMatchingItems(
    BarterConditionEntity condition,
    String currentItemId,
  );

  /// İki ilan arasında barter uyumunu kontrol et
  Future<Either<Failure, BarterMatchResult>> validateBarterMatch(
    String offeredItemId,
    String requestedItemId,
  );

  /// Para farkını hesapla
  Future<Either<Failure, double>> calculateCashDifferential(
    String item1Id,
    String item2Id,
  );

  /// Önerilen para farkını hesapla (değer bazlı)
  Future<Either<Failure, CashDifferentialSuggestion>> suggestCashDifferential(
    double item1Value,
    double item2Value,
  );
}

/// Barter eşleşme sonucu
class BarterMatchResult {
  final bool isMatch;
  final double compatibilityScore; // 0-100
  final String? reason;
  final double? suggestedCashDifferential;
  final CashPaymentDirection? suggestedPaymentDirection;

  const BarterMatchResult({
    required this.isMatch,
    required this.compatibilityScore,
    this.reason,
    this.suggestedCashDifferential,
    this.suggestedPaymentDirection,
  });

  @override
  String toString() {
    return 'BarterMatchResult(isMatch: $isMatch, score: $compatibilityScore)';
  }
}

/// Para farkı önerisi
class CashDifferentialSuggestion {
  final double amount;
  final CashPaymentDirection direction;
  final String reason;

  const CashDifferentialSuggestion({
    required this.amount,
    required this.direction,
    required this.reason,
  });

  @override
  String toString() {
    return 'CashSuggestion(amount: $amount, direction: $direction)';
  }
}
