# 📊 Analytics Events Guide - Phase 2
## Barter Qween - Comprehensive Event Tracking

**Created:** January 16, 2025  
**Version:** 2.0 (Enhanced)  
**Service:** `lib/core/services/analytics_service.dart`

---

## 🎯 **Overview**

This guide documents all 40+ analytics events tracked in Barter Qween. Use this for:
- Understanding user behavior
- Building conversion funnels
- A/B testing
- Performance monitoring
- Data-driven product decisions

---

## 📑 **Event Categories**

### **1. Search & Discovery (5 events)**

#### `search_performed`
Advanced search with filters.
```dart
await analyticsService.logSearchWithFilters(
  query: 'iPhone',
  category: 'Electronics',
  minPrice: 1000,
  maxPrice: 5000,
  condition: 'excellent',
  city: 'İstanbul',
  resultsCount: 42,
);
```

#### `filter_applied`
User applies a filter.
```dart
await analyticsService.logFilterApplied(
  filterType: 'price',
  filterValue: '1000-5000',
);
```

#### `sort_changed`
User changes sort order.
```dart
await analyticsService.logSortChanged(sortType: 'price_low_to_high');
```

#### `category_browsed`
User browses a specific category.
```dart
await analyticsService.logCategoryBrowsed(category: 'Electronics');
```

---

### **2. Item Interactions (6 events)**

#### `item_clicked`
Item clicked from search/feed (with source tracking).
```dart
await analyticsService.logItemClicked(
  itemId: 'item_123',
  source: 'search', // or 'feed', 'recommendations', 'profile'
  position: 3,
);
```

#### `item_shared`
Item shared via social media.
```dart
await analyticsService.logItemShared(
  itemId: 'item_123',
  method: 'whatsapp', // or 'telegram', 'instagram', 'copy_link'
);
```

#### `similar_items_viewed`
User viewed similar items carousel.
```dart
await analyticsService.logSimilarItemsViewed(
  sourceItemId: 'item_123',
  count: 10,
);
```

#### `item_image_fullscreen`
User viewed item image in fullscreen.
```dart
await analyticsService.logItemImageFullscreen(
  itemId: 'item_123',
  imageIndex: 2,
);
```

#### `seller_contact_clicked`
User clicked to contact seller.
```dart
await analyticsService.logSellerContactClicked(
  itemId: 'item_123',
  sellerId: 'user_456',
);
```

---

### **3. Listing Creation Funnel (7 events)**

Track the entire listing creation flow to identify drop-off points.

#### `listing_started`
User started creating a listing.
```dart
await analyticsService.logListingStarted();
```

#### `listing_photo_uploaded`
Photos uploaded.
```dart
await analyticsService.logListingPhotoUploaded(photoCount: 3);
```

#### `listing_category_selected`
Category selected.
```dart
await analyticsService.logListingCategorySelected(category: 'Electronics');
```

#### `listing_price_entered`
Price entered (track if suggestion was used).
```dart
await analyticsService.logListingPriceEntered(
  price: 2500.0,
  usedSuggestion: true,
);
```

#### `listing_location_added`
Location added.
```dart
await analyticsService.logListingLocationAdded(
  city: 'İstanbul',
  usedMap: true,
);
```

#### `listing_abandoned`
User abandoned listing creation.
```dart
await analyticsService.logListingAbandoned(
  abandonedAt: 'price', // or 'photos', 'details', 'location'
);
```

#### `item_created`
Listing successfully created.
```dart
await analyticsService.logItemCreated(
  itemId: 'item_789',
  category: 'Electronics',
);
```

**Funnel Flow:**
```
listing_started → 
  listing_photo_uploaded → 
  listing_category_selected → 
  listing_price_entered → 
  listing_location_added → 
  item_created ✅
  
OR listing_abandoned ❌
```

---

### **4. Conversion Tracking (5 events)**

#### `sign_up`
User signed up.
```dart
await analyticsService.logSignup(method: 'google'); // or 'email', 'apple'
```

#### `login`
User logged in.
```dart
await analyticsService.logLogin(method: 'google');
```

#### `first_item_listed`
First listing created (key milestone).
```dart
await analyticsService.logFirstItemListed(itemId: 'item_123');
```

#### `first_trade_completed`
First trade completed (activation milestone).
```dart
await analyticsService.logFirstTradeCompleted(tradeId: 'trade_456');
```

#### `user_verified`
User completed verification.
```dart
await analyticsService.logUserVerified(verificationType: 'phone'); // or 'id', 'selfie'
```

---

### **5. Engagement Metrics (5 events)**

#### `session_start`
App session started.
```dart
await analyticsService.logSessionStart();
```

#### `session_end`
App session ended (with duration).
```dart
await analyticsService.logSessionEnd(durationSeconds: 420);
```

#### `feature_used`
Any feature used.
```dart
await analyticsService.logFeatureUsed(
  featureName: 'map_view',
  additionalParams: {'zoom_level': 15},
);
```

#### `map_interaction`
Map widget interaction.
```dart
await analyticsService.logMapInteraction(
  action: 'marker_click', // or 'zoom', 'pan', 'fullscreen'
  itemId: 'item_123',
);
```

