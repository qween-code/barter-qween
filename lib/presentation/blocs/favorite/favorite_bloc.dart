import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    
    try {
      // TODO: Load favorites from Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for now
      emit(FavoritesLoaded(favorites: []));
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      // TODO: Toggle favorite in Firebase
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock success
      emit(FavoriteToggled(itemId: event.itemId));
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }
}