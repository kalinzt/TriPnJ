import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/utils/logger.dart';

/// 추천 품질 메트릭
///
/// 추천 시스템의 성능을 측정하고 개선점을 파악합니다.
class RecommendationMetrics {
  final SharedPreferences _prefs;

  /// 메트릭 데이터 저장 키
  static const String _metricsKey = 'recommendation_metrics';

  /// 최대 이벤트 저장 개수
  static const int _maxEvents = 500;

  RecommendationMetrics(this._prefs);

  // ============================================
  // 이벤트 로깅
  // ============================================

  /// 추천 노출 이벤트 (Impression)
  Future<void> logImpression({
    required String placeId,
    required String placeName,
    required List<String> categories,
    double? score,
  }) async {
    await _logEvent(MetricEvent(
      eventType: MetricEventType.impression,
      placeId: placeId,
      placeName: placeName,
      categories: categories,
      score: score,
      timestamp: DateTime.now(),
    ));

    Logger.info(
      '추천 노출: $placeName (score: ${score?.toStringAsFixed(2) ?? "N/A"})',
      'RecommendationMetrics',
    );
  }

  /// 클릭 이벤트
  Future<void> logClick({
    required String placeId,
    required String placeName,
    required List<String> categories,
    double? score,
  }) async {
    await _logEvent(MetricEvent(
      eventType: MetricEventType.click,
      placeId: placeId,
      placeName: placeName,
      categories: categories,
      score: score,
      timestamp: DateTime.now(),
    ));

    Logger.info('클릭: $placeName', 'RecommendationMetrics');
  }

  /// 여행 계획 추가 이벤트 (Conversion)
  Future<void> logConversion({
    required String placeId,
    required String placeName,
    required List<String> categories,
    double? score,
  }) async {
    await _logEvent(MetricEvent(
      eventType: MetricEventType.conversion,
      placeId: placeId,
      placeName: placeName,
      categories: categories,
      score: score,
      timestamp: DateTime.now(),
    ));

    Logger.info('여행 계획 추가: $placeName', 'RecommendationMetrics');
  }

  /// 피드백 이벤트
  Future<void> logFeedback({
    required String placeId,
    required String placeName,
    required List<String> categories,
    required bool isPositive,
    double? score,
  }) async {
    await _logEvent(MetricEvent(
      eventType: MetricEventType.feedback,
      placeId: placeId,
      placeName: placeName,
      categories: categories,
      score: score,
      isPositiveFeedback: isPositive,
      timestamp: DateTime.now(),
    ));

    Logger.info(
      '피드백: $placeName (${isPositive ? "긍정" : "부정"})',
      'RecommendationMetrics',
    );
  }

  /// 이벤트 저장
  Future<void> _logEvent(MetricEvent event) async {
    try {
      final events = await _getEvents();
      events.add(event);

      // 최대 개수 제한
      if (events.length > _maxEvents) {
        events.removeRange(0, events.length - _maxEvents);
      }

      await _saveEvents(events);
    } catch (e, stackTrace) {
      Logger.error('메트릭 이벤트 저장 실패', e, stackTrace, 'RecommendationMetrics');
    }
  }

  /// 이벤트 목록 가져오기
  Future<List<MetricEvent>> _getEvents() async {
    try {
      final json = _prefs.getString(_metricsKey);
      if (json == null) return [];

      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => MetricEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('메트릭 이벤트 로드 실패', e, null, 'RecommendationMetrics');
      return [];
    }
  }

  /// 이벤트 저장
  Future<void> _saveEvents(List<MetricEvent> events) async {
    try {
      final json = jsonEncode(events.map((e) => e.toJson()).toList());
      await _prefs.setString(_metricsKey, json);
    } catch (e) {
      Logger.error('메트릭 이벤트 저장 실패', e, null, 'RecommendationMetrics');
    }
  }

  // ============================================
  // 메트릭 계산
  // ============================================

