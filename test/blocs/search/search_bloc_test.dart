import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:barter_qween/core/error/failures.dart';
import 'package:barter_qween/domain/entities/item_entity.dart';
import 'package:barter_qween/domain/entities/search/search_filter_entity.dart';
import 'package:barter_qween/domain/usecases/get_search_suggestions_usecase.dart';
import 'package:barter_qween/domain/usecases/search_items_usecase.dart';
import 'package:barter_qween/presentation/blocs/search/search_bloc.dart';
import 'package:barter_qween/presentation/blocs/search/search_event.dart';
import 'package:barter_qween/presentation/blocs/search/search_state.dart';

// Mock classes
class MockSearchItemsUseCase extends Mock implements SearchItemsUseCase {}

class MockGetSearchSuggestionsUseCase extends Mock
    implements GetSearchSuggestionsUseCase {}

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
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    const tQuery = 'iPhone';

    final tItem = ItemEntity(
      id: '1',
      title: 'iPhone 12',
      description: 'Like new iPhone 12',
      category: 'Electronics',
      images: const ['image1.jpg'],
      condition: 'new',
      price: 250.0,
      ownerId: 'user1',
      ownerName: 'John Doe',
      city: 'Istanbul',
      status: ItemStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      viewCount: 0,
      favoriteCount: 0,
    );

    test('initial state should be SearchInitial', () {
      expect(searchBloc.state, equals(const SearchInitial()));
    });

    group('SearchQueryChanged', () {
      blocTest<SearchBloc, SearchState>(
        'emits [SearchInitial] when query is empty',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged('')),
        expect: () => [const SearchInitial()],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [] when query length < 2',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged('a')),
        expect: () => <SearchState>[],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchCompleted] when search succeeds',
        build: () {
          when(
            () => mockSearchItemsUseCase(any()),
          ).thenAnswer((_) async => Right([tItem]));
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        expect: () => [
          const SearchLoading(),
          SearchCompleted(query: tQuery, results: [tItem]),
        ],
        verify: (_) {
          verify(() => mockSearchItemsUseCase(any())).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchEmpty] when no results found',
        build: () {
          when(
            () => mockSearchItemsUseCase(any()),
          ).thenAnswer((_) async => const Right(<ItemEntity>[]));
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        expect: () => [const SearchLoading(), const SearchEmpty(query: tQuery)],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchError] when search fails',
        build: () {
          when(() => mockSearchItemsUseCase(any())).thenAnswer(
            (_) => Future<Either<Failure, List<ItemEntity>>>.value(
              Left<Failure, List<ItemEntity>>(ServerFailure('error')),
            ),
          );
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchQueryChanged(tQuery)),
        expect: () => [
          const SearchLoading(),
          const SearchError(message: 'error'),
        ],
      );
    });

    group('ClearSearch', () {
      blocTest<SearchBloc, SearchState>(
        'emits [SearchInitial] when search is cleared',
        build: () => searchBloc,
        seed: () => SearchCompleted(query: tQuery, results: [tItem]),
        act: (bloc) => bloc.add(const ClearSearch()),
        expect: () => [const SearchInitial()],
      );
    });

    group('SearchWithFilters', () {
      const tNewFilters = SearchFilterEntity(minPrice: 100, maxPrice: 1000);

      blocTest<SearchBloc, SearchState>(
        'triggers new search with updated filters',
        build: () {
          when(
            () => mockSearchItemsUseCase(any()),
          ).thenAnswer((_) async => Right([tItem]));
          return searchBloc;
        },
        seed: () => SearchCompleted(query: tQuery, results: [tItem]),
        act: (bloc) => bloc.add(
          const SearchWithFilters(query: tQuery, filters: tNewFilters),
        ),
        expect: () => [
          const SearchLoading(),
          SearchCompleted(query: tQuery, results: [tItem]),
        ],
        verify: (_) {
          verify(() => mockSearchItemsUseCase(any())).called(1);
        },
      );
    });

    // The current SearchBloc does not expose a suggestions stream; suggestion
    // use case is reserved for future interactive search UI. The mock is kept
    // to satisfy the constructor contract, and interactions are covered via
    // verify() calls in other tests when needed.
  });
}
