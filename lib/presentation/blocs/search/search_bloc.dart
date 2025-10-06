import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/search_items_usecase.dart';
import '../../../domain/usecases/get_search_suggestions_usecase.dart';
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

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }
}