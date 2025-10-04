import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeRefreshing extends HomeState {
  const HomeRefreshing();
}

class HomeDataLoaded extends HomeState {
  const HomeDataLoaded();
}

class HomeFeaturedItemsLoaded extends HomeState {
  final List<ItemEntity> featuredItems;

  const HomeFeaturedItemsLoaded(this.featuredItems);

  @override
  List<Object> get props => [featuredItems];
}

class HomeRecentItemsLoaded extends HomeState {
  final List<ItemEntity> recentItems;

  const HomeRecentItemsLoaded(this.recentItems);

  @override
  List<Object> get props => [recentItems];
}

class HomeTrendingItemsLoaded extends HomeState {
  final List<ItemEntity> trendingItems;

  const HomeTrendingItemsLoaded(this.trendingItems);

  @override
  List<Object> get props => [trendingItems];
}

class HomeCategorySelected extends HomeState {
  final String category;

  const HomeCategorySelected(this.category);

  @override
  List<Object> get props => [category];
}

class HomeSearchQueryChanged extends HomeState {
  final String query;

  const HomeSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class HomeFavoriteToggled extends HomeState {
  final String itemId;
  final bool isFavorite;

  const HomeFavoriteToggled(this.itemId, this.isFavorite);

  @override
  List<Object> get props => [itemId, isFavorite];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
