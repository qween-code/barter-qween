import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/barter_condition_entity.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/barter_repository.dart';
import '../models/item_model.dart';

@LazySingleton(as: BarterRepository)
class BarterRepositoryImpl implements BarterRepository {
  final FirebaseFirestore _firestore;

  BarterRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<Either<Failure, List<ItemEntity>>> getMatchingItems(
    BarterConditionEntity condition,
    String currentItemId,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .where('moderationStatus', isEqualTo: 'approved');

      // Mevcut ilan hariç
      query = query.where(FieldPath.documentId, isNotEqualTo: currentItemId);

      // Condition type'a göre filtreleme
      switch (condition.type) {
        case BarterConditionType.categorySpecific:
          if (condition.acceptedCategories != null &&
              condition.acceptedCategories!.isNotEmpty) {
            query = query.where('category',
                whereIn: condition.acceptedCategories);
          }
          break;

        case BarterConditionType.valueRange:
          if (condition.minValue != null) {
            query =
                query.where('monetaryValue', isGreaterThanOrEqualTo: condition.minValue);
          }
          if (condition.maxValue != null) {
            query =
                query.where('monetaryValue', isLessThanOrEqualTo: condition.maxValue);
          }
          break;

        default:
          // Diğer tipler için genel sorgulama
          break;
      }

      // Limit ekle
      query = query.limit(20);

      final querySnapshot = await query.get();
      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(items);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarterMatchResult>> validateBarterMatch(
    String offeredItemId,
    String requestedItemId,
  ) async {
    try {
      // Her iki ilanı getir
      final offeredDoc =
          await _firestore.collection('items').doc(offeredItemId).get();
      final requestedDoc =
          await _firestore.collection('items').doc(requestedItemId).get();

      if (!offeredDoc.exists || !requestedDoc.exists) {
        return Left(ServerFailure('Bir veya her iki ilan bulunamadı'));
      }

      final offeredItem = ItemModel.fromFirestore(offeredDoc).toEntity();
      final requestedItem = ItemModel.fromFirestore(requestedDoc).toEntity();

      // Uyumluluk skorunu hesapla
      double compatibilityScore = 0.0;
      String? reason;
      double? suggestedCash;
      CashPaymentDirection? suggestedDirection;

      // Değer uyumu kontrolü (en önemli faktör: %50)
      if (offeredItem.monetaryValue != null &&
          requestedItem.monetaryValue != null) {
        final valueDiff =
            (offeredItem.monetaryValue! - requestedItem.monetaryValue!).abs();
        final avgValue =
            (offeredItem.monetaryValue! + requestedItem.monetaryValue!) / 2;
        final valueDiffPercent = (valueDiff / avgValue) * 100;

        if (valueDiffPercent < 10) {
          compatibilityScore += 50;
        } else if (valueDiffPercent < 30) {
          compatibilityScore += 30;
        } else {
          compatibilityScore += 10;
          // Para farkı öner
          suggestedCash = valueDiff;
          suggestedDirection =
              offeredItem.monetaryValue! > requestedItem.monetaryValue!
                  ? CashPaymentDirection.toMe
                  : CashPaymentDirection.fromMe;
        }
      } else {
        compatibilityScore += 25; // Değer belirtilmemiş, orta skor
      }

      // Kategori uyumu (%20)
      if (requestedItem.barterCondition != null) {
        final condition = requestedItem.barterCondition!;
        if (condition.type == BarterConditionType.categorySpecific &&
            condition.acceptedCategories != null) {
          if (condition.acceptedCategories!.contains(offeredItem.category)) {
            compatibilityScore += 20;
          }
        } else {
          compatibilityScore += 10; // Esnek şart
        }
      } else {
        compatibilityScore += 15;
      }

      // Durum uyumu (%15)
      if (offeredItem.condition == requestedItem.condition) {
        compatibilityScore += 15;
      } else {
        compatibilityScore += 5;
      }

      // Konum yakınlığı (%15)
      if (offeredItem.city == requestedItem.city) {
        compatibilityScore += 15;
      } else if (offeredItem.city != null && requestedItem.city != null) {
        compatibilityScore += 5;
      }

      // Sonuç
      final isMatch = compatibilityScore >= 60;

      if (isMatch) {
        reason = 'İyi bir eşleşme! Skor: ${compatibilityScore.toInt()}/100';
      } else {
        reason =
            'Düşük uyumluluk. Skor: ${compatibilityScore.toInt()}/100. Farklı seçeneklere bakın.';
      }

      return Right(
        BarterMatchResult(
          isMatch: isMatch,
          compatibilityScore: compatibilityScore,
          reason: reason,
          suggestedCashDifferential: suggestedCash,
          suggestedPaymentDirection: suggestedDirection,
        ),
      );
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateCashDifferential(
    String item1Id,
    String item2Id,
  ) async {
    try {
      final item1Doc = await _firestore.collection('items').doc(item1Id).get();
      final item2Doc = await _firestore.collection('items').doc(item2Id).get();

      if (!item1Doc.exists || !item2Doc.exists) {
        return Left(ServerFailure('İlanlar bulunamadı'));
      }

      final item1 = ItemModel.fromFirestore(item1Doc).toEntity();
      final item2 = ItemModel.fromFirestore(item2Doc).toEntity();

      if (item1.monetaryValue == null || item2.monetaryValue == null) {
        return Left(ServerFailure('İlan değerleri belirtilmemiş'));
      }

      final differential = (item1.monetaryValue! - item2.monetaryValue!).abs();
      return Right(differential);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CashDifferentialSuggestion>> suggestCashDifferential(
    double item1Value,
    double item2Value,
  ) async {
    try {
      final differential = (item1Value - item2Value).abs();

      // Küçük fark ise para önerme
      if (differential < 50) {
        return Right(
          CashDifferentialSuggestion(
            amount: 0,
            direction: CashPaymentDirection.fromMe,
            reason: 'Değerler çok yakın, para farkı gerekmez',
          ),
        );
      }

      // Büyük fark ise yuvarla
      final roundedDiff = (differential / 50).ceil() * 50;

      final direction = item1Value > item2Value
          ? CashPaymentDirection.toMe
          : CashPaymentDirection.fromMe;

      final reason = direction == CashPaymentDirection.fromMe
          ? 'Ürününüz daha düşük değerde, $roundedDiff TL eklemeniz önerilir'
          : 'Ürününüz daha yüksek değerde, $roundedDiff TL fark alabilirsiniz';

      return Right(
        CashDifferentialSuggestion(
          amount: roundedDiff.toDouble(),
          direction: direction,
          reason: reason,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
