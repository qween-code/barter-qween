import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../../domain/usecases/favorites/get_favorite_items_usecase.dart';
import '../../../domain/usecases/favorites/remove_favorite_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

@injectable
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final GetFavoriteItemsUseCase getFavoriteItemsUseCase;

  // Cache favorite IDs for quick access
  final Set<String> _favoriteIds = {};

  FavoriteBloc({
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getFavoriteItemsUseCase,
  }) : super(const FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  bool isFavorited(String itemId) => _favoriteIds.contains(itemId);

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(const FavoriteLoading());

    final result = await getFavoriteItemsUseCase(event.userId);

    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (items) {
        _favoriteIds.clear();
        _favoriteIds.addAll(items.map((item) => item.id));
        emit(FavoritesLoaded(items, Set.from(_favoriteIds)));
      },
    );
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    final result = await addFavoriteUseCase(event.userId, event.itemId);

    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (_) {
        _favoriteIds.add(event.itemId);
        emit(FavoriteAdded(event.itemId));
      },
    );
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    final result = await removeFavoriteUseCase(event.userId, event.itemId);

    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (_) {
        _favoriteIds.remove(event.itemId);
        emit(FavoriteRemoved(event.itemId));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    if (_favoriteIds.contains(event.itemId)) {
      add(RemoveFromFavorites(event.userId, event.itemId));
    } else {
      add(AddToFavorites(event.userId, event.itemId));
    }
  }
}
