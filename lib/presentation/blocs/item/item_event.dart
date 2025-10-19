import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../../domain/entities/item_entity.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadItem extends ItemEvent {
  final String itemId;

  const LoadItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
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

class SearchItems extends ItemEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterItems extends ItemEvent {
  final Map<String, dynamic> filters;

  const FilterItems(this.filters);

  @override
  List<Object?> get props => [filters];
}

class CreateItem extends ItemEvent {
  final ItemEntity item;
  final List<File> images;

  const CreateItem(this.item, {required this.images});

  @override
  List<Object?> get props => [item, images];
}

class UpdateItem extends ItemEvent {
  final ItemEntity item;
  final List<File> newImages;

  const UpdateItem(this.item, this.newImages);

  @override
  List<Object?> get props => [item, newImages];
}

class DeleteItem extends ItemEvent {
  final String itemId;

  const DeleteItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadFeaturedItems extends ItemEvent {
  final int limit;

  const LoadFeaturedItems({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class LoadRecentItems extends ItemEvent {
  const LoadRecentItems();

  @override
  List<Object?> get props => [];
}

class LoadTrendingItems extends ItemEvent {
  const LoadTrendingItems();

  @override
  List<Object?> get props => [];
}

class LoadRecommendedItems extends ItemEvent {
  final String userId;
  final String? city;
  final double? latitude;
  final double? longitude;

  const LoadRecommendedItems({
    required this.userId,
    this.city,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [userId, city, latitude, longitude];
}
