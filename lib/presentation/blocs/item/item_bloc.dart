import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/usecases/get_item_usecase.dart';
import '../../../domain/usecases/items/get_all_items_usecase.dart';
import '../../../domain/usecases/items/get_trending_items_usecase.dart';
import '../../../domain/usecases/items/get_recent_items_usecase.dart';
import '../../../core/usecases/usecase.dart';

import 'item_event.dart';
import 'item_state.dart';

/// BLoC for managing item state
@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemUsecase _getItemUsecase;
  final GetAllItemsUseCase _getAllItemsUseCase;
  final GetTrendingItemsUseCase _getTrendingItemsUseCase;
  final GetRecentItemsUseCase _getRecentItemsUseCase;

  ItemBloc(
    this._getItemUsecase,
    this._getAllItemsUseCase,
    this._getTrendingItemsUseCase,
    this._getRecentItemsUseCase,
  ) : super(ItemInitial()) {
    on<LoadItem>(_onLoadItem);
    on<LoadAllItems>(_onLoadAllItems);
    on<LoadUserItems>(_onLoadUserItems);
    on<SearchItems>(_onSearchItems);
    on<FilterItems>(_onFilterItems);
    on<CreateItem>(_onCreateItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<LoadFeaturedItems>(_onLoadFeaturedItems);
    on<LoadRecentItems>(_onLoadRecentItems);
    on<LoadTrendingItems>(_onLoadTrendingItems);
  }

  Future<void> _onLoadItem(LoadItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await _getItemUsecase(GetItemParams(itemId: event.itemId));

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemLoaded(item)),
    );
  }

  Future<void> _onLoadAllItems(LoadAllItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    
    final result = await _getAllItemsUseCase(NoParams());
    
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadUserItems(LoadUserItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement getUserItems usecase
    emit(const ItemsLoaded([]));
  }

  Future<void> _onSearchItems(SearchItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement searchItems usecase
    emit(const ItemsLoaded([]));
  }

  Future<void> _onFilterItems(FilterItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement filterItems usecase
    emit(const ItemsLoaded([]));
  }

  Future<void> _onCreateItem(CreateItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement createItem usecase
    emit(ItemCreated(event.item));
  }

  Future<void> _onUpdateItem(UpdateItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement updateItem usecase
    emit(ItemUpdated(event.item));
  }

  Future<void> _onDeleteItem(DeleteItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    // TODO: Implement deleteItem usecase
    emit(ItemDeleted(event.itemId));
  }

  Future<void> _onLoadFeaturedItems(LoadFeaturedItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    
    final result = await _getAllItemsUseCase(NoParams());
    
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadRecentItems(LoadRecentItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    
    final result = await _getRecentItemsUseCase(NoParams());
    
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadTrendingItems(LoadTrendingItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    
    final result = await _getTrendingItemsUseCase(NoParams());
    
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }
}