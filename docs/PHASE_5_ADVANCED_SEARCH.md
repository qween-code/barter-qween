# Phase 5: Advanced Search & Filtering System

## Overview
Implement advanced search functionality with comprehensive filtering capabilities for items, users, and trade offers.

## Features

### 1. Search Infrastructure
- **Algolia/Firebase Search Integration**
  - Real-time search indexing
  - Fuzzy matching and typo tolerance
  - Multi-field search (title, description, tags, category)
  - Search analytics and suggestions

- **Search Domain Layer**
  - SearchEntity (search query, filters, results)
  - SearchRepository interface
  - Search use cases

### 2. Filter System
- **Item Filters**
  - Category & Subcategory
  - Condition (New, Like New, Good, Fair, Poor)
  - Price range (estimated value)
  - Color selection
  - Location/City
  - Date range (posted date)
  - Sort options (newest, oldest, most viewed, most favorited)
  - Status (active, pending, traded)
  - Tags

- **User Filters**
  - Verification status
  - Rating range
  - Location
  - Join date
  - Activity level

- **Trade Offer Filters**
  - Status (pending, accepted, rejected, completed)
  - Date range
  - Value range
  - Sort by date/value

### 3. Search UI Components
- **SearchBarWidget**
  - Auto-complete suggestions
  - Search history
  - Voice search (optional)
  - Clear/reset button

- **FilterSheet (Bottom Sheet)**
  - Category filter chips
  - Condition selector
  - Price range slider
  - Color picker grid
  - Location picker
  - Date range picker
  - Sort options
  - Apply/Reset buttons
  - Active filter count badge

- **SearchResultsPage**
  - Grid/List view toggle
  - Sort dropdown
  - Filter button with badge
  - Result count
  - Empty state
  - Loading state
  - Infinite scroll pagination

- **FilterChipsRow**
  - Active filters display
  - Quick remove filters
  - Clear all filters

### 4. Recent Searches & Suggestions
- **LocalStorage for Recent Searches**
  - Save last 10 searches
  - Display in search bar dropdown
  - Clear history option

- **Popular Searches**
  - Track search analytics
  - Display trending searches
  - Category-based suggestions

### 5. Search State Management (BLoC)
- **SearchBloc**
  - SearchStarted event
  - SearchQueryChanged event
  - FiltersApplied event
  - SortChanged event
  - ClearFilters event
  - SaveRecentSearch event
  - States: Initial, Loading, Loaded, Error, Empty

### 6. Advanced Features
- **Saved Searches**
  - Save search queries with filters
  - Notifications for new matches
  - Manage saved searches

- **Search Analytics**
  - Track popular searches
  - Search conversion tracking
  - User behavior insights

## Technical Architecture

### Domain Layer
```
lib/domain/
├── entities/
│   ├── search_entity.dart
│   ├── search_filter_entity.dart
│   └── search_suggestion_entity.dart
├── repositories/
│   └── search_repository.dart
└── usecases/
    ├── search_items_usecase.dart
    ├── search_users_usecase.dart
    ├── apply_filters_usecase.dart
    ├── save_search_usecase.dart
    └── get_search_suggestions_usecase.dart
```

### Data Layer
```
lib/data/
├── models/
│   ├── search_model.dart
│   ├── search_filter_model.dart
│   └── search_result_model.dart
├── datasources/
│   ├── search_remote_data_source.dart (Firestore/Algolia)
│   └── search_local_data_source.dart (Recent searches)
└── repositories/
    └── search_repository_impl.dart
```

### Presentation Layer
```
lib/presentation/
├── blocs/
│   └── search/
│       ├── search_bloc.dart
│       ├── search_event.dart
│       └── search_state.dart
├── pages/
│   └── search/
│       ├── search_page.dart
│       └── search_results_page.dart
└── widgets/
    └── search/
        ├── search_bar_widget.dart
        ├── filter_bottom_sheet.dart
        ├── filter_chips_row.dart
        ├── category_filter_widget.dart
        ├── price_range_filter.dart
        ├── condition_filter.dart
        ├── color_filter.dart
        ├── location_filter.dart
        └── search_result_card.dart
```

## Implementation Plan

