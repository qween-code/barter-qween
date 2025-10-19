import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/search_filter_entity.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchItems extends SearchEvent {
  final String query;
  final SearchFilterEntity? filters;

  const SearchItems(this.query, {this.filters});

  @override
  List<Object?> get props => [query, filters];
}

// Alias for SearchItems to support legacy code
class SearchQueryChanged extends SearchEvent {
  final String query;
  final SearchFilterEntity? filters;

  const SearchQueryChanged(this.query, {this.filters});

  @override
  List<Object?> get props => [query, filters];
}

class SearchWithFilters extends SearchEvent {
  final String query;
  final SearchFilterEntity filters;

  const SearchWithFilters({required this.query, required this.filters});

  @override
  List<Object?> get props => [query, filters];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

// Alias for ClearSearch to support legacy code
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
