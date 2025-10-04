import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/usecases/item/item_usecases.dart';
import '../../../domain/usecases/items/get_recent_items_usecase.dart';
import '../../../domain/usecases/items/get_trending_items_usecase.dart';
import '../../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../../domain/usecases/favorites/remove_favorite_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing homepage functionality
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllItemsUseCase getAllItemsUseCase;
  final GetFeaturedItemsUseCase getFeaturedItemsUseCase;
  final GetRecentItemsUseCase getRecentItemsUseCase;
  final GetTrendingItemsUseCase getTrendingItemsUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  StreamSubscription? _itemsSubscription;
  StreamSubscription? _featuredSubscription;

  HomeBloc({
    required this.getAllItemsUseCase,
    required this.getFeaturedItemsUseCase,
    required this.getRecentItemsUseCase,
    required this.getTrendingItemsUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadFeaturedItems>(_onLoadFeaturedItems);
    on<LoadRecentItems>(_onLoadRecentItems);
    on<LoadTrendingItems>(_onLoadTrendingItems);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<CategorySelected>(_onCategorySelected);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    _featuredSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    
    try {
      // Load featured items
      add(const LoadFeaturedItems());
      
      // Load recent items
      add(const LoadRecentItems());
      
      // Load trending items
      add(const LoadTrendingItems());
      
      emit(const HomeDataLoaded());
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }

  Future<void> _onLoadFeaturedItems(
    LoadFeaturedItems event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getFeaturedItemsUseCase();
    
    result.fold(
      (failure) => emit(HomeError('Failed to load featured items: ${failure.message}')),
      (items) => emit(HomeFeaturedItemsLoaded(items)),
    );
  }

  Future<void> _onLoadRecentItems(
    LoadRecentItems event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getRecentItemsUseCase();
    
    result.fold(
      (failure) => emit(HomeError('Failed to load recent items: ${failure.message}')),
      (items) => emit(HomeRecentItemsLoaded(items)),
    );
  }

  Future<void> _onLoadTrendingItems(
    LoadTrendingItems event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getTrendingItemsUseCase();
    
    result.fold(
      (failure) => emit(HomeError('Failed to load trending items: ${failure.message}')),
      (items) => emit(HomeTrendingItemsLoaded(items)),
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeRefreshing());
    add(const LoadHomeData());
  }


  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeCategorySelected(event.category));
    add(LoadRecentItems(category: event.category));
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeSearchQueryChanged(event.query));
  }
}
