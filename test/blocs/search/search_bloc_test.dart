import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:barter_qween/core/error/failures.dart';
import 'package:barter_qween/domain/entities/item_entity.dart';
import 'package:barter_qween/domain/entities/search/search_filter_entity.dart';
import 'package:barter_qween/domain/entities/search/search_result_entity.dart';
import 'package:barter_qween/domain/usecases/search/search_items_usecase.dart';
import 'package:barter_qween/domain/usecases/search/get_search_suggestions_usecase.dart';
import 'package:barter_qween/presentation/blocs/search/search_bloc.dart';
import 'package:barter_qween/presentation/blocs/search/search_event.dart';
import 'package:barter_qween/presentation/blocs/search/search_state.dart';

// Mock classes
class MockSearchItemsUseCase extends Mock implements SearchItemsUseCase {}
class MockGetSearchSuggestionsUseCase extends Mock implements GetSearchSuggestionsUseCase {}

void main() {
  late SearchBloc searchBloc;
  late MockSearchItemsUseCase mockSearchItemsUseCase;
  late MockGetSearchSuggestionsUseCase mockGetSuggestionsUseCase;

  setUp(() {
    mockSearchItemsUseCase = MockSearchItemsUseCase();
    mockGetSuggestionsUseCase = MockGetSearchSuggestionsUseCase();
    searchBloc = SearchBloc(
      searchItemsUseCase: mockSearchItemsUseCase,
      getSuggestionsUseCase: mockGetSuggestionsUseCase,
    );

    // Register fallback values
    registerFallbackValue(const SearchFilterEntity());
    registerFallbackValue(SearchItemsParams(
      query: '',
      filters: const SearchFilterEntity(),
    ));
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    const tQuery = 'iPhone';
    const tFilters = SearchFilterEntity();
    
    final tItem = ItemEntity(
      id: '1',
      title: 'iPhone 12',
      description: 'Like new iPhone 12',
      category: 'Electronics',
      images: ['image1.jpg'],
      condition: 'new',
      ownerId: 'user1',
      ownerName: 'John Doe',
      city: 'Istanbul',
      status: ItemStatus.active, // Fixed: Use enum instead of string
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      viewCount: 0,
      favoriteCount: 0,
    );
    
    final tMetadata = SearchMetadata(
      query: tQuery,
      resultsCount: 1,
      searchDuration: const Duration(milliseconds: 100),
      timestamp: DateTime.now(),
    );
    
    final tSearchResult = SearchResultEntity(
      items: [tItem],
      totalCount: 1,
      hasMore: false,
      metadata: tMetadata, // Added required metadata
    );

    test('initial state should be SearchInitial', () {
      expect(searchBloc.state, equals(const SearchInitial()));
    });

    group('SearchQueryChanged', () {
      blocTest<SearchBloc, SearchState>(
        'emits [] when query is empty',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged('')),
        expect: () => [const SearchInitial()],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchLoaded] when search succeeds',
        build: () {
          when(() => mockSearchItemsUseCase(any())).thenAnswer(
            (_) => Stream.value(Right(tSearchResult)),
          );
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          const SearchLoading(),
          SearchLoaded(
            query: tQuery,
            results: [tItem],
          ),
        ],
        verify: (_) {
          verify(() => mockSearchItemsUseCase(any())).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchEmpty] when no results found',
        build: () {
          final emptyMetadata = SearchMetadata(
            query: tQuery,
            resultsCount: 0,
            searchDuration: const Duration(milliseconds: 50),
            timestamp: DateTime.now(),
          );
          when(() => mockSearchItemsUseCase(any())).thenAnswer(
            (_) => Stream.value(Right(SearchResultEntity(
              items: const [],
              totalCount: 0,
              hasMore: false,
              metadata: emptyMetadata, // Added required metadata
            ))),
          );
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const SearchLoading(),
          const SearchEmpty(query: tQuery, filters: tFilters),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchError] when search fails',
        build: () {
          when(() => mockSearchItemsUseCase(any())).thenAnswer(
            (_) => Stream.value(Left(ServerFailure('Server error'))),
          );
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const SearchLoading(),
          const SearchError('Server error'),
        ],
      );
    });

    group('SearchCleared', () {
      blocTest<SearchBloc, SearchState>(
        'emits [SearchInitial] when search is cleared',
        build: () => searchBloc,
        seed: () => SearchLoaded(
          items: [tItem],
          query: tQuery,
          filters: tFilters,
          totalCount: 1,
          hasMore: false,
          metadata: tMetadata, // Added required metadata
        ),
        act: (bloc) => bloc.add(const SearchCleared()),
        expect: () => [const SearchInitial()],
      );
    });

    group('FiltersApplied', () {
      const tNewFilters = SearchFilterEntity(
        minPrice: 100,
        maxPrice: 1000,
      );

      blocTest<SearchBloc, SearchState>(
        'triggers new search with updated filters',
        build: () {
          when(() => mockSearchItemsUseCase(any())).thenAnswer(
            (_) => Stream.value(Right(tSearchResult)),
          );
          return searchBloc;
        },
        seed: () => SearchLoaded(
          items: [tItem],
          query: tQuery,
          filters: tFilters,
          totalCount: 1,
          hasMore: false,
          metadata: tMetadata, // Added required metadata
        ),
        act: (bloc) => bloc.add(const FiltersApplied(tNewFilters)),
        expect: () => [
          const SearchLoading(),
          SearchLoaded(
            items: [tItem],
            query: tQuery,
            filters: tNewFilters,
            totalCount: 1,
            hasMore: false,
            metadata: tMetadata, // Added required metadata
          ),
        ],
        verify: (_) {
          verify(() => mockSearchItemsUseCase(any())).called(1);
        },
      );
    });

    group('GetSuggestionsEvent', () {
      const tPartialQuery = 'iP';
      
      // Fixed: Use SearchSuggestionEntity instead of plain strings
      final tSuggestions = [
        const SearchSuggestionEntity(
          suggestion: 'iPhone',
          type: SuggestionType.autoComplete,
          popularity: 100,
        ),
        const SearchSuggestionEntity(
          suggestion: 'iPad',
          type: SuggestionType.autoComplete,
          popularity: 80,
        ),
        const SearchSuggestionEntity(
          suggestion: 'iPod',
          type: SuggestionType.autoComplete,
          popularity: 50,
        ),
      ];

      blocTest<SearchBloc, SearchState>(
        'emits [SuggestionsLoaded] when suggestions succeed',
        build: () {
          when(() => mockGetSuggestionsUseCase(tPartialQuery))
              .thenAnswer((_) async => Right(tSuggestions));
          return searchBloc;
        },
        act: (bloc) => bloc.add(const GetSuggestionsEvent(tPartialQuery)),
        expect: () => [SuggestionsLoaded(tSuggestions)],
        verify: (_) {
          verify(() => mockGetSuggestionsUseCase(tPartialQuery)).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'silently fails when suggestions fail',
        build: () {
          when(() => mockGetSuggestionsUseCase(tPartialQuery))
              .thenAnswer((_) async => Left(ServerFailure('Error')));
          return searchBloc;
        },
        act: (bloc) => bloc.add(const GetSuggestionsEvent(tPartialQuery)),
        expect: () => [],
        verify: (_) {
          verify(() => mockGetSuggestionsUseCase(tPartialQuery)).called(1);
        },
      );
    });
  });
}
