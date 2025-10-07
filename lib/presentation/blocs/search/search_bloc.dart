import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/search_items_usecase.dart';
import '../../../domain/usecases/get_search_suggestions_usecase.dart';
import '../../../domain/entities/search/search_filter_entity.dart';
import 'search_event.dart';
import 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItemsUseCase searchItemsUseCase;
  final GetSearchSuggestionsUseCase getSuggestionsUseCase;

  SearchBloc({
    required this.searchItemsUseCase,
    required this.getSuggestionsUseCase,
  }) : super(SearchInitial()) {
    on<SearchItems>(_onSearchItems);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchWithFilters>(_onSearchWithFilters);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    try {
      final result = await searchItemsUseCase(event.query);
      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (items) => emit(SearchCompleted(query: event.query, results: items)),
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    if (event.query.length < 2) {
      // Wait for at least 2 characters
      return;
    }

    emit(SearchLoading());
    
    try {
      final result = await searchItemsUseCase(event.query);
      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (items) {
          if (items.isEmpty) {
            emit(SearchEmpty(query: event.query));
          } else {
            emit(SearchCompleted(query: event.query, results: items));
          }
        },
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchWithFilters(
    SearchWithFilters event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    try {
      // TODO: Implement filtered search in ItemRepository
      // For now, do basic search and filter in-memory
      final result = await searchItemsUseCase(event.query);
      
      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (items) {
          // Apply filters
          var filteredItems = items;
          
          // Category filter
          if (event.filters.categories != null && event.filters.categories!.isNotEmpty) {
            filteredItems = filteredItems.where((item) =>
              event.filters.categories!.contains(item.category)
            ).toList();
          }
          
          // Price range filter
          if (event.filters.minPrice != null || event.filters.maxPrice != null) {
            filteredItems = filteredItems.where((item) {
              final price = item.estimatedValue ?? 0;
              final minOk = event.filters.minPrice == null || price >= event.filters.minPrice!;
              final maxOk = event.filters.maxPrice == null || price <= event.filters.maxPrice!;
              return minOk && maxOk;
            }).toList();
          }
          
          // Condition filter
          if (event.filters.conditions != null && event.filters.conditions!.isNotEmpty) {
            filteredItems = filteredItems.where((item) =>
              event.filters.conditions!.contains(item.condition)
            ).toList();
          }
          
          // Sort
          switch (event.filters.sortBy) {
            case SortOption.price:
              filteredItems.sort((a, b) => 
                (a.estimatedValue ?? 0).compareTo(b.estimatedValue ?? 0)
              );
              break;
            case SortOption.viewCount:
              filteredItems.sort((a, b) => 
                (b.viewCount ?? 0).compareTo(a.viewCount ?? 0)
              );
              break;
            case SortOption.createdAt:
            default:
              filteredItems.sort((a, b) {
                if (a.createdAt == null) return 1;
                if (b.createdAt == null) return -1;
                return b.createdAt!.compareTo(a.createdAt!);
              });
          }
          
          if (filteredItems.isEmpty) {
            emit(SearchEmpty(query: event.query));
          } else {
            emit(SearchCompleted(query: event.query, results: filteredItems));
          }
        },
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }
}