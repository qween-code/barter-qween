import 'package:equatable/equatable.dart';

/// Barter şartlarını tanımlayan entity
class BarterConditionEntity extends Equatable {
  final String id;
  final BarterConditionType type;
  final double? cashDifferential; // Para farkı (TL)
  final CashPaymentDirection? paymentDirection; // Kim ödeyecek
  final List<String>? acceptedCategories; // Kabul edilen kategoriler
  final String? specificItemRequest; // Belirli ürün talebi
  final double? minValue; // Minimum değer
  final double? maxValue; // Maximum değer
  final String? description; // Özel açıklama
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
  directSwap, // Direkt takas (1:1)
  cashPlus, // Ürün + para (ben ödeyeceğim)
  cashMinus, // Ürün - para (karşı taraf ödeyecek)
  categorySpecific, // Belirli kategorilerle
  specificItem, // Belirli ürün talebi
  valueRange, // Değer aralığı
  flexible, // Esnek (her şey olabilir)
}

/// Para ödeme yönü
enum CashPaymentDirection {
  fromMe, // Ben ödeyeceğim (my item + cash)
  toMe, // Bana ödenecek (my item - cash for me)
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

extension CashPaymentDirectionExtension on CashPaymentDirection {
  String get displayName {
    switch (this) {
      case CashPaymentDirection.fromMe:
        return 'Ben Ödeyeceğim';
      case CashPaymentDirection.toMe:
        return 'Karşı Taraf Ödeyecek';
    }
  }
}
