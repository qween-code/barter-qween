import 'package:equatable/equatable.dart';
import 'barter_condition_entity.dart';

/// World-Class Item Entity
/// Based on Depop, Vinted, Poshmark, OfferUp, Mercari, Facebook Marketplace best practices
///
/// Total Fields: 80+ fields for maximum marketplace competitiveness
class ItemEntity extends Equatable {
  // ========================================
  // BASIC INFO
  // ========================================
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> images;

  // ========================================
  // PRODUCT IDENTIFICATION (WORLD-CLASS)
  // ========================================
  /// Brand name separate from title for better search/filter
  /// Example: "Nike", "Zara", "Apple", "H&M"
  final String? brand;

  /// Official product/model name
  /// Example: "Air Jordan 1 High", "iPhone 13 Pro Max"
  final String? styleName;

  /// Model/SKU number
  /// Example: "555088-101", "A2484"
  final String? modelNumber;

  /// UPC/Barcode for instant product recognition
  final String? upc;

  /// Serial number (electronics/luxury items)
  final String? serialNumber;

  // ========================================
  // SIZING & FIT (WORLD-CLASS)
  // ========================================
  /// Size: "XS", "M", "42", "UK 8", "One Size"
  final String? size;

  /// Size system: "EU", "US", "UK", "IT", "FR", "One Size"
  final String? sizeSystem;

  /// Gender: "Men", "Women", "Unisex", "Boys", "Girls", "Kids"
  final String? gender;

  /// Fit type: "Slim", "Regular", "Oversized", "Petite", "Curvy", "Athletic"
  final String? fitType;

  /// Age group: "Adult", "Teen", "Kids", "Baby", "Toddler"
  final String? ageGroup;

  /// Detailed measurements in cm or inches
  /// Example: {"chest": "98cm", "length": "72cm", "shoulders": "44cm", "sleeves": "64cm"}
  /// Shoes: {"insoleLength": "28cm", "width": "10cm"}
  /// Bags: {"height": "30cm", "width": "40cm", "depth": "12cm", "strapDrop": "25cm"}
  final Map<String, String>? measurements;

  // ========================================
  // MATERIAL & COMPOSITION (WORLD-CLASS)
  // ========================================
  /// Primary material: "100% Cotton", "Genuine Leather", "Polyester", "Denim"
  final String? material;

  /// Material composition list: ["60% Cotton", "40% Polyester"]
  final List<String>? materials;

  /// Care instructions: "Machine wash cold, tumble dry low"
  final String? careInstructions;

  /// Vegan-friendly materials
  final bool? isVegan;

  /// Organic materials
  final bool? isOrganic;

  // ========================================
  // CONDITION (ENHANCED WORLD-CLASS)
  // ========================================
  /// Condition: "Brand New", "Like New", "Good", "Fair", "Poor"
  final String? condition;

  /// Detailed condition description (free-text)
  /// Example: "Only worn 2-3 times, no visible flaws except minor creasing on toe box"
  final String? conditionDescription;

  /// List of defects/flaws
  /// Example: ["Small scratch on left sleeve", "Missing one button"]
  final List<String>? defects;

  /// URLs to photos showing defects
  final List<String>? defectPhotos;

  /// Condition rating on 1-10 scale (10 = perfect)
  final int? conditionRating;

  /// Wear level: "Never worn", "Worn once", "Worn 2-3 times", "Lightly used", "Well-used"
  final String? wearLevel;

  // ========================================
  // PURCHASE HISTORY (WORLD-CLASS)
  // ========================================
  /// Original purchase price (for discount calculation)
  final double? originalPrice;

  /// Original currency: "TRY", "USD", "EUR", "GBP"
  final String? originalCurrency;

  /// When item was originally purchased
  final DateTime? purchaseDate;

  /// Where purchased: "Zara Istanbul", "Nike.com", "Amazon"
  final String? purchaseLocation;

