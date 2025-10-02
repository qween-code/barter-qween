import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/search/search_filter_entity.dart';
import '../../../domain/entities/search/search_result_entity.dart';

/// Base class for all search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Search results loaded successfully
class SearchLoaded extends SearchState {
  final List<ItemEntity> items;
  final String query;
  final SearchFilterEntity filters;
  final int totalCount;
  final bool hasMore;
  final SearchMetadata metadata;

  const SearchLoaded({
    required this.items,
    required this.query,
    required this.filters,
    required this.totalCount,
    required this.hasMore,
    required this.metadata,
  });

  SearchLoaded copyWith({
    List<ItemEntity>? items,
    String? query,
    SearchFilterEntity? filters,
    int? totalCount,
    bool? hasMore,
    SearchMetadata? metadata,
  }) {
    return SearchLoaded(
      items: items ?? this.items,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [items, query, filters, totalCount, hasMore, metadata];
}

/// Empty search results
class SearchEmpty extends SearchState {
  final String query;
  final SearchFilterEntity filters;

  const SearchEmpty({
    required this.query,
    required this.filters,
  });

  @override
  List<Object?> get props => [query, filters];
}

/// Search error
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Suggestions loaded
class SuggestionsLoaded extends SearchState {
  final List<SearchSuggestionEntity> suggestions;

  const SuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

/// Recent searches loaded
class RecentSearchesLoaded extends SearchState {
  final List<RecentSearchEntity> recentSearches;

  const RecentSearchesLoaded(this.recentSearches);

  @override
  List<Object?> get props => [recentSearches];
}

/// Loading more results (pagination)
class LoadingMore extends SearchState {
  final List<ItemEntity> currentItems;
  final String query;
  final SearchFilterEntity filters;

  const LoadingMore({
    required this.currentItems,
    required this.query,
    required this.filters,
  });

  @override
  List<Object?> get props => [currentItems, query, filters];
}
