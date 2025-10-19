import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/di/injection.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/usecases/get_item_usecase.dart';
import '../../../domain/usecases/item/item_usecases.dart' as item_uc;
import '../../../domain/usecases/items/delete_item_usecase.dart';
import '../../../domain/usecases/items/get_all_items_usecase.dart';
import '../../../domain/usecases/items/get_recent_items_usecase.dart';
import '../../../domain/usecases/items/get_trending_items_usecase.dart';
import '../../../domain/usecases/items/get_user_items_usecase.dart';
import '../../../domain/usecases/items/get_recommended_items_usecase.dart';

import 'item_event.dart';
import 'item_state.dart';

/// BLoC for managing item state
@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemUsecase _getItemUsecase;
  final GetAllItemsUseCase _getAllItemsUseCase;
  final GetTrendingItemsUseCase _getTrendingItemsUseCase;
  final GetRecentItemsUseCase _getRecentItemsUseCase;
  final GetUserItemsUseCase _getUserItemsUseCase = getIt<GetUserItemsUseCase>();
  final item_uc.SearchItemsUseCase _searchItemsUseCase =
      getIt<item_uc.SearchItemsUseCase>();
  final item_uc.CreateItemUseCase _createItemUseCase =
      getIt<item_uc.CreateItemUseCase>();
  final item_uc.UpdateItemUseCase _updateItemUseCase =
      getIt<item_uc.UpdateItemUseCase>();
  final DeleteItemUseCase _deleteItemUseCase = getIt<DeleteItemUseCase>();
  final GetRecommendedItemsUseCase _getRecommendedItemsUseCase =
      getIt<GetRecommendedItemsUseCase>();

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
    on<LoadRecommendedItems>(_onLoadRecommendedItems);
  }

  Future<void> _onLoadItem(LoadItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await _getItemUsecase(GetItemParams(itemId: event.itemId));

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemLoaded(item)),
    );
  }

  Future<void> _onLoadAllItems(
    LoadAllItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    final result = await _getAllItemsUseCase(
      GetAllItemsParams(category: event.category, city: event.city),
    );

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadUserItems(
    LoadUserItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());
    final result = await _getUserItemsUseCase(event.userId);

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());
    final result = await _searchItemsUseCase(event.query);

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onFilterItems(
    FilterItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());
    final category = event.filters['category'] as String?;
    final city = event.filters['city'] as String?;
    final result = await _getAllItemsUseCase(
      GetAllItemsParams(category: category, city: city),
    );

    result.fold((failure) => emit(ItemError(failure.message)), (items) {
      var filtered = List<ItemEntity>.from(items);

      final condition = _stringValue(event.filters['condition']);
      if (condition != null && condition.isNotEmpty) {
        filtered = filtered
            .where(
              (item) =>
                  (item.condition ?? '').toLowerCase() ==
                  condition.toLowerCase(),
            )
            .toList();
      }

      final minPrice = _doubleValue(event.filters['minPrice']);
      final maxPrice = _doubleValue(event.filters['maxPrice']);
      if (minPrice != null || maxPrice != null) {
        filtered = filtered.where((item) {
          final price = item.price ?? item.monetaryValue;
          if (price == null) return false;
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
          return true;
        }).toList();
      }

      final status = _stringValue(event.filters['status']);
      if (status != null && status.isNotEmpty) {
        filtered = filtered
            .where(
              (item) => item.status.name.toLowerCase() == status.toLowerCase(),
            )
            .toList();
      }

      final userLat = _doubleValue(event.filters['latitude']);
      final userLng = _doubleValue(event.filters['longitude']);
      final maxDistance = _doubleValue(event.filters['maxDistance']);

      if (userLat != null && userLng != null && maxDistance != null) {
        filtered = filtered.where((item) {
          if (item.latitude == null || item.longitude == null) {
            return true; // keep if no location to avoid empty lists
          }
          final distance = _calculateDistance(
            userLat,
            userLng,
            item.latitude!,
            item.longitude!,
          );
          return distance <= maxDistance;
        }).toList();

        filtered.sort((a, b) {
          final distA = (a.latitude != null && a.longitude != null)
              ? _calculateDistance(userLat, userLng, a.latitude!, a.longitude!)
              : double.infinity;
          final distB = (b.latitude != null && b.longitude != null)
              ? _calculateDistance(userLat, userLng, b.latitude!, b.longitude!)
              : double.infinity;
          return distA.compareTo(distB);
        });
      }

      emit(ItemsLoaded(filtered));
    });
  }

  Future<void> _onCreateItem(CreateItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    final result = await _createItemUseCase(event.item, event.images);

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemCreated(item)),
    );
  }

  Future<void> _onUpdateItem(UpdateItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    final result = await _updateItemUseCase(event.item, event.newImages);

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemUpdated(item)),
    );
  }

  Future<void> _onDeleteItem(DeleteItem event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    final result = await _deleteItemUseCase(event.itemId);

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (_) => emit(ItemDeleted(event.itemId)),
    );
  }

  Future<void> _onLoadFeaturedItems(
    LoadFeaturedItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    final result = await _getAllItemsUseCase(const GetAllItemsParams());

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadRecentItems(
    LoadRecentItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    final result = await _getRecentItemsUseCase(NoParams());

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadTrendingItems(
    LoadTrendingItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    final result = await _getTrendingItemsUseCase(NoParams());

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadRecommendedItems(
    LoadRecommendedItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    final result = await _getRecommendedItemsUseCase(
      GetRecommendedItemsParams(
        userId: event.userId,
        city: event.city,
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  double? _doubleValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(endLat - startLat);
    final dLon = _degreesToRadians(endLng - startLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
}