  /// Receipt/proof of purchase available
  final bool? hasReceipt;

  /// Receipt photo URL
  final String? receiptImageUrl;

  // ========================================
  // PRICING (ENHANCED WORLD-CLASS)
  // ========================================
  /// Current listing price in TRY
  final double? price;

  /// Calculated discount amount (originalPrice - price)
  final double? discountAmount;

  /// Discount percentage: 65, 50, 30
  final int? discountPercentage;

  /// Is price firm (not negotiable)
  final bool? firmPrice;

  /// Minimum acceptable offer
  final double? lowestAcceptedOffer;

  /// Bundle discount available (buy 3+ items get discount)
  final bool? bundleDiscountAvailable;

  /// Bundle discount percentage: 10, 15, 20
  final int? bundleDiscountPercent;

  /// Free shipping offered
  final bool? freeShipping;

  /// Shipping cost if not free
  final double? shippingCost;

  // ========================================
  // SHIPPING & LOGISTICS (WORLD-CLASS)
  // ========================================
  /// Item weight in kg
  final double? itemWeight;

  /// Package dimensions in cm: {"length": 30, "width": 20, "height": 10}
  final Map<String, double>? packageDimensions;

  /// Package size category: "Small", "Medium", "Large", "XL"
  final String? packageSize;

  /// Can ship nationwide
  final bool shippingAvailable;

  /// Local pickup only (no shipping)
  final bool localPickupOnly;

  /// Shipping methods: ["Standard", "Express", "Hand Delivery"]
  final List<String>? shippingMethods;

  /// Estimated shipping days: 3, 5, 7
  final int? estimatedShippingDays;

  /// Preferred meetup location: "Public place, metro station, mall"
  final String? meetupLocation;

  /// List of safe meetup points: ["Starbucks Kadıköy", "Kadıköy Metro"]
  final List<String>? preferredMeetupPoints;

  // ========================================
  // PRODUCT FEATURES (WORLD-CLASS)
  // ========================================
  /// Product features list: ["Wireless", "Waterproof", "LED Display", "Bluetooth"]
  final List<String>? features;

  /// Included accessories: ["Original box", "Charger", "Manual", "Extra laces"]
  final List<String>? accessories;

  /// Warranty information: "AppleCare+ until March 2025"
  final String? warranty;

  /// Warranty expiration date
  final DateTime? warrantyExpiry;

  /// Battery health for electronics: "95%", "100%"
  final String? batteryHealth;

  /// Functional status: "Fully working", "Minor issues", "For parts only"
  final String? functionalStatus;

  // ========================================
  // LIFESTYLE & STYLE (WORLD-CLASS)
  // ========================================
  /// Season: "Spring/Summer", "Autumn/Winter", "All Season"
  final String? season;

  /// Occasion: "Casual", "Formal", "Party", "Sport", "Work", "Beach"
  final String? occasion;

  /// Style: "Vintage", "Y2K", "Minimalist", "Streetwear", "Bohemian", "Grunge"
  final String? style;

  /// Era/decade: "1990s", "2000s", "2010s", "2020s"
  final String? era;

  /// Aesthetic tags: ["Boho", "Grunge", "Cottagecore", "Dark Academia"]
  final List<String>? aesthetics;

  /// Target audience: "Teens", "Young Adults", "Professionals", "Students"
  final String? targetAudience;

  // ========================================
  // SELLER ENVIRONMENT (WORLD-CLASS)
  // ========================================
  /// Pet-free home
  final bool? petFreeHome;

  /// Smoke-free home
  final bool? smokeFreeHome;

  /// Allergen-free home
  final bool? allergenFreeHome;

  /// Storage condition: "Climate controlled", "Clean dry storage"
  final String? storageCondition;

  // ========================================
  // POLICIES (WORLD-CLASS)
  // ========================================
  /// Returns accepted
  final bool? returnsAccepted;

