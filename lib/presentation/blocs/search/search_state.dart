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

  const SearchCompleted({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}