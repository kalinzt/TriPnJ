import 'dart:math' as math;
import '../../../../core/utils/logger.dart';

/// 사용자 선호도 학습 알고리즘
///
/// Exponential Moving Average를 사용하여 사용자의 피드백을 학습하고
/// 추천 가중치를 동적으로 조정합니다.
class PreferenceLearning {
  /// 학습률 (0.0 ~ 1.0)
  /// 0.1 = 최근 피드백에 10% 가중치, 기존 데이터에 90% 가중치
  static const double learningRate = 0.1;

  /// 신뢰도 점수 계산을 위한 최소 데이터 포인트
  static const int minDataPointsForConfidence = 10;

  /// 거부 패턴 분석을 위한 최소 거부 횟수
  static const int minRejectionsForPattern = 3;

  /// 피드백을 기반으로 카테고리 가중치 업데이트
  ///
  /// Exponential Moving Average (EMA) 공식:
  /// newWeight = oldWeight * (1 - α) + feedback * α
  /// 여기서 α는 학습률 (learningRate)
  ///
  /// [categoryWeights]: 현재 카테고리 가중치 맵 (카테고리 -> 가중치 0.0~1.0)
  /// [category]: 피드백이 발생한 카테고리
  /// [isPositive]: true=긍정 피드백, false=부정 피드백
  ///
  /// Returns: 업데이트된 카테고리 가중치 맵
  static Map<String, double> updateWeightsFromFeedback({
    required Map<String, double> categoryWeights,
    required String category,
    required bool isPositive,
  }) {
    // 피드백 값 (긍정: 1.0, 부정: 0.0)
    final feedbackValue = isPositive ? 1.0 : 0.0;

    // 현재 가중치 (없으면 0.5로 초기화)
    final currentWeight = categoryWeights[category] ?? 0.5;

    // EMA 공식 적용
    final newWeight = currentWeight * (1 - learningRate) + feedbackValue * learningRate;

    // 가중치 범위 제한 (0.0 ~ 1.0)
    final clampedWeight = newWeight.clamp(0.0, 1.0);

    Logger.info(
      '카테고리 \'$category\' 가중치 업데이트: '
      '${currentWeight.toStringAsFixed(3)} → ${clampedWeight.toStringAsFixed(3)} '
      '(피드백: ${isPositive ? "긍정" : "부정"})',
      'PreferenceLearning',
    );

    // 업데이트된 맵 반환
    return {
      ...categoryWeights,
      category: clampedWeight,
    };
  }

  /// 여러 카테고리에 대한 일괄 가중치 업데이트
  ///
  /// [categoryWeights]: 현재 카테고리 가중치 맵
  /// [feedbacks]: 카테고리별 피드백 맵 (카테고리 -> isPositive)
  ///
  /// Returns: 업데이트된 카테고리 가중치 맵
  static Map<String, double> batchUpdateWeights({
    required Map<String, double> categoryWeights,
    required Map<String, bool> feedbacks,
  }) {
    var updatedWeights = Map<String, double>.from(categoryWeights);

    for (final entry in feedbacks.entries) {
      updatedWeights = updateWeightsFromFeedback(
        categoryWeights: updatedWeights,
        category: entry.key,
        isPositive: entry.value,
      );
    }

    return updatedWeights;
  }

  /// 거부 패턴 분석
  ///
  /// 자주 거부되는 카테고리를 식별하여 추천에서 제외하거나 우선순위를 낮춥니다.
  ///
  /// [rejectionHistory]: 카테고리별 거부 횟수 (카테고리 -> 거부 횟수)
  /// [totalFeedbackCount]: 전체 피드백 횟수
  ///
  /// Returns: 자주 거부되는 카테고리 목록 (거부율 기준 내림차순)
  static List<RejectionPattern> analyzeRejectionPatterns({
    required Map<String, int> rejectionHistory,
    required int totalFeedbackCount,
  }) {
    if (totalFeedbackCount == 0) {
      return [];
    }

    final patterns = <RejectionPattern>[];

    for (final entry in rejectionHistory.entries) {
      final category = entry.key;
      final rejectionCount = entry.value;

      // 최소 거부 횟수를 만족하는 경우만 패턴으로 간주
      if (rejectionCount >= minRejectionsForPattern) {
        final rejectionRate = rejectionCount / totalFeedbackCount;

        patterns.add(RejectionPattern(
          category: category,
          rejectionCount: rejectionCount,
          rejectionRate: rejectionRate,
        ));
      }
    }

    // 거부율 기준 내림차순 정렬
    patterns.sort((a, b) => b.rejectionRate.compareTo(a.rejectionRate));

    Logger.info(
      '거부 패턴 분석 완료: ${patterns.length}개 패턴 발견',
      'PreferenceLearning',
    );

    for (final pattern in patterns) {
      Logger.info(
        '  - ${pattern.category}: ${pattern.rejectionCount}회 거부 '
        '(거부율 ${(pattern.rejectionRate * 100).toStringAsFixed(1)}%)',
        'PreferenceLearning',
      );
    }

    return patterns;
  }

