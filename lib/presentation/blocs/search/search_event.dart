import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchItems extends SearchEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}

// Alias for SearchItems to support legacy code
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

// Alias for ClearSearch to support legacy code
class SearchCleared extends SearchEvent {
  const SearchCleared();
}