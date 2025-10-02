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
}