  /// Return window in days: 3, 7, 14, 30
  final int? returnWindowDays;

  /// Return policy description
  final String? returnPolicy;

  /// Exchange available (different size/color)
  final bool? exchangeAvailable;

  /// Money-back satisfaction guarantee
  final bool? satisfactionGuaranteed;

  // ========================================
  // ENGAGEMENT & SOCIAL (ENHANCED)
  // ========================================
  /// Total view count
  final int viewCount;

  /// Total favorite/like count
  final int favoriteCount;

  /// Total share count (social media shares)
  final int shareCount;

  /// Total inquiry/message count
  final int inquiryCount;

  /// Seller response time: "Within 1 hour", "Within 24 hours"
  final String? sellerResponseTime;

  /// Seller overall rating (if available)
  final double? sellerRating;

  /// Seller total completed sales
  final int? sellerTotalSales;

  /// Fast shipping badge
  final bool? fastShipping;

  /// Top-rated seller badge
  final bool? topRatedSeller;

  // ========================================
  // SEO & DISCOVERABILITY (WORLD-CLASS)
  // ========================================
  /// General tags for search
  final List<String>? tags;

  /// SEO-optimized keywords: ["air jordan 1", "retro sneakers", "chicago colorway"]
  final List<String>? seoKeywords;

  /// Social media hashtags: ["#nike", "#jordan", "#sneakers", "#vintage"]
  final List<String>? hashtags;

  /// Meta description for SEO
  final String? metaDescription;

  /// Common search terms users might use
  final List<String>? searchTerms;

  // ========================================
  // SUSTAINABILITY (WORLD-CLASS)
  // ========================================
  /// Second-hand item (reduces environmental impact)
  final bool? isSecondHand;

  /// Upcycled or repurposed item
  final bool? isUpcycled;

  /// Eco-friendly product
  final bool? isEcoFriendly;

  /// Sustainability score: "Saves 2.5kg CO2", "Reduces 10L water"
  final String? sustainabilityScore;

  /// Sustainability badges: ["Circular Fashion", "Slow Fashion", "Zero Waste"]
  final List<String>? sustainabilityBadges;

  /// Uses recyclable packaging
  final bool? recyclablePackaging;

  // ========================================
  // PROMOTION & VISIBILITY
  // ========================================
  /// Featured item (paid)
  final bool isFeatured;

  /// Promoted/boosted listing
  final bool? isPromoted;

  /// Boosted visibility active
  final bool? isBoosted;

  /// Featured until date
  final DateTime? featuredUntil;

  /// Promotion level: 1-5
  final int? promotionLevel;

  /// Special deal/flash sale
  final bool? isDeal;

  /// Deal expiration date
  final DateTime? dealExpiry;

  // ========================================
  // EXISTING CORE FIELDS
  // ========================================
  final String? color;
  final String ownerId;
  final String ownerName;
  String get userId => ownerId;
  final String? ownerPhotoUrl;
  final String? location;
  final String? city;
  final String? district;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? tradePreference;

  // ========================================
  // BARTER-SPECIFIC (EXISTING)
  // ========================================
  final double? monetaryValue;
  final BarterConditionEntity? barterCondition;
  final ItemTier? tier;

  // ========================================
  // MODERATION (EXISTING)
  // ========================================
  final ModerationStatus moderationStatus;
  final String? adminNotes;
  final DateTime? approvedAt;
  final String? approvedBy;

  // ========================================
  // MEDIA (EXISTING)
  // ========================================
  final List<String>? videoUrls;

  // ========================================
  // DELIVERY (EXISTING)
  // ========================================
  final bool requiresDelivery;
  final String? deliveryInfo;

  // ========================================
  // LOCATION (EXISTING)
  // ========================================
  final double? latitude;
  final double? longitude;
  final String? fullAddress;

