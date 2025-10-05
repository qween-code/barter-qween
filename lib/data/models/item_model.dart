import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/barter_condition_entity.dart';

/// World-Class ItemModel with complete Firestore mapping
/// Supports all 80+ fields from ItemEntity
class ItemModel {
  // Basic Info
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> images;
  
  // Product Identification
  final String? brand;
  final String? styleName;
  final String? modelNumber;
  final String? upc;
  final String? serialNumber;
  
  // Sizing & Fit
  final String? size;
  final String? sizeSystem;
  final String? gender;
  final String? fitType;
  final String? ageGroup;
  final Map<String, dynamic>? measurements;
  
  // Material & Composition
  final String? material;
  final List<String>? materials;
  final String? careInstructions;
  final bool? isVegan;
  final bool? isOrganic;
  
  // Condition
  final String? condition;
  final String? conditionDescription;
  final List<String>? defects;
  final List<String>? defectPhotos;
  final int? conditionRating;
  final String? wearLevel;
  
  // Purchase History
  final double? originalPrice;
  final String? originalCurrency;
  final Timestamp? purchaseDate;
  final String? purchaseLocation;
  final bool? hasReceipt;
  final String? receiptImageUrl;
  
  // Pricing
  final double? price;
  final double? discountAmount;
  final int? discountPercentage;
  final bool? firmPrice;
  final double? lowestAcceptedOffer;
  final bool? bundleDiscountAvailable;
  final int? bundleDiscountPercent;
  final bool? freeShipping;
  final double? shippingCost;
  
  // Shipping & Logistics
  final double? itemWeight;
  final Map<String, dynamic>? packageDimensions;
  final String? packageSize;
  final bool shippingAvailable;
  final bool localPickupOnly;
  final List<String>? shippingMethods;
  final int? estimatedShippingDays;
  final String? meetupLocation;
  final List<String>? preferredMeetupPoints;
  
  // Product Features
  final List<String>? features;
  final List<String>? accessories;
  final String? warranty;
  final Timestamp? warrantyExpiry;
  final String? batteryHealth;
  final String? functionalStatus;
  
  // Lifestyle & Style
  final String? season;
  final String? occasion;
  final String? style;
  final String? era;
  final List<String>? aesthetics;
  final String? targetAudience;
  
  // Seller Environment
  final bool? petFreeHome;
  final bool? smokeFreeHome;
  final bool? allergenFreeHome;
  final String? storageCondition;
  
  // Policies
  final bool? returnsAccepted;
  final int? returnWindowDays;
  final String? returnPolicy;
  final bool? exchangeAvailable;
  final bool? satisfactionGuaranteed;
  
  // Engagement
  final int viewCount;
  final int favoriteCount;
  final int shareCount;
  final int inquiryCount;
  final String? sellerResponseTime;
  final double? sellerRating;
  final int? sellerTotalSales;
  final bool? fastShipping;
  final bool? topRatedSeller;
  
  // SEO
  final List<String>? tags;
  final List<String>? seoKeywords;
  final List<String>? hashtags;
  final String? metaDescription;
  final List<String>? searchTerms;
  
  // Sustainability
  final bool? isSecondHand;
  final bool? isUpcycled;
  final bool? isEcoFriendly;
  final String? sustainabilityScore;
  final List<String>? sustainabilityBadges;
  final bool? recyclablePackaging;
  
  // Promotion
  final bool isFeatured;
  final bool? isPromoted;
  final bool? isBoosted;
  final Timestamp? featuredUntil;
  final int? promotionLevel;
  final bool? isDeal;
  final Timestamp? dealExpiry;
  
  // Core Fields
  final String? color;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String? location;
  final String? city;
  final String status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String? tradePreference;
  
  // Barter
  final double? monetaryValue;
  final Map<String, dynamic>? barterCondition;
  final String? tier;
  
  // Moderation
  final String moderationStatus;
  final String? adminNotes;
  final Timestamp? approvedAt;
  final String? approvedBy;
  
  // Media
  final List<String>? videoUrls;
  
  // Delivery
  final bool requiresDelivery;
  final String? deliveryInfo;
  
  // Location
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
  
