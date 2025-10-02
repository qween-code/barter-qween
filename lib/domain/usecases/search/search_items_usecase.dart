import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/search/search_filter_entity.dart';
import '../../entities/search/search_result_entity.dart';
import '../../repositories/search_repository.dart';

/// Use case for searching items with query and filters
@injectable
class SearchItemsUseCase {
  final SearchRepository repository;

  SearchItemsUseCase(this.repository);

  /// Execute search with given parameters
  /// Returns a stream that emits search results in real-time
  Stream<Either<Failure, SearchResultEntity>> call(SearchItemsParams params) {
    return repository.searchItems(
      query: params.query,
      filters: params.filters,
    );
  }
}

/// Parameters for search items use case
class SearchItemsParams {
  final String query;
  final SearchFilterEntity filters;

  const SearchItemsParams({
    required this.query,
    required this.filters,
  });
}
