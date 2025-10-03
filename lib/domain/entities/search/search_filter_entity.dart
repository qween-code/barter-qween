import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../item_entity.dart';

/// Entity representing search filters for items
class SearchFilterEntity extends Equatable {
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

  // Specifications (Sprint 4)
  final Map<String, dynamic>? specifications;

  // Sort
  final SortOption sortBy;
  final SortDirection sortDirection;

  // Pagination
  final int limit;
  final DocumentSnapshot? startAfter;

  const SearchFilterEntity({
    this.categories,
    this.subcategories,
    this.conditions,
    this.colors,
    this.statuses,
    this.minPrice,
    this.maxPrice,
    this.cities,
    this.radiusKm,
    this.centerLocation,
    this.startDate,
    this.endDate,
    this.tags,
    this.specifications,
    this.sortBy = SortOption.createdAt,
    this.sortDirection = SortDirection.descending,
    this.limit = 20,
    this.startAfter,
  });

  /// Check if any filters are active
  bool get hasActiveFilters {
    return categories != null ||
        subcategories != null ||
        conditions != null ||
        colors != null ||
        statuses != null ||
        minPrice != null ||
        maxPrice != null ||
        cities != null ||
        startDate != null ||
        endDate != null ||
        tags != null ||
        specifications != null;
  }

  /// Count of active filters
  int get activeFilterCount {
    int count = 0;
    if (categories != null && categories!.isNotEmpty) count++;
    if (subcategories != null && subcategories!.isNotEmpty) count++;
    if (conditions != null && conditions!.isNotEmpty) count++;
    if (colors != null && colors!.isNotEmpty) count++;
    if (statuses != null && statuses!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (cities != null && cities!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    if (tags != null && tags!.isNotEmpty) count++;
    if (specifications != null && specifications!.isNotEmpty) count++;
    return count;
  }

  SearchFilterEntity copyWith({
    List<String>? categories,
    List<String>? subcategories,
    List<String>? conditions,
    List<String>? colors,
    List<ItemStatus>? statuses,
    double? minPrice,
    double? maxPrice,
    List<String>? cities,
    double? radiusKm,
    GeoPoint? centerLocation,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    SortOption? sortBy,
    SortDirection? sortDirection,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    return SearchFilterEntity(
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      conditions: conditions ?? this.conditions,
      colors: colors ?? this.colors,
      statuses: statuses ?? this.statuses,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      cities: cities ?? this.cities,
      radiusKm: radiusKm ?? this.radiusKm,
      centerLocation: centerLocation ?? this.centerLocation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      limit: limit ?? this.limit,
      startAfter: startAfter ?? this.startAfter,
    );
  }

  /// Clear all filters
  SearchFilterEntity clearAll() {
    return const SearchFilterEntity();
  }

  @override
  List<Object?> get props => [
        categories,
        subcategories,
        conditions,
        colors,
        statuses,
        minPrice,
        maxPrice,
        cities,
        radiusKm,
        centerLocation,
        startDate,
        endDate,
        tags,
        specifications,
        sortBy,
        sortDirection,
        limit,
        startAfter,
      ];
}

/// Sort options for search results
enum SortOption {
  createdAt,
  price,
  viewCount,
  favoriteCount,
  title,
}

/// Sort direction
enum SortDirection {
  ascending,
  descending,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.createdAt:
        return 'Date';
      case SortOption.price:
        return 'Price';
      case SortOption.viewCount:
        return 'Views';
      case SortOption.favoriteCount:
        return 'Favorites';
      case SortOption.title:
        return 'Title';
    }
  }

  String get firestoreField {
    switch (this) {
      case SortOption.createdAt:
        return 'createdAt';
      case SortOption.price:
        return 'price';
      case SortOption.viewCount:
        return 'viewCount';
      case SortOption.favoriteCount:
        return 'favoriteCount';
      case SortOption.title:
        return 'title';
    }
  }
}