  // Specifications
  final Map<String, dynamic>? specifications;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.images,
    this.brand,
    this.styleName,
    this.modelNumber,
    this.upc,
    this.serialNumber,
    this.size,
    this.sizeSystem,
    this.gender,
    this.fitType,
    this.ageGroup,
    this.measurements,
    this.material,
    this.materials,
    this.careInstructions,
    this.isVegan,
    this.isOrganic,
    this.condition,
    this.conditionDescription,
    this.defects,
    this.defectPhotos,
    this.conditionRating,
    this.wearLevel,
    this.originalPrice,
    this.originalCurrency,
    this.purchaseDate,
    this.purchaseLocation,
    this.hasReceipt,
    this.receiptImageUrl,
    this.price,
    this.discountAmount,
    this.discountPercentage,
    this.firmPrice,
    this.lowestAcceptedOffer,
    this.bundleDiscountAvailable,
    this.bundleDiscountPercent,
    this.freeShipping,
    this.shippingCost,
    this.itemWeight,
    this.packageDimensions,
    this.packageSize,
    this.shippingAvailable = false,
    this.localPickupOnly = false,
    this.shippingMethods,
    this.estimatedShippingDays,
    this.meetupLocation,
    this.preferredMeetupPoints,
    this.features,
    this.accessories,
    this.warranty,
    this.warrantyExpiry,
    this.batteryHealth,
    this.functionalStatus,
    this.season,
    this.occasion,
    this.style,
    this.era,
    this.aesthetics,
    this.targetAudience,
    this.petFreeHome,
    this.smokeFreeHome,
    this.allergenFreeHome,
    this.storageCondition,
    this.returnsAccepted,
    this.returnWindowDays,
    this.returnPolicy,
    this.exchangeAvailable,
    this.satisfactionGuaranteed,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.shareCount = 0,
    this.inquiryCount = 0,
    this.sellerResponseTime,
    this.sellerRating,
    this.sellerTotalSales,
    this.fastShipping,
    this.topRatedSeller,
    this.tags,
    this.seoKeywords,
    this.hashtags,
    this.metaDescription,
    this.searchTerms,
    this.isSecondHand,
    this.isUpcycled,
    this.isEcoFriendly,
    this.sustainabilityScore,
    this.sustainabilityBadges,
    this.recyclablePackaging,
    this.isFeatured = false,
    this.isPromoted,
    this.isBoosted,
    this.featuredUntil,
    this.promotionLevel,
    this.isDeal,
    this.dealExpiry,
    this.color,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    this.location,
    this.city,
    required this.status,
    required this.createdAt,
    this.updatedAt,
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

  /// From Firestore Document - Complete mapping
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ItemModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      images: List<String>.from(data['images'] ?? []),
      
      // Product Identification
      brand: data['brand'],
      styleName: data['styleName'],
      modelNumber: data['modelNumber'],
      upc: data['upc'],
      serialNumber: data['serialNumber'],
      
      // Sizing & Fit
      size: data['size'],
      sizeSystem: data['sizeSystem'],
      gender: data['gender'],
      fitType: data['fitType'],
      ageGroup: data['ageGroup'],
      measurements: data['measurements'] != null 
          ? Map<String, dynamic>.from(data['measurements']) 
          : null,
      
      // Material
      material: data['material'],
      materials: data['materials'] != null 
          ? List<String>.from(data['materials']) 
          : null,
      careInstructions: data['careInstructions'],
      isVegan: data['isVegan'],
      isOrganic: data['isOrganic'],
      
      // Condition
      condition: data['condition'],
      conditionDescription: data['conditionDescription'],
      defects: data['defects'] != null 
          ? List<String>.from(data['defects']) 
          : null,
      defectPhotos: data['defectPhotos'] != null 
          ? List<String>.from(data['defectPhotos']) 
          : null,
      conditionRating: data['conditionRating'],
      wearLevel: data['wearLevel'],
      
      // Purchase History
      originalPrice: data['originalPrice']?.toDouble(),
      originalCurrency: data['originalCurrency'],
      purchaseDate: data['purchaseDate'],
      purchaseLocation: data['purchaseLocation'],
      hasReceipt: data['hasReceipt'],
      receiptImageUrl: data['receiptImageUrl'],
      
