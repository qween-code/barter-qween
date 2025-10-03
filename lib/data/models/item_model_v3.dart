import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/barter_condition_entity.dart';
import 'barter_condition_model.dart';

/// ItemModel V3 - Complete implementation with all Sprint 1-4 features
class ItemModelV3 {
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
  
  // Sprint 1: Barter System
  final double? monetaryValue;
  final Map<String, dynamic>? barterCondition;
  final String? tier;
  
  // Sprint 1: Moderation
  final String moderationStatus;
  final String? adminNotes;
  final Timestamp? approvedAt;
  final String? approvedBy;
  
  // Sprint 1: Media
  final List<String>? videoUrls;
  
  // Sprint 1: Delivery
  final bool requiresDelivery;
  final String? deliveryInfo;
  
  // Sprint 1: Location
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
  
  // Sprint 4: Specifications
  final Map<String, dynamic>? specifications;

  ItemModelV3({
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
    this.specifications,
  });

  // From Firestore Document
  factory ItemModelV3.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModelV3(
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
      monetaryValue: data['monetaryValue']?.toDouble(),
      barterCondition: data['barterCondition'] != null 
          ? Map<String, dynamic>.from(data['barterCondition'])
          : null,
      tier: data['tier'],
      moderationStatus: data['moderationStatus'] ?? 'pending',
      adminNotes: data['adminNotes'],
      approvedAt: data['approvedAt'],
      approvedBy: data['approvedBy'],
      videoUrls: data['videoUrls'] != null 
          ? List<String>.from(data['videoUrls']) 
          : null,
      requiresDelivery: data['requiresDelivery'] ?? false,
      deliveryInfo: data['deliveryInfo'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      fullAddress: data['fullAddress'],
      specifications: data['specifications'] != null 
          ? Map<String, dynamic>.from(data['specifications'])
          : null,
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
      'specifications': specifications,
    };
  }

  // From Entity
  factory ItemModelV3.fromEntity(ItemEntity entity) {
    return ItemModelV3(
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
      monetaryValue: entity.monetaryValue,
      barterCondition: entity.barterCondition != null 
          ? BarterConditionModel.fromEntity(entity.barterCondition!).toJson()
          : null,
      tier: entity.tier != null ? _tierToString(entity.tier!) : null,
      moderationStatus: _moderationStatusToString(entity.moderationStatus),
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
      specifications: entity.specifications,
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
      monetaryValue: monetaryValue,
      barterCondition: barterCondition != null 
          ? BarterConditionModel.fromJson(barterCondition!).toEntity()
          : null,
      tier: tier != null ? _stringToTier(tier!) : null,
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
      specifications: specifications,
    );
  }

  // Helper: Status conversions
  static String _statusToString(ItemStatus status) {
    return status.toString().split('.').last;
  }

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

  // Helper: Tier conversions
  static String _tierToString(ItemTier tier) {
    return tier.toString().split('.').last;
  }

  static ItemTier _stringToTier(String tier) {
    switch (tier) {
      case 'small':
        return ItemTier.small;
      case 'medium':
        return ItemTier.medium;
      case 'large':
        return ItemTier.large;
      default:
        return ItemTier.small;
    }
  }

  // Helper: ModerationStatus conversions
  static String _moderationStatusToString(ModerationStatus status) {
    return status.toString().split('.').last;
  }

  static ModerationStatus _stringToModerationStatus(String status) {
    switch (status) {
      case 'pending':
        return ModerationStatus.pending;
      case 'approved':
        return ModerationStatus.approved;
      case 'rejected':
        return ModerationStatus.rejected;
      case 'flagged':
        return ModerationStatus.flagged;
      case 'autoApproved':
        return ModerationStatus.autoApproved;
      default:
        return ModerationStatus.pending;
    }
  }
}
