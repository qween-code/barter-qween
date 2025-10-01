import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {
  const ItemInitial();
}

class ItemLoading extends ItemState {
  const ItemLoading();
}

class ItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const ItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ItemLoaded extends ItemState {
  final ItemEntity item;

  const ItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
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
  const ItemDeleted();
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}