  // ========================================
  // TECHNICAL SPECIFICATIONS
  // ========================================
  /// Category-specific technical specs
  /// Electronics: {"storage": "256GB", "ram": "16GB", "processor": "M1 Pro"}
  /// Furniture: {"material": "Oak wood", "assembly": "Required"}
  final Map<String, dynamic>? specifications;

  const ItemEntity({
    // Basic
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.images,

    // Product Identification
    this.brand,
    this.styleName,
    this.modelNumber,
    this.upc,
    this.serialNumber,

    // Sizing & Fit
    this.size,
    this.sizeSystem,
    this.gender,
    this.fitType,
    this.ageGroup,
    this.measurements,

    // Material
    this.material,
    this.materials,
    this.careInstructions,
    this.isVegan,
    this.isOrganic,

    // Condition
    this.condition,
    this.conditionDescription,
    this.defects,
    this.defectPhotos,
    this.conditionRating,
    this.wearLevel,

    // Purchase History
    this.originalPrice,
    this.originalCurrency,
    this.purchaseDate,
    this.purchaseLocation,
    this.hasReceipt,
    this.receiptImageUrl,

    // Pricing
    this.price,
    this.discountAmount,
    this.discountPercentage,
    this.firmPrice,
    this.lowestAcceptedOffer,
    this.bundleDiscountAvailable,
    this.bundleDiscountPercent,
    this.freeShipping,
    this.shippingCost,

    // Shipping & Logistics
    this.itemWeight,
    this.packageDimensions,
    this.packageSize,
    this.shippingAvailable = false,
    this.localPickupOnly = false,
    this.shippingMethods,
    this.estimatedShippingDays,
    this.meetupLocation,
    this.preferredMeetupPoints,

    // Product Features
    this.features,
    this.accessories,
    this.warranty,
    this.warrantyExpiry,
    this.batteryHealth,
    this.functionalStatus,

    // Lifestyle & Style
    this.season,
    this.occasion,
    this.style,
    this.era,
    this.aesthetics,
    this.targetAudience,

    // Seller Environment
    this.petFreeHome,
    this.smokeFreeHome,
    this.allergenFreeHome,
    this.storageCondition,

    // Policies
    this.returnsAccepted,
    this.returnWindowDays,
    this.returnPolicy,
    this.exchangeAvailable,
    this.satisfactionGuaranteed,

    // Engagement
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.shareCount = 0,
    this.inquiryCount = 0,
    this.sellerResponseTime,
    this.sellerRating,
    this.sellerTotalSales,
    this.fastShipping,
    this.topRatedSeller,

    // SEO
    this.tags,
    this.seoKeywords,
    this.hashtags,
    this.metaDescription,
    this.searchTerms,

    // Sustainability
    this.isSecondHand,
    this.isUpcycled,
    this.isEcoFriendly,
    this.sustainabilityScore,
    this.sustainabilityBadges,
    this.recyclablePackaging,

    // Promotion
    this.isFeatured = false,
    this.isPromoted,
    this.isBoosted,
    this.featuredUntil,
    this.promotionLevel,
    this.isDeal,
    this.dealExpiry,

    // Core fields
    this.color,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    this.location,
    this.city,
    this.district,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.tradePreference,

    // Barter
    this.monetaryValue,
    this.barterCondition,
    this.tier,

    // Moderation
    this.moderationStatus = ModerationStatus.pending,
    this.adminNotes,
    this.approvedAt,
    this.approvedBy,

    // Media
    this.videoUrls,

    // Delivery
    this.requiresDelivery = false,
    this.deliveryInfo,

    // Location
    this.latitude,
    this.longitude,
    this.fullAddress,

    // Specifications
    this.specifications,
  });

  /// Alias for price field (backward compatibility)
  double? get estimatedValue => price;

  /// Calculate discount percentage if original price exists
  int? get calculatedDiscountPercentage {
    if (originalPrice != null && price != null && originalPrice! > 0) {
      return (((originalPrice! - price!) / originalPrice!) * 100).round();
    }
    return discountPercentage;
  }

