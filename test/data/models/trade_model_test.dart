import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barter_qween/data/models/trade_model.dart';
import 'package:barter_qween/domain/entities/trade_entity.dart';

void main() {
  group('TradeModel', () {
    late TradeEntity testEntity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 18, 12, 0, 0);
      testEntity = TradeEntity(
        id: 'trade123',
        offerId: 'offer123',
        initiatorId: 'user1',
        initiatorItemId: 'item1',
        receiverId: 'user2',
        receiverItemId: 'item2',
        status: TradeStatus.pending,
        agreedAt: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('fromEntity', () {
      test('converts minimal entity correctly', () {
        final model = TradeModel.fromEntity(testEntity);

        expect(model.id, testEntity.id);
        expect(model.offerId, testEntity.offerId);
        expect(model.initiatorId, testEntity.initiatorId);
        expect(model.status, 'pending');
        expect(model.agreedAt, testEntity.agreedAt);
      });

      test('converts full entity with all fields', () {
        final fullEntity = testEntity.copyWith(
          cashDifferential: 50.0,
          paymentDirection: CashPaymentDirection.fromInitiator,
          paymentMethod: 'cash',
          meetupLocation: 'Starbucks',
          meetupLatitude: 41.0082,
          meetupLongitude: 28.9784,
          scheduledMeetupTime: testDate.add(const Duration(days: 1)),
          initiatorConfirmed: true,
          receiverConfirmed: false,
          initiatorRating: 4.5,
          hasIssues: true,
          issueDescription: 'Item condition issue',
          disputeStatus: DisputeStatus.underReview,
        );

        final model = TradeModel.fromEntity(fullEntity);

        expect(model.cashDifferential, 50.0);
        expect(model.paymentDirection, 'fromInitiator');
        expect(model.paymentMethod, 'cash');
        expect(model.meetupLocation, 'Starbucks');
        expect(model.meetupLatitude, 41.0082);
        expect(model.initiatorConfirmed, true);
        expect(model.receiverConfirmed, false);
        expect(model.initiatorRating, 4.5);
        expect(model.hasIssues, true);
        expect(model.issueDescription, 'Item condition issue');
        expect(model.disputeStatus, 'underReview');
      });

      test('handles null enums correctly', () {
        final model = TradeModel.fromEntity(testEntity);

        expect(model.paymentDirection, isNull);
        expect(model.disputeStatus, isNull);
      });
    });

    group('toEntity', () {
      test('converts model back to entity correctly', () {
        final model = TradeModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, testEntity.id);
        expect(entity.offerId, testEntity.offerId);
        expect(entity.status, TradeStatus.pending);
        expect(entity.agreedAt, testEntity.agreedAt);
      });

      test('preserves enum values through conversion', () {
        final entityWithEnums = testEntity.copyWith(
          status: TradeStatus.completed,
          paymentDirection: CashPaymentDirection.fromReceiver,
          disputeStatus: DisputeStatus.resolved,
        );

        final model = TradeModel.fromEntity(entityWithEnums);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, TradeStatus.completed);
        expect(convertedEntity.paymentDirection, CashPaymentDirection.fromReceiver);
        expect(convertedEntity.disputeStatus, DisputeStatus.resolved);
      });
    });

    group('toFirestore', () {
      test('creates valid Firestore map', () {
        final model = TradeModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['offerId'], 'offer123');
        expect(firestoreData['initiatorId'], 'user1');
        expect(firestoreData['status'], 'pending');
        expect(firestoreData['agreedAt'], isA<Timestamp>());
        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['initiatorConfirmed'], false);
        expect(firestoreData['receiverConfirmed'], false);
        expect(firestoreData['hasIssues'], false);
      });

      test('converts DateTime to Timestamp correctly', () {
        final model = TradeModel.fromEntity(testEntity.copyWith(
          scheduledMeetupTime: testDate.add(const Duration(days: 2)),
          completedAt: testDate.add(const Duration(days: 3)),
        ));
        final firestoreData = model.toFirestore();

        expect(firestoreData['scheduledMeetupTime'], isA<Timestamp>());
        expect(firestoreData['completedAt'], isA<Timestamp>());
        expect(
          (firestoreData['scheduledMeetupTime'] as Timestamp).toDate(),
          testDate.add(const Duration(days: 2)),
        );
      });

      test('handles null DateTime fields', () {
        final model = TradeModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['completedAt'], isNull);
        expect(firestoreData['cancelledAt'], isNull);
        expect(firestoreData['scheduledMeetupTime'], isNull);
      });
    });

    group('roundtrip conversions', () {
      test('entity -> model -> entity preserves data', () {
        final originalEntity = testEntity.copyWith(
          cashDifferential: 100.0,
          paymentDirection: CashPaymentDirection.fromInitiator,
          meetupLocation: 'Central Park',
          initiatorConfirmed: true,
          initiatorRating: 5.0,
        );

        final model = TradeModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.id, originalEntity.id);
        expect(convertedEntity.cashDifferential, originalEntity.cashDifferential);
        expect(convertedEntity.paymentDirection, originalEntity.paymentDirection);
        expect(convertedEntity.meetupLocation, originalEntity.meetupLocation);
        expect(convertedEntity.initiatorConfirmed, originalEntity.initiatorConfirmed);
        expect(convertedEntity.initiatorRating, originalEntity.initiatorRating);
      });

      test('entity -> model -> Firestore map preserves data', () {
        final originalEntity = testEntity.copyWith(
          status: TradeStatus.inProgress,
          cashDifferential: 75.0,
          hasIssues: true,
        );

        final model = TradeModel.fromEntity(originalEntity);
        final firestoreData = model.toFirestore();
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, TradeStatus.inProgress);
        expect(convertedEntity.cashDifferential, 75.0);
        expect(convertedEntity.hasIssues, true);
        expect(firestoreData['status'], 'inProgress');
        expect(firestoreData['cashDifferential'], 75.0);
        expect(firestoreData['hasIssues'], true);
      });
    });

    group('edge cases', () {
      test('handles zero cash differential', () {
        final entity = testEntity.copyWith(cashDifferential: 0.0);
        final model = TradeModel.fromEntity(entity);

        expect(model.cashDifferential, 0.0);
      });

      test('handles all TradeStatus enum values', () {
        for (final status in TradeStatus.values) {
          final entity = testEntity.copyWith(status: status);
          final model = TradeModel.fromEntity(entity);
          final convertedEntity = model.toEntity();

          expect(convertedEntity.status, status);
        }
      });

      test('handles metadata field', () {
        final entity = testEntity.copyWith(
          metadata: {'key1': 'value1', 'key2': 123},
        );
        final model = TradeModel.fromEntity(entity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['metadata'], {'key1': 'value1', 'key2': 123});
      });
    });
  });
}
