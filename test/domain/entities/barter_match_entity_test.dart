import 'package:flutter_test/flutter_test.dart';
import 'package:barter_qween/domain/entities/barter_match_entity.dart';

void main() {
  group('BarterMatchEntity', () {
    late BarterMatchEntity match;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 18);
      match = BarterMatchEntity(
        id: 'match123',
        sourceItemId: 'item1',
        targetItemId: 'item2',
        sourceUserId: 'user1',
        targetUserId: 'user2',
        matchScore: 85.0,
        compatibilityScore: 82.0,
        categoryScore: 100.0,
        priceScore: 90.0,
        locationScore: 80.0,
        trustScore: 50.0,
        conditionScore: 100.0,
        quality: MatchQuality.veryGood,
        matchReasons: ['Aynı kategoride', 'Benzer değerde'],
        conditionsCompatible: true,
        calculatedAt: testDate,
      );
    });

    test('should create entity with required fields', () {
      expect(match.id, 'match123');
      expect(match.matchScore, 85.0);
      expect(match.quality, MatchQuality.veryGood);
    });

    test('should have correct individual scores', () {
      expect(match.categoryScore, 100.0);
      expect(match.priceScore, 90.0);
      expect(match.locationScore, 80.0);
      expect(match.trustScore, 50.0);
      expect(match.conditionScore, 100.0);
    });

    group('isHighQuality', () {
      test('should return true when score >= 80', () {
        expect(match.isHighQuality, true);
      });

      test('should return false when score < 80', () {
        final lowMatch = match.copyWith(matchScore: 75.0);
        expect(lowMatch.isHighQuality, false);
      });

      test('should return true when score exactly 80', () {
        final exactMatch = match.copyWith(matchScore: 80.0);
        expect(exactMatch.isHighQuality, true);
      });
    });

    group('isWorthShowing', () {
      test('should return true when score >= 50 and not dismissed', () {
        expect(match.isWorthShowing, true);
      });

      test('should return false when dismissed', () {
        final dismissed = match.copyWith(isDismissed: true);
        expect(dismissed.isWorthShowing, false);
      });

      test('should return false when score < 50', () {
        final lowMatch = match.copyWith(matchScore: 45.0);
        expect(lowMatch.isWorthShowing, false);
      });
    });

    group('formattedDistance', () {
      test('should return unknown when distance is null', () {
        expect(match.formattedDistance, 'Konum bilinmiyor');
      });

      test('should return meters when distance < 1km', () {
        final nearby = match.copyWith(distanceKm: 0.5);
        expect(nearby.formattedDistance, '500 m uzaklıkta');
      });

      test('should return km when distance >= 1km', () {
        final far = match.copyWith(distanceKm: 5.7);
        expect(far.formattedDistance, '5.7 km uzaklıkta');
      });
    });

    group('qualityLabel', () {
      test('should return correct label for excellent', () {
        final excellent = match.copyWith(quality: MatchQuality.excellent);
        expect(excellent.qualityLabel, 'Mükemmel Eşleşme');
      });

      test('should return correct label for very good', () {
        expect(match.qualityLabel, 'Çok İyi Eşleşme');
      });

      test('should return correct label for good', () {
        final good = match.copyWith(quality: MatchQuality.good);
        expect(good.qualityLabel, 'İyi Eşleşme');
      });

      test('should return correct label for fair', () {
        final fair = match.copyWith(quality: MatchQuality.fair);
        expect(fair.qualityLabel, 'Kabul Edilebilir');
      });

      test('should return correct label for poor', () {
        final poor = match.copyWith(quality: MatchQuality.poor);
        expect(poor.qualityLabel, 'Zayıf Eşleşme');
      });
    });

    group('matchQualityFromScore', () {
      test('should return excellent for score >= 90', () {
        expect(matchQualityFromScore(95.0), MatchQuality.excellent);
        expect(matchQualityFromScore(90.0), MatchQuality.excellent);
      });

      test('should return veryGood for score 80-89', () {
        expect(matchQualityFromScore(85.0), MatchQuality.veryGood);
        expect(matchQualityFromScore(80.0), MatchQuality.veryGood);
      });

      test('should return good for score 70-79', () {
        expect(matchQualityFromScore(75.0), MatchQuality.good);
        expect(matchQualityFromScore(70.0), MatchQuality.good);
      });

      test('should return fair for score 50-69', () {
        expect(matchQualityFromScore(60.0), MatchQuality.fair);
        expect(matchQualityFromScore(50.0), MatchQuality.fair);
      });

      test('should return poor for score < 50', () {
        expect(matchQualityFromScore(45.0), MatchQuality.poor);
        expect(matchQualityFromScore(0.0), MatchQuality.poor);
      });
    });

    group('MatchQuality extension', () {
      test('should have correct emojis', () {
        expect(MatchQuality.excellent.emoji, '🎯');
        expect(MatchQuality.veryGood.emoji, '⭐');
        expect(MatchQuality.good.emoji, '👍');
        expect(MatchQuality.fair.emoji, '✓');
        expect(MatchQuality.poor.emoji, '⚠️');
      });

      test('should have correct colors', () {
        expect(MatchQuality.excellent.color, '#4CAF50');
        expect(MatchQuality.veryGood.color, '#8BC34A');
        expect(MatchQuality.good.color, '#FFC107');
        expect(MatchQuality.fair.color, '#FF9800');
        expect(MatchQuality.poor.color, '#F44336');
      });
    });

    group('copyWith', () {
      test('should create copy with updated seen status', () {
        final seen = match.copyWith(isSeen: true);
        expect(seen.isSeen, true);
        expect(seen.id, match.id);
      });

      test('should create copy with updated dismissed status', () {
        final dismissed = match.copyWith(isDismissed: true);
        expect(dismissed.isDismissed, true);
      });

      test('should create copy with updated view count', () {
        final viewed = match.copyWith(viewCount: 5);
        expect(viewed.viewCount, 5);
      });

      test('should create copy with offer info', () {
        final offered = match.copyWith(wasOffered: true, offerId: 'offer123');
        expect(offered.wasOffered, true);
        expect(offered.offerId, 'offer123');
      });
    });

    group('Equatable', () {
      test('should be equal with same values', () {
        final match2 = BarterMatchEntity(
          id: 'match123',
          sourceItemId: 'item1',
          targetItemId: 'item2',
          sourceUserId: 'user1',
          targetUserId: 'user2',
          matchScore: 85.0,
          compatibilityScore: 82.0,
          categoryScore: 100.0,
          priceScore: 90.0,
          locationScore: 80.0,
          trustScore: 50.0,
          conditionScore: 100.0,
          quality: MatchQuality.veryGood,
          matchReasons: ['Aynı kategoride', 'Benzer değerde'],
          conditionsCompatible: true,
          calculatedAt: testDate,
        );
        expect(match, equals(match2));
      });

      test('should not be equal with different score', () {
        final match2 = match.copyWith(matchScore: 75.0);
        expect(match, isNot(equals(match2)));
      });
    });
  });
}