  /// Calculate discount amount if original price exists
  double? get calculatedDiscountAmount {
    if (originalPrice != null && price != null) {
      return originalPrice! - price!;
    }
    return discountAmount;
  }

  /// Check if item is a good deal (>30% off)
  bool get isGoodDeal {
    final discount = calculatedDiscountPercentage;
    return discount != null && discount >= 30;
  }

  /// Get full size string (size + system)
  String? get fullSize {
    if (size == null) return null;
    if (sizeSystem != null && sizeSystem != 'One Size') {
      return '$size ($sizeSystem)';
    }
    return size;
  }

  ItemEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subcategory,
    List<String>? images,
    String? brand,
    String? styleName,
    String? modelNumber,
    String? upc,
    String? serialNumber,
    String? size,
    String? sizeSystem,
    String? gender,
    String? fitType,
    String? ageGroup,
    Map<String, String>? measurements,
    String? material,
    List<String>? materials,
    String? careInstructions,
    bool? isVegan,
    bool? isOrganic,
    String? condition,
    String? conditionDescription,
    List<String>? defects,
    List<String>? defectPhotos,
    int? conditionRating,
    String? wearLevel,
    double? originalPrice,
    String? originalCurrency,
    DateTime? purchaseDate,
    String? purchaseLocation,
    bool? hasReceipt,
    String? receiptImageUrl,
    double? price,
    double? discountAmount,
    int? discountPercentage,
    bool? firmPrice,
    double? lowestAcceptedOffer,
    bool? bundleDiscountAvailable,
    int? bundleDiscountPercent,
    bool? freeShipping,
    double? shippingCost,
    double? itemWeight,
    Map<String, double>? packageDimensions,
    String? packageSize,
    bool? shippingAvailable,
    bool? localPickupOnly,
    List<String>? shippingMethods,
    int? estimatedShippingDays,
    String? meetupLocation,
    List<String>? preferredMeetupPoints,
    List<String>? features,
    List<String>? accessories,
    String? warranty,
    DateTime? warrantyExpiry,
    String? batteryHealth,
    String? functionalStatus,
    String? season,
    String? occasion,
    String? style,
    String? era,
    List<String>? aesthetics,
    String? targetAudience,
    bool? petFreeHome,
    bool? smokeFreeHome,
    bool? allergenFreeHome,
    String? storageCondition,
    bool? returnsAccepted,
    int? returnWindowDays,
    String? returnPolicy,
    bool? exchangeAvailable,
    bool? satisfactionGuaranteed,
    int? viewCount,
    int? favoriteCount,
    int? shareCount,
    int? inquiryCount,
    String? sellerResponseTime,
    double? sellerRating,
    int? sellerTotalSales,
    bool? fastShipping,
    bool? topRatedSeller,
    List<String>? tags,
    List<String>? seoKeywords,
    List<String>? hashtags,
    String? metaDescription,
    List<String>? searchTerms,
    bool? isSecondHand,
    bool? isUpcycled,
    bool? isEcoFriendly,
    String? sustainabilityScore,
    List<String>? sustainabilityBadges,
    bool? recyclablePackaging,
    bool? isFeatured,
    bool? isPromoted,
    bool? isBoosted,
    DateTime? featuredUntil,
    int? promotionLevel,
    bool? isDeal,
    DateTime? dealExpiry,
    String? color,
    String? ownerId,
    String? ownerName,
    String? ownerPhotoUrl,
    String? location,
    String? city,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tradePreference,
    double? monetaryValue,
    BarterConditionEntity? barterCondition,
    ItemTier? tier,
    ModerationStatus? moderationStatus,
    String? adminNotes,
    DateTime? approvedAt,
    String? approvedBy,
    List<String>? videoUrls,
    bool? requiresDelivery,
    String? deliveryInfo,
    double? latitude,
    double? longitude,
    String? fullAddress,
    Map<String, dynamic>? specifications,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      images: images ?? this.images,
      brand: brand ?? this.brand,
      styleName: styleName ?? this.styleName,
      modelNumber: modelNumber ?? this.modelNumber,
      upc: upc ?? this.upc,
      serialNumber: serialNumber ?? this.serialNumber,
      size: size ?? this.size,
      sizeSystem: sizeSystem ?? this.sizeSystem,
      gender: gender ?? this.gender,
      fitType: fitType ?? this.fitType,
      ageGroup: ageGroup ?? this.ageGroup,
      measurements: measurements ?? this.measurements,
      material: material ?? this.material,
      materials: materials ?? this.materials,
      careInstructions: careInstructions ?? this.careInstructions,
      isVegan: isVegan ?? this.isVegan,
      isOrganic: isOrganic ?? this.isOrganic,
      condition: condition ?? this.condition,
      conditionDescription: conditionDescription ?? this.conditionDescription,
      defects: defects ?? this.defects,
      defectPhotos: defectPhotos ?? this.defectPhotos,
      conditionRating: conditionRating ?? this.conditionRating,
      wearLevel: wearLevel ?? this.wearLevel,
      originalPrice: originalPrice ?? this.originalPrice,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      price: price ?? this.price,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      firmPrice: firmPrice ?? this.firmPrice,
      lowestAcceptedOffer: lowestAcceptedOffer ?? this.lowestAcceptedOffer,
      bundleDiscountAvailable:
          bundleDiscountAvailable ?? this.bundleDiscountAvailable,
      bundleDiscountPercent:
          bundleDiscountPercent ?? this.bundleDiscountPercent,
      freeShipping: freeShipping ?? this.freeShipping,
      shippingCost: shippingCost ?? this.shippingCost,
      itemWeight: itemWeight ?? this.itemWeight,
      packageDimensions: packageDimensions ?? this.packageDimensions,
      packageSize: packageSize ?? this.packageSize,
      shippingAvailable: shippingAvailable ?? this.shippingAvailable,
      localPickupOnly: localPickupOnly ?? this.localPickupOnly,
      shippingMethods: shippingMethods ?? this.shippingMethods,
      estimatedShippingDays:
          estimatedShippingDays ?? this.estimatedShippingDays,
      meetupLocation: meetupLocation ?? this.meetupLocation,
      preferredMeetupPoints:
          preferredMeetupPoints ?? this.preferredMeetupPoints,
      features: features ?? this.features,
      accessories: accessories ?? this.accessories,
      warranty: warranty ?? this.warranty,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      functionalStatus: functionalStatus ?? this.functionalStatus,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      style: style ?? this.style,
      era: era ?? this.era,
      aesthetics: aesthetics ?? this.aesthetics,
      targetAudience: targetAudience ?? this.targetAudience,
      petFreeHome: petFreeHome ?? this.petFreeHome,
      smokeFreeHome: smokeFreeHome ?? this.smokeFreeHome,
      allergenFreeHome: allergenFreeHome ?? this.allergenFreeHome,
      storageCondition: storageCondition ?? this.storageCondition,
      returnsAccepted: returnsAccepted ?? this.returnsAccepted,
      returnWindowDays: returnWindowDays ?? this.returnWindowDays,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      exchangeAvailable: exchangeAvailable ?? this.exchangeAvailable,
      satisfactionGuaranteed:
          satisfactionGuaranteed ?? this.satisfactionGuaranteed,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      shareCount: shareCount ?? this.shareCount,
      inquiryCount: inquiryCount ?? this.inquiryCount,
      sellerResponseTime: sellerResponseTime ?? this.sellerResponseTime,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerTotalSales: sellerTotalSales ?? this.sellerTotalSales,
      fastShipping: fastShipping ?? this.fastShipping,
      topRatedSeller: topRatedSeller ?? this.topRatedSeller,
      tags: tags ?? this.tags,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      hashtags: hashtags ?? this.hashtags,
      metaDescription: metaDescription ?? this.metaDescription,
      searchTerms: searchTerms ?? this.searchTerms,
      isSecondHand: isSecondHand ?? this.isSecondHand,
      isUpcycled: isUpcycled ?? this.isUpcycled,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      sustainabilityBadges: sustainabilityBadges ?? this.sustainabilityBadges,
      recyclablePackaging: recyclablePackaging ?? this.recyclablePackaging,
      isFeatured: isFeatured ?? this.isFeatured,
      isPromoted: isPromoted ?? this.isPromoted,
      isBoosted: isBoosted ?? this.isBoosted,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      promotionLevel: promotionLevel ?? this.promotionLevel,
      isDeal: isDeal ?? this.isDeal,
      dealExpiry: dealExpiry ?? this.dealExpiry,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhotoUrl: ownerPhotoUrl ?? this.ownerPhotoUrl,
      location: location ?? this.location,
      city: city ?? this.city,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tradePreference: tradePreference ?? this.tradePreference,
      monetaryValue: monetaryValue ?? this.monetaryValue,
      barterCondition: barterCondition ?? this.barterCondition,
      tier: tier ?? this.tier,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      adminNotes: adminNotes ?? this.adminNotes,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      videoUrls: videoUrls ?? this.videoUrls,
      requiresDelivery: requiresDelivery ?? this.requiresDelivery,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullAddress: fullAddress ?? this.fullAddress,
      specifications: specifications ?? this.specifications,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    subcategory,
    images,
    brand,
    styleName,
    modelNumber,
    upc,
    serialNumber,
    size,
    sizeSystem,
    gender,
    fitType,
    ageGroup,
    measurements,
    material,
    materials,
    careInstructions,
    isVegan,
    isOrganic,
    condition,
    conditionDescription,
    defects,
    defectPhotos,
    conditionRating,
    wearLevel,
    originalPrice,
    originalCurrency,
    purchaseDate,
    purchaseLocation,
    hasReceipt,
    receiptImageUrl,
    price,
    discountAmount,
    discountPercentage,
    firmPrice,
    lowestAcceptedOffer,
    bundleDiscountAvailable,
    bundleDiscountPercent,
    freeShipping,
    shippingCost,
    itemWeight,
    packageDimensions,
    packageSize,
    shippingAvailable,
    localPickupOnly,
    shippingMethods,
    estimatedShippingDays,
    meetupLocation,
    preferredMeetupPoints,
    features,
    accessories,
    warranty,
    warrantyExpiry,
    batteryHealth,
    functionalStatus,
    season,
    occasion,
    style,
    era,
    aesthetics,
    targetAudience,
    petFreeHome,
    smokeFreeHome,
    allergenFreeHome,
    storageCondition,
    returnsAccepted,
    returnWindowDays,
    returnPolicy,
    exchangeAvailable,
    satisfactionGuaranteed,
    viewCount,
    favoriteCount,
    shareCount,
    inquiryCount,
    sellerResponseTime,
    sellerRating,
    sellerTotalSales,
    fastShipping,
    topRatedSeller,
    tags,
    seoKeywords,
    hashtags,
    metaDescription,
    searchTerms,
    isSecondHand,
    isUpcycled,
    isEcoFriendly,
    sustainabilityScore,
    sustainabilityBadges,
    recyclablePackaging,
    isFeatured,
    isPromoted,
    isBoosted,
    featuredUntil,
    promotionLevel,
    isDeal,
    dealExpiry,
    color,
    ownerId,
    ownerName,
    ownerPhotoUrl,
    location,
    city,
    district,
    status,
    createdAt,
    updatedAt,
    tradePreference,
    monetaryValue,
    barterCondition,
    tier,
    moderationStatus,
    adminNotes,
    approvedAt,
    approvedBy,
    videoUrls,
    requiresDelivery,
    deliveryInfo,
    latitude,
    longitude,
    fullAddress,
    specifications,
  ];
}

