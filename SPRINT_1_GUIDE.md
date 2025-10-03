# 🎯 SPRINT 1: BARTER HAVUZU ŞARTLARI SİSTEMİ

> **Süre:** 2-3 hafta  
> **Öncelik:** 🔥 Kritik  
> **Bağımlılık:** Yok (ilk sprint)

---

## 📋 SPRINT HEDEFLERI

1. ✅ Barter şartları veri yapısını oluştur
2. ✅ "Ürün + X TL" hibrit sistem
3. ✅ Kategori bazlı takas şartları
4. ✅ Barter eşleştirme algoritması
5. ✅ UI/UX için widget'lar

---

## 📅 HAFTALIK PLAN

### **HAFTA 1: Domain & Data Layer** (5 gün)
- Gün 1-2: Entities ve enums
- Gün 3: Repository interfaces
- Gün 4: Data models
- Gün 5: Repository implementation

### **HAFTA 2: Business Logic & Backend** (5 gün)
- Gün 1-2: Use cases
- Gün 3: BLoC implementation
- Gün 4-5: Firebase Cloud Functions

### **HAFTA 3: UI & Testing** (5 gün)
- Gün 1-2: Widgets (barter condition selector, value input)
- Gün 3: Pages (create item wizard)
- Gün 4: Unit & widget tests
- Gün 5: Integration testing & bug fixes

---

## 🏗️ ADIM ADIM UYGULAMA

## ADIM 1: Domain Layer - Entities (Gün 1)

### 1.1. Barter Condition Entity Oluştur

**Dosya: `lib/domain/entities/barter_condition_entity.dart`**

```dart
import 'package:equatable/equatable.dart';

/// Barter şartlarını tanımlayan entity
class BarterConditionEntity extends Equatable {
  final String id;
  final BarterConditionType type;
  final double? cashDifferential;           // Para farkı (TL)
  final CashPaymentDirection? paymentDirection; // Kim ödeyecek
  final List<String>? acceptedCategories;   // Kabul edilen kategoriler
  final String? specificItemRequest;        // Belirli ürün talebi
  final double? minValue;                   // Minimum değer
  final double? maxValue;                   // Maximum değer
  final String? description;                // Özel açıklama
  final DateTime createdAt;

  const BarterConditionEntity({
    required this.id,
    required this.type,
    this.cashDifferential,
    this.paymentDirection,
    this.acceptedCategories,
    this.specificItemRequest,
    this.minValue,
    this.maxValue,
    this.description,
    required this.createdAt,
  });

  BarterConditionEntity copyWith({
    String? id,
    BarterConditionType? type,
    double? cashDifferential,
    CashPaymentDirection? paymentDirection,
    List<String>? acceptedCategories,
    String? specificItemRequest,
    double? minValue,
    double? maxValue,
    String? description,
    DateTime? createdAt,
  }) {
    return BarterConditionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      cashDifferential: cashDifferential ?? this.cashDifferential,
      paymentDirection: paymentDirection ?? this.paymentDirection,
      acceptedCategories: acceptedCategories ?? this.acceptedCategories,
      specificItemRequest: specificItemRequest ?? this.specificItemRequest,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        cashDifferential,
        paymentDirection,
        acceptedCategories,
        specificItemRequest,
        minValue,
        maxValue,
        description,
        createdAt,
      ];

  @override
  String toString() {
    return 'BarterCondition(type: $type, cash: $cashDifferential)';
  }
}

/// Barter şart tipleri
enum BarterConditionType {
  directSwap,       // Direkt takas (1:1)
  cashPlus,         // Ürün + para (ben ödeyeceğim)
  cashMinus,        // Ürün - para (karşı taraf ödeyecek)
  categorySpecific, // Belirli kategorilerle
  specificItem,     // Belirli ürün talebi
  valueRange,       // Değer aralığı
  flexible,         // Esnek (her şey olabilir)
}

/// Para ödeme yönü
enum CashPaymentDirection {
  fromMe,     // Ben ödeyeceğim (my item + cash)
  toMe,       // Bana ödenecek (my item - cash for me)
}

/// Extension: Display names
extension BarterConditionTypeExtension on BarterConditionType {
  String get displayName {
    switch (this) {
      case BarterConditionType.directSwap:
        return 'Direkt Takas';
      case BarterConditionType.cashPlus:
        return 'Ürünüm + Para';
      case BarterConditionType.cashMinus:
        return 'Ürünüm - Para Alırım';
      case BarterConditionType.categorySpecific:
        return 'Belirli Kategoriler';
      case BarterConditionType.specificItem:
        return 'Belirli Ürün İstiyorum';
      case BarterConditionType.valueRange:
        return 'Değer Aralığı';
      case BarterConditionType.flexible:
        return 'Esnek';
    }
  }

  String get description {
    switch (this) {
      case BarterConditionType.directSwap:
        return 'Ürünümü başka bir ürünle direkt takas etmek istiyorum';
      case BarterConditionType.cashPlus:
        return 'Ürünüm + belirli miktarda para karşılığında takas';
      case BarterConditionType.cashMinus:
        return 'Ürünüm değerli, karşı taraf para eklemeli';
      case BarterConditionType.categorySpecific:
        return 'Sadece belirli kategorilerdeki ürünlerle takas';
      case BarterConditionType.specificItem:
        return 'Aradığım belirli bir ürün var';
      case BarterConditionType.valueRange:
        return 'Belirli değer aralığındaki ürünler';
      case BarterConditionType.flexible:
        return 'Esnek, tüm tekliflere açığım';
    }
  }
}
```