  /// 신뢰도 점수 계산
  ///
  /// 사용자 데이터의 양을 기반으로 추천의 신뢰도를 계산합니다.
  /// 데이터가 많을수록 신뢰도가 높습니다.
  ///
  /// [totalFeedbackCount]: 전체 피드백 횟수
  ///
  /// Returns: 신뢰도 점수 (0.0 ~ 1.0)
  ///   - 0.0 ~ 0.3: 낮은 신뢰도 (데이터 부족)
  ///   - 0.3 ~ 0.7: 중간 신뢰도
  ///   - 0.7 ~ 1.0: 높은 신뢰도
  static double calculateConfidenceScore({
    required int totalFeedbackCount,
  }) {
    if (totalFeedbackCount == 0) {
      return 0.0;
    }

    // Sigmoid 함수를 사용한 부드러운 증가 곡선
    // f(x) = 1 / (1 + e^(-k(x - x0)))
    // k = 0.3 (증가 속도), x0 = minDataPointsForConfidence (중심점)
    const k = 0.3;
    final x = totalFeedbackCount.toDouble();
    final x0 = minDataPointsForConfidence.toDouble();

    final confidence = 1.0 / (1.0 + math.exp(-k * (x - x0)));

    Logger.info(
      '신뢰도 점수 계산: ${confidence.toStringAsFixed(3)} '
      '(피드백 수: $totalFeedbackCount)',
      'PreferenceLearning',
    );

    return confidence;
  }

  /// 카테고리별 선호도 점수 계산
  ///
  /// 가중치와 신뢰도를 결합하여 최종 선호도 점수를 계산합니다.
  ///
  /// [categoryWeights]: 카테고리 가중치 맵
  /// [confidenceScore]: 신뢰도 점수 (0.0 ~ 1.0)
  ///
  /// Returns: 카테고리별 선호도 점수 맵
  static Map<String, double> calculatePreferenceScores({
    required Map<String, double> categoryWeights,
    required double confidenceScore,
  }) {
    final preferenceScores = <String, double>{};

    for (final entry in categoryWeights.entries) {
      final category = entry.key;
      final weight = entry.value;

      // 선호도 점수 = 가중치 * 신뢰도 + 기본값 * (1 - 신뢰도)
      // 신뢰도가 낮을 때는 기본값(0.5)에 가까워짐
      final preferenceScore = weight * confidenceScore + 0.5 * (1 - confidenceScore);

      preferenceScores[category] = preferenceScore;
    }

    return preferenceScores;
  }

  /// 학습률 동적 조정
  ///
  /// 사용자 데이터가 많아질수록 학습률을 낮춰 안정성을 높입니다.
  ///
  /// [totalFeedbackCount]: 전체 피드백 횟수
  ///
  /// Returns: 조정된 학습률 (0.01 ~ 0.1)
  static double getAdaptiveLearningRate({
    required int totalFeedbackCount,
  }) {
    if (totalFeedbackCount < 10) {
      return 0.1; // 초기: 빠른 학습
    } else if (totalFeedbackCount < 50) {
      return 0.05; // 중기: 중간 학습
    } else {
      return 0.01; // 후기: 안정적 학습
    }
  }
}

/// 거부 패턴 정보
class RejectionPattern {
  final String category;
  final int rejectionCount;
  final double rejectionRate;

  const RejectionPattern({
    required this.category,
    required this.rejectionCount,
    required this.rejectionRate,
  });

  @override
  String toString() {
    return 'RejectionPattern('
        'category: $category, '
        'rejectionCount: $rejectionCount, '
        'rejectionRate: ${(rejectionRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}