### Step 1: Domain Layer (1-2 hours)
- [ ] Create SearchEntity with filter properties
- [ ] Create SearchFilterEntity
- [ ] Define SearchRepository interface
- [ ] Implement search use cases

### Step 2: Data Layer (2-3 hours)
- [ ] Create search models with JSON serialization
- [ ] Implement SearchRemoteDataSource (Firestore query)
- [ ] Implement SearchLocalDataSource (SharedPreferences for recent searches)
- [ ] Implement SearchRepositoryImpl

### Step 3: BLoC Layer (1-2 hours)
- [ ] Create SearchEvent classes
- [ ] Create SearchState classes
- [ ] Implement SearchBloc with search logic
- [ ] Add debouncing for search queries

### Step 4: UI Components (3-4 hours)
- [ ] SearchBarWidget with auto-complete
- [ ] FilterBottomSheet with all filter options
- [ ] FilterChipsRow for active filters
- [ ] SearchResultsPage with grid/list toggle
- [ ] Individual filter widgets

### Step 5: Integration (1-2 hours)
- [ ] Add search icon to app bar
- [ ] Navigate to search page
- [ ] Connect SearchBloc to widgets
- [ ] Test search and filtering
- [ ] Add dependency injection

### Step 6: Firebase/Firestore Optimization (1-2 hours)
- [ ] Create Firestore composite indexes
- [ ] Optimize queries for filtering
- [ ] Add pagination for search results
- [ ] Cache search results

### Step 7: Testing & Polish (1-2 hours)
- [ ] Unit tests for search use cases
- [ ] Widget tests for search components
- [ ] Integration tests for search flow
- [ ] Performance optimization
- [ ] Error handling and edge cases

## Firebase Firestore Indexes Required

```javascript
// items collection composite indexes
{
  collectionGroup: "items",
  queryScope: "COLLECTION",
  fields: [
    { fieldPath: "status", order: "ASCENDING" },
    { fieldPath: "category", order: "ASCENDING" },
    { fieldPath: "createdAt", order: "DESCENDING" }
  ]
},
{
  collectionGroup: "items",
  queryScope: "COLLECTION",
  fields: [
    { fieldPath: "status", order: "ASCENDING" },
    { fieldPath: "price", order: "ASCENDING" },
    { fieldPath: "createdAt", order: "DESCENDING" }
  ]
},
{
  collectionGroup: "items",
  queryScope: "COLLECTION",
  fields: [
    { fieldPath: "status", order: "ASCENDING" },
    { fieldPath: "city", order: "ASCENDING" },
    { fieldPath: "createdAt", order: "DESCENDING" }
  ]
}
```

## Filter Options Data Structure

```dart
class SearchFilters {
  // Category & Subcategory
  final List<String>? categories;
  final List<String>? subcategories;
  
  // Item properties
  final List<String>? conditions;
  final List<String>? colors;
  final List<ItemStatus>? statuses;
  
  // Price range
  final double? minPrice;
  final double? maxPrice;
  
  // Location
  final List<String>? cities;
  final double? radiusKm;
  final GeoPoint? centerLocation;
  
  // Date range
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Tags
  final List<String>? tags;
  
  // Sort
  final SortOption sortBy;
  final SortDirection sortDirection;
  
  // Pagination
  final int? limit;
  final DocumentSnapshot? startAfter;
}

enum SortOption {
  createdAt,
  price,
  viewCount,
  favoriteCount,
  title,
}

enum SortDirection {
  ascending,
  descending,
}
```

## Estimated Time
- **Total: 10-15 hours**
- Domain & Data Layers: 3-5 hours
- BLoC Layer: 1-2 hours
- UI Components: 3-4 hours
- Integration & Testing: 2-3 hours
- Firebase setup & optimization: 1-2 hours

## Success Criteria
✅ Users can search items with real-time results  
✅ Multiple filters can be applied simultaneously  
✅ Search results update dynamically  
✅ Recent searches are saved and displayed  
✅ Filter UI is intuitive and responsive  
✅ Pagination works correctly  
✅ Performance is optimized (< 500ms response)  
✅ Empty states and error handling work properly  

## Notes
- Consider using Algolia for production for better search performance
- Implement search analytics to understand user behavior
- Add search suggestions based on popular queries
- Consider adding AI-powered recommendations based on search history
