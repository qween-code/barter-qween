import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/entities/search/search_filter_entity.dart';
import '../../../domain/usecases/search/search_items_usecase.dart';
import '../../../domain/usecases/search/get_search_suggestions_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search functionality
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItemsUseCase searchItemsUseCase;
  final GetSearchSuggestionsUseCase getSuggestionsUseCase;

  StreamSubscription? _searchSubscription;
  String _currentQuery = '';
  SearchFilterEntity _currentFilters = const SearchFilterEntity();

  SearchBloc({
    required this.searchItemsUseCase,
    required this.getSuggestionsUseCase,
  }) : super(const SearchInitial()) {
    // Register event handlers with debouncing for search query
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<SearchStarted>(_onSearchStarted);
    on<FiltersApplied>(_onFiltersApplied);
    on<SortChanged>(_onSortChanged);
    on<FiltersClearedEvent>(_onFiltersCleared);
    on<SearchCleared>(_onSearchCleared);
    on<GetSuggestionsEvent>(_onGetSuggestions);
  }

  /// Debounce transformer for search queries
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  /// Handle search query changes with debouncing
  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    
    if (event.query.isEmpty) {
      await _searchSubscription?.cancel();
      emit(const SearchInitial());
      return;
    }

    add(SearchStarted(query: event.query, filters: _currentFilters));
  }

  /// Start a new search
  Future<void> _onSearchStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    _currentQuery = event.query;
    _currentFilters = event.filters;

    // Cancel previous search subscription
    await _searchSubscription?.cancel();

    // Subscribe to search results stream
    _searchSubscription = searchItemsUseCase(
      SearchItemsParams(
        query: event.query,
        filters: event.filters,
      ),
    ).listen(
      (result) async {
        if (emit.isDone) return;
        
        result.fold(
          (failure) {
            if (!emit.isDone) emit(SearchError(failure.message));
          },
          (searchResult) {
            if (emit.isDone) return;
            
            if (searchResult.items.isEmpty) {
              emit(SearchEmpty(
                query: event.query,
                filters: event.filters,
              ));
            } else {
              emit(SearchLoaded(
                items: searchResult.items,
                query: event.query,
                filters: event.filters,
                totalCount: searchResult.totalCount,
                hasMore: searchResult.hasMore,
                metadata: searchResult.metadata,
              ));
            }
          },
        );
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(SearchError('Search failed: $error'));
        }
      },
    );
  }

  /// Apply filters to current search
  Future<void> _onFiltersApplied(
    FiltersApplied event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilters = event.filters;
    add(SearchStarted(query: _currentQuery, filters: event.filters));
  }

  /// Change sort option
  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<SearchState> emit,
  ) async {
    final newFilters = _currentFilters.copyWith(
      sortBy: event.sortBy,
      sortDirection: event.sortDirection,
    );
    
    add(FiltersApplied(newFilters));
  }

  /// Clear all filters
  Future<void> _onFiltersCleared(
    FiltersClearedEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilters = const SearchFilterEntity();
    add(SearchStarted(query: _currentQuery, filters: _currentFilters));
  }

  /// Clear search
  Future<void> _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _searchSubscription?.cancel();
    _currentQuery = '';
    _currentFilters = const SearchFilterEntity();
    emit(const SearchInitial());
  }

  /// Get search suggestions
  Future<void> _onGetSuggestions(
    GetSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.partialQuery.isEmpty) {
      return;
    }

    final result = await getSuggestionsUseCase(event.partialQuery);
    
    result.fold(
      (failure) {
        // Silently fail for suggestions
      },
      (suggestions) {
        if (!emit.isDone) {
          emit(SuggestionsLoaded(suggestions));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    return super.close();
  }
}
