import 'package:flutter_test/flutter_test.dart';
import 'package:barter_qween/domain/entities/trade_entity.dart';

void main() {
  group('TradeEntity', () {
    late TradeEntity trade;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 18);
      trade = TradeEntity(
        id: 'trade123',
        offerId: 'offer456',
        initiatorId: 'user1',
        initiatorItemId: 'item1',
        receiverId: 'user2',
        receiverItemId: 'item2',
        status: TradeStatus.inProgress,
        agreedAt: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    test('should create entity with required fields', () {
      expect(trade.id, 'trade123');
      expect(trade.offerId, 'offer456');
      expect(trade.initiatorId, 'user1');
      expect(trade.receiverId, 'user2');
      expect(trade.status, TradeStatus.inProgress);
    });

    test('should have default false values for confirmation flags', () {
      expect(trade.initiatorConfirmed, false);
      expect(trade.receiverConfirmed, false);
      expect(trade.hasIssues, false);
    });

    group('isComplete', () {
      test('should return false when neither party confirmed', () {
        expect(trade.isComplete, false);
      });

      test('should return false when only initiator confirmed', () {
        final confirmed = trade.copyWith(initiatorConfirmed: true);
        expect(confirmed.isComplete, false);
      });

      test('should return false when only receiver confirmed', () {
        final confirmed = trade.copyWith(receiverConfirmed: true);
        expect(confirmed.isComplete, false);
      });

      test('should return true when both parties confirmed', () {
        final confirmed = trade.copyWith(
          initiatorConfirmed: true,
          receiverConfirmed: true,
        );
        expect(confirmed.isComplete, true);
      });
    });

    group('canConfirm', () {
      test('should return false if trade not in progress', () {
        final pending = trade.copyWith(status: TradeStatus.pending);
        expect(pending.canConfirm('user1'), false);
        expect(pending.canConfirm('user2'), false);
      });

      test('should return true for initiator if not yet confirmed', () {
        expect(trade.canConfirm('user1'), true);
      });

      test('should return false for initiator if already confirmed', () {
        final confirmed = trade.copyWith(initiatorConfirmed: true);
        expect(confirmed.canConfirm('user1'), false);
      });

      test('should return true for receiver if not yet confirmed', () {
        expect(trade.canConfirm('user2'), true);
      });

      test('should return false for receiver if already confirmed', () {
        final confirmed = trade.copyWith(receiverConfirmed: true);
        expect(confirmed.canConfirm('user2'), false);
      });

      test('should return false for non-participant', () {
        expect(trade.canConfirm('user3'), false);
      });
    });

    group('canCancel', () {
      test('should return true for initiator if not completed', () {
        expect(trade.canCancel('user1'), true);
      });

      test('should return true for receiver if not completed', () {
        expect(trade.canCancel('user2'), true);
      });

      test('should return false if trade completed', () {
        final completed = trade.copyWith(status: TradeStatus.completed);
        expect(completed.canCancel('user1'), false);
        expect(completed.canCancel('user2'), false);
      });

      test('should return false if trade cancelled', () {
        final cancelled = trade.copyWith(status: TradeStatus.cancelled);
        expect(cancelled.canCancel('user1'), false);
        expect(cancelled.canCancel('user2'), false);
      });

      test('should return false for non-participant', () {
        expect(trade.canCancel('user3'), false);
      });
    });

    group('canRate', () {
      final completed = TradeEntity(
        id: 'trade123',
        offerId: 'offer456',
        initiatorId: 'user1',
        initiatorItemId: 'item1',
        receiverId: 'user2',
        receiverItemId: 'item2',
        status: TradeStatus.completed,
        agreedAt: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );

      test('should return false if trade not completed', () {
        expect(trade.canRate('user1'), false);
        expect(trade.canRate('user2'), false);
      });

      test('should return true for initiator if not yet rated', () {
        expect(completed.canRate('user1'), true);
      });

      test('should return false for initiator if already rated', () {
        final rated = completed.copyWith(initiatorRating: 5.0);
        expect(rated.canRate('user1'), false);
      });

      test('should return true for receiver if not yet rated', () {
        expect(completed.canRate('user2'), true);
      });

      test('should return false for receiver if already rated', () {
        final rated = completed.copyWith(receiverRating: 4.5);
        expect(rated.canRate('user2'), false);
      });
    });

    group('getOtherPartyId', () {
      test('should return receiver ID when given initiator ID', () {
        expect(trade.getOtherPartyId('user1'), 'user2');
      });

      test('should return initiator ID when given receiver ID', () {
        expect(trade.getOtherPartyId('user2'), 'user1');
      });

      test('should throw error for non-participant', () {
        expect(
          () => trade.getOtherPartyId('user3'),
          throwsArgumentError,
        );
      });
    });

    group('copyWith', () {
      test('should create copy with updated status', () {
        final updated = trade.copyWith(status: TradeStatus.completed);
        expect(updated.status, TradeStatus.completed);
        expect(updated.id, trade.id);
        expect(updated.initiatorId, trade.initiatorId);
      });

      test('should create copy with updated confirmations', () {
        final updated = trade.copyWith(
          initiatorConfirmed: true,
          receiverConfirmed: true,
        );
        expect(updated.initiatorConfirmed, true);
        expect(updated.receiverConfirmed, true);
      });

      test('should create copy with meetup details', () {
        final updated = trade.copyWith(
          meetupLocation: 'Kadıköy',
          meetupLatitude: 40.9900,
          meetupLongitude: 29.0253,
        );
        expect(updated.meetupLocation, 'Kadıköy');
        expect(updated.meetupLatitude, 40.9900);
        expect(updated.meetupLongitude, 29.0253);
      });
    });

    group('TradeStatus extension', () {
      test('should have correct display names', () {
        expect(TradeStatus.pending.displayName, 'Bekliyor');
        expect(TradeStatus.scheduled.displayName, 'Planlandı');
        expect(TradeStatus.inProgress.displayName, 'Devam Ediyor');
        expect(TradeStatus.completed.displayName, 'Tamamlandı');
        expect(TradeStatus.cancelled.displayName, 'İptal Edildi');
        expect(TradeStatus.disputed.displayName, 'Anlaşmazlık');
      });

      test('should have correct descriptions', () {
        expect(
          TradeStatus.pending.description,
          'Takas kabul edildi, detaylar bekleniyor',
        );
        expect(
          TradeStatus.completed.description,
          'Takas başarıyla tamamlandı',
        );
      });

      test('should correctly identify active status', () {
        expect(TradeStatus.inProgress.isActive, true);
        expect(TradeStatus.scheduled.isActive, true);
        expect(TradeStatus.pending.isActive, false);
        expect(TradeStatus.completed.isActive, false);
      });

      test('should correctly identify final status', () {
        expect(TradeStatus.completed.isFinal, true);
        expect(TradeStatus.cancelled.isFinal, true);
        expect(TradeStatus.inProgress.isFinal, false);
        expect(TradeStatus.pending.isFinal, false);
      });
    });

    group('Equatable', () {
      test('should be equal with same values', () {
        final trade2 = TradeEntity(
          id: 'trade123',
          offerId: 'offer456',
          initiatorId: 'user1',
          initiatorItemId: 'item1',
          receiverId: 'user2',
          receiverItemId: 'item2',
          status: TradeStatus.inProgress,
          agreedAt: testDate,
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(trade, equals(trade2));
      });

      test('should not be equal with different status', () {
        final trade2 = trade.copyWith(status: TradeStatus.completed);
        expect(trade, isNot(equals(trade2)));
      });
    });
  });
}
