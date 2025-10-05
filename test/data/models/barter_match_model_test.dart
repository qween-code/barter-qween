import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barter_qween/data/models/barter_match_model.dart';
import 'package:barter_qween/domain/entities/barter_match_entity.dart';

void main() {
  group('BarterMatchModel', () {
    late BarterMatchEntity testEntity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 18, 12, 0, 0);
      testEntity = BarterMatchEntity(
        id: 'match123',
        sourceItemId: 'item1',
        targetItemId: 'item2',
        sourceUserId: 'user1',
        targetUserId: 'user2',
        matchScore: 85.5,
        categoryScore: 30.0,
        priceScore: 22.5,
        locationScore: 18.0,
        trustScore: 12.0,
        conditionScore: 3.0,
        quality: MatchQuality.excellent,
        matchReasons: ['Same category', 'Similar price'],
        conditionsCompatible: true,
        calculatedAt: testDate,
      );
    });

    group('fromEntity', () {
      test('converts minimal entity correctly', () {
        final model = BarterMatchModel.fromEntity(testEntity);

        expect(model.id, testEntity.id);
        expect(model.sourceItemId, 'item1');
        expect(model.matchScore, 85.5);
        expect(model.quality, 'excellent');
        expect(model.matchReasons, ['Same category', 'Similar price']);
        expect(model.isSeen, false);
        expect(model.viewCount, 0);
      });

      test('converts full entity with all fields', () {
        final fullEntity = testEntity.copyWith(
          concerns: ['Distance is far'],
          distanceKm: 5.2,
          locationDescription: '5.2 km away',
          compatibilityNote: 'Perfect match',
          suggestedCashDifferential: 50.0,
          cashDirection: CashDirection.sourceToTarget,
          isSeen: true,
          seenAt: testDate.add(const Duration(hours: 1)),
          viewCount: 3,
          wasOffered: true,
          offerId: 'offer123',
        );

        final model = BarterMatchModel.fromEntity(fullEntity);

        expect(model.concerns, ['Distance is far']);
        expect(model.distanceKm, 5.2);
        expect(model.locationDescription, '5.2 km away');
        expect(model.suggestedCashDifferential, 50.0);
        expect(model.cashDirection, 'sourceToTarget');
        expect(model.isSeen, true);
        expect(model.viewCount, 3);
        expect(model.wasOffered, true);
        expect(model.offerId, 'offer123');
      });

      test('handles all MatchQuality enum values', () {
        for (final quality in MatchQuality.values) {
          final entity = testEntity.copyWith(quality: quality);
          final model = BarterMatchModel.fromEntity(entity);

          expect(model.quality, quality.name);
        }
      });
    });

    group('toEntity', () {
      test('converts model back to entity correctly', () {
        final model = BarterMatchModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, testEntity.id);
        expect(entity.matchScore, testEntity.matchScore);
        expect(entity.quality, MatchQuality.excellent);
        expect(entity.matchReasons, testEntity.matchReasons);
      });

      test('preserves all score values', () {
        final model = BarterMatchModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.categoryScore, 30.0);
        expect(entity.priceScore, 22.5);
        expect(entity.locationScore, 18.0);
        expect(entity.trustScore, 12.0);
        expect(entity.conditionScore, 3.0);
      });

      test('converts CashDirection enum correctly', () {
        final entityWithCash = testEntity.copyWith(
          cashDirection: CashDirection.targetToSource,
        );

        final model = BarterMatchModel.fromEntity(entityWithCash);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.cashDirection, CashDirection.targetToSource);
      });
    });

    group('toFirestore', () {
      test('creates valid Firestore map', () {
        final model = BarterMatchModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['sourceItemId'], 'item1');
        expect(firestoreData['targetItemId'], 'item2');
        expect(firestoreData['matchScore'], 85.5);
        expect(firestoreData['quality'], 'excellent');
        expect(firestoreData['matchReasons'], isA<List>());
        expect(firestoreData['calculatedAt'], isA<Timestamp>());
        expect(firestoreData['isSeen'], false);
        expect(firestoreData['viewCount'], 0);
      });

      test('handles list fields correctly', () {
        final model = BarterMatchModel.fromEntity(testEntity.copyWith(
          matchReasons: ['Reason 1', 'Reason 2', 'Reason 3'],
          concerns: ['Concern 1', 'Concern 2'],
        ));
        final firestoreData = model.toFirestore();

        expect(firestoreData['matchReasons'], ['Reason 1', 'Reason 2', 'Reason 3']);
        expect(firestoreData['concerns'], ['Concern 1', 'Concern 2']);
      });

      test('converts DateTime fields to Timestamp', () {
        final model = BarterMatchModel.fromEntity(testEntity.copyWith(
          isSeen: true,
          seenAt: testDate.add(const Duration(hours: 2)),
          isDismissed: true,
          dismissedAt: testDate.add(const Duration(hours: 3)),
        ));
        final firestoreData = model.toFirestore();

        expect(firestoreData['seenAt'], isA<Timestamp>());
        expect(firestoreData['dismissedAt'], isA<Timestamp>());
      });
    });

    group('Firestore serialization', () {
      test('toFirestore creates valid map', () {
        final model = BarterMatchModel.fromEntity(testEntity);
        final data = model.toFirestore();

        expect(data['sourceItemId'], 'item1');
        expect(data['matchScore'], 85.5);
        expect(data['quality'], 'excellent');
        expect(data['calculatedAt'], isA<Timestamp>());
      });

      test('toFirestore handles defaults', () {
        final model = BarterMatchModel.fromEntity(testEntity);
        final data = model.toFirestore();

        expect(data['isSeen'], false);
        expect(data['isDismissed'], false);
        expect(data['viewCount'], 0);
        expect(data['wasOffered'], false);
      });
    });

    group('roundtrip conversions', () {
      test('entity -> model -> entity preserves data', () {
        final originalEntity = testEntity.copyWith(
          distanceKm: 3.5,
          suggestedCashDifferential: 25.0,
          cashDirection: CashDirection.sourceToTarget,
          isSeen: true,
          viewCount: 5,
        );

        final model = BarterMatchModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.distanceKm, 3.5);
        expect(convertedEntity.suggestedCashDifferential, 25.0);
        expect(convertedEntity.cashDirection, CashDirection.sourceToTarget);
        expect(convertedEntity.isSeen, true);
        expect(convertedEntity.viewCount, 5);
      });

      test('entity -> model -> Firestore map preserves data', () {
        final originalEntity = testEntity.copyWith(
          quality: MatchQuality.good,
          concerns: ['Minor issue'],
          distanceKm: 10.5,
        );

        final model = BarterMatchModel.fromEntity(originalEntity);
        final firestoreData = model.toFirestore();
        final convertedEntity = model.toEntity();

        expect(convertedEntity.quality, MatchQuality.good);
        expect(convertedEntity.concerns, ['Minor issue']);
        expect(convertedEntity.distanceKm, 10.5);
        expect(firestoreData['quality'], 'good');
        expect(firestoreData['concerns'], ['Minor issue']);
        expect(firestoreData['distanceKm'], 10.5);
      });
    });

    group('score precision', () {
      test('preserves decimal precision for scores', () {
        final entity = testEntity.copyWith(
          matchScore: 87.345,
          categoryScore: 29.999,
          priceScore: 24.567,
        );

        final model = BarterMatchModel.fromEntity(entity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.matchScore, 87.345);
        expect(convertedEntity.categoryScore, 29.999);
        expect(convertedEntity.priceScore, 24.567);
      });
    });

    group('edge cases', () {
      test('handles empty lists', () {
        final entity = testEntity.copyWith(
          matchReasons: [],
          concerns: [],
        );

        final model = BarterMatchModel.fromEntity(entity);
        expect(model.matchReasons, isEmpty);
        expect(model.concerns, isEmpty);
      });

      test('handles maximum viewCount', () {
        final entity = testEntity.copyWith(viewCount: 999999);
        final model = BarterMatchModel.fromEntity(entity);

        expect(model.viewCount, 999999);
      });

      test('handles all MatchQuality values in roundtrip', () {
        for (final quality in MatchQuality.values) {
          final entity = testEntity.copyWith(quality: quality);
          final model = BarterMatchModel.fromEntity(entity);
          final convertedEntity = model.toEntity();

          expect(convertedEntity.quality, quality);
        }
      });
    });
  });
}
