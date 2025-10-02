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

  Future<void> logItemCreated({required String itemId, String? category}) async {
    await _analytics.logEvent(name: 'item_created', parameters: {
      'item_id': itemId,
      if (category != null) 'category': category,
    });
  }

  Future<void> logItemDeleted({required String itemId}) async {
    await _analytics.logEvent(name: 'item_deleted', parameters: {
      'item_id': itemId,
    });
  }

  Future<void> logTradeAccepted({required String tradeId}) async {
    await _analytics.logEvent(name: 'trade_accepted', parameters: {
      'trade_id': tradeId,
    });
  }

  Future<void> logTradeRejected({required String tradeId}) async {
    await _analytics.logEvent(name: 'trade_rejected', parameters: {
      'trade_id': tradeId,
    });
  }

  Future<void> logTradeCompleted({required String tradeId}) async {
    await _analytics.logEvent(name: 'trade_completed', parameters: {
      'trade_id': tradeId,
    });
  }

  Future<void> logUserRated({required String ratedUserId, required int rating}) async {
    await _analytics.logEvent(name: 'user_rated', parameters: {
      'rated_user_id': ratedUserId,
      'rating': rating,
    });
  }

  Future<void> logProfileViewed({required String profileUserId}) async {
    await _analytics.logEvent(name: 'profile_viewed', parameters: {
      'profile_user_id': profileUserId,
    });
  }

  Future<void> logConversationStarted({required String conversationId, required String otherUserId}) async {
    await _analytics.logEvent(name: 'conversation_started', parameters: {
      'conversation_id': conversationId,
      'other_user_id': otherUserId,
    });
  }

  Future<void> logNotificationOpened({required String notificationType, String? entityId}) async {
    await _analytics.logEvent(name: 'notification_opened', parameters: {
      'notification_type': notificationType,
      if (entityId != null) 'entity_id': entityId,
    });
  }

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> enableCollection(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}
