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

class ItemError extends ItemState {
  final String message;

  const ItemError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FeaturedItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const FeaturedItemsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class RecentItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const RecentItemsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class TrendingItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const TrendingItemsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class ItemLoaded extends ItemState {
  final ItemEntity item;

  const ItemLoaded({required this.item});

  @override
  List<Object?> get props => [item];
}

class AllItemsLoaded extends ItemState {
  final List<ItemEntity> items;

  const AllItemsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}
