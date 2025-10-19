import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/usecases/get_user_favorites_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

@injectable
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetUserFavoritesUseCase getUserFavorites;
  final ToggleFavoriteUseCase toggleFavorite;

  // Track favorited items locally for quick access
  final Set<String> _favoritedItemIds = {};
  final List<ItemEntity> _currentFavorites = [];
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  List<ItemEntity> get favorites => List.unmodifiable(_currentFavorites);

  FavoriteBloc({required this.getUserFavorites, required this.toggleFavorite})
    : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  /// Check if an item is favorited
  bool isFavorited(String itemId) {
    return _favoritedItemIds.contains(itemId);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(const FavoriteLoading());

    try {
      final result = await getUserFavorites();

      result.fold((failure) => emit(FavoriteError(message: failure.message)), (
        items,
      ) {
        _updateFavoritesCache(items);
        emit(FavoritesLoaded(favorites: favorites));
      });
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final wasFavorited = _favoritedItemIds.contains(event.itemId);

    try {
      final result = await toggleFavorite(event.itemId);

      await result.fold((failure) async {
        emit(FavoriteError(message: failure.message));
      }, (_) async {
        if (wasFavorited) {
          _favoritedItemIds.remove(event.itemId);
          _currentFavorites.removeWhere((item) => item.id == event.itemId);
          emit(
            FavoriteToggled(
              itemId: event.itemId,
              isFavorited: false,
              favorites: favorites,
            ),
          );
          await _analyticsService.logFavoriteToggled(
            itemId: event.itemId,
            added: false,
          );
        } else {
          final favoritesResult = await getUserFavorites();
          await favoritesResult.fold((failure) async {
            emit(FavoriteError(message: failure.message));
          }, (items) async {
            _updateFavoritesCache(items);
            emit(
              FavoriteToggled(
                itemId: event.itemId,
                isFavorited: true,
                favorites: favorites,
              ),
            );
            await _analyticsService.logFavoriteToggled(
              itemId: event.itemId,
              added: true,
            );
          });
        }
      });
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  void _updateFavoritesCache(List<ItemEntity> items) {
    _currentFavorites
      ..clear()
      ..addAll(items);
    _favoritedItemIds
      ..clear()
      ..addAll(items.map((item) => item.id));
  }
}
