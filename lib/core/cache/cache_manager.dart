import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/item_entity.dart';

/// Simple in-memory + persistent cache manager
/// Implements cache-first strategy with TTL (Time To Live)
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // In-memory caches
  final Map<String, _CacheEntry<dynamic>> _memoryCache = {};

  // Cache TTL durations
  static const Duration userCacheTTL = Duration(minutes: 10);
  static const Duration itemsCacheTTL = Duration(minutes: 5);
  static const Duration profileStatsTTL = Duration(minutes: 15);

  // SharedPreferences instance
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Generic get from memory cache
  T? getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Generic set to memory cache
  void setInMemory<T>(String key, T data, {Duration? ttl}) {
    _memoryCache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? const Duration(minutes: 5)),
    );
  }

  /// Clear specific key from memory
  void clearMemory(String key) {
    _memoryCache.remove(key);
  }

  /// Clear all memory cache
  void clearAllMemory() {
    _memoryCache.clear();
  }

  /// User-specific cache methods
  Future<void> cacheUser(String userId, UserEntity user) async {
    // Memory cache
    setInMemory('user_$userId', user, ttl: userCacheTTL);

    // Persistent cache (for offline access)
    if (_prefs != null) {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'city': user.city,
        'address': user.address,
        'bio': user.bio,
        'isEmailVerified': user.isEmailVerified,
      };
      await _prefs!.setString('user_$userId', jsonEncode(userData));
    }
  }

  UserEntity? getCachedUser(String userId) {
    return getFromMemory<UserEntity>('user_$userId');
  }

  Future<void> clearUserCache(String userId) async {
    clearMemory('user_$userId');
    await _prefs?.remove('user_$userId');
  }

  /// Items cache methods
  void cacheItems(List<ItemEntity> items, {String? category}) {
    final key = category != null ? 'items_$category' : 'items_all';
    setInMemory(key, items, ttl: itemsCacheTTL);
  }

  List<ItemEntity>? getCachedItems({String? category}) {
    final key = category != null ? 'items_$category' : 'items_all';
    return getFromMemory<List<ItemEntity>>(key);
  }

  void clearItemsCache() {
    _memoryCache.removeWhere((key, value) => key.startsWith('items_'));
  }

  /// Profile stats cache
  void cacheProfileStats(String userId, Map<String, dynamic> stats) {
    setInMemory('stats_$userId', stats, ttl: profileStatsTTL);
  }

  Map<String, dynamic>? getCachedProfileStats(String userId) {
    return getFromMemory<Map<String, dynamic>>('stats_$userId');
  }

  /// Clear all caches
  Future<void> clearAll() async {
    clearAllMemory();
    await _prefs?.clear();
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
