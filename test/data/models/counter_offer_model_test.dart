import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barter_qween/data/models/counter_offer_model.dart';
import 'package:barter_qween/domain/entities/counter_offer_entity.dart';

void main() {
  group('CounterOfferModel', () {
    late CounterOfferEntity testEntity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 18, 12, 0, 0);
      testEntity = CounterOfferEntity(
        id: 'counter123',
        negotiationId: 'negotiation123',
        offerId: 'offer123',
        offererId: 'user1',
        targetUserId: 'user2',
        type: CounterOfferType.cash,
        status: CounterOfferStatus.pending,
        createdAt: testDate,
      );
    });

    group('fromEntity', () {
      test('converts minimal cash offer entity', () {
        final model = CounterOfferModel.fromEntity(testEntity);

        expect(model.id, 'counter123');
        expect(model.negotiationId, 'negotiation123');
        expect(model.type, 'cash');
        expect(model.status, 'pending');
        expect(model.isExpired, false);
      });

      test('converts full cash offer with all fields', () {
        final fullEntity = testEntity.copyWith(
          proposedCash: 75.0,
          proposedPaymentDirection: 'user1ToUser2',
          message: 'I can add 75 TL',
          expiresAt: testDate.add(const Duration(hours: 48)),
        );

        final model = CounterOfferModel.fromEntity(fullEntity);

        expect(model.proposedCash, 75.0);
        expect(model.proposedPaymentDirection, 'user1ToUser2');
        expect(model.message, 'I can add 75 TL');
      });

      test('converts location type offer', () {
        final locationEntity = testEntity.copyWith(
          type: CounterOfferType.location,
          proposedMeetupLocation: 'Starbucks Taksim',
          message: 'Can we meet here instead?',
        );

        final model = CounterOfferModel.fromEntity(locationEntity);

        expect(model.type, 'location');
        expect(model.proposedMeetupLocation, 'Starbucks Taksim');
        expect(model.message, 'Can we meet here instead?');
      });

      test('converts time type offer', () {
        final timeEntity = testEntity.copyWith(
          type: CounterOfferType.time,
          proposedMeetupTime: testDate.add(const Duration(days: 2)),
          message: 'Friday 3pm works better',
        );

        final model = CounterOfferModel.fromEntity(timeEntity);

        expect(model.type, 'time');
        expect(model.proposedMeetupTime, isNotNull);
        expect(model.message, 'Friday 3pm works better');
      });

      test('converts full offer with all changes', () {
        final fullEntity = testEntity.copyWith(
          type: CounterOfferType.full,
          proposedCash: 50.0,
          proposedPaymentDirection: 'user2ToUser1',
          proposedMeetupLocation: 'Mall of Istanbul',
          proposedMeetupTime: testDate.add(const Duration(days: 1)),
          message: 'Full counter proposal',
        );

        final model = CounterOfferModel.fromEntity(fullEntity);

        expect(model.type, 'full');
        expect(model.proposedCash, 50.0);
        expect(model.proposedMeetupLocation, 'Mall of Istanbul');
        expect(model.proposedMeetupTime, isNotNull);
      });

      test('handles all CounterOfferType enum values', () {
        for (final type in CounterOfferType.values) {
          final entity = testEntity.copyWith(type: type);
          final model = CounterOfferModel.fromEntity(entity);

          expect(model.type, type.name);
        }
      });

      test('handles all CounterOfferStatus enum values', () {
        for (final status in CounterOfferStatus.values) {
          final entity = testEntity.copyWith(status: status);
          final model = CounterOfferModel.fromEntity(entity);

          expect(model.status, status.name);
        }
      });
    });

    group('toEntity', () {
      test('converts model back to entity correctly', () {
        final model = CounterOfferModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, testEntity.id);
        expect(entity.negotiationId, testEntity.negotiationId);
        expect(entity.type, CounterOfferType.cash);
        expect(entity.status, CounterOfferStatus.pending);
      });

      test('preserves all type-specific fields', () {
        final fullEntity = testEntity.copyWith(
          type: CounterOfferType.full,
          proposedCash: 100.0,
          proposedMeetupLocation: 'Central Park',
          proposedMeetupTime: testDate.add(const Duration(days: 1)),
          message: 'Complete offer',
        );

        final model = CounterOfferModel.fromEntity(fullEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.proposedCash, 100.0);
        expect(convertedEntity.proposedMeetupLocation, 'Central Park');
        expect(convertedEntity.proposedMeetupTime, isNotNull);
        expect(convertedEntity.message, 'Complete offer');
      });

      test('preserves response data', () {
        final entityWithResponse = testEntity.copyWith(
          status: CounterOfferStatus.accepted,
          respondedAt: testDate.add(const Duration(hours: 2)),
          responseMessage: 'Accepted!',
        );

        final model = CounterOfferModel.fromEntity(entityWithResponse);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, CounterOfferStatus.accepted);
        expect(convertedEntity.responseMessage, 'Accepted!');
      });
    });

    group('toFirestore', () {
      test('creates valid Firestore map', () {
        final model = CounterOfferModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['negotiationId'], 'negotiation123');
        expect(firestoreData['offerId'], 'offer123');
        expect(firestoreData['type'], 'cash');
        expect(firestoreData['status'], 'pending');
        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['isExpired'], false);
      });

      test('converts DateTime fields to Timestamp', () {
        final model = CounterOfferModel.fromEntity(testEntity.copyWith(
          proposedMeetupTime: testDate.add(const Duration(days: 1)),
          expiresAt: testDate.add(const Duration(hours: 48)),
          status: CounterOfferStatus.accepted,
          respondedAt: testDate.add(const Duration(hours: 2)),
        ));
        final firestoreData = model.toFirestore();

        expect(firestoreData['proposedMeetupTime'], isA<Timestamp>());
        expect(firestoreData['expiresAt'], isA<Timestamp>());
        expect(firestoreData['respondedAt'], isA<Timestamp>());
      });

      test('handles null optional fields', () {
        final model = CounterOfferModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['proposedCash'], isNull);
        expect(firestoreData['proposedMeetupLocation'], isNull);
        expect(firestoreData['proposedMeetupTime'], isNull);
        expect(firestoreData['message'], isNull);
        expect(firestoreData['respondedAt'], isNull);
      });
    });

    group('Firestore serialization', () {
      test('toFirestore creates valid map', () {
        final model = CounterOfferModel.fromEntity(testEntity);
        final data = model.toFirestore();

        expect(data['negotiationId'], 'negotiation123');
        expect(data['type'], 'cash');
        expect(data['status'], 'pending');
        expect(data['createdAt'], isA<Timestamp>());
        expect(data['isExpired'], false);
      });

      test('toFirestore handles defaults', () {
        final model = CounterOfferModel.fromEntity(testEntity);
        final data = model.toFirestore();

        expect(data['isExpired'], false);
        expect(data['proposedCash'], isNull);
        expect(data['respondedAt'], isNull);
      });
    });

    group('roundtrip conversions', () {
      test('entity -> model -> entity preserves cash offer data', () {
        final originalEntity = testEntity.copyWith(
          proposedCash: 125.0,
          proposedPaymentDirection: 'user1ToUser2',
          message: 'I can add 125 TL to balance',
        );

        final model = CounterOfferModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.proposedCash, 125.0);
        expect(convertedEntity.proposedPaymentDirection, 'user1ToUser2');
        expect(convertedEntity.message, 'I can add 125 TL to balance');
      });

      test('entity -> model -> entity preserves location offer data', () {
        final originalEntity = testEntity.copyWith(
          type: CounterOfferType.location,
          proposedMeetupLocation: 'Zorlu Center',
          message: 'This location is closer to me',
        );

        final model = CounterOfferModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.type, CounterOfferType.location);
        expect(convertedEntity.proposedMeetupLocation, 'Zorlu Center');
      });

      test('entity -> model -> Firestore map preserves data', () {
        final originalEntity = testEntity.copyWith(
          type: CounterOfferType.full,
          proposedCash: 80.0,
          proposedMeetupLocation: 'Istinye Park',
          proposedMeetupTime: testDate.add(const Duration(days: 2)),
          message: 'Full proposal',
        );

        final model = CounterOfferModel.fromEntity(originalEntity);
        final firestoreData = model.toFirestore();
        final convertedEntity = model.toEntity();

        expect(convertedEntity.type, CounterOfferType.full);
        expect(convertedEntity.proposedCash, 80.0);
        expect(convertedEntity.proposedMeetupLocation, 'Istinye Park');
        expect(convertedEntity.message, 'Full proposal');
        expect(firestoreData['type'], 'full');
        expect(firestoreData['proposedCash'], 80.0);
        expect(firestoreData['proposedMeetupLocation'], 'Istinye Park');
      });
    });

    group('edge cases', () {
      test('handles zero cash proposal', () {
        final entity = testEntity.copyWith(proposedCash: 0.0);
        final model = CounterOfferModel.fromEntity(entity);

        expect(model.proposedCash, 0.0);
      });

      test('handles all CounterOfferType values in roundtrip', () {
        for (final type in CounterOfferType.values) {
          final entity = testEntity.copyWith(type: type);
          final model = CounterOfferModel.fromEntity(entity);
          final convertedEntity = model.toEntity();

          expect(convertedEntity.type, type);
        }
      });

      test('handles all CounterOfferStatus values in roundtrip', () {
        for (final status in CounterOfferStatus.values) {
          final entity = testEntity.copyWith(status: status);
          final model = CounterOfferModel.fromEntity(entity);
          final convertedEntity = model.toEntity();

          expect(convertedEntity.status, status);
        }
      });

      test('handles expired offer', () {
        final entity = testEntity.copyWith(
          isExpired: true,
          expiresAt: testDate.subtract(const Duration(hours: 1)),
        );

        final model = CounterOfferModel.fromEntity(entity);
        expect(model.isExpired, true);
      });

      test('handles accepted offer with response', () {
        final entity = testEntity.copyWith(
          status: CounterOfferStatus.accepted,
          respondedAt: testDate.add(const Duration(minutes: 30)),
          responseMessage: 'Great, let\'s do it!',
        );

        final model = CounterOfferModel.fromEntity(entity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, CounterOfferStatus.accepted);
        expect(convertedEntity.responseMessage, 'Great, let\'s do it!');
      });

      test('handles rejected offer with response', () {
        final entity = testEntity.copyWith(
          status: CounterOfferStatus.rejected,
          respondedAt: testDate.add(const Duration(hours: 1)),
          responseMessage: 'Sorry, cannot accept this',
        );

        final model = CounterOfferModel.fromEntity(entity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, CounterOfferStatus.rejected);
        expect(convertedEntity.responseMessage, 'Sorry, cannot accept this');
      });
    });

    group('type-specific validations', () {
      test('terms type only has message', () {
        final entity = testEntity.copyWith(
          type: CounterOfferType.terms,
          message: 'Need to discuss delivery terms',
        );

        final model = CounterOfferModel.fromEntity(entity);

        expect(model.type, 'terms');
        expect(model.message, isNotNull);
        expect(model.proposedCash, isNull);
        expect(model.proposedMeetupLocation, isNull);
      });

      test('time type has proposed time', () {
        final entity = testEntity.copyWith(
          type: CounterOfferType.time,
          proposedMeetupTime: testDate.add(const Duration(days: 3)),
        );

        final model = CounterOfferModel.fromEntity(entity);

        expect(model.type, 'time');
        expect(model.proposedMeetupTime, isNotNull);
      });
    });
  });
}
