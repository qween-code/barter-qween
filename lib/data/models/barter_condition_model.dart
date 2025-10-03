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
      paymentDirection:
          _parsePaymentDirection(data['paymentDirection'] as String?),
      acceptedCategories: (data['acceptedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specificItemRequest: data['specificItemRequest'] as String?,
      minValue: (data['minValue'] as num?)?.toDouble(),
      maxValue: (data['maxValue'] as num?)?.toDouble(),
      description: data['description'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
