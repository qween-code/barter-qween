import 'package:equatable/equatable.dart';
import '../item_entity.dart';

/// Entity representing search results
class SearchResultEntity extends Equatable {
  final List<ItemEntity> items;
  final int totalCount;
  final bool hasMore;
  final String? nextPageToken;
  final SearchMetadata metadata;

  const SearchResultEntity({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    this.nextPageToken,
    required this.metadata,
  });

  SearchResultEntity copyWith({
    List<ItemEntity>? items,
    int? totalCount,
    bool? hasMore,
    String? nextPageToken,
    SearchMetadata? metadata,
  }) {
    return SearchResultEntity(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        items,
        totalCount,
        hasMore,
        nextPageToken,
        metadata,
      ];
}

/// Metadata about the search operation
class SearchMetadata extends Equatable {
  final String query;
  final int resultsCount;
  final Duration searchDuration;
  final DateTime timestamp;

  const SearchMetadata({
    required this.query,
    required this.resultsCount,
    required this.searchDuration,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        query,
        resultsCount,
        searchDuration,
        timestamp,
      ];
}

/// Entity for recent search history
class RecentSearchEntity extends Equatable {
  final String id;
  final String query;
  final DateTime searchedAt;
  final int resultCount;

  const RecentSearchEntity({
    required this.id,
    required this.query,
    required this.searchedAt,
    required this.resultCount,
  });

  @override
  List<Object?> get props => [id, query, searchedAt, resultCount];
}

/// Entity for search suggestions
class SearchSuggestionEntity extends Equatable {
  final String suggestion;
  final SuggestionType type;
  final int popularity;

  const SearchSuggestionEntity({
    required this.suggestion,
    required this.type,
    this.popularity = 0,
  });

  @override
  List<Object?> get props => [suggestion, type, popularity];
}

enum SuggestionType {
  category,
  recentSearch,
  popularSearch,
  autoComplete,
}
