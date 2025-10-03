import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/barter_condition_entity.dart';
import '../../entities/item_entity.dart';
import '../../repositories/barter_repository.dart';

/// Get Matching Items Use Case
/// İlan için uygun eşleşmeleri getir
@injectable
class GetMatchingItemsUseCase {
  final BarterRepository repository;

  GetMatchingItemsUseCase(this.repository);

  Future<Either<Failure, List<ItemEntity>>> call(
    BarterConditionEntity condition,
    String currentItemId,
  ) async {
    try {
      // Validation: condition ID boş olmamalı
      if (condition.id.isEmpty) {
        return Left(ValidationFailure('Barter condition ID is required'));
      }

      // Validation: currentItemId boş olmamalı
      if (currentItemId.isEmpty) {
        return Left(ValidationFailure('Current item ID is required'));
      }

      return await repository.getMatchingItems(condition, currentItemId);
    } catch (e) {
      return Left(
          UnknownFailure('Failed to get matching items: ${e.toString()}'));
    }
  }
}

/// Validate Barter Match Use Case
/// İki ilan arasında uyumluluk kontrolü yap
@injectable
class ValidateBarterMatchUseCase {
  final BarterRepository repository;

  ValidateBarterMatchUseCase(this.repository);

  Future<Either<Failure, BarterMatchResult>> call(
    String offeredItemId,
    String requestedItemId,
  ) async {
    try {
      // Validation: Item ID'ler boş olmamalı
      if (offeredItemId.isEmpty || requestedItemId.isEmpty) {
        return Left(ValidationFailure('Both item IDs are required'));
      }

      // Validation: Aynı ilan olamaz
      if (offeredItemId == requestedItemId) {
        return Left(
            ValidationFailure('Cannot validate match with the same item'));
      }

      return await repository.validateBarterMatch(
        offeredItemId,
        requestedItemId,
      );
    } catch (e) {
      return Left(
          UnknownFailure('Failed to validate barter match: ${e.toString()}'));
    }
  }
}

/// Calculate Cash Differential Use Case
/// İki ilan arasındaki para farkını hesapla
@injectable
class CalculateCashDifferentialUseCase {
  final BarterRepository repository;

  CalculateCashDifferentialUseCase(this.repository);

  Future<Either<Failure, double>> call(
    String item1Id,
    String item2Id,
  ) async {
    try {
      // Validation: Item ID'ler boş olmamalı
      if (item1Id.isEmpty || item2Id.isEmpty) {
        return Left(ValidationFailure('Both item IDs are required'));
      }

      // Validation: Aynı ilan olamaz
      if (item1Id == item2Id) {
        return Left(ValidationFailure(
            'Cannot calculate differential for the same item'));
      }

      return await repository.calculateCashDifferential(item1Id, item2Id);
    } catch (e) {
      return Left(UnknownFailure(
          'Failed to calculate cash differential: ${e.toString()}'));
    }
  }
}

/// Suggest Cash Differential Use Case
/// Değer bazlı para farkı önerisi sun
@injectable
class SuggestCashDifferentialUseCase {
  final BarterRepository repository;

  SuggestCashDifferentialUseCase(this.repository);

  Future<Either<Failure, CashDifferentialSuggestion>> call(
    double item1Value,
    double item2Value,
  ) async {
    try {
      // Validation: Değerler pozitif olmalı
      if (item1Value < 0 || item2Value < 0) {
        return Left(ValidationFailure('Item values must be positive'));
      }

      // Validation: Değerler sıfırdan büyük olmalı
      if (item1Value == 0 || item2Value == 0) {
        return Left(ValidationFailure('Item values must be greater than zero'));
      }

      return await repository.suggestCashDifferential(item1Value, item2Value);
    } catch (e) {
      return Left(UnknownFailure(
          'Failed to suggest cash differential: ${e.toString()}'));
    }
  }
}
