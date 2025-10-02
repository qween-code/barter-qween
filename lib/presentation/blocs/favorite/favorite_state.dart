import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoritesLoaded extends FavoriteState {
  final List<ItemEntity> items;
  final Set<String> favoriteIds;

  const FavoritesLoaded(this.items, this.favoriteIds);

  @override
  List<Object?> get props => [items, favoriteIds];
}

class FavoriteAdded extends FavoriteState {
  final String itemId;

  const FavoriteAdded(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class FavoriteRemoved extends FavoriteState {
  final String itemId;

  const FavoriteRemoved(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}
