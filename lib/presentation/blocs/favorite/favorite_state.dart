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

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FavoritesLoaded extends FavoriteState {
  final List<ItemEntity> favorites;

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

class FavoriteToggled extends FavoriteState {
  final String itemId;
  final bool isFavorited;
  final List<ItemEntity> favorites;

  const FavoriteToggled({
    required this.itemId,
    required this.isFavorited,
    required this.favorites,
  });

  @override
  List<Object?> get props => [itemId, isFavorited, favorites];
}
