import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/search/search_filter_entity.dart';
import '../../domain/entities/search/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_data_source.dart';
import '../datasources/search_remote_data_source.dart';

/// Implementation of SearchRepository
@Injectable(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<Either<Failure, SearchResultEntity>> searchItems({
    required String query,
    required SearchFilterEntity filters,
  }) async* {
    try {
      final startTime = DateTime.now();
      
      await for (final items in remoteDataSource.searchItems(
        query: query,
        filters: filters,
      )) {
        final duration = DateTime.now().difference(startTime);
        
        final metadata = SearchMetadata(
          query: query,
          resultsCount: items.length,
          searchDuration: duration,
          timestamp: DateTime.now(),
        );
        
        // Convert ItemModel list to ItemEntity list
        final itemEntities = items.map((model) => model.toEntity()).toList();
        
        final result = SearchResultEntity(
          items: itemEntities,
          totalCount: itemEntities.length,
          hasMore: itemEntities.length >= filters.limit,
          metadata: metadata,
        );
        
        yield Right(result);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchSuggestionEntity>>> getSuggestions({
    required String partialQuery,
  }) async {
    try {
      // For now, return recent searches as suggestions
      final recent = await localDataSource.getRecentSearches();
      final suggestions = recent
          .where((s) =>
              s.query.toLowerCase().contains(partialQuery.toLowerCase()))
          .map((s) => SearchSuggestionEntity(
                suggestion: s.query,
                type: SuggestionType.recentSearch,
                popularity: s.resultCount,
              ))
          .toList();
      
      return Right(suggestions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecentSearch({
    required String query,
    required int resultCount,
  }) async {
    try {
      await localDataSource.saveRecentSearch(
        query: query,
        resultCount: resultCount,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentSearchEntity>>> getRecentSearches({
    int limit = 10,
  }) async {
    try {
      final searches = await localDataSource.getRecentSearches();
      return Right(searches.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentSearches() async {
    try {
      await localDataSource.clearRecentSearches();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecentSearch(String searchId) async {
    try {
      await localDataSource.deleteRecentSearch(searchId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchSuggestionEntity>>> getPopularSearches({
    String? category,
    int limit = 10,
  }) async {
    try {
      final popular = await remoteDataSource.getPopularSearches(
        category: category,
        limit: limit,
      );
      
      final suggestions = popular
          .map((query) => SearchSuggestionEntity(
                suggestion: query,
                type: SuggestionType.popularSearch,
              ))
          .toList();
      
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> trackSearch({
    required String query,
    required int resultCount,
    required Duration searchDuration,
  }) async {
    try {
      await remoteDataSource.trackSearch(
        query: query,
        resultCount: resultCount,
        searchDuration: searchDuration,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
