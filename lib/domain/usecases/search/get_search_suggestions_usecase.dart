import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/search/search_result_entity.dart';
import '../../repositories/search_repository.dart';

/// Use case for getting search suggestions
@injectable
class GetSearchSuggestionsUseCase {
  final SearchRepository repository;

  GetSearchSuggestionsUseCase(this.repository);

  Future<Either<Failure, List<SearchSuggestionEntity>>> call(
    String partialQuery,
  ) {
    return repository.getSuggestions(partialQuery: partialQuery);
  }
}

/// Use case for getting recent searches
@injectable
class GetRecentSearchesUseCase {
  final SearchRepository repository;

  GetRecentSearchesUseCase(this.repository);

  Future<Either<Failure, List<RecentSearchEntity>>> call({int limit = 10}) {
    return repository.getRecentSearches(limit: limit);
  }
}

/// Use case for saving a recent search
@injectable
class SaveRecentSearchUseCase {
  final SearchRepository repository;

  SaveRecentSearchUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String query,
    required int resultCount,
  }) {
    return repository.saveRecentSearch(
      query: query,
      resultCount: resultCount,
    );
  }
}

/// Use case for clearing recent searches
@injectable
class ClearRecentSearchesUseCase {
  final SearchRepository repository;

  ClearRecentSearchesUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.clearRecentSearches();
  }
}

/// Use case for deleting a specific recent search
@injectable
class DeleteRecentSearchUseCase {
  final SearchRepository repository;

  DeleteRecentSearchUseCase(this.repository);

  Future<Either<Failure, void>> call(String searchId) {
    return repository.deleteRecentSearch(searchId);
  }
}

/// Use case for getting popular searches
@injectable
class GetPopularSearchesUseCase {
  final SearchRepository repository;

  GetPopularSearchesUseCase(this.repository);

  Future<Either<Failure, List<SearchSuggestionEntity>>> call({
    String? category,
    int limit = 10,
  }) {
    return repository.getPopularSearches(
      category: category,
      limit: limit,
    );
  }
}
