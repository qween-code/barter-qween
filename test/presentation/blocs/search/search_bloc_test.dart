import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:barter_qween/lib/domain/entities/item_entity.dart';
import 'package:barter_qween/lib/domain/entities/search/search_filter_entity.dart';
import 'package:barter_qween/lib/domain/entities/search/search_result_entity.dart';
import 'package:barter_qween/lib/domain/usecases/search/get_search_suggestions_usecase.dart';
import 'package:barter_qween/lib/domain/usecases/search/search_items_usecase.dart';
import 'package:barter_qween/lib/presentation/blocs/search/search_bloc.dart';
import 'package:barter_qween/lib/presentation/blocs/search/search_event.dart';
import 'package:barter_qween/lib/presentation/blocs/search/search_state.dart';
import 'package:barter_qween/lib/core/error/failures.dart';

import 'search_bloc_test.mocks.dart';

@GenerateMocks([SearchItemsUseCase, GetSearchSuggestionsUseCase])
void main() {
  late SearchBloc searchBloc;
  late MockSearchItemsUseCase mockSearchItemsUseCase;
  late MockGetSearchSuggestionsUseCase mockGetSearchSuggestionsUseCase;

  setUp(() {
    mockSearchItemsUseCase = MockSearchItemsUseCase();
    mockGetSearchSuggestionsUseCase = MockGetSearchSuggestionsUseCase();
    searchBloc = SearchBloc(
      searchItemsUseCase: mockSearchItemsUseCase,
      getSuggestionsUseCase: mockGetSearchSuggestionsUseCase,
    );
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    final tQuery = 'test query';
    final tFilters = SearchFilterEntity(category: 'Electronics');
    final tItems = [ItemEntity(id: '1', title: 'Test Item')];
    final tSearchResult = SearchResultEntity(items: tItems, totalCount: 1, hasMore: false);

    test('initial state is SearchInitial', () {
      expect(searchBloc.state, const SearchInitial());
    });

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when SearchStarted is added and succeeds',
      build: () {
        when(mockSearchItemsUseCase(any)).thenAnswer((_) => Stream.value(Right(tSearchResult)));
        return searchBloc;
      },
      act: (bloc) => bloc.add(SearchStarted(query: tQuery, filters: const SearchFilterEntity())),
      expect: () => [
        const SearchLoading(),
        SearchLoaded(
          items: tItems,
          query: tQuery,
          filters: const SearchFilterEntity(),
          totalCount: 1,
          hasMore: false,
          metadata: {},
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] when SearchStarted fails',
      build: () {
        when(mockSearchItemsUseCase(any)).thenAnswer((_) => Stream.value(Left(ServerFailure('Server Error'))));
        return searchBloc;
      },
      act: (bloc) => bloc.add(SearchStarted(query: tQuery, filters: const SearchFilterEntity())),
      expect: () => [
        const SearchLoading(),
        const SearchError('Server Error'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when FiltersApplied is added with a query',
      build: () {
        when(mockSearchItemsUseCase(any)).thenAnswer((_) => Stream.value(Right(tSearchResult)));
        return searchBloc;
      },
      seed: () {
        // Set a non-empty query
        searchBloc.add(SearchQueryChanged(query: tQuery));
        return SearchLoaded(items: [], query: tQuery, filters: const SearchFilterEntity(), totalCount: 0, hasMore: false, metadata: {});
      },
      act: (bloc) => bloc.add(FiltersApplied(tFilters)),
      expect: () => [
        const SearchLoading(),
        SearchLoaded(
          items: tItems,
          query: tQuery,
          filters: tFilters,
          totalCount: 1,
          hasMore: false,
          metadata: {},
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when FiltersApplied is added without a query',
      build: () {
        when(mockSearchItemsUseCase(any)).thenAnswer((_) => Stream.value(Right(tSearchResult)));
        return searchBloc;
      },
      act: (bloc) => bloc.add(FiltersApplied(tFilters)),
      expect: () => [
        const SearchLoading(),
        SearchLoaded(
          items: tItems,
          query: '',
          filters: tFilters,
          totalCount: 1,
          hasMore: false,
          metadata: {},
        ),
      ],
    );
  });
}