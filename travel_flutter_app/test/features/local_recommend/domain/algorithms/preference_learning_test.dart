import 'package:flutter_test/flutter_test.dart';
import 'package:travel_flutter_app/features/local_recommend/domain/algorithms/preference_learning.dart';

void main() {
  group('PreferenceLearning', () {
    group('updateWeightsFromFeedback', () {
      test('긍정 피드백으로 가중치 증가', () {
        // Arrange
        final categoryWeights = {'restaurant': 0.5};

        // Act
        final updated = PreferenceLearning.updateWeightsFromFeedback(
          categoryWeights: categoryWeights,
          category: 'restaurant',
          isPositive: true,
        );

        // Assert
        expect(updated['restaurant'], greaterThan(0.5));
        expect(updated['restaurant'], lessThanOrEqualTo(1.0));
      });

      test('부정 피드백으로 가중치 감소', () {
        // Arrange
        final categoryWeights = {'restaurant': 0.5};

        // Act
        final updated = PreferenceLearning.updateWeightsFromFeedback(
          categoryWeights: categoryWeights,
          category: 'restaurant',
          isPositive: false,
        );

        // Assert
        expect(updated['restaurant'], lessThan(0.5));
        expect(updated['restaurant'], greaterThanOrEqualTo(0.0));
      });

      test('가중치가 0~1 범위로 제한됨', () {
        // Arrange - 이미 높은 가중치
        final highWeights = {'restaurant': 0.95};

        // Act - 연속 긍정 피드백
        var updated = highWeights;
        for (var i = 0; i < 10; i++) {
          updated = PreferenceLearning.updateWeightsFromFeedback(
            categoryWeights: updated,
            category: 'restaurant',
            isPositive: true,
          );
        }

        // Assert
        expect(updated['restaurant'], lessThanOrEqualTo(1.0));
        expect(updated['restaurant'], greaterThanOrEqualTo(0.0));
      });
    });

    group('analyzeRejectionPatterns', () {
      test('자주 거부된 카테고리 식별', () {
        // Arrange
        final rejectionHistory = {
          'restaurant': 10,
          'cafe': 2,
          'park': 5,
        };
        const totalFeedbackCount = 20;

        // Act
        final patterns = PreferenceLearning.analyzeRejectionPatterns(
          rejectionHistory: rejectionHistory,
          totalFeedbackCount: totalFeedbackCount,
        );

        // Assert
        expect(patterns, isNotEmpty);
        expect(patterns.first.category, equals('restaurant'));
        expect(patterns.first.rejectionRate, equals(0.5));
      });

      test('거부율 기준 내림차순 정렬', () {
        // Arrange
        final rejectionHistory = {
          'restaurant': 3,
          'cafe': 8,
          'park': 5,
        };
        const totalFeedbackCount = 20;

        // Act
        final patterns = PreferenceLearning.analyzeRejectionPatterns(
          rejectionHistory: rejectionHistory,
          totalFeedbackCount: totalFeedbackCount,
        );

        // Assert
        expect(patterns[0].category, equals('cafe'));
        expect(patterns[1].category, equals('park'));
        expect(patterns[2].category, equals('restaurant'));
      });
    });

    group('calculateConfidenceScore', () {
      test('피드백 수가 많을수록 신뢰도 증가', () {
        // Act
        final lowConfidence = PreferenceLearning.calculateConfidenceScore(
          totalFeedbackCount: 1,
        );
        final mediumConfidence = PreferenceLearning.calculateConfidenceScore(
          totalFeedbackCount: 10,
        );
        final highConfidence = PreferenceLearning.calculateConfidenceScore(
          totalFeedbackCount: 50,
        );

        // Assert
        expect(lowConfidence, lessThan(mediumConfidence));
        expect(mediumConfidence, lessThan(highConfidence));
      });

      test('신뢰도가 0~1 범위 내', () {
        // Act
        final confidence = PreferenceLearning.calculateConfidenceScore(
          totalFeedbackCount: 100,
        );

        // Assert
        expect(confidence, greaterThanOrEqualTo(0.0));
        expect(confidence, lessThanOrEqualTo(1.0));
      });
    });

    group('getAdaptiveLearningRate', () {
      test('초기에는 높은 학습률', () {
        // Act
        final learningRate = PreferenceLearning.getAdaptiveLearningRate(
          totalFeedbackCount: 5,
        );

        // Assert
        expect(learningRate, equals(0.1));
      });

      test('데이터가 쌓이면 학습률 감소', () {
        // Act
        final midRate = PreferenceLearning.getAdaptiveLearningRate(
          totalFeedbackCount: 25,
        );
        final lateRate = PreferenceLearning.getAdaptiveLearningRate(
          totalFeedbackCount: 100,
        );

        // Assert
        expect(midRate, equals(0.05));
        expect(lateRate, equals(0.01));
      });
    });
  });
}
