import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/item/item_usecases.dart';
import 'item_event.dart';
import 'item_state.dart';

@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetAllItemsUseCase getAllItemsUseCase;
  final GetUserItemsUseCase getUserItemsUseCase;
  final GetItemUseCase getItemUseCase;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;
  final SearchItemsUseCase searchItemsUseCase;
  final GetFeaturedItemsUseCase getFeaturedItemsUseCase;

  ItemBloc({
    required this.getAllItemsUseCase,
    required this.getUserItemsUseCase,
    required this.getItemUseCase,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
    required this.searchItemsUseCase,
    required this.getFeaturedItemsUseCase,
  }) : super(const ItemInitial()) {
    on<LoadAllItems>(_onLoadAllItems);
    on<LoadUserItems>(_onLoadUserItems);
    on<LoadItem>(_onLoadItem);
    on<CreateItem>(_onCreateItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<SearchItems>(_onSearchItems);
    on<LoadFeaturedItems>(_onLoadFeaturedItems);
    on<FilterItems>(_onFilterItems);
  }

  Future<void> _onLoadAllItems(
    LoadAllItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await getAllItemsUseCase(
      category: event.category,
      city: event.city,
    );
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadUserItems(
    LoadUserItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await getUserItemsUseCase(event.userId);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadItem(
    LoadItem event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await getItemUseCase(event.itemId);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemLoaded(item)),
    );
  }

  Future<void> _onCreateItem(
    CreateItem event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await createItemUseCase(event.item, event.images);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemCreated(item)),
    );
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await updateItemUseCase(event.item, event.newImages);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (item) => emit(ItemUpdated(item)),
    );
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await deleteItemUseCase(event.itemId);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (_) => emit(const ItemDeleted()),
    );
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await searchItemsUseCase(event.query);
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onLoadFeaturedItems(
    LoadFeaturedItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    final result = await getFeaturedItemsUseCase();
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onFilterItems(
    FilterItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemLoading());
    
    // Get all items first
    final result = await getAllItemsUseCase();
    
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) {
        var filteredItems = items;

        // Apply category filter
        if (event.categories != null && event.categories!.isNotEmpty) {
          filteredItems = filteredItems.where((item) {
            return event.categories!.contains(item.category);
          }).toList();
        }

        // Apply condition filter
        if (event.condition != null) {
          filteredItems = filteredItems.where((item) {
            return item.condition?.toLowerCase() == event.condition!.toLowerCase();
          }).toList();
        }

        // Apply price range filter
        if (event.minPrice != null || event.maxPrice != null) {
          filteredItems = filteredItems.where((item) {
            final itemPrice = item.estimatedValue ?? 0;
            final min = event.minPrice ?? 0;
            final max = event.maxPrice ?? double.infinity;
            return itemPrice >= min && itemPrice <= max;
          }).toList();
        }

        // Apply sorting
        if (event.sortBy != null) {
          switch (event.sortBy) {
            case 'newest':
              filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case 'oldest':
              filteredItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
            case 'popular':
              filteredItems.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
              break;
            case 'nearest':
              // For nearest, we'd need user location - for now just keep order
              break;
          }
        }

        emit(ItemsLoaded(filteredItems));
      },
    );
  }
}
