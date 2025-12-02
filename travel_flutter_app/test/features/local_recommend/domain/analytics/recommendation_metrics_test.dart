import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_flutter_app/features/local_recommend/domain/analytics/recommendation_metrics.dart';

void main() {
  group('RecommendationMetrics', () {
    late RecommendationMetrics metrics;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      metrics = RecommendationMetrics(prefs);
    });

    tearDown(() async {
      await metrics.clearAllData();
    });

    group('이벤트 로깅', () {
      test('노출 이벤트 로깅 후 CTR 계산 가능', () async {
        // Act
        await metrics.logImpression(
          placeId: 'place_1',
          placeName: '테스트 장소',
          categories: ['restaurant'],
          score: 0.8,
        );

        // Assert - CTR을 통해 이벤트가 저장되었는지 확인
        final result = await metrics.calculateCTR();
        expect(result.context['impressions'], equals(1));
      });

      test('클릭 이벤트 로깅 후 CTR 계산 가능', () async {
        // Arrange
        await metrics.logImpression(
          placeId: 'place_1',
          placeName: '테스트 장소',
          categories: ['restaurant'],
          score: 0.8,
        );

        // Act
        await metrics.logClick(
          placeId: 'place_1',
          placeName: '테스트 장소',
          categories: ['restaurant'],
          score: 0.8,
        );

        // Assert
        final result = await metrics.calculateCTR();
        expect(result.context['clicks'], equals(1));
      });

      test('피드백 이벤트 로깅 후 만족도 계산 가능', () async {
        // Act
        await metrics.logFeedback(
          placeId: 'place_1',
          placeName: '테스트 장소',
          categories: ['restaurant'],
          isPositive: true,
          score: 0.8,
        );

        // Assert
        final result = await metrics.calculateUserSatisfaction();
        expect(result.context['positiveFeedbacks'], equals(1));
      });
    });

    group('CTR 계산', () {
      test('정상적인 CTR 계산', () async {
        // Arrange
        await metrics.logImpression(
          placeId: 'place_1',
          placeName: '장소 1',
          categories: ['restaurant'],
        );
        await metrics.logImpression(
          placeId: 'place_2',
          placeName: '장소 2',
          categories: ['cafe'],
        );
        await metrics.logClick(
          placeId: 'place_1',
          placeName: '장소 1',
          categories: ['restaurant'],
        );

        // Act
        final result = await metrics.calculateCTR();

        // Assert
        expect(result.value, equals(0.5)); // 1 click / 2 impressions
        expect(result.displayValue, equals('50.00%'));
      });

      test('클릭이 없을 때 CTR은 0', () async {
        // Arrange
        await metrics.logImpression(
          placeId: 'place_1',
          placeName: '장소 1',
          categories: ['restaurant'],
        );

        // Act
        final result = await metrics.calculateCTR();

        // Assert
        expect(result.value, equals(0.0));
      });
    });

    group('전환율 계산', () {
      test('정상적인 전환율 계산', () async {
        // Arrange
        for (var i = 0; i < 10; i++) {
          await metrics.logImpression(
            placeId: 'place_$i',
            placeName: '장소 $i',
            categories: ['restaurant'],
          );
        }
        for (var i = 0; i < 3; i++) {
          await metrics.logConversion(
            placeId: 'place_$i',
            placeName: '장소 $i',
            categories: ['restaurant'],
          );
        }

        // Act
        final result = await metrics.calculateConversionRate();

        // Assert
        expect(result.value, equals(0.3)); // 3 / 10
      });
    });

    group('사용자 만족도 계산', () {
      test('정상적인 만족도 계산', () async {
        // Arrange
        await metrics.logFeedback(
          placeId: 'place_1',
          placeName: '장소 1',
          categories: ['restaurant'],
          isPositive: true,
        );
        await metrics.logFeedback(
          placeId: 'place_2',
          placeName: '장소 2',
          categories: ['cafe'],
          isPositive: true,
        );
        await metrics.logFeedback(
          placeId: 'place_3',
          placeName: '장소 3',
          categories: ['park'],
          isPositive: false,
        );

        // Act
        final result = await metrics.calculateUserSatisfaction();

        // Assert
        expect(result.value, closeTo(0.667, 0.01)); // 2 positive / 3 total
      });

      test('피드백이 없을 때', () async {
        // Act
        final result = await metrics.calculateUserSatisfaction();

        // Assert
        expect(result.value, equals(0.0));
        expect(result.displayValue, equals('N/A'));
      });
    });

    group('카테고리별 성능 분석', () {
      test('카테고리별 통계 계산', () async {
        // Arrange - restaurant 카테고리
        await metrics.logImpression(
          placeId: 'r1',
          placeName: '레스토랑 1',
          categories: ['restaurant'],
        );
        await metrics.logClick(
          placeId: 'r1',
          placeName: '레스토랑 1',
          categories: ['restaurant'],
        );
        await metrics.logConversion(
          placeId: 'r1',
          placeName: '레스토랑 1',
          categories: ['restaurant'],
        );

        // Arrange - cafe 카테고리
        await metrics.logImpression(
          placeId: 'c1',
          placeName: '카페 1',
          categories: ['cafe'],
        );
        await metrics.logImpression(
          placeId: 'c2',
          placeName: '카페 2',
          categories: ['cafe'],
        );

        // Act
        final performance = await metrics.analyzeCategoryPerformance();

        // Assert
        expect(performance.containsKey('restaurant'), isTrue);
        expect(performance.containsKey('cafe'), isTrue);

        final restaurantStats = performance['restaurant']!;
        expect(restaurantStats.impressions, equals(1));
        expect(restaurantStats.clicks, equals(1));
        expect(restaurantStats.conversions, equals(1));
        expect(restaurantStats.ctr, equals(1.0));
        expect(restaurantStats.conversionRate, equals(1.0));

        final cafeStats = performance['cafe']!;
        expect(cafeStats.impressions, equals(2));
        expect(cafeStats.clicks, equals(0));
      });
    });

    group('점수 상관관계 분석', () {
      test('높은 점수가 더 나은 성과를 보이는지 확인', () async {
        // Arrange - 높은 점수 장소
        for (var i = 0; i < 5; i++) {
          await metrics.logImpression(
            placeId: 'high_$i',
            placeName: '높은 점수 $i',
            categories: ['restaurant'],
            score: 0.9,
          );
          await metrics.logClick(
            placeId: 'high_$i',
            placeName: '높은 점수 $i',
            categories: ['restaurant'],
            score: 0.9,
          );
        }

        // Arrange - 낮은 점수 장소
        for (var i = 0; i < 10; i++) {
          await metrics.logImpression(
            placeId: 'low_$i',
            placeName: '낮은 점수 $i',
            categories: ['restaurant'],
            score: 0.3,
          );
          if (i < 2) {
            await metrics.logClick(
              placeId: 'low_$i',
              placeName: '낮은 점수 $i',
              categories: ['restaurant'],
              score: 0.3,
            );
          }
        }

        // Act
        final correlation = await metrics.analyzeScoreCorrelation();

        // Assert
        expect(correlation.scoreGroups, isNotEmpty);
        // 높은 점수 그룹의 CTR이 낮은 점수 그룹보다 높아야 함
        final highScoreGroup = correlation.scoreGroups[9]; // 0.9 score
        final lowScoreGroup = correlation.scoreGroups[3]; // 0.3 score

        if (highScoreGroup != null && lowScoreGroup != null) {
          expect(highScoreGroup.ctr, greaterThan(lowScoreGroup.ctr));
        }
      });
    });
  });
}
