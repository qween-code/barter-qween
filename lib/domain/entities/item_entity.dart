import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> images;
  final String? condition; // New, Like New, Good, Fair, Poor
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String? location;
  final String? city;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final int favoriteCount;
  final List<String>? tags;
  final bool isFeatured;
  final String? tradePreference; // What user wants in exchange

  const ItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.images,
    this.condition,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    this.location,
    this.city,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.tags,
    this.isFeatured = false,
    this.tradePreference,
  });

  ItemEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? images,
    String? condition,
    String? ownerId,
    String? ownerName,
    String? ownerPhotoUrl,
    String? location,
    String? city,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
    List<String>? tags,
    bool? isFeatured,
    String? tradePreference,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhotoUrl: ownerPhotoUrl ?? this.ownerPhotoUrl,
      location: location ?? this.location,
      city: city ?? this.city,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      tradePreference: tradePreference ?? this.tradePreference,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        images,
        condition,
        ownerId,
        ownerName,
        ownerPhotoUrl,
        location,
        city,
        status,
        createdAt,
        updatedAt,
        viewCount,
        favoriteCount,
        tags,
        isFeatured,
        tradePreference,
      ];
}

enum ItemStatus {
  active,
  pending, // Trade in progress
  traded, // Successfully traded
  deleted,
  expired,
}

// Item Categories
class ItemCategory {
  static const String electronics = 'Electronics';
  static const String clothing = 'Clothing';
  static const String books = 'Books';
  static const String furniture = 'Furniture';
  static const String toys = 'Toys';
  static const String sports = 'Sports';
  static const String home = 'Home & Garden';
  static const String beauty = 'Beauty';
  static const String automotive = 'Automotive';
  static const String collectibles = 'Collectibles';
  static const String other = 'Other';

  static List<String> get all => [
        electronics,
        clothing,
        books,
        furniture,
        toys,
        sports,
        home,
        beauty,
        automotive,
        collectibles,
        other,
      ];
}

// Item Conditions
class ItemCondition {
  static const String brandNew = 'Brand New';
  static const String likeNew = 'Like New';
  static const String good = 'Good';
  static const String fair = 'Fair';
  static const String poor = 'Poor';

  static List<String> get all => [
        brandNew,
        likeNew,
        good,
        fair,
        poor,
      ];
}
