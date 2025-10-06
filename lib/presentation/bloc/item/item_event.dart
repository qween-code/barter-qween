import 'package:equatable/equatable.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeaturedItems extends ItemEvent {
  const LoadFeaturedItems();
}

class LoadRecentItems extends ItemEvent {
  const LoadRecentItems();
}

class LoadTrendingItems extends ItemEvent {
  const LoadTrendingItems();
}

class LoadItem extends ItemEvent {
  final String itemId;

  const LoadItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadAllItems extends ItemEvent {
  const LoadAllItems();
}
