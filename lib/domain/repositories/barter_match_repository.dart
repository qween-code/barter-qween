import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/barter_match_entity.dart';

/// Repository interface for barter match operations
abstract class BarterMatchRepository {
  /// Find matches for an item
  Future<Either<Failure, List<BarterMatchEntity>>> findMatches(
    String itemId, {
    int limit = 20,
  });

  /// Get a specific match by ID
  Future<Either<Failure, BarterMatchEntity>> getMatch(String matchId);

  /// Create a new match
  Future<Either<Failure, BarterMatchEntity>> createMatch(
    BarterMatchEntity match,
  );

  /// Update match status (seen/dismissed)
  Future<Either<Failure, BarterMatchEntity>> updateMatchStatus(
    String matchId,
    bool isSeen,
    bool isDismissed,
  );

  /// Increment view count
  Future<Either<Failure, void>> incrementViewCount(String matchId);

  /// Mark match as offered
  Future<Either<Failure, void>> markAsOffered(String matchId, String offerId);

  /// Get high quality matches (score >= 80)
  Future<Either<Failure, List<BarterMatchEntity>>> getHighQualityMatches(
    String itemId,
  );

  /// Delete a match
  Future<Either<Failure, void>> deleteMatch(String matchId);

  /// Get barter matches for an item
  Future<Either<Failure, List<BarterMatchEntity>>> getBarterMatches(
    String itemId,
  );

  /// Dismiss a barter match
  Future<Either<Failure, void>> dismissBarterMatch(String matchId);
}
