import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/recommendation_logger.dart';
import '../models/analytics_metrics.dart';

/// 추천 시스템 분석 및 메트릭 수집 서비스
/// SharedPreferences를 사용하여 JSON 형태로 데이터를 저장합니다.
class RecommendationAnalytics {
  static final RecommendationAnalytics _instance = RecommendationAnalytics._internal();
  factory RecommendationAnalytics() => _instance;
  RecommendationAnalytics._internal();

  static const String _metricsPrefix = 'rec_metrics_';
  static const String _performanceKey = 'rec_performance';
  static const String _errorKey = 'rec_errors';
  static const int _maxErrorLogs = 100;
  static const int _maxPerformanceMetrics = 1000;

  final _logger = RecommendationLogger();
  SharedPreferences? _prefs;

  /// 초기화
  Future<void> init() async {
    try {
      _logger.info('추천 분석 시스템 초기화 중...');
      _prefs = await SharedPreferences.getInstance();
      _logger.info('추천 분석 시스템 초기화 완료');
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.init',
      );
      rethrow;
    }
  }

  /// 오늘 날짜 키 생성
  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 오늘의 메트릭 가져오기 (없으면 생성)
  DailyMetrics _getTodayMetrics() {
    final key = '$_metricsPrefix$_todayKey';
    final jsonStr = _prefs?.getString(key);

    if (jsonStr == null) {
      return DailyMetrics(date: _todayKey);
    }

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DailyMetrics.fromJson(json);
    } catch (e) {
      _logger.warning('메트릭 파싱 실패, 새로 생성', data: {'error': e.toString()});
      return DailyMetrics(date: _todayKey);
    }
  }

  /// 메트릭 저장
  Future<void> _saveTodayMetrics(DailyMetrics metrics) async {
    final key = '$_metricsPrefix${metrics.date}';
    final jsonStr = jsonEncode(metrics.toJson());
    await _prefs?.setString(key, jsonStr);
  }

  /// 추천 생성 메트릭 기록
  Future<void> recordRecommendationGenerated({
    required int count,
    required double averageScore,
  }) async {
    try {
      final metrics = _getTodayMetrics();
      metrics.recommendationCount += count;
      metrics.totalRecommendationScore += averageScore * count;
      await _saveTodayMetrics(metrics);

      _logger.debug('추천 생성 메트릭 기록', data: {
        'count': count,
        'avg_score': averageScore,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordRecommendationGenerated',
      );
    }
  }

  /// 사용자 액션 메트릭 기록
  Future<void> recordUserAction({
    required String actionType,
  }) async {
    try {
      final metrics = _getTodayMetrics();
      metrics.userActionCount++;
      metrics.actionTypeCounts[actionType] = (metrics.actionTypeCounts[actionType] ?? 0) + 1;
      await _saveTodayMetrics(metrics);

      _logger.debug('사용자 액션 메트릭 기록', data: {
        'action_type': actionType,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordUserAction',
      );
    }
  }

  /// API 호출 메트릭 기록
  Future<void> recordApiCall({
    required bool success,
    required int responseTimeMs,
  }) async {
    try {
      final metrics = _getTodayMetrics();
      metrics.apiCallCount++;

      if (!success) {
        metrics.apiFailureCount++;
      }

      metrics.responseTimes.add(responseTimeMs);

      // 응답 시간 리스트가 너무 커지지 않도록 제한
      if (metrics.responseTimes.length > 10000) {
        metrics.responseTimes.removeRange(0, 5000);
      }

      await _saveTodayMetrics(metrics);

      _logger.debug('API 호출 메트릭 기록', data: {
        'success': success,
        'response_time_ms': responseTimeMs,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordApiCall',
      );
    }
  }

  /// 캐시 이벤트 메트릭 기록
  Future<void> recordCacheEvent({
    required bool isHit,
  }) async {
    try {
      final metrics = _getTodayMetrics();

      if (isHit) {
        metrics.cacheHitCount++;
      } else {
        metrics.cacheMissCount++;
      }

      await _saveTodayMetrics(metrics);

      _logger.debug('캐시 이벤트 메트릭 기록', data: {
        'is_hit': isHit,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordCacheEvent',
      );
    }
  }

  /// 에러 발생 기록
  Future<void> recordError({
    required String errorType,
    required String context,
    required String message,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final metrics = _getTodayMetrics();
      metrics.errorCount++;
      await _saveTodayMetrics(metrics);

      // 에러 로그 저장
      final errorLog = ErrorLog(
        errorType: errorType,
        context: context,
        message: message,
        timestamp: DateTime.now(),
        additionalInfo: additionalInfo,
      );

      final errors = getRecentErrors();
      errors.add(errorLog);

      // 최대 개수 제한
      if (errors.length > _maxErrorLogs) {
        errors.removeRange(0, errors.length - _maxErrorLogs);
      }

      final errorsJson = errors.map((e) => e.toJson()).toList();
      await _prefs?.setString(_errorKey, jsonEncode(errorsJson));

      _logger.debug('에러 메트릭 기록', data: {
        'error_type': errorType,
        'context': context,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordError',
      );
    }
  }

  /// 성능 메트릭 기록
  Future<void> recordPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final metric = PerformanceMetric(
        operation: operation,
        durationMs: duration.inMilliseconds,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      final metrics = _getPerformanceMetrics();
      metrics.add(metric);

      // 최대 개수 제한
      if (metrics.length > _maxPerformanceMetrics) {
        metrics.removeRange(0, metrics.length - _maxPerformanceMetrics);
      }

      final metricsJson = metrics.map((m) => m.toJson()).toList();
      await _prefs?.setString(_performanceKey, jsonEncode(metricsJson));

      _logger.debug('성능 메트릭 기록', data: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.recordPerformance',
      );
    }
  }

  /// 성능 메트릭 목록 가져오기
  List<PerformanceMetric> _getPerformanceMetrics() {
    final jsonStr = _prefs?.getString(_performanceKey);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((json) => PerformanceMetric.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.warning('성능 메트릭 파싱 실패', data: {'error': e.toString()});
      return [];
    }
  }

  /// 메트릭 수집
  Map<String, dynamic> collectMetrics() {
    try {
      final todayMetrics = _getTodayMetrics();

      return {
        'daily': todayMetrics.toSummary(),
        'total_errors_logged': getRecentErrors().length,
        'total_performance_metrics': _getPerformanceMetrics().length,
      };
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.collectMetrics',
      );
      return {};
    }
  }

  /// 일일 리포트 생성
  Map<String, dynamic> generateDailyReport() {
    try {
      final todayMetrics = _getTodayMetrics();
      final summary = todayMetrics.toSummary();

      // 주요 지표 분석
      final insights = <String>[];

      // CTR 분석
      final ctr = todayMetrics.clickThroughRate;
      if (ctr > 0.3) {
        insights.add('높은 클릭률 (${(ctr * 100).toStringAsFixed(1)}%) - 추천 품질 우수');
      } else if (ctr < 0.1 && todayMetrics.recommendationCount > 0) {
        insights.add('낮은 클릭률 (${(ctr * 100).toStringAsFixed(1)}%) - 추천 알고리즘 개선 필요');
      }

      // 전환율 분석
      final conversionRate = todayMetrics.conversionRate;
      if (conversionRate > 0.2) {
        insights.add('높은 전환율 (${(conversionRate * 100).toStringAsFixed(1)}%) - 우수한 성과');
      } else if (conversionRate < 0.05 && todayMetrics.recommendationCount > 0) {
        insights.add('낮은 전환율 (${(conversionRate * 100).toStringAsFixed(1)}%) - UX 개선 검토 필요');
      }

      // API 실패율 분석
      final failureRate = todayMetrics.apiFailureRate;
      if (failureRate > 0.1) {
        insights.add('높은 API 실패율 (${(failureRate * 100).toStringAsFixed(1)}%) - 안정성 문제');
      }

      // 캐시 효율성 분석
      final cacheHitRate = todayMetrics.cacheHitRate;
      if (cacheHitRate > 0.7) {
        insights.add('우수한 캐시 효율 (${(cacheHitRate * 100).toStringAsFixed(1)}%)');
      } else if (cacheHitRate < 0.3 && (todayMetrics.cacheHitCount + todayMetrics.cacheMissCount) > 0) {
        insights.add('낮은 캐시 효율 (${(cacheHitRate * 100).toStringAsFixed(1)}%) - 캐시 전략 재검토');
      }

      // 응답 시간 분석
      final avgResponseTime = todayMetrics.averageResponseTime;
      if (avgResponseTime > 1000) {
        insights.add('느린 평균 응답 시간 (${avgResponseTime.toStringAsFixed(0)}ms) - 성능 최적화 필요');
      }

      // 에러 분석
      if (todayMetrics.errorCount > 10) {
        insights.add('높은 에러 발생 (${todayMetrics.errorCount}건) - 안정성 개선 필요');
      }

      return {
        'date': todayMetrics.date,
        'summary': summary,
        'insights': insights,
        'recommendations': _generateRecommendations(todayMetrics),
        'top_actions': _getTopActions(todayMetrics),
      };
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.generateDailyReport',
      );
      return {};
    }
  }

  /// 개선 권장사항 생성
  List<String> _generateRecommendations(DailyMetrics metrics) {
    final recommendations = <String>[];

    if (metrics.apiFailureRate > 0.05) {
      recommendations.add('API 안정성 개선: 재시도 로직 강화 또는 fallback 메커니즘 추가');
    }

    if (metrics.cacheHitRate < 0.5 && (metrics.cacheHitCount + metrics.cacheMissCount) > 10) {
      recommendations.add('캐시 전략 개선: TTL 조정 또는 캐시 워밍 전략 도입');
    }

    if (metrics.averageResponseTime > 500) {
      recommendations.add('성능 최적화: 데이터베이스 쿼리 최적화 또는 병렬 처리 도입');
    }

    if (metrics.clickThroughRate < 0.15 && metrics.recommendationCount > 10) {
      recommendations.add('추천 알고리즘 개선: 개인화 강화 또는 다양성 증가');
    }

    if (metrics.conversionRate < 0.1 && metrics.recommendationCount > 10) {
      recommendations.add('UX 개선: 추천 표시 방식 개선 또는 액션 버튼 강조');
    }

    return recommendations;
  }

  /// 상위 액션 타입 가져오기
  List<Map<String, dynamic>> _getTopActions(DailyMetrics metrics) {
    final entries = metrics.actionTypeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(5).map((e) => {
      'action': e.key,
      'count': e.value,
      'percentage': metrics.userActionCount > 0
          ? '${((e.value / metrics.userActionCount) * 100).toStringAsFixed(1)}%'
          : '0%',
    }).toList();
  }

  /// 기간별 메트릭 조회
  List<DailyMetrics> getMetricsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      final metrics = <DailyMetrics>[];
      var currentDate = startDate;

      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final dateStr = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
        final key = '$_metricsPrefix$dateStr';
        final jsonStr = _prefs?.getString(key);

        if (jsonStr != null) {
          try {
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            metrics.add(DailyMetrics.fromJson(json));
          } catch (e) {
            // 파싱 실패 시 건너뛰기
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      return metrics;
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.getMetricsForPeriod',
      );
      return [];
    }
  }

  /// 최근 에러 로그 조회
  List<ErrorLog> getRecentErrors({int limit = 20}) {
    try {
      final jsonStr = _prefs?.getString(_errorKey);
      if (jsonStr == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      final errors = jsonList
          .map((json) => ErrorLog.fromJson(json as Map<String, dynamic>))
          .toList();

      errors.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return errors.take(limit).toList();
    } catch (e) {
      _logger.warning('에러 로그 파싱 실패', data: {'error': e.toString()});
      return [];
    }
  }

  /// 특정 작업의 성능 통계
  Map<String, dynamic> getPerformanceStats(String operation) {
    try {
      final metrics = _getPerformanceMetrics()
          .where((m) => m.operation == operation)
          .toList();

      if (metrics.isEmpty) {
        return {};
      }

      final durations = metrics.map((m) => m.durationMs).toList()..sort();
      final sum = durations.reduce((a, b) => a + b);

      return {
        'operation': operation,
        'count': metrics.length,
        'avg_ms': (sum / metrics.length).toStringAsFixed(2),
        'min_ms': durations.first,
        'max_ms': durations.last,
        'p50_ms': durations[(durations.length * 0.5).floor()],
        'p95_ms': durations[(durations.length * 0.95).floor()],
        'p99_ms': durations[(durations.length * 0.99).floor()],
      };
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.getPerformanceStats',
      );
      return {};
    }
  }

  /// 오래된 데이터 정리 (30일 이전)
  Future<void> cleanupOldData() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final keys = _prefs?.getKeys() ?? <String>{};

      final keysToDelete = <String>[];

      for (final key in keys) {
        if (key.startsWith(_metricsPrefix)) {
          final dateStr = key.substring(_metricsPrefix.length);
          final dateParts = dateStr.split('-');

          if (dateParts.length == 3) {
            try {
              final date = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );

              if (date.isBefore(thirtyDaysAgo)) {
                keysToDelete.add(key);
              }
            } catch (e) {
              // 파싱 실패 시 건너뛰기
            }
          }
        }
      }

      for (final key in keysToDelete) {
        await _prefs?.remove(key);
      }

      _logger.info('오래된 메트릭 데이터 정리 완료', data: {
        'deleted_count': keysToDelete.length,
      });
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.cleanupOldData',
      );
    }
  }

  /// 모든 데이터 초기화 (테스트용)
  Future<void> clearAllData() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};

      for (final key in keys) {
        if (key.startsWith(_metricsPrefix) ||
            key == _performanceKey ||
            key == _errorKey) {
          await _prefs?.remove(key);
        }
      }

      _logger.info('모든 분석 데이터 초기화 완료');
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'RecommendationAnalytics.clearAllData',
      );
    }
  }
}