  /// 클릭률 (CTR) 계산
  ///
  /// CTR = (클릭 수) / (노출 수)
  Future<MetricResult> calculateCTR({DateTime? startDate, DateTime? endDate}) async {
    final events = _filterEventsByDateRange(
      await _getEvents(),
      startDate,
      endDate,
    );

    final impressions = events
        .where((e) => e.eventType == MetricEventType.impression)
        .length;
    final clicks = events
        .where((e) => e.eventType == MetricEventType.click)
        .length;

    final ctr = impressions > 0 ? clicks / impressions : 0.0;

    Logger.info(
      'CTR 계산: ${(ctr * 100).toStringAsFixed(2)}% (클릭: $clicks, 노출: $impressions)',
      'RecommendationMetrics',
    );

    return MetricResult(
      metricName: 'Click-Through Rate (CTR)',
      value: ctr,
      displayValue: '${(ctr * 100).toStringAsFixed(2)}%',
      context: {
        'impressions': impressions,
        'clicks': clicks,
      },
    );
  }

  /// 전환율 (Conversion Rate) 계산
  ///
  /// Conversion Rate = (전환 수) / (노출 수)
  Future<MetricResult> calculateConversionRate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final events = _filterEventsByDateRange(
      await _getEvents(),
      startDate,
      endDate,
    );

    final impressions = events
        .where((e) => e.eventType == MetricEventType.impression)
        .length;
    final conversions = events
        .where((e) => e.eventType == MetricEventType.conversion)
        .length;

    final conversionRate = impressions > 0 ? conversions / impressions : 0.0;

    Logger.info(
      '전환율 계산: ${(conversionRate * 100).toStringAsFixed(2)}% '
      '(전환: $conversions, 노출: $impressions)',
      'RecommendationMetrics',
    );