// ========================================
// ENUMS & CONSTANTS
// ========================================

enum ItemStatus { active, pending, traded, deleted, expired }

enum ItemTier {
  small, // 0-500 TL
  medium, // 500-2000 TL
  large, // 2000+ TL
}

extension ItemTierExtension on ItemTier {
  String get displayName {
    switch (this) {
      case ItemTier.small:
        return 'Küçük';
      case ItemTier.medium:
        return 'Orta';
      case ItemTier.large:
        return 'Büyük';
    }
  }

  String get description {
    switch (this) {
      case ItemTier.small:
        return '0-500 TL arası değer';
      case ItemTier.medium:
        return '500-2000 TL arası değer';
      case ItemTier.large:
        return '2000+ TL değer';
    }
  }
}

enum ModerationStatus { pending, approved, rejected, flagged, autoApproved }

extension ModerationStatusExtension on ModerationStatus {
  String get displayName {
    switch (this) {
      case ModerationStatus.pending:
        return 'İnceleniyor';
      case ModerationStatus.approved:
        return 'Onaylandı';
      case ModerationStatus.rejected:
        return 'Reddedildi';
      case ModerationStatus.flagged:
        return 'İşaretlendi';
      case ModerationStatus.autoApproved:
        return 'Otomatik Onaylandı';
    }
  }
}