      // Pricing
      price: data['price']?.toDouble(),
      discountAmount: data['discountAmount']?.toDouble(),
      discountPercentage: data['discountPercentage'],
      firmPrice: data['firmPrice'],
      lowestAcceptedOffer: data['lowestAcceptedOffer']?.toDouble(),
      bundleDiscountAvailable: data['bundleDiscountAvailable'],
      bundleDiscountPercent: data['bundleDiscountPercent'],
      freeShipping: data['freeShipping'],
      shippingCost: data['shippingCost']?.toDouble(),
      
      // Shipping
      itemWeight: data['itemWeight']?.toDouble(),
      packageDimensions: data['packageDimensions'] != null 
          ? Map<String, dynamic>.from(data['packageDimensions']) 
          : null,
      packageSize: data['packageSize'],
      shippingAvailable: data['shippingAvailable'] ?? false,
      localPickupOnly: data['localPickupOnly'] ?? false,
      shippingMethods: data['shippingMethods'] != null 
          ? List<String>.from(data['shippingMethods']) 
          : null,
      estimatedShippingDays: data['estimatedShippingDays'],
      meetupLocation: data['meetupLocation'],
      preferredMeetupPoints: data['preferredMeetupPoints'] != null 
          ? List<String>.from(data['preferredMeetupPoints']) 
          : null,
      
      // Features
      features: data['features'] != null 
          ? List<String>.from(data['features']) 
          : null,
      accessories: data['accessories'] != null 
          ? List<String>.from(data['accessories']) 
          : null,
      warranty: data['warranty'],
      warrantyExpiry: data['warrantyExpiry'],
      batteryHealth: data['batteryHealth'],
      functionalStatus: data['functionalStatus'],
      
      // Lifestyle
      season: data['season'],
      occasion: data['occasion'],
      style: data['style'],
      era: data['era'],
      aesthetics: data['aesthetics'] != null 
          ? List<String>.from(data['aesthetics']) 
          : null,
      targetAudience: data['targetAudience'],
      
      // Seller Environment
      petFreeHome: data['petFreeHome'],
      smokeFreeHome: data['smokeFreeHome'],
      allergenFreeHome: data['allergenFreeHome'],
      storageCondition: data['storageCondition'],
      
      // Policies
      returnsAccepted: data['returnsAccepted'],
      returnWindowDays: data['returnWindowDays'],
      returnPolicy: data['returnPolicy'],
      exchangeAvailable: data['exchangeAvailable'],
      satisfactionGuaranteed: data['satisfactionGuaranteed'],
      
      // Engagement
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      inquiryCount: data['inquiryCount'] ?? 0,
      sellerResponseTime: data['sellerResponseTime'],
      sellerRating: data['sellerRating']?.toDouble(),
      sellerTotalSales: data['sellerTotalSales'],
      fastShipping: data['fastShipping'],
      topRatedSeller: data['topRatedSeller'],
      
      // SEO
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      seoKeywords: data['seoKeywords'] != null 
          ? List<String>.from(data['seoKeywords']) 
          : null,
      hashtags: data['hashtags'] != null 
          ? List<String>.from(data['hashtags']) 
          : null,
      metaDescription: data['metaDescription'],
      searchTerms: data['searchTerms'] != null 
          ? List<String>.from(data['searchTerms']) 
          : null,
      
      // Sustainability
      isSecondHand: data['isSecondHand'],
      isUpcycled: data['isUpcycled'],
      isEcoFriendly: data['isEcoFriendly'],
      sustainabilityScore: data['sustainabilityScore'],
      sustainabilityBadges: data['sustainabilityBadges'] != null 
          ? List<String>.from(data['sustainabilityBadges']) 
          : null,
      recyclablePackaging: data['recyclablePackaging'],
      
      // Promotion
      isFeatured: data['isFeatured'] ?? false,
      isPromoted: data['isPromoted'],
      isBoosted: data['isBoosted'],
      featuredUntil: data['featuredUntil'],
      promotionLevel: data['promotionLevel'],
      isDeal: data['isDeal'],
      dealExpiry: data['dealExpiry'],
      
