import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barter_qween/data/models/negotiation_model.dart';
import 'package:barter_qween/domain/entities/negotiation_entity.dart';

void main() {
  group('NegotiationModel', () {
    late NegotiationEntity testEntity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 18, 12, 0, 0);
      testEntity = NegotiationEntity(
        id: 'negotiation123',
        tradeOfferId: 'offer123',
        initiatorId: 'user1',
        responderId: 'user2',
        status: NegotiationStatus.active,
        currentOfferer: 'user1',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('fromEntity', () {
      test('converts minimal entity correctly', () {
        final model = NegotiationModel.fromEntity(testEntity);

        expect(model.id, 'negotiation123');
        expect(model.tradeOfferId, 'offer123');
        expect(model.status, 'active');
        expect(model.currentOfferer, 'user1');
        expect(model.roundCount, 0);
        expect(model.rounds, isEmpty);
        expect(model.totalMessages, 0);
        expect(model.isExpired, false);
      });

      test('converts entity with rounds', () {
        final entityWithRounds = testEntity.copyWith(
          roundCount: 2,
          rounds: [
            NegotiationRound(
              roundNumber: 1,
              offererId: 'user1',
              cashOffer: 50.0,
              paymentDirection: 'user1ToUser2',
              notes: 'First offer',
              createdAt: testDate,
            ),
            NegotiationRound(
              roundNumber: 2,
              offererId: 'user2',
              cashOffer: 30.0,
              paymentDirection: 'user2ToUser1',
              notes: 'Counter offer',
              createdAt: testDate.add(const Duration(hours: 1)),
            ),
          ],
        );

        final model = NegotiationModel.fromEntity(entityWithRounds);

        expect(model.roundCount, 2);
        expect(model.rounds.length, 2);
        expect(model.rounds[0]['roundNumber'], 1);
        expect(model.rounds[0]['cashOffer'], 50.0);
        expect(model.rounds[1]['roundNumber'], 2);
        expect(model.rounds[1]['cashOffer'], 30.0);
      });

      test('converts full entity with all fields', () {
        final fullEntity = testEntity.copyWith(
          roundCount: 1,
          currentCashOffer: 75.0,
          currentPaymentDirection: 'user1ToUser2',
          currentMeetupLocation: 'Starbucks Central',
          currentMeetupTime: testDate.add(const Duration(days: 1)),
          currentNotes: 'Let\'s meet here',
          totalMessages: 5,
          expiresAt: testDate.add(const Duration(days: 7)),
          lastActivityAt: testDate.add(const Duration(hours: 2)),
        );

        final model = NegotiationModel.fromEntity(fullEntity);

        expect(model.currentCashOffer, 75.0);
        expect(model.currentPaymentDirection, 'user1ToUser2');
        expect(model.currentMeetupLocation, 'Starbucks Central');
        expect(model.currentNotes, 'Let\'s meet here');
        expect(model.totalMessages, 5);
      });

      test('handles all NegotiationStatus enum values', () {
        for (final status in NegotiationStatus.values) {
          final entity = testEntity.copyWith(status: status);
          final model = NegotiationModel.fromEntity(entity);

          expect(model.status, status.name);
        }
      });
    });

    group('toEntity', () {
      test('converts model back to entity correctly', () {
        final model = NegotiationModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, testEntity.id);
        expect(entity.tradeOfferId, testEntity.tradeOfferId);
        expect(entity.status, NegotiationStatus.active);
        expect(entity.currentOfferer, testEntity.currentOfferer);
      });

      test('converts rounds correctly', () {
        final entityWithRounds = testEntity.copyWith(
          rounds: [
            NegotiationRound(
              roundNumber: 1,
              offererId: 'user1',
              cashOffer: 100.0,
              meetupLocation: 'Park',
              meetupTime: testDate.add(const Duration(days: 1)),
              notes: 'Round 1 notes',
              createdAt: testDate,
            ),
          ],
        );

        final model = NegotiationModel.fromEntity(entityWithRounds);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.rounds.length, 1);
        expect(convertedEntity.rounds[0].roundNumber, 1);
        expect(convertedEntity.rounds[0].cashOffer, 100.0);
        expect(convertedEntity.rounds[0].meetupLocation, 'Park');
        expect(convertedEntity.rounds[0].notes, 'Round 1 notes');
      });

      test('preserves rejection data', () {
        final entityWithRejection = testEntity.copyWith(
          status: NegotiationStatus.rejected,
          rejectedAt: testDate.add(const Duration(hours: 3)),
          rejectionReason: 'Price too high',
          rejectedBy: 'user2',
        );

        final model = NegotiationModel.fromEntity(entityWithRejection);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, NegotiationStatus.rejected);
        expect(convertedEntity.rejectionReason, 'Price too high');
        expect(convertedEntity.rejectedBy, 'user2');
      });
    });

    group('toFirestore', () {
      test('creates valid Firestore map', () {
        final model = NegotiationModel.fromEntity(testEntity);
        final firestoreData = model.toFirestore();

        expect(firestoreData['tradeOfferId'], 'offer123');
        expect(firestoreData['initiatorId'], 'user1');
        expect(firestoreData['status'], 'active');
        expect(firestoreData['roundCount'], 0);
        expect(firestoreData['rounds'], isA<List>());
        expect(firestoreData['createdAt'], isA<Timestamp>());
      });

      test('converts rounds with Timestamps correctly', () {
        final entityWithRounds = testEntity.copyWith(
          rounds: [
            NegotiationRound(
              roundNumber: 1,
              offererId: 'user1',
              cashOffer: 50.0,
              meetupTime: testDate.add(const Duration(days: 1)),
              createdAt: testDate,
            ),
          ],
        );

        final model = NegotiationModel.fromEntity(entityWithRounds);
        final firestoreData = model.toFirestore();

        expect(firestoreData['rounds'], isA<List>());
        expect((firestoreData['rounds'] as List).length, 1);
        expect((firestoreData['rounds'] as List)[0]['meetupTime'], isA<Timestamp>());
        expect((firestoreData['rounds'] as List)[0]['createdAt'], isA<Timestamp>());
      });

      test('handles optional DateTime fields', () {
        final model = NegotiationModel.fromEntity(testEntity.copyWith(
          expiresAt: testDate.add(const Duration(days: 7)),
          lastActivityAt: testDate.add(const Duration(hours: 1)),
        ));
        final firestoreData = model.toFirestore();

        expect(firestoreData['expiresAt'], isA<Timestamp>());
        expect(firestoreData['lastActivityAt'], isA<Timestamp>());
      });
    });

    group('Firestore serialization', () {
      test('toFirestore creates valid map', () {
        final model = NegotiationModel.fromEntity(testEntity);
        final data = model.toFirestore();

        expect(data['tradeOfferId'], 'offer123');
        expect(data['status'], 'active');
        expect(data['roundCount'], 0);
        expect(data['rounds'], isA<List>());
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('toFirestore handles rounds correctly', () {
        final entityWithRounds = testEntity.copyWith(
          rounds: [
            NegotiationRound(
              roundNumber: 1,
              offererId: 'user1',
              cashOffer: 50.0,
              notes: 'First round',
              createdAt: testDate,
            ),
          ],
        );
        final model = NegotiationModel.fromEntity(entityWithRounds);
        final data = model.toFirestore();

        expect(data['rounds'], isA<List>());
        expect((data['rounds'] as List).length, 1);
        expect((data['rounds'] as List)[0]['cashOffer'], 50.0);
      });
    });

    group('roundtrip conversions', () {
      test('entity -> model -> entity preserves simple data', () {
        final originalEntity = testEntity.copyWith(
          status: NegotiationStatus.agreed,
          currentCashOffer: 100.0,
          totalMessages: 10,
          agreedAt: testDate.add(const Duration(hours: 5)),
        );

        final model = NegotiationModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, NegotiationStatus.agreed);
        expect(convertedEntity.currentCashOffer, 100.0);
        expect(convertedEntity.totalMessages, 10);
      });

      test('entity -> model -> entity preserves rounds', () {
        final originalEntity = testEntity.copyWith(
          rounds: [
            NegotiationRound(
              roundNumber: 1,
              offererId: 'user1',
              cashOffer: 75.0,
              notes: 'Initial offer',
              createdAt: testDate,
            ),
            NegotiationRound(
              roundNumber: 2,
              offererId: 'user2',
              cashOffer: 60.0,
              notes: 'Counter offer',
              createdAt: testDate.add(const Duration(hours: 1)),
            ),
          ],
        );

        final model = NegotiationModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.rounds.length, 2);
        expect(convertedEntity.rounds[0].cashOffer, 75.0);
        expect(convertedEntity.rounds[1].cashOffer, 60.0);
      });

      test('entity -> model -> Firestore map preserves data', () {
        final originalEntity = testEntity.copyWith(
          status: NegotiationStatus.active,
          currentCashOffer: 85.0,
          totalMessages: 3,
        );

        final model = NegotiationModel.fromEntity(originalEntity);
        final firestoreData = model.toFirestore();
        final convertedEntity = model.toEntity();

        expect(convertedEntity.status, NegotiationStatus.active);
        expect(convertedEntity.currentCashOffer, 85.0);
        expect(convertedEntity.totalMessages, 3);
        expect(firestoreData['status'], 'active');
        expect(firestoreData['currentCashOffer'], 85.0);
        expect(firestoreData['totalMessages'], 3);
      });
    });

    group('edge cases', () {
      test('handles empty rounds list', () {
        final entity = testEntity.copyWith(rounds: []);
        final model = NegotiationModel.fromEntity(entity);

        expect(model.rounds, isEmpty);
      });

      test('handles all NegotiationStatus values in roundtrip', () {
        for (final status in NegotiationStatus.values) {
          final entity = testEntity.copyWith(status: status);
          final model = NegotiationModel.fromEntity(entity);
          final convertedEntity = model.toEntity();

          expect(convertedEntity.status, status);
        }
      });

      test('handles expired negotiation', () {
        final entity = testEntity.copyWith(
          isExpired: true,
          expiresAt: testDate.subtract(const Duration(days: 1)),
        );

        final model = NegotiationModel.fromEntity(entity);
        expect(model.isExpired, true);
      });

      test('handles multiple rounds with all fields', () {
        final entity = testEntity.copyWith(
          rounds: List.generate(
            5,
            (i) => NegotiationRound(
              roundNumber: i + 1,
              offererId: i.isEven ? 'user1' : 'user2',
              cashOffer: 100.0 - (i * 10),
              paymentDirection: 'user1ToUser2',
              meetupLocation: 'Location ${i + 1}',
              meetupTime: testDate.add(Duration(days: i + 1)),
              notes: 'Round ${i + 1} notes',
              createdAt: testDate.add(Duration(hours: i)),
            ),
          ),
        );

        final model = NegotiationModel.fromEntity(entity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.rounds.length, 5);
        expect(convertedEntity.rounds[0].cashOffer, 100.0);
        expect(convertedEntity.rounds[4].cashOffer, 60.0);
      });
    });
  });
}
