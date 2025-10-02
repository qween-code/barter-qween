import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/search/search_filter_entity.dart';

/// Model class for SearchFilterEntity with JSON serialization
class SearchFilterModel extends SearchFilterEntity {
  const SearchFilterModel({
    super.categories,
    super.subcategories,
    super.conditions,
    super.colors,
    super.statuses,
    super.minPrice,
    super.maxPrice,
    super.cities,
    super.radiusKm,
    super.centerLocation,
    super.startDate,
    super.endDate,
    super.tags,
    super.sortBy,
    super.sortDirection,
    super.limit,
    super.startAfter,
  });

  factory SearchFilterModel.fromEntity(SearchFilterEntity entity) {
    return SearchFilterModel(
      categories: entity.categories,
      subcategories: entity.subcategories,
      conditions: entity.conditions,
      colors: entity.colors,
      statuses: entity.statuses,
      minPrice: entity.minPrice,
      maxPrice: entity.maxPrice,
      cities: entity.cities,
      radiusKm: entity.radiusKm,
      centerLocation: entity.centerLocation,
      startDate: entity.startDate,
      endDate: entity.endDate,
      tags: entity.tags,
      sortBy: entity.sortBy,
      sortDirection: entity.sortDirection,
      limit: entity.limit,
      startAfter: entity.startAfter,
    );
  }

  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      subcategories: json['subcategories'] != null
          ? List<String>.from(json['subcategories'])
          : null,
      conditions: json['conditions'] != null
          ? List<String>.from(json['conditions'])
          : null,
      colors:
          json['colors'] != null ? List<String>.from(json['colors']) : null,
      statuses: json['statuses'] != null
          ? (json['statuses'] as List)
              .map((e) => ItemStatus.values.firstWhere(
                    (status) => status.toString() == 'ItemStatus.$e',
                    orElse: () => ItemStatus.active,
                  ))
              .toList()
          : null,
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      cities:
          json['cities'] != null ? List<String>.from(json['cities']) : null,
      radiusKm: json['radiusKm']?.toDouble(),
      centerLocation: json['centerLocation'] != null
          ? GeoPoint(
              json['centerLocation']['latitude'],
              json['centerLocation']['longitude'],
            )
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      sortBy: json['sortBy'] != null
          ? SortOption.values.firstWhere(
              (e) => e.toString() == 'SortOption.${json['sortBy']}',
              orElse: () => SortOption.createdAt,
            )
          : SortOption.createdAt,
      sortDirection: json['sortDirection'] != null
          ? SortDirection.values.firstWhere(
              (e) => e.toString() == 'SortDirection.${json['sortDirection']}',
              orElse: () => SortDirection.descending,
            )
          : SortDirection.descending,
      limit: json['limit'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (categories != null) 'categories': categories,
      if (subcategories != null) 'subcategories': subcategories,
      if (conditions != null) 'conditions': conditions,
      if (colors != null) 'colors': colors,
      if (statuses != null)
        'statuses': statuses!.map((e) => e.toString().split('.').last).toList(),
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (cities != null) 'cities': cities,
      if (radiusKm != null) 'radiusKm': radiusKm,
      if (centerLocation != null)
        'centerLocation': {
          'latitude': centerLocation!.latitude,
          'longitude': centerLocation!.longitude,
        },
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (tags != null) 'tags': tags,
      'sortBy': sortBy.toString().split('.').last,
      'sortDirection': sortDirection.toString().split('.').last,
      'limit': limit,
    };
  }
}
