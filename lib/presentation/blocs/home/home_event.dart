import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class LoadFeaturedItems extends HomeEvent {
  const LoadFeaturedItems();
}

class LoadRecentItems extends HomeEvent {
  final String? category;
  final String? city;

  const LoadRecentItems({
    this.category,
    this.city,
  });

  @override
  List<Object?> get props => [category, city];
}

class LoadTrendingItems extends HomeEvent {
  final String? category;
  final String? city;

  const LoadTrendingItems({
    this.category,
    this.city,
  });

  @override
  List<Object?> get props => [category, city];
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}


class CategorySelected extends HomeEvent {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object> get props => [category];
}

class SearchQueryChanged extends HomeEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}
