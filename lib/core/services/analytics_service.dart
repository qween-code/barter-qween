import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver _observer;

  AnalyticsService(this._analytics, this._observer);

  FirebaseAnalyticsObserver get observer => _observer;

  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logItemViewed({required String itemId, String? category}) async {
    await _analytics.logViewItem(items: [
      AnalyticsEventItem(itemId: itemId, itemCategory: category),
    ]);
  }

  Future<void> logFavoriteToggled({required String itemId, required bool added}) async {
    await _analytics.logEvent(name: 'favorite_${added ? 'add' : 'remove'}', parameters: {
      'item_id': itemId,
    });
  }

  Future<void> logTradeOfferSent({required String tradeId, required String itemId}) async {
    await _analytics.logEvent(name: 'trade_offer_sent', parameters: {
      'trade_id': tradeId,
      'item_id': itemId,
    });
  }

  Future<void> logMessageSent({required String conversationId}) async {
    await _analytics.logEvent(name: 'message_sent', parameters: {
      'conversation_id': conversationId,
    });
  }

  Future<void> logSearch({required String query}) async {
    await _analytics.logSearch(searchTerm: query);
  }

  Future<void> enableCollection(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}