#### `trust_badge_viewed`
User viewed a trust badge.
```dart
await analyticsService.logTrustBadgeViewed(
  badgeType: 'verified',
  userId: 'user_456',
);
```

---

### **6. Error & Performance (2 events)**

#### `error_occurred`
App error occurred.
```dart
await analyticsService.logError(
  errorType: 'network',
  errorMessage: 'Failed to load items',
  stackTrace: error.toString(),
);
```

#### `slow_operation`
Operation took too long.
```dart
await analyticsService.logSlowOperation(
  operation: 'load_items',
  durationMs: 3500,
);
```

---

### **7. A/B Testing (1 event)**

#### `experiment_variant`
Track which variant user sees.
```dart
await analyticsService.logExperimentVariant(
  experimentName: 'search_algorithm_v2',
  variantName: 'control', // or 'variant_a', 'variant_b'
);
```

---

### **8. Existing Events (Maintained)**

All previous events still work:
- `logItemViewed()`
- `logFavoriteToggled()`
- `logTradeOfferSent()`
- `logMessageSent()`
- `logSearch()`
- `logTradeAccepted()`
- `logTradeRejected()`
- `logTradeCompleted()`
- `logUserRated()`
- `logProfileViewed()`
- `logConversationStarted()`
- `logNotificationOpened()`
- `logScreenView()`

---

## 📈 **Key Metrics & Funnels**

### **Listing Creation Funnel**
```
Started: 1000 users
├─ Photo Uploaded: 850 (15% drop)
├─ Category Selected: 800 (5% drop)
├─ Price Entered: 720 (10% drop)
├─ Location Added: 680 (5% drop)
└─ Published: 600 (12% drop)

Overall Conversion: 60%
```

### **Search to Purchase Funnel**
```
Search: 5000 searches
├─ Results Viewed: 4500 (90%)
├─ Item Clicked: 1500 (33%)
├─ Seller Contacted: 450 (30%)
└─ Trade Completed: 180 (40%)

Overall Conversion: 3.6%
```

### **User Activation Funnel**
```
Signup: 1000 users
├─ First Login: 950 (95%)
├─ Profile Completed: 800 (84%)
├─ First Item Listed: 500 (62%)
└─ First Trade: 200 (40%)

Activation Rate: 20%
```

---

## 🎯 **Success Metrics - Phase 2 Goals**

**Search Performance:**
- [ ] Search result relevance: 80%+ satisfaction
- [ ] Search speed: <100ms
- [ ] Search engagement: 30%+ increase

**Listing Quality:**
- [ ] Listings with AI suggestions: 60%+
- [ ] Listing completion rate: +25%
- [ ] Time to create listing: -40%

**Engagement:**
- [ ] DAU/MAU ratio: 30% → 45%
- [ ] Session duration: +40%
- [ ] Items viewed per session: +50%

**Revenue Impact:**
- [ ] Items sold: +30%
- [ ] Average sale price: +10%
- [ ] Time-to-sell: -20%

---

## 🔧 **Implementation Examples**

### **In Pages/Widgets:**
```dart
class ItemDetailPage extends StatelessWidget {
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  
  @override
  void initState() {
    super.initState();
    // Track page view
    _analytics.logItemViewed(itemId: widget.itemId);
  }
  
  void _onSharePressed() {
    // Track share
    _analytics.logItemShared(
      itemId: widget.itemId,
      method: 'whatsapp',
    );
    // Share logic...
  }
  
  void _onImageTapped(int index) {
    // Track fullscreen
    _analytics.logItemImageFullscreen(
      itemId: widget.itemId,
      imageIndex: index,
    );
    // Show fullscreen...
  }
}
```

### **In BLoCs:**
```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AnalyticsService _analytics;
  
  SearchBloc(this._analytics) : super(SearchInitial()) {
    on<SearchPerformed>((event, emit) async {
      // Perform search...
      final results = await _repository.search(event.query);
      
      // Track search
      await _analytics.logSearchWithFilters(
        query: event.query,
        category: event.filters.category,
        resultsCount: results.length,
      );
      
      emit(SearchLoaded(results));
    });
  }
}
```

---

## 📊 **Firebase Analytics Dashboard**

**View your analytics:**
1. Firebase Console → Analytics → Events
2. Filter by event name
3. Create custom funnels
4. Setup conversion tracking
5. Export to BigQuery for advanced analysis

**Recommended Dashboards:**
- User Acquisition (signup → first_item_listed)
- Listing Creation Funnel (listing_started → item_created)
- Search Performance (search_performed → item_clicked)
- Feature Usage (all feature_used events)
- Error Monitoring (error_occurred + slow_operation)

---

## 🚀 **Next Steps**

1. ✅ Enhanced AnalyticsService implemented
2. ⏳ Integrate events in key user flows
3. ⏳ Setup Firebase funnels
4. ⏳ Create custom dashboards
5. ⏳ Setup Mixpanel (optional, for advanced cohort analysis)

---

**Questions?** Check `lib/core/services/analytics_service.dart` for implementation details.
