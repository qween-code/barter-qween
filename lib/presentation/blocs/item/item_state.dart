import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final ItemEntity item;

  const ItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}

class ItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const ItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ItemCreated extends ItemState {
  final ItemEntity item;

  const ItemCreated(this.item);

  @override
  List<Object?> get props => [item];
}

class ItemUpdated extends ItemState {
  final ItemEntity item;

  const ItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

class ItemDeleted extends ItemState {
  final String itemId;

  const ItemDeleted(this.itemId);

  @override
  List<Object?> get props => [itemId];
}