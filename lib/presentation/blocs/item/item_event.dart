import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/item_entity.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllItems extends ItemEvent {
  final String? category;
  final String? city;

  const LoadAllItems({this.category, this.city});

  @override
  List<Object?> get props => [category, city];
}

class LoadUserItems extends ItemEvent {
  final String userId;

  const LoadUserItems(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadItem extends ItemEvent {
  final String itemId;

  const LoadItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class CreateItem extends ItemEvent {
  final ItemEntity item;
  final List<File>? images;

  const CreateItem(this.item, {this.images});

  @override
  List<Object?> get props => [item, images];
}

class UpdateItem extends ItemEvent {
  final ItemEntity item;
  final List<File>? newImages;

  const UpdateItem(this.item, [this.newImages]);

  @override
  List<Object?> get props => [item, newImages];
}

class DeleteItem extends ItemEvent {
  final String itemId;

  const DeleteItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class SearchItems extends ItemEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadFeaturedItems extends ItemEvent {
  const LoadFeaturedItems();
}

class FilterItems extends ItemEvent {
  final List<String>? categories;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const FilterItems({
    this.categories,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        categories,
        condition,
        minPrice,
        maxPrice,
        sortBy,
      ];
}
