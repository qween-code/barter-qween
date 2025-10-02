import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  final String userId;

  const LoadFavorites(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddToFavorites extends FavoriteEvent {
  final String userId;
  final String itemId;

  const AddToFavorites(this.userId, this.itemId);

  @override
  List<Object?> get props => [userId, itemId];
}

class RemoveFromFavorites extends FavoriteEvent {
  final String userId;
  final String itemId;

  const RemoveFromFavorites(this.userId, this.itemId);

  @override
  List<Object?> get props => [userId, itemId];
}

class ToggleFavorite extends FavoriteEvent {
  final String userId;
  final String itemId;

  const ToggleFavorite(this.userId, this.itemId);

  @override
  List<Object?> get props => [userId, itemId];
}
