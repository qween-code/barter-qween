import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/search/search_result_entity.dart';

/// Local data source for search-related data (recent searches)
@injectable
class SearchLocalDataSource {
  final SharedPreferences prefs;
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  SearchLocalDataSource(this.prefs);

  /// Save a recent search
  Future<void> saveRecentSearch({
    required String query,
    required int resultCount,
  }) async {
    final searches = await getRecentSearches();
    
    // Remove existing search with same query
    searches.removeWhere((s) => s.query.toLowerCase() == query.toLowerCase());
    
    // Add new search at the beginning
    searches.insert(
      0,
      RecentSearchEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query,
        searchedAt: DateTime.now(),
        resultCount: resultCount,
      ),
    );
    
    // Keep only max recent searches
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }
    
    // Save to preferences
    final jsonList = searches
        .map((s) => {
              'id': s.id,
              'query': s.query,
              'searchedAt': s.searchedAt.toIso8601String(),
              'resultCount': s.resultCount,
            })
        .toList();
    
    await prefs.setString(_recentSearchesKey, jsonEncode(jsonList));
  }

  /// Get recent searches
  Future<List<RecentSearchEntity>> getRecentSearches() async {
    final jsonString = prefs.getString(_recentSearchesKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => RecentSearchEntity(
                id: json['id'],
                query: json['query'],
                searchedAt: DateTime.parse(json['searchedAt']),
                resultCount: json['resultCount'],
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    await prefs.remove(_recentSearchesKey);
  }

  /// Delete a specific recent search
  Future<void> deleteRecentSearch(String searchId) async {
    final searches = await getRecentSearches();
    searches.removeWhere((s) => s.id == searchId);
    
    final jsonList = searches
        .map((s) => {
              'id': s.id,
              'query': s.query,
              'searchedAt': s.searchedAt.toIso8601String(),
              'resultCount': s.resultCount,
            })
        .toList();
    
    await prefs.setString(_recentSearchesKey, jsonEncode(jsonList));
  }
}