// ========================================
// ITEM CONDITION CONSTANTS
// ========================================

class ItemCondition {
  static const String brandNew = 'Brand New';
  static const String likeNew = 'Like New';
  static const String good = 'Good';
  static const String fair = 'Fair';
  static const String poor = 'Poor';

  static List<String> get all => [brandNew, likeNew, good, fair, poor];

  static String getDescription(String condition) {
    switch (condition) {
      case brandNew:
        return 'Hiç kullanılmamış, etiketleriyle birlikte';
      case likeNew:
        return 'Çok az kullanılmış, kusursuz durumda';
      case good:
        return 'İyi durumda, hafif kullanım izleri var';
      case fair:
        return 'Kullanılmış, görünür kullanım izleri var';
      case poor:
        return 'Yoğun kullanılmış, belirgin kusurlar var';
      default:
        return '';
    }
  }
}

// ========================================
// COLOR CONSTANTS
// ========================================

class ItemColor {
  static const String black = 'Black';
  static const String white = 'White';
  static const String gray = 'Gray';
  static const String silver = 'Silver';
  static const String red = 'Red';
  static const String blue = 'Blue';
  static const String green = 'Green';
  static const String yellow = 'Yellow';
  static const String orange = 'Orange';
  static const String pink = 'Pink';
  static const String purple = 'Purple';
  static const String brown = 'Brown';
  static const String beige = 'Beige';
  static const String gold = 'Gold';
  static const String rose = 'Rose Gold';
  static const String multicolor = 'Multicolor';
  static const String other = 'Other';

  static List<String> get all => [
    black,
    white,
    gray,
    silver,
    red,
    blue,
    green,
    yellow,
    orange,
    pink,
    purple,
    brown,
    beige,
    gold,
    rose,
    multicolor,
    other,
  ];

  static const Map<String, String> hexCodes = {
    black: '#000000',
    white: '#FFFFFF',
    gray: '#808080',
    silver: '#C0C0C0',
    red: '#FF0000',
    blue: '#0000FF',
    green: '#008000',
    yellow: '#FFFF00',
    orange: '#FFA500',
    pink: '#FFC0CB',
    purple: '#800080',
    brown: '#A52A2A',
    beige: '#F5F5DC',
    gold: '#FFD700',
    rose: '#B76E79',
    multicolor: '#RAINBOW',
    other: '#CCCCCC',
  };
}