**✅ CHECKPOINT:** Entity oluşturuldu, compile ediyor mu kontrol et:
```bash
flutter analyze lib/domain/entities/barter_condition_entity.dart
```

---

### 1.2. Item Entity'yi Güncelle (Gün 1)

**Dosya: `lib/domain/entities/item_entity.dart` (MEVCUT DOSYAYI GÜNCELLE)**

Mevcut ItemEntity class'ına şu fieldları ekle:

```dart
// YENİ FIELDLAR (ItemEntity class içine ekle):

  // Barter & Monetization
  final double? monetaryValue;                    // TL cinsinden değer
  final BarterConditionEntity? barterCondition;   // Barter şartları
  final ItemTier? tier;                           // Küçük/Orta/Büyük
  
  // Moderation
  final ModerationStatus moderationStatus;         // Onay durumu
  final String? adminNotes;                        // Admin notları
  final DateTime? approvedAt;                      // Onay zamanı
  final String? approvedBy;                        // Onaylayan admin ID
  
  // Media
  final List<String>? videoUrls;                   // Video URL'leri
  
  // Delivery
  final bool requiresDelivery;                     // Teslimat gerekli mi
  final String? deliveryInfo;                      // Teslimat bilgisi
  
  // Location (harita için)
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
```

**Ayrıca bu enum'ları ekle (dosyanın sonuna):**

```dart
/// İlan büyüklük seviyeleri
enum ItemTier {
  small,    // 0-500 TL
  medium,   // 500-2000 TL
  large,    // 2000+ TL
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

/// Moderasyon durumu
enum ModerationStatus {
  pending,        // Onay bekliyor
  approved,       // Onaylandı
  rejected,       // Reddedildi
  flagged,        // İşaretlendi (tekrar inceleme)
  autoApproved,   // Otomatik onaylandı
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
```

**⚠️ ÖNEMLİ:** copyWith metodunu da güncellemeyi unutma!

---

### 1.3. Trade Offer Entity'yi Güncelle (Gün 2)

**Dosya: `lib/domain/entities/trade_offer_entity.dart` (GÜNCELLE)**

TradeOfferEntity'ye şu fieldları ekle:

```dart
// YENİ FIELDLAR:
  final double? cashDifferential;              // Para farkı
  final CashPaymentDirection? paymentDirection; // Kim ödeyecek
  final String? conditionNotes;                // Şart notları
  final bool meetsBarterCondition;             // Şartları karşılıyor mu
  final double? offeredItemValue;              // Teklif edilen ürün değeri
  final double? requestedItemValue;            // İstenen ürün değeri
```

---

## ADIM 2: Domain Layer - Repositories (Gün 2)

### 2.1. Barter Repository Interface

**Dosya: `lib/domain/repositories/barter_repository.dart` (YENİ)**

