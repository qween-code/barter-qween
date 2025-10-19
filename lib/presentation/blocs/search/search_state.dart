import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SearchCompleted extends SearchState {
  final String query;
  final List<ItemEntity> results;

  const SearchCompleted({required this.query, required this.results});

  @override
  List<Object?> get props => [query, results];
}

// Alias for SearchCompleted to support legacy code
class SearchLoaded extends SearchState {
  final String query;
  final List<ItemEntity> results;

  const SearchLoaded({required this.query, required this.results});

  // Aliases for legacy code compatibility
  List<ItemEntity> get items => results;
  int get totalCount => results.length;

  @override
  List<Object?> get props => [query, results];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchClearedState extends SearchState {
  const SearchClearedState();
}
