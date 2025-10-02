import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/search_filter_entity.dart';

/// Base class for all search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a search with query and filters
class SearchStarted extends SearchEvent {
  final String query;
  final SearchFilterEntity filters;

  const SearchStarted({
    required this.query,
    this.filters = const SearchFilterEntity(),
  });

  @override
  List<Object?> get props => [query, filters];
}

/// Event when search query changes (for debouncing)
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to apply/update filters
class FiltersApplied extends SearchEvent {
  final SearchFilterEntity filters;

  const FiltersApplied(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Event to change sort option
class SortChanged extends SearchEvent {
  final SortOption sortBy;
  final SortDirection sortDirection;

  const SortChanged({
    required this.sortBy,
    required this.sortDirection,
  });

  @override
  List<Object?> get props => [sortBy, sortDirection];
}

/// Event to clear all filters
class FiltersClearedEvent extends SearchEvent {
  const FiltersClearedEvent();
}

/// Event to clear search and reset
class SearchCleared extends SearchEvent {
  const SearchCleared();
}

/// Event to load more results (pagination)
class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}

/// Event to get search suggestions
class GetSuggestionsEvent extends SearchEvent {
  final String partialQuery;

  const GetSuggestionsEvent(this.partialQuery);

  @override
  List<Object?> get props => [partialQuery];
}

/// Event to get recent searches
class GetRecentSearches extends SearchEvent {
  const GetRecentSearches();
}

/// Event to delete a recent search
class DeleteRecentSearchEvent extends SearchEvent {
  final String searchId;

  const DeleteRecentSearchEvent(this.searchId);

  @override
  List<Object?> get props => [searchId];
}

/// Event to clear all recent searches
class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}

/// Event to save current search to recent
class SaveToRecentSearches extends SearchEvent {
  final String query;
  final int resultCount;

  const SaveToRecentSearches({
    required this.query,
    required this.resultCount,
  });

  @override
  List<Object?> get props => [query, resultCount];
}
