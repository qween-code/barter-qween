import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/barter_condition_entity.dart';
import 'barter_condition_model.dart';

class ItemModelV2 {
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

  // NEW FIELDS
  final double? monetaryValue;
  final Map<String, dynamic>? barterCondition;
  final String? tier;
  final String moderationStatus;
  final String? adminNotes;
  final Timestamp? approvedAt;
  final String? approvedBy;
  final List<String>? videoUrls;
  final bool requiresDelivery;
  final String? deliveryInfo;
  final double? latitude;
  final double? longitude;
  final String? fullAddress;

  ItemModelV2({
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
    // New fields
    this.monetaryValue,
    this.barterCondition,
    this.tier,
    this.moderationStatus = 'pending',
    this.adminNotes,
    this.approvedAt,
    this.approvedBy,
    this.videoUrls,
    this.requiresDelivery = false,
    this.deliveryInfo,
    this.latitude,
    this.longitude,
    this.fullAddress,
  });

  // From Firestore Document
  factory ItemModelV2.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModelV2(
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
      // New fields
      monetaryValue: data['monetaryValue']?.toDouble(),
      barterCondition: data['barterCondition'],
      tier: data['tier'],
      moderationStatus: data['moderationStatus'] ?? 'pending',
      adminNotes: data['adminNotes'],
      approvedAt: data['approvedAt'],
      approvedBy: data['approvedBy'],
      videoUrls:
          data['videoUrls'] != null ? List<String>.from(data['videoUrls']) : null,
      requiresDelivery: data['requiresDelivery'] ?? false,
      deliveryInfo: data['deliveryInfo'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      fullAddress: data['fullAddress'],
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
      // New fields
      'monetaryValue': monetaryValue,
      'barterCondition': barterCondition,
      'tier': tier,
      'moderationStatus': moderationStatus,
      'adminNotes': adminNotes,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'videoUrls': videoUrls,
      'requiresDelivery': requiresDelivery,
      'deliveryInfo': deliveryInfo,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
    };
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
      // New fields
      monetaryValue: monetaryValue,
      barterCondition: barterCondition != null
          ? BarterConditionModel.fromFirestore(barterCondition!)
          : null,
      tier: _stringToTier(tier),
      moderationStatus: _stringToModerationStatus(moderationStatus),
      adminNotes: adminNotes,
      approvedAt: approvedAt?.toDate(),
      approvedBy: approvedBy,
      videoUrls: videoUrls,
      requiresDelivery: requiresDelivery,
      deliveryInfo: deliveryInfo,
      latitude: latitude,
      longitude: longitude,
      fullAddress: fullAddress,
    );
  }

  // From Entity
  factory ItemModelV2.fromEntity(ItemEntity entity) {
    return ItemModelV2(
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
      updatedAt:
          entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
      viewCount: entity.viewCount,
      favoriteCount: entity.favoriteCount,
      tags: entity.tags,
      isFeatured: entity.isFeatured,
      tradePreference: entity.tradePreference,
      // New fields
      monetaryValue: entity.monetaryValue,
      barterCondition: entity.barterCondition != null
          ? BarterConditionModel.fromEntity(entity.barterCondition!)
              .toFirestore()
          : null,
      tier: entity.tier?.name,
      moderationStatus: entity.moderationStatus.name,
      adminNotes: entity.adminNotes,
      approvedAt: entity.approvedAt != null
          ? Timestamp.fromDate(entity.approvedAt!)
          : null,
      approvedBy: entity.approvedBy,
      videoUrls: entity.videoUrls,
      requiresDelivery: entity.requiresDelivery,
      deliveryInfo: entity.deliveryInfo,
      latitude: entity.latitude,
      longitude: entity.longitude,
      fullAddress: entity.fullAddress,
    );
  }

  // Helper: Status to String
  static String _statusToString(ItemStatus status) {
    return status.name;
  }

  // Helper: String to Status
  static ItemStatus _stringToStatus(String status) {
    return ItemStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ItemStatus.active,
    );
  }

  // Helper: String to Tier
  static ItemTier? _stringToTier(String? tier) {
    if (tier == null) return null;
    return ItemTier.values.firstWhere(
      (e) => e.name == tier,
      orElse: () => ItemTier.small,
    );
  }

  // Helper: String to ModerationStatus
  static ModerationStatus _stringToModerationStatus(String status) {
    return ModerationStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ModerationStatus.pending,
    );
  }
}
