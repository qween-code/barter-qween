import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

/// Enhanced Analytics Service - Phase 2
/// 
/// Comprehensive event tracking for:
/// - User behavior analysis
/// - Conversion funnels
/// - Feature usage
/// - Engagement metrics
/// - A/B testing support
@LazySingleton()
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver _observer;

  AnalyticsService(this._analytics, this._observer);

  FirebaseAnalyticsObserver get observer => _observer;

  // ========================================
  // PHASE 2: ENHANCED ANALYTICS
  // ========================================

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

  // ========================================
  // PHASE 2: SEARCH & DISCOVERY
  // ========================================

  /// Track search performed with filters
  Future<void> logSearchWithFilters({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? city,
    int? resultsCount,
  }) async {
    await _analytics.logEvent(name: 'search_performed', parameters: {
      'query': query,
      if (category != null) 'category': category,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (condition != null) 'condition': condition,
      if (city != null) 'city': city,
      if (resultsCount != null) 'results_count': resultsCount,
    });
  }

  /// Track filter applied
  Future<void> logFilterApplied({
    required String filterType,
    required String filterValue,
  }) async {
    await _analytics.logEvent(name: 'filter_applied', parameters: {
      'filter_type': filterType,
      'filter_value': filterValue,
    });
  }

  /// Track sort option changed
  Future<void> logSortChanged({required String sortType}) async {
    await _analytics.logEvent(name: 'sort_changed', parameters: {
      'sort_type': sortType,
    });
  }

  /// Track category browsed
  Future<void> logCategoryBrowsed({required String category}) async {
    await _analytics.logEvent(name: 'category_browsed', parameters: {
      'category': category,
    });
  }

  // ========================================
  // PHASE 2: ITEM INTERACTIONS
  // ========================================

  /// Track item clicked from search/feed
  Future<void> logItemClicked({
    required String itemId,
    required String source, // 'search', 'feed', 'recommendations', 'profile'
    int? position,
  }) async {
    await _analytics.logSelectContent(
      contentType: 'item',
      itemId: itemId,
    );
    await _analytics.logEvent(name: 'item_clicked', parameters: {
      'item_id': itemId,
      'source': source,
      if (position != null) 'position': position,
    });
  }

  /// Track item shared
  Future<void> logItemShared({
    required String itemId,
    required String method, // 'whatsapp', 'telegram', 'instagram', 'copy_link'
  }) async {
    await _analytics.logShare(
      contentType: 'item',
      itemId: itemId,
      method: method,
    );
  }

  /// Track similar items viewed
  Future<void> logSimilarItemsViewed({
    required String sourceItemId,
    required int count,
  }) async {
    await _analytics.logEvent(name: 'similar_items_viewed', parameters: {
      'source_item_id': sourceItemId,
      'count': count,
    });
  }

  /// Track item image fullscreen
  Future<void> logItemImageFullscreen({
    required String itemId,
    required int imageIndex,
  }) async {
    await _analytics.logEvent(name: 'item_image_fullscreen', parameters: {
      'item_id': itemId,
      'image_index': imageIndex,
    });
  }

  /// Track seller contact button clicked
  Future<void> logSellerContactClicked({
    required String itemId,
    required String sellerId,
  }) async {
    await _analytics.logEvent(name: 'seller_contact_clicked', parameters: {
      'item_id': itemId,
      'seller_id': sellerId,
    });
  }

  // ========================================
  // PHASE 2: LISTING CREATION FUNNEL
  // ========================================

  /// Track listing creation started
  Future<void> logListingStarted() async {
    await _analytics.logEvent(name: 'listing_started', parameters: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track photo uploaded
  Future<void> logListingPhotoUploaded({required int photoCount}) async {
    await _analytics.logEvent(name: 'listing_photo_uploaded', parameters: {
      'photo_count': photoCount,
    });
  }

  /// Track category selected
  Future<void> logListingCategorySelected({required String category}) async {
    await _analytics.logEvent(name: 'listing_category_selected', parameters: {
      'category': category,
    });
  }

  /// Track price entered
  Future<void> logListingPriceEntered({
    required double price,
    bool? usedSuggestion,
  }) async {
    await _analytics.logEvent(name: 'listing_price_entered', parameters: {
      'price': price,
      if (usedSuggestion != null) 'used_suggestion': usedSuggestion,
    });
  }

  /// Track location added
  Future<void> logListingLocationAdded({
    required String city,
    bool? usedMap,
  }) async {
    await _analytics.logEvent(name: 'listing_location_added', parameters: {
      'city': city,
      if (usedMap != null) 'used_map': usedMap,
    });
  }

  /// Track listing abandoned (user left without publishing)
  Future<void> logListingAbandoned({
    required String abandonedAt, // 'photos', 'details', 'price', 'location'
  }) async {
    await _analytics.logEvent(name: 'listing_abandoned', parameters: {
      'abandoned_at': abandonedAt,
    });
  }

  // ========================================
  // PHASE 2: CONVERSION TRACKING
  // ========================================

  /// Track user signup method
  Future<void> logSignup({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Track user login
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Track first item listed (conversion milestone)
  Future<void> logFirstItemListed({required String itemId}) async {
    await _analytics.logEvent(name: 'first_item_listed', parameters: {
      'item_id': itemId,
    });
  }

  /// Track first trade completed (key conversion)
  Future<void> logFirstTradeCompleted({required String tradeId}) async {
    await _analytics.logEvent(name: 'first_trade_completed', parameters: {
      'trade_id': tradeId,
    });
  }

  /// Track user became verified
  Future<void> logUserVerified({required String verificationType}) async {
    await _analytics.logEvent(name: 'user_verified', parameters: {
      'verification_type': verificationType,
    });
  }

  // ========================================
  // PHASE 2: ENGAGEMENT METRICS
  // ========================================

  /// Track session start
  Future<void> logSessionStart() async {
    await _analytics.logEvent(name: 'session_start', parameters: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track session duration
  Future<void> logSessionEnd({required int durationSeconds}) async {
    await _analytics.logEvent(name: 'session_end', parameters: {
      'duration_seconds': durationSeconds,
    });
  }

  /// Track feature used
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, dynamic>? additionalParams,
  }) async {
    await _analytics.logEvent(name: 'feature_used', parameters: {
      'feature_name': featureName,
      if (additionalParams != null) ...additionalParams,
    });
  }

  /// Track map interaction
  Future<void> logMapInteraction({
    required String action, // 'zoom', 'pan', 'marker_click', 'fullscreen'
    String? itemId,
  }) async {
    await _analytics.logEvent(name: 'map_interaction', parameters: {
      'action': action,
      if (itemId != null) 'item_id': itemId,
    });
  }

  /// Track trust badge viewed
  Future<void> logTrustBadgeViewed({
    required String badgeType,
    required String userId,
  }) async {
    await _analytics.logEvent(name: 'trust_badge_viewed', parameters: {
      'badge_type': badgeType,
      'user_id': userId,
    });
  }

  // ========================================
  // PHASE 2: ERROR & PERFORMANCE TRACKING
  // ========================================

  /// Track error occurred
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(name: 'error_occurred', parameters: {
      'error_type': errorType,
      'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  /// Track slow operation
  Future<void> logSlowOperation({
    required String operation,
    required int durationMs,
  }) async {
    await _analytics.logEvent(name: 'slow_operation', parameters: {
      'operation': operation,
      'duration_ms': durationMs,
    });
  }

  // ========================================
  // PHASE 2: A/B TESTING SUPPORT
  // ========================================

  /// Track experiment variant shown
  Future<void> logExperimentVariant({
    required String experimentName,
    required String variantName,
  }) async {
    await _analytics.logEvent(name: 'experiment_variant', parameters: {
      'experiment_name': experimentName,
      'variant_name': variantName,
    });
  }

  // ========================================
  // PHASE 2: USER PROPERTIES (Enhanced)
  // ========================================

  /// Set comprehensive user properties
  Future<void> setEnhancedUserProperties({
    required String userId,
    String? city,
    String? trustScore,
    int? itemsListed,
    int? tradesCompleted,
    bool? isPremium,
  }) async {
    await _analytics.setUserId(id: userId);
    
    if (city != null) {
      await _analytics.setUserProperty(name: 'city', value: city);
    }
    if (trustScore != null) {
      await _analytics.setUserProperty(name: 'trust_score', value: trustScore);
    }
    if (itemsListed != null) {
      await _analytics.setUserProperty(name: 'items_listed', value: itemsListed.toString());
    }
    if (tradesCompleted != null) {
      await _analytics.setUserProperty(name: 'trades_completed', value: tradesCompleted.toString());
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(name: 'is_premium', value: isPremium.toString());
    }
  }

  // ========================================
  // PHASE 2: CUSTOM EVENTS
  // ========================================

  /// Generic custom event tracking
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
