import 'dart:async';
import '../../../../core/utils/recommendation_logger.dart';
import 'recommendation_analytics.dart';

/// 성능 모니터링 서비스
/// Stopwatch로 각 작업의 소요 시간을 측정하고 병목 지점을 감지합니다.
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final _logger = RecommendationLogger();
  final _analytics = RecommendationAnalytics();

  // 성능 임계값 설정 (ms)
  static const Map<String, int> _thresholds = {
    'recommendation_generation': 1000, // 추천 생성: 1초
    'algorithm_execution': 500, // 알고리즘 실행: 500ms
    'api_call': 2000, // API 호출: 2초
    'cache_operation': 100, // 캐시 작업: 100ms
    'database_query': 300, // 데이터베이스 쿼리: 300ms
    'data_processing': 200, // 데이터 처리: 200ms
  };

  /// 작업 실행 시간 측정 및 모니터링
  ///
  /// [operation]: 작업 이름
  /// [task]: 측정할 작업
  /// [metadata]: 추가 메타데이터
  /// [warnOnSlow]: 느린 경우 경고 로그 출력 여부
  Future<T> measure<T>({
    required String operation,
    required Future<T> Function() task,
    Map<String, dynamic>? metadata,
    bool warnOnSlow = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    T result;

    try {
      result = await task();
      stopwatch.stop();

      final duration = stopwatch.elapsed;
      final durationMs = duration.inMilliseconds;

      // 성능 메트릭 기록
      await _analytics.recordPerformance(
        operation: operation,
        duration: duration,
        metadata: metadata,
      );

      // 임계값 체크 및 경고
      if (warnOnSlow) {
        _checkThreshold(operation, duration, metadata);
      }

      _logger.debug('작업 완료: $operation', data: {
        'duration_ms': durationMs,
        if (metadata != null) ...metadata,
      });

      return result;
    } catch (e) {
      stopwatch.stop();

      _logger.logError(
        error: e,
        context: 'PerformanceMonitor.measure',
        additionalInfo: {
          'operation': operation,
          'duration_ms': stopwatch.elapsed.inMilliseconds,
          if (metadata != null) ...metadata,
        },
      );

      rethrow;
    }
  }

  /// 동기 작업 측정
  T measureSync<T>({
    required String operation,
    required T Function() task,
    Map<String, dynamic>? metadata,
    bool warnOnSlow = true,
  }) {
    final stopwatch = Stopwatch()..start();
    T result;

    try {
      result = task();
      stopwatch.stop();

      final duration = stopwatch.elapsed;

      // 성능 메트릭 기록 (비동기지만 await 하지 않음)
      _analytics.recordPerformance(
        operation: operation,
        duration: duration,
        metadata: metadata,
      );

      // 임계값 체크
      if (warnOnSlow) {
        _checkThreshold(operation, duration, metadata);
      }

      return result;
    } catch (e) {
      stopwatch.stop();

      _logger.logError(
        error: e,
        context: 'PerformanceMonitor.measureSync',
        additionalInfo: {
          'operation': operation,
          'duration_ms': stopwatch.elapsed.inMilliseconds,
          if (metadata != null) ...metadata,
        },
      );

      rethrow;
    }
  }

  /// 알고리즘 성능 측정
  Future<T> measureAlgorithmPerformance<T>({
    required String algorithmName,
    required Future<T> Function() algorithm,
    Map<String, dynamic>? parameters,
  }) async {
    return measure<T>(
      operation: 'algorithm_execution',
      task: algorithm,
      metadata: {
        'algorithm': algorithmName,
        if (parameters != null) 'parameters': parameters,
      },
    );
  }

  /// API 성능 측정
  Future<T> measureApiPerformance<T>({
    required String endpoint,
    required String method,
    required Future<T> Function() apiCall,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await apiCall();
      stopwatch.stop();

      final duration = stopwatch.elapsed;

      // API 호출 메트릭 기록
      await _analytics.recordApiCall(
        success: true,
        responseTimeMs: duration.inMilliseconds,
      );

      // 로그 기록
      _logger.logApiCall(
        endpoint: endpoint,
        method: method,
        responseTime: duration,
        statusCode: 200,
        success: true,
      );

      // 임계값 체크
      _checkThreshold('api_call', duration, {
        'endpoint': endpoint,
        'method': method,
      });

      return result;
    } catch (e) {
      stopwatch.stop();

      // 실패한 API 호출 기록
      await _analytics.recordApiCall(
        success: false,
        responseTimeMs: stopwatch.elapsed.inMilliseconds,
      );

      _logger.logApiCall(
        endpoint: endpoint,
        method: method,
        responseTime: stopwatch.elapsed,
        statusCode: 0,
        success: false,
        errorMessage: e.toString(),
      );

      rethrow;
    }
  }

  /// 데이터베이스 쿼리 성능 측정
  Future<T> measureDatabaseQuery<T>({
    required String queryName,
    required Future<T> Function() query,
    Map<String, dynamic>? queryParams,
  }) async {
    return measure<T>(
      operation: 'database_query',
      task: query,
      metadata: {
        'query': queryName,
        if (queryParams != null) 'params': queryParams,
      },
    );
  }

  /// 캐시 작업 성능 측정
  Future<T> measureCacheOperation<T>({
    required String operationType,
    required Future<T> Function() operation,
    String? cacheKey,
  }) async {
    return measure<T>(
      operation: 'cache_operation',
      task: operation,
      metadata: {
        'type': operationType,
        if (cacheKey != null) 'key': cacheKey,
      },
    );
  }

  /// 데이터 처리 성능 측정
  Future<T> measureDataProcessing<T>({
    required String processingType,
    required Future<T> Function() processing,
    int? dataSize,
  }) async {
    return measure<T>(
      operation: 'data_processing',
      task: processing,
      metadata: {
        'type': processingType,
        if (dataSize != null) 'data_size': dataSize,
      },
    );
  }

  /// 병목 지점 감지
  void _checkThreshold(
    String operation,
    Duration duration,
    Map<String, dynamic>? details,
  ) {
    final threshold = _thresholds[operation];

    if (threshold == null) return;

    final thresholdDuration = Duration(milliseconds: threshold);

    if (duration > thresholdDuration) {
      _logger.logPerformanceWarning(
        operation: operation,
        duration: duration,
        threshold: thresholdDuration,
        details: details,
      );
    }
  }

  /// 배치 작업 성능 측정
  ///
  /// 여러 작업을 순차적으로 실행하고 각각의 성능을 측정합니다.
  Future<List<T>> measureBatch<T>({
    required String batchName,
    required List<Future<T> Function()> tasks,
    bool stopOnError = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = <T>[];
    final taskTimings = <int>[];

    for (var i = 0; i < tasks.length; i++) {
      final taskStopwatch = Stopwatch()..start();

      try {
        final result = await tasks[i]();
        taskStopwatch.stop();

        results.add(result);
        taskTimings.add(taskStopwatch.elapsed.inMilliseconds);
      } catch (e) {
        taskStopwatch.stop();

        _logger.logError(
          error: e,
          context: 'PerformanceMonitor.measureBatch',
          additionalInfo: {
            'batch_name': batchName,
            'task_index': i,
            'elapsed_ms': taskStopwatch.elapsed.inMilliseconds,
          },
        );

        if (stopOnError) {
          rethrow;
        }
      }
    }

    stopwatch.stop();

    // 배치 성능 메트릭 기록
    await _analytics.recordPerformance(
      operation: 'batch_operation',
      duration: stopwatch.elapsed,
      metadata: {
        'batch_name': batchName,
        'total_tasks': tasks.length,
        'successful_tasks': results.length,
        'total_duration_ms': stopwatch.elapsed.inMilliseconds,
        'avg_task_duration_ms': taskTimings.isNotEmpty
            ? (taskTimings.reduce((a, b) => a + b) / taskTimings.length).toStringAsFixed(2)
            : '0',
        'min_task_duration_ms': taskTimings.isNotEmpty ? taskTimings.reduce((a, b) => a < b ? a : b) : 0,
        'max_task_duration_ms': taskTimings.isNotEmpty ? taskTimings.reduce((a, b) => a > b ? a : b) : 0,
      },
    );

    return results;
  }

  /// 병렬 작업 성능 측정
  ///
  /// 여러 작업을 병렬로 실행하고 전체 성능을 측정합니다.
  Future<List<T>> measureParallel<T>({
    required String batchName,
    required List<Future<T> Function()> tasks,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final results = await Future.wait(
        tasks.map((task) => task()),
        eagerError: false,
      );

      stopwatch.stop();

      // 병렬 실행 성능 메트릭 기록
      await _analytics.recordPerformance(
        operation: 'parallel_operation',
        duration: stopwatch.elapsed,
        metadata: {
          'batch_name': batchName,
          'total_tasks': tasks.length,
          'total_duration_ms': stopwatch.elapsed.inMilliseconds,
        },
      );

      return results;
    } catch (e) {
      stopwatch.stop();

      _logger.logError(
        error: e,
        context: 'PerformanceMonitor.measureParallel',
        additionalInfo: {
          'batch_name': batchName,
          'elapsed_ms': stopwatch.elapsed.inMilliseconds,
        },
      );

      rethrow;
    }
  }

  /// 타임아웃이 있는 작업 측정
  Future<T> measureWithTimeout<T>({
    required String operation,
    required Future<T> Function() task,
    required Duration timeout,
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await task().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            '작업이 타임아웃되었습니다: $operation',
            timeout,
          );
        },
      );

      stopwatch.stop();

      await _analytics.recordPerformance(
        operation: operation,
        duration: stopwatch.elapsed,
        metadata: {
          'timeout_ms': timeout.inMilliseconds,
          'timed_out': false,
          if (metadata != null) ...metadata,
        },
      );

      return result;
    } on TimeoutException catch (e) {
      stopwatch.stop();

      await _analytics.recordPerformance(
        operation: operation,
        duration: stopwatch.elapsed,
        metadata: {
          'timeout_ms': timeout.inMilliseconds,
          'timed_out': true,
          if (metadata != null) ...metadata,
        },
      );

      _logger.logError(
        error: e,
        context: 'PerformanceMonitor.measureWithTimeout',
        additionalInfo: {
          'operation': operation,
          'timeout_ms': timeout.inMilliseconds,
          if (metadata != null) ...metadata,
        },
      );

      rethrow;
    } catch (e) {
      stopwatch.stop();

      _logger.logError(
        error: e,
        context: 'PerformanceMonitor.measureWithTimeout',
        additionalInfo: {
          'operation': operation,
          'elapsed_ms': stopwatch.elapsed.inMilliseconds,
          if (metadata != null) ...metadata,
        },
      );

      rethrow;
    }
  }

  /// 성능 통계 조회
  Map<String, dynamic> getPerformanceStats(String operation) {
    return _analytics.getPerformanceStats(operation);
  }

  /// 모든 작업의 성능 요약
  Map<String, Map<String, dynamic>> getAllPerformanceStats() {
    final operations = _thresholds.keys.toList();
    final stats = <String, Map<String, dynamic>>{};

    for (final operation in operations) {
      final operationStats = _analytics.getPerformanceStats(operation);
      if (operationStats.isNotEmpty) {
        stats[operation] = operationStats;
      }
    }

    return stats;
  }
}

/// 타임아웃 예외
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inMilliseconds}ms)';
}
