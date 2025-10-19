import 'package:equatable/equatable.dart';

/// Payment Entity - Tüm ödeme işlemleri için
class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final PaymentType type;
  final PaymentMethod method;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? transactionId;
  final String? orderId;
  final String? receiptData;
  final String? itemId; // İlanla ilişkili ise
  final String? tradeOfferId; // Trade ile ilişkili ise
  final String? subscriptionId; // Abonelikle ilişkili ise
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final String? errorMessage;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.method,
    required this.amount,
    this.currency = 'TRY',
    required this.status,
    this.transactionId,
    this.orderId,
    this.receiptData,
    this.itemId,
    this.tradeOfferId,
    this.subscriptionId,
    this.description,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    this.refundedAt,
    this.errorMessage,
  });

  PaymentEntity copyWith({
    String? id,
    String? userId,
    PaymentType? type,
    PaymentMethod? method,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? transactionId,
    String? orderId,
    String? receiptData,
    String? itemId,
    String? tradeOfferId,
    String? subscriptionId,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? refundedAt,
    String? errorMessage,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      receiptData: receiptData ?? this.receiptData,
      itemId: itemId ?? this.itemId,
      tradeOfferId: tradeOfferId ?? this.tradeOfferId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    method,
    amount,
    currency,
    status,
    transactionId,
    orderId,
    receiptData,
    itemId,
    tradeOfferId,
    subscriptionId,
    description,
    metadata,
    createdAt,
    completedAt,
    refundedAt,
    errorMessage,
  ];
}

/// Payment Type - Ödeme tipi
enum PaymentType {
  listingFee, // İlan verme ücreti
  premiumListing, // Premium ilan/öne çıkarma
  subscription, // Abonelik
  tradeCommission, // Trade komisyonu
  cashDifferential, // Trade'deki para farkı ödemesi
  adRemoval, // Reklam kaldırma (tek seferlik)
}

/// Payment Method - Ödeme yöntemi
enum PaymentMethod {
  googlePay, // Google Pay
  applePay, // Apple Pay
  inAppPurchase, // In-App Purchase (store)
  creditCard, // Kredi kartı (gelecek)
}

/// Payment Status
enum PaymentStatus {
  pending, // Ödeme bekleniyor
  processing, // İşleniyor
  completed, // Tamamlandı
  failed, // Başarısız
  refunded, // İade edildi
  cancelled, // İptal edildi
}

/// Extension for display
extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.listingFee:
        return 'İlan Ücreti';
      case PaymentType.premiumListing:
        return 'Premium İlan';
      case PaymentType.subscription:
        return 'Abonelik';
      case PaymentType.tradeCommission:
        return 'Trade Komisyonu';
      case PaymentType.cashDifferential:
        return 'Para Farkı';
      case PaymentType.adRemoval:
        return 'Reklamsız';
    }
  }

  String get description {
    switch (this) {
      case PaymentType.listingFee:
        return 'İlan verme ücreti ödemesi';
      case PaymentType.premiumListing:
        return 'İlanı öne çıkarma ödemesi';
      case PaymentType.subscription:
        return 'Aylık/yıllık abonelik ödemesi';
      case PaymentType.tradeCommission:
        return 'Başarılı trade komisyonu';
      case PaymentType.cashDifferential:
        return 'Trade para farkı ödemesi';
      case PaymentType.adRemoval:
        return 'Reklamları kaldırma ödemesi';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.inAppPurchase:
        return 'Uygulama İçi Satın Alma';
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.googlePay:
        return '💳';
      case PaymentMethod.applePay:
        return '🍎';
      case PaymentMethod.inAppPurchase:
        return '📱';
      case PaymentMethod.creditCard:
        return '💳';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Bekliyor';
      case PaymentStatus.processing:
        return 'İşleniyor';
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
      case PaymentStatus.cancelled:
        return 'İptal';
    }
  }

  bool get isSuccessful => this == PaymentStatus.completed;
  bool get isPending =>
      this == PaymentStatus.pending || this == PaymentStatus.processing;
  bool get isFailed =>
      this == PaymentStatus.failed || this == PaymentStatus.cancelled;
}