      // Core
      color: data['color'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhotoUrl: data['ownerPhotoUrl'],
      location: data['location'],
      city: data['city'],
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      tradePreference: data['tradePreference'],
      
      // Barter
      monetaryValue: data['monetaryValue']?.toDouble(),
      barterCondition: data['barterCondition'] != null 
          ? Map<String, dynamic>.from(data['barterCondition']) 
          : null,
      tier: data['tier'],
      
      // Moderation
      moderationStatus: data['moderationStatus'] ?? 'pending',
      adminNotes: data['adminNotes'],
      approvedAt: data['approvedAt'],
      approvedBy: data['approvedBy'],
      
      // Media
      videoUrls: data['videoUrls'] != null 
          ? List<String>.from(data['videoUrls']) 
          : null,
      
      // Delivery
      requiresDelivery: data['requiresDelivery'] ?? false,
      deliveryInfo: data['deliveryInfo'],
      
      // Location
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      fullAddress: data['fullAddress'],
      
      // Specifications
      specifications: data['specifications'] != null 
          ? Map<String, dynamic>.from(data['specifications']) 
          : null,
    );
  }

  /// From JSON (for search results and API)
  factory ItemModel.fromJson(Map<String, dynamic> data) {
    return ItemModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      images: List<String>.from(data['images'] ?? []),
      brand: data['brand'],
      styleName: data['styleName'],
      modelNumber: data['modelNumber'],
      upc: data['upc'],
      serialNumber: data['serialNumber'],
      size: data['size'],
      sizeSystem: data['sizeSystem'],
      gender: data['gender'],
      fitType: data['fitType'],
      ageGroup: data['ageGroup'],
      measurements: data['measurements'] != null 
          ? Map<String, dynamic>.from(data['measurements']) 
          : null,
      material: data['material'],
      materials: data['materials'] != null 
          ? List<String>.from(data['materials']) 
          : null,
      careInstructions: data['careInstructions'],
      isVegan: data['isVegan'],
      isOrganic: data['isOrganic'],
      condition: data['condition'],
      conditionDescription: data['conditionDescription'],
      defects: data['defects'] != null 
          ? List<String>.from(data['defects']) 
          : null,
      defectPhotos: data['defectPhotos'] != null 
          ? List<String>.from(data['defectPhotos']) 
          : null,
      conditionRating: data['conditionRating'],
      wearLevel: data['wearLevel'],
      originalPrice: data['originalPrice']?.toDouble(),
      originalCurrency: data['originalCurrency'],
      purchaseDate: data['purchaseDate'] is Timestamp 
          ? data['purchaseDate'] 
          : null,
      purchaseLocation: data['purchaseLocation'],
      hasReceipt: data['hasReceipt'],
      receiptImageUrl: data['receiptImageUrl'],
      price: data['price']?.toDouble(),
      discountAmount: data['discountAmount']?.toDouble(),
      discountPercentage: data['discountPercentage'],
      firmPrice: data['firmPrice'],
      lowestAcceptedOffer: data['lowestAcceptedOffer']?.toDouble(),
      bundleDiscountAvailable: data['bundleDiscountAvailable'],
      bundleDiscountPercent: data['bundleDiscountPercent'],
      freeShipping: data['freeShipping'],
      shippingCost: data['shippingCost']?.toDouble(),
      itemWeight: data['itemWeight']?.toDouble(),
      packageDimensions: data['packageDimensions'] != null 
          ? Map<String, dynamic>.from(data['packageDimensions']) 
          : null,
      packageSize: data['packageSize'],
      shippingAvailable: data['shippingAvailable'] ?? false,
      localPickupOnly: data['localPickupOnly'] ?? false,
      shippingMethods: data['shippingMethods'] != null 
          ? List<String>.from(data['shippingMethods']) 
          : null,
      estimatedShippingDays: data['estimatedShippingDays'],
      meetupLocation: data['meetupLocation'],
      preferredMeetupPoints: data['preferredMeetupPoints'] != null 
          ? List<String>.from(data['preferredMeetupPoints']) 
          : null,
      features: data['features'] != null 
          ? List<String>.from(data['features']) 
          : null,
      accessories: data['accessories'] != null 
          ? List<String>.from(data['accessories']) 
          : null,
      warranty: data['warranty'],
      warrantyExpiry: data['warrantyExpiry'] is Timestamp 
          ? data['warrantyExpiry'] 
          : null,
      batteryHealth: data['batteryHealth'],
      functionalStatus: data['functionalStatus'],
      season: data['season'],
      occasion: data['occasion'],
      style: data['style'],
      era: data['era'],
      aesthetics: data['aesthetics'] != null 
          ? List<String>.from(data['aesthetics']) 
          : null,
      targetAudience: data['targetAudience'],
      petFreeHome: data['petFreeHome'],
      smokeFreeHome: data['smokeFreeHome'],
      allergenFreeHome: data['allergenFreeHome'],
      storageCondition: data['storageCondition'],
      returnsAccepted: data['returnsAccepted'],
      returnWindowDays: data['returnWindowDays'],
      returnPolicy: data['returnPolicy'],
      exchangeAvailable: data['exchangeAvailable'],
      satisfactionGuaranteed: data['satisfactionGuaranteed'],
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      inquiryCount: data['inquiryCount'] ?? 0,
      sellerResponseTime: data['sellerResponseTime'],
      sellerRating: data['sellerRating']?.toDouble(),
      sellerTotalSales: data['sellerTotalSales'],
      fastShipping: data['fastShipping'],
      topRatedSeller: data['topRatedSeller'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      seoKeywords: data['seoKeywords'] != null 
          ? List<String>.from(data['seoKeywords']) 
          : null,
      hashtags: data['hashtags'] != null 
          ? List<String>.from(data['hashtags']) 
          : null,
      metaDescription: data['metaDescription'],
      searchTerms: data['searchTerms'] != null 
          ? List<String>.from(data['searchTerms']) 
          : null,
      isSecondHand: data['isSecondHand'],
      isUpcycled: data['isUpcycled'],
      isEcoFriendly: data['isEcoFriendly'],
      sustainabilityScore: data['sustainabilityScore'],
      sustainabilityBadges: data['sustainabilityBadges'] != null 
          ? List<String>.from(data['sustainabilityBadges']) 
          : null,
      recyclablePackaging: data['recyclablePackaging'],
      isFeatured: data['isFeatured'] ?? false,
      isPromoted: data['isPromoted'],
      isBoosted: data['isBoosted'],
      featuredUntil: data['featuredUntil'] is Timestamp 
          ? data['featuredUntil'] 
          : null,
      promotionLevel: data['promotionLevel'],
      isDeal: data['isDeal'],
      dealExpiry: data['dealExpiry'] is Timestamp 
          ? data['dealExpiry'] 
          : null,
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
      updatedAt: data['updatedAt'] is Timestamp 
          ? data['updatedAt'] 
          : null,
      tradePreference: data['tradePreference'],
      monetaryValue: data['monetaryValue']?.toDouble(),
      barterCondition: data['barterCondition'] != null 
          ? Map<String, dynamic>.from(data['barterCondition']) 
          : null,
      tier: data['tier'],
      moderationStatus: data['moderationStatus'] ?? 'pending',
      adminNotes: data['adminNotes'],
      approvedAt: data['approvedAt'] is Timestamp 
          ? data['approvedAt'] 
          : null,
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

  /// To Firestore Document - Complete mapping
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'images': images,
      
      // Product Identification
      'brand': brand,
      'styleName': styleName,
      'modelNumber': modelNumber,
      'upc': upc,
      'serialNumber': serialNumber,
      
      // Sizing & Fit
      'size': size,
      'sizeSystem': sizeSystem,
      'gender': gender,
      'fitType': fitType,
      'ageGroup': ageGroup,
      'measurements': measurements,
      
      // Material
      'material': material,
      'materials': materials,
      'careInstructions': careInstructions,
      'isVegan': isVegan,
      'isOrganic': isOrganic,
      
      // Condition
      'condition': condition,
      'conditionDescription': conditionDescription,
      'defects': defects,
      'defectPhotos': defectPhotos,
      'conditionRating': conditionRating,
      'wearLevel': wearLevel,
      
      // Purchase History
      'originalPrice': originalPrice,
      'originalCurrency': originalCurrency,
      'purchaseDate': purchaseDate,
      'purchaseLocation': purchaseLocation,
      'hasReceipt': hasReceipt,
      'receiptImageUrl': receiptImageUrl,
      
      // Pricing
      'price': price,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'firmPrice': firmPrice,
      'lowestAcceptedOffer': lowestAcceptedOffer,
      'bundleDiscountAvailable': bundleDiscountAvailable,
      'bundleDiscountPercent': bundleDiscountPercent,
      'freeShipping': freeShipping,
      'shippingCost': shippingCost,
      
      // Shipping
      'itemWeight': itemWeight,
      'packageDimensions': packageDimensions,
      'packageSize': packageSize,
      'shippingAvailable': shippingAvailable,
      'localPickupOnly': localPickupOnly,
      'shippingMethods': shippingMethods,
      'estimatedShippingDays': estimatedShippingDays,
      'meetupLocation': meetupLocation,
      'preferredMeetupPoints': preferredMeetupPoints,
      
      // Features
      'features': features,
      'accessories': accessories,
      'warranty': warranty,
      'warrantyExpiry': warrantyExpiry,
      'batteryHealth': batteryHealth,
      'functionalStatus': functionalStatus,
      
      // Lifestyle
      'season': season,
      'occasion': occasion,
      'style': style,
      'era': era,
      'aesthetics': aesthetics,
      'targetAudience': targetAudience,
      
      // Seller Environment
      'petFreeHome': petFreeHome,
      'smokeFreeHome': smokeFreeHome,
      'allergenFreeHome': allergenFreeHome,
      'storageCondition': storageCondition,
      
      // Policies
      'returnsAccepted': returnsAccepted,
      'returnWindowDays': returnWindowDays,
      'returnPolicy': returnPolicy,
      'exchangeAvailable': exchangeAvailable,
      'satisfactionGuaranteed': satisfactionGuaranteed,
      
      // Engagement
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'shareCount': shareCount,
      'inquiryCount': inquiryCount,
      'sellerResponseTime': sellerResponseTime,
      'sellerRating': sellerRating,
      'sellerTotalSales': sellerTotalSales,
      'fastShipping': fastShipping,
      'topRatedSeller': topRatedSeller,
      
      // SEO
      'tags': tags,
      'seoKeywords': seoKeywords,
      'hashtags': hashtags,
      'metaDescription': metaDescription,
      'searchTerms': searchTerms,
      
      // Sustainability
      'isSecondHand': isSecondHand,
      'isUpcycled': isUpcycled,
      'isEcoFriendly': isEcoFriendly,
      'sustainabilityScore': sustainabilityScore,
      'sustainabilityBadges': sustainabilityBadges,
      'recyclablePackaging': recyclablePackaging,
      
      // Promotion
      'isFeatured': isFeatured,
      'isPromoted': isPromoted,
      'isBoosted': isBoosted,
      'featuredUntil': featuredUntil,
      'promotionLevel': promotionLevel,
      'isDeal': isDeal,
      'dealExpiry': dealExpiry,
      
      // Core
      'color': color,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'location': location,
      'city': city,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tradePreference': tradePreference,
      
      // Barter
      'monetaryValue': monetaryValue,
      'barterCondition': barterCondition,
      'tier': tier,
      
      // Moderation
      'moderationStatus': moderationStatus,
      'adminNotes': adminNotes,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      
      // Media
      'videoUrls': videoUrls,
      
      // Delivery
      'requiresDelivery': requiresDelivery,
      'deliveryInfo': deliveryInfo,
      
      // Location
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
      
      // Specifications
      'specifications': specifications,
    };
    
    // Remove null values to save Firestore space
    map.removeWhere((key, value) => value == null);
    
    return map;
  }

  /// From Entity - Complete conversion
  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      subcategory: entity.subcategory,
      images: entity.images,
      brand: entity.brand,
      styleName: entity.styleName,
      modelNumber: entity.modelNumber,
      upc: entity.upc,
      serialNumber: entity.serialNumber,
      size: entity.size,
      sizeSystem: entity.sizeSystem,
      gender: entity.gender,
      fitType: entity.fitType,
      ageGroup: entity.ageGroup,
      measurements: entity.measurements,
      material: entity.material,
      materials: entity.materials,
      careInstructions: entity.careInstructions,
      isVegan: entity.isVegan,
      isOrganic: entity.isOrganic,
      condition: entity.condition,
      conditionDescription: entity.conditionDescription,
      defects: entity.defects,
      defectPhotos: entity.defectPhotos,
      conditionRating: entity.conditionRating,
      wearLevel: entity.wearLevel,
      originalPrice: entity.originalPrice,
      originalCurrency: entity.originalCurrency,
      purchaseDate: entity.purchaseDate != null 
          ? Timestamp.fromDate(entity.purchaseDate!) 
          : null,
      purchaseLocation: entity.purchaseLocation,
      hasReceipt: entity.hasReceipt,
      receiptImageUrl: entity.receiptImageUrl,
      price: entity.price,
      discountAmount: entity.discountAmount,
      discountPercentage: entity.discountPercentage,
      firmPrice: entity.firmPrice,
      lowestAcceptedOffer: entity.lowestAcceptedOffer,
      bundleDiscountAvailable: entity.bundleDiscountAvailable,
      bundleDiscountPercent: entity.bundleDiscountPercent,
      freeShipping: entity.freeShipping,
      shippingCost: entity.shippingCost,
      itemWeight: entity.itemWeight,
      packageDimensions: entity.packageDimensions,
      packageSize: entity.packageSize,
      shippingAvailable: entity.shippingAvailable,
      localPickupOnly: entity.localPickupOnly,
      shippingMethods: entity.shippingMethods,
      estimatedShippingDays: entity.estimatedShippingDays,
      meetupLocation: entity.meetupLocation,
      preferredMeetupPoints: entity.preferredMeetupPoints,
      features: entity.features,
      accessories: entity.accessories,
      warranty: entity.warranty,
      warrantyExpiry: entity.warrantyExpiry != null 
          ? Timestamp.fromDate(entity.warrantyExpiry!) 
          : null,
      batteryHealth: entity.batteryHealth,
      functionalStatus: entity.functionalStatus,
      season: entity.season,
      occasion: entity.occasion,
      style: entity.style,
      era: entity.era,
      aesthetics: entity.aesthetics,
      targetAudience: entity.targetAudience,
      petFreeHome: entity.petFreeHome,
      smokeFreeHome: entity.smokeFreeHome,
      allergenFreeHome: entity.allergenFreeHome,
      storageCondition: entity.storageCondition,
      returnsAccepted: entity.returnsAccepted,
      returnWindowDays: entity.returnWindowDays,
      returnPolicy: entity.returnPolicy,
      exchangeAvailable: entity.exchangeAvailable,
      satisfactionGuaranteed: entity.satisfactionGuaranteed,
      viewCount: entity.viewCount,
      favoriteCount: entity.favoriteCount,
      shareCount: entity.shareCount,
      inquiryCount: entity.inquiryCount,
      sellerResponseTime: entity.sellerResponseTime,
      sellerRating: entity.sellerRating,
      sellerTotalSales: entity.sellerTotalSales,
      fastShipping: entity.fastShipping,
      topRatedSeller: entity.topRatedSeller,
      tags: entity.tags,
      seoKeywords: entity.seoKeywords,
      hashtags: entity.hashtags,
      metaDescription: entity.metaDescription,
      searchTerms: entity.searchTerms,
      isSecondHand: entity.isSecondHand,
      isUpcycled: entity.isUpcycled,
      isEcoFriendly: entity.isEcoFriendly,
      sustainabilityScore: entity.sustainabilityScore,
      sustainabilityBadges: entity.sustainabilityBadges,
      recyclablePackaging: entity.recyclablePackaging,
      isFeatured: entity.isFeatured,
      isPromoted: entity.isPromoted,
      isBoosted: entity.isBoosted,
      featuredUntil: entity.featuredUntil != null 
          ? Timestamp.fromDate(entity.featuredUntil!) 
          : null,
      promotionLevel: entity.promotionLevel,
      isDeal: entity.isDeal,
      dealExpiry: entity.dealExpiry != null 
          ? Timestamp.fromDate(entity.dealExpiry!) 
          : null,
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
      tradePreference: entity.tradePreference,
      monetaryValue: entity.monetaryValue,
      barterCondition: entity.barterCondition != null 
          ? _barterConditionToMap(entity.barterCondition!) 
          : null,
      tier: entity.tier?.name,
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

  /// To Entity - Complete conversion
  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      subcategory: subcategory,
      images: images,
      brand: brand,
      styleName: styleName,
      modelNumber: modelNumber,
      upc: upc,
      serialNumber: serialNumber,
      size: size,
      sizeSystem: sizeSystem,
      gender: gender,
      fitType: fitType,
      ageGroup: ageGroup,
      measurements: measurements != null 
          ? Map<String, String>.from(measurements!) 
          : null,
      material: material,
      materials: materials,
      careInstructions: careInstructions,
      isVegan: isVegan,
      isOrganic: isOrganic,
      condition: condition,
      conditionDescription: conditionDescription,
      defects: defects,
      defectPhotos: defectPhotos,
      conditionRating: conditionRating,
      wearLevel: wearLevel,
      originalPrice: originalPrice,
      originalCurrency: originalCurrency,
      purchaseDate: purchaseDate?.toDate(),
      purchaseLocation: purchaseLocation,
      hasReceipt: hasReceipt,
      receiptImageUrl: receiptImageUrl,
      price: price,
      discountAmount: discountAmount,
      discountPercentage: discountPercentage,
      firmPrice: firmPrice,
      lowestAcceptedOffer: lowestAcceptedOffer,
      bundleDiscountAvailable: bundleDiscountAvailable,
      bundleDiscountPercent: bundleDiscountPercent,
      freeShipping: freeShipping,
      shippingCost: shippingCost,
      itemWeight: itemWeight,
      packageDimensions: packageDimensions != null 
          ? Map<String, double>.from(packageDimensions!) 
          : null,
      packageSize: packageSize,
      shippingAvailable: shippingAvailable,
      localPickupOnly: localPickupOnly,
      shippingMethods: shippingMethods,
      estimatedShippingDays: estimatedShippingDays,
      meetupLocation: meetupLocation,
      preferredMeetupPoints: preferredMeetupPoints,
      features: features,
      accessories: accessories,
      warranty: warranty,
      warrantyExpiry: warrantyExpiry?.toDate(),
      batteryHealth: batteryHealth,
      functionalStatus: functionalStatus,
      season: season,
      occasion: occasion,
      style: style,
      era: era,
      aesthetics: aesthetics,
      targetAudience: targetAudience,
      petFreeHome: petFreeHome,
      smokeFreeHome: smokeFreeHome,
      allergenFreeHome: allergenFreeHome,
      storageCondition: storageCondition,
      returnsAccepted: returnsAccepted,
      returnWindowDays: returnWindowDays,
      returnPolicy: returnPolicy,
      exchangeAvailable: exchangeAvailable,
      satisfactionGuaranteed: satisfactionGuaranteed,
      viewCount: viewCount,
      favoriteCount: favoriteCount,
      shareCount: shareCount,
      inquiryCount: inquiryCount,
      sellerResponseTime: sellerResponseTime,
      sellerRating: sellerRating,
      sellerTotalSales: sellerTotalSales,
      fastShipping: fastShipping,
      topRatedSeller: topRatedSeller,
      tags: tags,
      seoKeywords: seoKeywords,
      hashtags: hashtags,
      metaDescription: metaDescription,
      searchTerms: searchTerms,
      isSecondHand: isSecondHand,
      isUpcycled: isUpcycled,
      isEcoFriendly: isEcoFriendly,
      sustainabilityScore: sustainabilityScore,
      sustainabilityBadges: sustainabilityBadges,
      recyclablePackaging: recyclablePackaging,
      isFeatured: isFeatured,
      isPromoted: isPromoted,
      isBoosted: isBoosted,
      featuredUntil: featuredUntil?.toDate(),
      promotionLevel: promotionLevel,
      isDeal: isDeal,
      dealExpiry: dealExpiry?.toDate(),
      color: color,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
      location: location,
      city: city,
      status: _stringToStatus(status),
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
      tradePreference: tradePreference,
      monetaryValue: monetaryValue,
      barterCondition: barterCondition != null 
          ? _mapToBarterCondition(barterCondition!) 
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

  // ========================================
  // HELPER METHODS
  // ========================================

  static String _statusToString(ItemStatus status) {
    return status.name;
  }

  static ItemStatus _stringToStatus(String status) {
    return ItemStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ItemStatus.active,
    );
  }

  static String _moderationStatusToString(ModerationStatus status) {
    return status.name;
  }

  static ModerationStatus _stringToModerationStatus(String status) {
    return ModerationStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ModerationStatus.pending,
    );
  }

  static ItemTier _stringToTier(String tier) {
    return ItemTier.values.firstWhere(
      (e) => e.name == tier,
      orElse: () => ItemTier.small,
    );
  }

  static Map<String, dynamic> _barterConditionToMap(BarterConditionEntity entity) {
    // TODO: Implement proper conversion
    return {};
  }

  static BarterConditionEntity? _mapToBarterCondition(Map<String, dynamic> map) {
    // TODO: Implement proper conversion
    return null;
  }
}
