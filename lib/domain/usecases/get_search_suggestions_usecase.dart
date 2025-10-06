import 'package:injectable/injectable.dart';
import '../repositories/item_repository.dart';

@injectable
class GetSearchSuggestionsUseCase {
  final ItemRepository _itemRepository;

  GetSearchSuggestionsUseCase(this._itemRepository);

  Future<List<String>> call(String query) async {
    return await _itemRepository.getSearchSuggestions(query);
  }
}