    return MetricResult(
      metricName: 'Conversion Rate',
      value: conversionRate,
      displayValue: '${(conversionRate * 100).toStringAsFixed(2)}%',
      context: {
        'impressions': impressions,
        'conversions': conversions,
      },
    );
  }

  /// 사용자 만족도 (User Satisfaction) 계산
  ///
  /// Satisfaction = (긍정 피드백 수) / (전체 피드백 수)
  Future<MetricResult> calculateUserSatisfaction({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final events = _filterEventsByDateRange(
      await _getEvents(),
      startDate,
      endDate,
    );

    final feedbackEvents = events
        .where((e) => e.eventType == MetricEventType.feedback)
        .toList();

    if (feedbackEvents.isEmpty) {
      return const MetricResult(
        metricName: 'User Satisfaction',
        value: 0.0,
        displayValue: 'N/A',
        context: {},
      );
    }

    final positiveFeedbacks = feedbackEvents
        .where((e) => e.isPositiveFeedback == true)
        .length;

    final satisfaction = positiveFeedbacks / feedbackEvents.length;

    Logger.info(
      '사용자 만족도: ${(satisfaction * 100).toStringAsFixed(2)}% '
      '(긍정: $positiveFeedbacks, 전체: ${feedbackEvents.length})',
      'RecommendationMetrics',
    );

    return MetricResult(
      metricName: 'User Satisfaction',
      value: satisfaction,
      displayValue: '${(satisfaction * 100).toStringAsFixed(2)}%',
      context: {
        'totalFeedbacks': feedbackEvents.length,
        'positiveFeedbacks': positiveFeedbacks,
        'negativeFeedbacks': feedbackEvents.length - positiveFeedbacks,
      },
    );
  }

  /// 카테고리별 성능 분석
  ///
  /// 각 카테고리의 CTR, 전환율, 만족도를 계산합니다.
  Future<Map<String, CategoryPerformance>> analyzeCategoryPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final events = _filterEventsByDateRange(
      await _getEvents(),
      startDate,
      endDate,
    );

    final categoryStats = <String, CategoryPerformance>{};

    // 카테고리별로 이벤트 그룹화
    for (final event in events) {
      for (final category in event.categories) {
        if (!categoryStats.containsKey(category)) {
          categoryStats[category] = CategoryPerformance(category: category);
        }

        final stats = categoryStats[category]!;

        switch (event.eventType) {
          case MetricEventType.impression:
            stats.impressions++;
            break;
          case MetricEventType.click:
            stats.clicks++;
            break;
          case MetricEventType.conversion:
            stats.conversions++;
            break;
          case MetricEventType.feedback:
            if (event.isPositiveFeedback == true) {
              stats.positiveFeedbacks++;
            } else {
              stats.negativeFeedbacks++;
            }
            break;
        }

        categoryStats[category] = stats;
      }
    }

    // 메트릭 계산
    for (final entry in categoryStats.entries) {
      final stats = entry.value;
      stats.ctr = stats.impressions > 0 ? stats.clicks / stats.impressions : 0.0;
      stats.conversionRate =
          stats.impressions > 0 ? stats.conversions / stats.impressions : 0.0;

      final totalFeedbacks = stats.positiveFeedbacks + stats.negativeFeedbacks;
      stats.satisfaction = totalFeedbacks > 0
          ? stats.positiveFeedbacks / totalFeedbacks
          : 0.0;
    }

    Logger.info(
      '카테고리별 성능 분석 완료: ${categoryStats.length}개 카테고리',
      'RecommendationMetrics',
    );

    return categoryStats;
  }

  /// 추천 점수와 실제 성과의 상관관계 분석
  ///
  /// 높은 점수의 추천이 실제로 더 나은 성과를 보이는지 확인합니다.
  Future<ScoreCorrelation> analyzeScoreCorrelation({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final events = _filterEventsByDateRange(
      await _getEvents(),
      startDate,
      endDate,
    );

    // 점수별로 그룹화 (0.1 단위)
    final scoreGroups = <int, ScoreGroupStats>{};

    for (final event in events) {
      if (event.score == null) continue;

      final scoreGroup = (event.score! * 10).floor(); // 0.0~0.99 -> 0, 1.0~1.99 -> 1, ...

      if (!scoreGroups.containsKey(scoreGroup)) {
        scoreGroups[scoreGroup] = ScoreGroupStats(
          minScore: scoreGroup / 10,
          maxScore: (scoreGroup + 1) / 10,
        );
      }

      final stats = scoreGroups[scoreGroup]!;

      switch (event.eventType) {
        case MetricEventType.impression:
          stats.impressions++;
          break;
        case MetricEventType.click:
          stats.clicks++;
          break;
        case MetricEventType.conversion:
          stats.conversions++;
          break;
        case MetricEventType.feedback:
          if (event.isPositiveFeedback == true) {
            stats.positiveFeedbacks++;
          } else {
            stats.negativeFeedbacks++;
          }
          break;
      }
    }

    // 메트릭 계산
    for (final stats in scoreGroups.values) {
      stats.ctr = stats.impressions > 0 ? stats.clicks / stats.impressions : 0.0;
      stats.conversionRate =
          stats.impressions > 0 ? stats.conversions / stats.impressions : 0.0;

      final totalFeedbacks = stats.positiveFeedbacks + stats.negativeFeedbacks;
      stats.satisfaction = totalFeedbacks > 0
          ? stats.positiveFeedbacks / totalFeedbacks
          : 0.0;
    }

    Logger.info(
      '점수 상관관계 분석 완료: ${scoreGroups.length}개 그룹',
      'RecommendationMetrics',
    );

    return ScoreCorrelation(scoreGroups: scoreGroups);
  }

  /// 날짜 범위로 이벤트 필터링
  List<MetricEvent> _filterEventsByDateRange(
    List<MetricEvent> events,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return events.where((event) {
      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // ============================================
  // 전체 대시보드 메트릭
  // ============================================

  /// 전체 대시보드 메트릭 가져오기
  Future<DashboardMetrics> getDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final ctr = await calculateCTR(startDate: startDate, endDate: endDate);
    final conversionRate = await calculateConversionRate(
      startDate: startDate,
      endDate: endDate,
    );
    final satisfaction = await calculateUserSatisfaction(
      startDate: startDate,
      endDate: endDate,
    );
    final categoryPerformance = await analyzeCategoryPerformance(
      startDate: startDate,
      endDate: endDate,
    );

    return DashboardMetrics(
      ctr: ctr,
      conversionRate: conversionRate,
      userSatisfaction: satisfaction,
      categoryPerformance: categoryPerformance,
    );
  }

  // ============================================
  // 데이터 관리
  // ============================================

  /// 모든 메트릭 데이터 삭제
  Future<void> clearAllData() async {
    await _prefs.remove(_metricsKey);
    Logger.info('모든 메트릭 데이터를 삭제했습니다.', 'RecommendationMetrics');
  }
}

// ============================================
// 데이터 모델
// ============================================

/// 메트릭 이벤트 타입
enum MetricEventType {
  impression, // 추천 노출
  click, // 클릭
  conversion, // 여행 계획 추가
  feedback, // 피드백
}

/// 메트릭 이벤트
class MetricEvent {
  final MetricEventType eventType;
  final String placeId;
  final String placeName;
  final List<String> categories;
  final double? score;
  final bool? isPositiveFeedback;
  final DateTime timestamp;

  const MetricEvent({
    required this.eventType,
    required this.placeId,
    required this.placeName,
    required this.categories,
    this.score,
    this.isPositiveFeedback,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType.name,
      'placeId': placeId,
      'placeName': placeName,
      'categories': categories,
      'score': score,
      'isPositiveFeedback': isPositiveFeedback,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MetricEvent.fromJson(Map<String, dynamic> json) {
    return MetricEvent(
      eventType: MetricEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
      ),
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String,
      categories: List<String>.from(json['categories'] as List),
      score: (json['score'] as num?)?.toDouble(),
      isPositiveFeedback: json['isPositiveFeedback'] as bool?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 메트릭 결과
class MetricResult {
  final String metricName;
  final double value;
  final String displayValue;
  final Map<String, dynamic> context;

  const MetricResult({
    required this.metricName,
    required this.value,
    required this.displayValue,
    required this.context,
  });
}

/// 카테고리 성능
class CategoryPerformance {
  final String category;
  int impressions = 0;
  int clicks = 0;
  int conversions = 0;
  int positiveFeedbacks = 0;
  int negativeFeedbacks = 0;
  double ctr = 0.0;
  double conversionRate = 0.0;
  double satisfaction = 0.0;

  CategoryPerformance({required this.category});

  @override
  String toString() {
    return 'CategoryPerformance('
        'category: $category, '
        'CTR: ${(ctr * 100).toStringAsFixed(2)}%, '
        'Conversion: ${(conversionRate * 100).toStringAsFixed(2)}%, '
        'Satisfaction: ${(satisfaction * 100).toStringAsFixed(2)}%'
        ')';
  }
}

/// 점수 그룹 통계
class ScoreGroupStats {
  final double minScore;
  final double maxScore;
  int impressions = 0;
  int clicks = 0;
  int conversions = 0;
  int positiveFeedbacks = 0;
  int negativeFeedbacks = 0;
  double ctr = 0.0;
  double conversionRate = 0.0;
  double satisfaction = 0.0;

  ScoreGroupStats({
    required this.minScore,
    required this.maxScore,
  });

  @override
  String toString() {
    return 'ScoreGroupStats('
        'range: ${minScore.toStringAsFixed(1)}-${maxScore.toStringAsFixed(1)}, '
        'CTR: ${(ctr * 100).toStringAsFixed(2)}%, '
        'Conversion: ${(conversionRate * 100).toStringAsFixed(2)}%, '
        'Satisfaction: ${(satisfaction * 100).toStringAsFixed(2)}%'
        ')';
  }
}

/// 점수 상관관계
class ScoreCorrelation {
  final Map<int, ScoreGroupStats> scoreGroups;

  const ScoreCorrelation({required this.scoreGroups});

  /// 점수와 CTR의 상관계수 (간단한 버전)
  double get scoreCTRCorrelation {
    if (scoreGroups.length < 2) return 0.0;

    // 점수가 높을수록 CTR이 높은지 확인
    final sortedGroups = scoreGroups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    double sumCTRDiff = 0;
    for (int i = 1; i < sortedGroups.length; i++) {
      sumCTRDiff += sortedGroups[i].value.ctr - sortedGroups[i - 1].value.ctr;
    }

    // 양수면 정상관, 음수면 역상관
    return sumCTRDiff / (sortedGroups.length - 1);
  }
}

/// 대시보드 메트릭
class DashboardMetrics {
  final MetricResult ctr;
  final MetricResult conversionRate;
  final MetricResult userSatisfaction;
  final Map<String, CategoryPerformance> categoryPerformance;

  const DashboardMetrics({
    required this.ctr,
    required this.conversionRate,
    required this.userSatisfaction,
    required this.categoryPerformance,
  });
}
