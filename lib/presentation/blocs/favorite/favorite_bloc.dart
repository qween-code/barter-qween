import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/favorite_repository.dart';
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

  FavoriteBloc({
    required this.getUserFavorites,
    required this.toggleFavorite,
  }) : super(FavoriteInitial()) {
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
    emit(FavoriteLoading());
    
    try {
      final result = await getUserFavorites();
      
      result.fold(
        (failure) => emit(FavoriteError(message: failure.message)),
        (items) {
          // Update local cache
          _favoritedItemIds.clear();
          for (var item in items) {
            if (item.id != null) _favoritedItemIds.add(item.id!);
          }
          
          emit(FavoritesLoaded(favorites: items));
        },
      );
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final result = await toggleFavorite(event.itemId);
      
      result.fold(
        (failure) => emit(FavoriteError(message: failure.message)),
        (_) {
          // Toggle in local set
          if (_favoritedItemIds.contains(event.itemId)) {
            _favoritedItemIds.remove(event.itemId);
          } else {
            _favoritedItemIds.add(event.itemId);
          }
          
          emit(FavoriteToggled(itemId: event.itemId));
        },
      );
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }
}