import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/barter_match_entity.dart';
import 'calculate_match_score_usecase.dart';

/// Use case for finding potential barter matches for an item
///
/// Uses multi-factor scoring algorithm to find the best matches:
/// - Category compatibility (30%)
/// - Price similarity (25%)
/// - Location proximity (20%)
/// - User trust score (15%)
/// - Item condition match (10%)
@lazySingleton
class FindBarterMatchesUsecase {
  final CalculateMatchScoreUsecase calculateScoreUsecase;

  FindBarterMatchesUsecase(this.calculateScoreUsecase);

  /// Execute the use case
  ///
  /// Finds potential matches for the given item, scores them,
  /// and returns them sorted by match quality
  Future<Either<Failure, List<BarterMatchEntity>>> call(
    FindMatchesParams params,
  ) async {
    try {
      // Validate params
      if (params.itemId.isEmpty) {
        return Left(ValidationFailure('Item ID is required'));
      }

      // TODO: Get the source item from repository
      // For now, return placeholder
      // This will be implemented when repository integration is complete

      return Left(
        ServerFailure('Not implemented: Repository integration pending'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Parameters for finding matches
class FindMatchesParams {
  final String itemId; // Source item to find matches for
  final int limit; // Maximum number of matches to return
  final double minScore; // Minimum match score (0-100)

  FindMatchesParams({
    required this.itemId,
    this.limit = 20,
    this.minScore = 50.0,
  });
}
