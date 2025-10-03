import 'package:equatable/equatable.dart';
import 'barter_condition_entity.dart';

class ItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> images;
  final String? condition; // New, Like New, Good, Fair, Poor
  final double? price; // Estimated value in TRY
  final String? color;
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

  // Barter & Monetization (NEW)
  final double? monetaryValue; // TL cinsinden değer
  final BarterConditionEntity? barterCondition; // Barter şartları
  final ItemTier? tier; // Küçük/Orta/Büyük

  // Moderation (NEW)
  final ModerationStatus moderationStatus; // Onay durumu
  final String? adminNotes; // Admin notları
  final DateTime? approvedAt; // Onay zamanı
  final String? approvedBy; // Onaylayan admin ID

  // Media (NEW)
  final List<String>? videoUrls; // Video URL'leri

  // Delivery (NEW)
  final bool requiresDelivery; // Teslimat gerekli mi
  final String? deliveryInfo; // Teslimat bilgisi

  // Location (NEW - harita için)
  final double? latitude;
  final double? longitude;
  final String? fullAddress;

  // Specifications (NEW - category-specific attributes)
  final Map<String, dynamic>? specifications;

  const ItemEntity({
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
    this.moderationStatus = ModerationStatus.pending,
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

  /// Alias for price field (for compatibility)
  double? get estimatedValue => price;

  ItemEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subcategory,
    List<String>? images,
    String? condition,
    double? price,
    String? color,
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
      condition: condition ?? this.condition,
      price: price ?? this.price,
      color: color ?? this.color,
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
        condition,
        price,
        color,
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

enum ItemStatus {
  active,
  pending, // Trade in progress
  traded, // Successfully traded
  deleted,
  expired,
}

// Item Categories with Subcategories
class ItemCategory {
  static const String electronics = 'Electronics';
  static const String fashion = 'Fashion';
  static const String books = 'Books';
  static const String furniture = 'Furniture';
  static const String toys = 'Toys';
  static const String sports = 'Sports';
  static const String home = 'Home & Garden';
  static const String beauty = 'Beauty';
  static const String automotive = 'Automotive';
  static const String collectibles = 'Collectibles';
  static const String hobbies = 'Hobbies & Crafts';
  static const String music = 'Music & Instruments';
  static const String pets = 'Pet Supplies';
  static const String baby = 'Baby & Kids';
  static const String office = 'Office Supplies';
  static const String other = 'Other';

  static List<String> get all => [
        electronics,
        fashion,
        books,
        furniture,
        toys,
        sports,
        home,
        beauty,
        automotive,
        collectibles,
        hobbies,
        music,
        pets,
        baby,
        office,
        other,
      ];
  
  // Subcategories for each category
  static const Map<String, List<String>> subcategories = {
    electronics: [
      'Smartphones & Tablets',
      'Laptops & Computers',
      'Gaming Consoles',
      'Cameras & Photography',
      'Audio & Headphones',
      'Smart Home Devices',
      'TV & Entertainment',
      'Wearables & Accessories',
    ],
    fashion: [
      'Men\'s Clothing',
      'Women\'s Clothing',
      'Shoes & Sneakers',
      'Bags & Accessories',
      'Watches & Jewelry',
      'Sunglasses',
      'Hats & Caps',
      'Vintage Fashion',
    ],
    books: [
      'Fiction',
      'Non-Fiction',
      'Academic & Education',
      'Comics & Manga',
      'Magazines',
      'Children\'s Books',
      'E-Readers',
      'Foreign Language',
    ],
    furniture: [
      'Living Room',
      'Bedroom',
      'Office Furniture',
      'Kitchen & Dining',
      'Outdoor Furniture',
      'Storage & Organization',
      'Lighting',
      'Decoration',
    ],
    toys: [
      'Action Figures',
      'Building Blocks',
      'Board Games',
      'Dolls & Accessories',
      'Puzzles',
      'RC & Vehicles',
      'Educational Toys',
      'Outdoor Toys',
    ],
    sports: [
      'Fitness Equipment',
      'Bicycles & Scooters',
      'Football & Soccer',
      'Basketball',
      'Tennis & Racquet Sports',
      'Water Sports',
      'Winter Sports',
      'Camping & Hiking',
    ],
    home: [
      'Kitchen Appliances',
      'Garden Tools',
      'Home Decor',
      'Bedding & Linens',
      'Cleaning Supplies',
      'Power Tools',
      'Plants & Seeds',
      'BBQ & Outdoor',
    ],
    beauty: [
      'Skincare',
      'Makeup',
      'Hair Care',
      'Perfumes & Fragrances',
      'Bath & Body',
      'Beauty Tools',
      'Nail Care',
      'Men\'s Grooming',
    ],
    automotive: [
      'Car Parts',
      'Motorcycle Parts',
      'Tires & Wheels',
      'Car Audio',
      'GPS & Navigation',
      'Car Accessories',
      'Tools & Equipment',
      'Maintenance Products',
    ],
    collectibles: [
      'Trading Cards',
      'Coins & Currency',
      'Stamps',
      'Antiques',
      'Art & Paintings',
      'Memorabilia',
      'Vintage Items',
      'Limited Editions',
    ],
    hobbies: [
      'Arts & Crafts',
      'Model Building',
      'Knitting & Sewing',
      'Painting Supplies',
      'Photography',
      'Collecting',
      'DIY Tools',
      'Scrapbooking',
    ],
    music: [
      'Guitars',
      'Keyboards & Pianos',
      'Drums & Percussion',
      'DJ Equipment',
      'Recording Equipment',
      'Vinyl Records',
      'Music Books',
      'Accessories',
    ],
    pets: [
      'Dog Supplies',
      'Cat Supplies',
      'Fish & Aquarium',
      'Bird Supplies',
      'Small Pet Supplies',
      'Pet Clothing',
      'Pet Toys',
      'Pet Health',
    ],
    baby: [
      'Baby Clothing',
      'Diapers & Wipes',
      'Baby Gear & Furniture',
      'Toys & Books',
      'Feeding Supplies',
      'Bath & Skincare',
      'Kids Clothing',
      'Safety Equipment',
    ],
    office: [
      'Desks & Chairs',
      'Stationery',
      'Printers & Scanners',
      'Storage & Filing',
      'Office Decor',
      'Art Supplies',
      'Presentation Tools',
      'Calculators',
    ],
    other: [
      'Miscellaneous',
      'Digital Products',
      'Gift Cards',
      'Services',
    ],
  };
  
  static List<String> getSubcategories(String category) {
    return subcategories[category] ?? [];
  }
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

// Item Colors
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
  
  // Color hex codes for UI display
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

/// İlan büyüklük seviyeleri (NEW)
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

/// Moderasyon durumu (NEW)
enum ModerationStatus {
  pending, // Onay bekliyor
  approved, // Onaylandı
  rejected, // Reddedildi
  flagged, // İşaretlendi (tekrar inceleme)
  autoApproved, // Otomatik onaylandı
}

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
