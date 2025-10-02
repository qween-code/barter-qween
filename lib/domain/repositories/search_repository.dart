import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/search/search_filter_entity.dart';
import '../entities/search/search_result_entity.dart';

/// Repository interface for search operations
abstract class SearchRepository {
  /// Search items with query and filters
  /// Returns a stream of search results that updates in real-time
  Stream<Either<Failure, SearchResultEntity>> searchItems({
    required String query,
    required SearchFilterEntity filters,
  });

  /// Get search suggestions based on partial query
  Future<Either<Failure, List<SearchSuggestionEntity>>> getSuggestions({
    required String partialQuery,
  });

  /// Save a search to recent history
  Future<Either<Failure, void>> saveRecentSearch({
    required String query,
    required int resultCount,
  });

  /// Get recent searches for the current user
  Future<Either<Failure, List<RecentSearchEntity>>> getRecentSearches({
    int limit = 10,
  });

  /// Clear recent search history
  Future<Either<Failure, void>> clearRecentSearches();

  /// Delete a specific recent search
  Future<Either<Failure, void>> deleteRecentSearch(String searchId);

  /// Get popular searches globally or by category
  Future<Either<Failure, List<SearchSuggestionEntity>>> getPopularSearches({
    String? category,
    int limit = 10,
  });

  /// Track search analytics (for internal use)
  Future<Either<Failure, void>> trackSearch({
    required String query,
    required int resultCount,
    required Duration searchDuration,
  });
}
