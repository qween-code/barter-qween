import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> images;
  final String? condition;
  final double? price;
  final String? color;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String? location;
  final String? city;
  final String status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final int viewCount;
  final int favoriteCount;
  final List<String>? tags;
  final bool isFeatured;
  final String? tradePreference;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.images,
    this.condition,
    this.price,
    this.color,
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

  // From JSON (for search results)
  factory ItemModel.fromJson(Map<String, dynamic> data) {
    return ItemModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      images: List<String>.from(data['images'] ?? []),
      condition: data['condition'],
      price: data['price']?.toDouble(),
      color: data['color'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhotoUrl: data['ownerPhotoUrl'],
      location: data['location'],
      city: data['city'],
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] is Timestamp 
          ? data['createdAt'] 
          : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : null,
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      isFeatured: data['isFeatured'] ?? false,
      tradePreference: data['tradePreference'],
    );
  }

  // From Firestore Document
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      images: List<String>.from(data['images'] ?? []),
      condition: data['condition'],
      price: data['price']?.toDouble(),
      color: data['color'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhotoUrl: data['ownerPhotoUrl'],
      location: data['location'],
      city: data['city'],
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      isFeatured: data['isFeatured'] ?? false,
      tradePreference: data['tradePreference'],
    );
  }

  // To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'images': images,
      'condition': condition,
      'price': price,
      'color': color,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'location': location,
      'city': city,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'tags': tags,
      'isFeatured': isFeatured,
      'tradePreference': tradePreference,
    };
  }

  // From Entity
  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      subcategory: entity.subcategory,
      images: entity.images,
      condition: entity.condition,
      price: entity.price,
      color: entity.color,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      ownerPhotoUrl: entity.ownerPhotoUrl,
      location: entity.location,
      city: entity.city,
      status: _statusToString(entity.status),
      createdAt: Timestamp.fromDate(entity.createdAt),
      updatedAt: entity.updatedAt != null 
          ? Timestamp.fromDate(entity.updatedAt!) 
          : null,
      viewCount: entity.viewCount,
      favoriteCount: entity.favoriteCount,
      tags: entity.tags,
      isFeatured: entity.isFeatured,
      tradePreference: entity.tradePreference,
    );
  }

  // To Entity
  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      subcategory: subcategory,
      images: images,
      condition: condition,
      price: price,
      color: color,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
      location: location,
      city: city,
      status: _stringToStatus(status),
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
      viewCount: viewCount,
      favoriteCount: favoriteCount,
      tags: tags,
      isFeatured: isFeatured,
      tradePreference: tradePreference,
    );
  }

  // Helper: Status to String
  static String _statusToString(ItemStatus status) {
    switch (status) {
      case ItemStatus.active:
        return 'active';
      case ItemStatus.pending:
        return 'pending';
      case ItemStatus.traded:
        return 'traded';
      case ItemStatus.deleted:
        return 'deleted';
      case ItemStatus.expired:
        return 'expired';
    }
  }

  // Helper: String to Status
  static ItemStatus _stringToStatus(String status) {
    switch (status) {
      case 'active':
        return ItemStatus.active;
      case 'pending':
        return ItemStatus.pending;
      case 'traded':
        return ItemStatus.traded;
      case 'deleted':
        return ItemStatus.deleted;
      case 'expired':
        return ItemStatus.expired;
      default:
        return ItemStatus.active;
    }
  }
}