```dart
import 'package:dartz/dartz.dart';
import '../entities/barter_condition_entity.dart';
import '../entities/item_entity.dart';
import '../../core/error/failures.dart';

abstract class BarterRepository {
  /// Barter şartına uygun ilanları getir
  Future<Either<Failure, List<ItemEntity>>> getMatchingItems(
    BarterConditionEntity condition,
    String currentItemId,
  );

  /// İki ilan arasında barter uyumunu kontrol et
  Future<Either<Failure, BarterMatchResult>> validateBarterMatch(
    String offeredItemId,
    String requestedItemId,
  );

  /// Para farkını hesapla
  Future<Either<Failure, double>> calculateCashDifferential(
    String item1Id,
    String item2Id,
  );

  /// Önerilen para farkını hesapla (değer bazlı)
  Future<Either<Failure, CashDifferentialSuggestion>> suggestCashDifferential(
    double item1Value,
    double item2Value,
  );
}

/// Barter eşleşme sonucu
class BarterMatchResult {
  final bool isMatch;
  final double compatibilityScore;  // 0-100
  final String? reason;
  final double? suggestedCashDifferential;
  final CashPaymentDirection? suggestedPaymentDirection;

  const BarterMatchResult({
    required this.isMatch,
    required this.compatibilityScore,
    this.reason,
    this.suggestedCashDifferential,
    this.suggestedPaymentDirection,
  });
}

/// Para farkı önerisi
class CashDifferentialSuggestion {
  final double amount;
  final CashPaymentDirection direction;
  final String reason;

  const CashDifferentialSuggestion({
    required this.amount,
    required this.direction,
    required this.reason,
  });
}
```

---

## ADIM 3: Data Layer - Models (Gün 3)

### 3.1. Barter Condition Model

**Dosya: `lib/data/models/barter_condition_model.dart` (YENİ)**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/barter_condition_entity.dart';

class BarterConditionModel extends BarterConditionEntity {
  const BarterConditionModel({
    required super.id,
    required super.type,
    super.cashDifferential,
    super.paymentDirection,
    super.acceptedCategories,
    super.specificItemRequest,
    super.minValue,
    super.maxValue,
    super.description,
    required super.createdAt,
  });

  /// Firestore'dan model oluştur
  factory BarterConditionModel.fromFirestore(Map<String, dynamic> data) {
    return BarterConditionModel(
      id: data['id'] as String? ?? '',
      type: _parseBarterConditionType(data['type'] as String?),
      cashDifferential: (data['cashDifferential'] as num?)?.toDouble(),
      paymentDirection: _parsePaymentDirection(data['paymentDirection'] as String?),
      acceptedCategories: (data['acceptedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specificItemRequest: data['specificItemRequest'] as String?,
      minValue: (data['minValue'] as num?)?.toDouble(),
      maxValue: (data['maxValue'] as num?)?.toDouble(),
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Model'i Firestore'a kaydet
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type.name,
      'cashDifferential': cashDifferential,
      'paymentDirection': paymentDirection?.name,
      'acceptedCategories': acceptedCategories,
      'specificItemRequest': specificItemRequest,
      'minValue': minValue,
      'maxValue': maxValue,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Entity'den model oluştur
  factory BarterConditionModel.fromEntity(BarterConditionEntity entity) {
    return BarterConditionModel(
      id: entity.id,
      type: entity.type,
      cashDifferential: entity.cashDifferential,
      paymentDirection: entity.paymentDirection,
      acceptedCategories: entity.acceptedCategories,
      specificItemRequest: entity.specificItemRequest,
      minValue: entity.minValue,
      maxValue: entity.maxValue,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }

  // Helper methods
  static BarterConditionType _parseBarterConditionType(String? value) {
    if (value == null) return BarterConditionType.flexible;
    return BarterConditionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BarterConditionType.flexible,
    );
  }

  static CashPaymentDirection? _parsePaymentDirection(String? value) {
    if (value == null) return null;
    return CashPaymentDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CashPaymentDirection.fromMe,
    );
  }
}
```

---

## 🎯 BU ADIMI TAMAMLA, DEVAM EDELİM Mİ?

Yukarıdaki dosyaları oluştur ve test et:

```bash
# 1. Dosyaları oluştur
# 2. Compile kontrolü
flutter analyze

# 3. Git commit
git add .
git commit -m "feat(domain): add barter condition entities and repository interface"
git push
```

**Hazır olduğunda "devam" de, Adım 4'e (Data Repository Implementation) geçelim! 🚀**
