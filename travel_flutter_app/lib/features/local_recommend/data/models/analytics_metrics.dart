/// 일일 메트릭 데이터
/// SharedPreferences를 사용하여 JSON 형태로 로컬에 저장됩니다.
class DailyMetrics {
  final String date; // YYYY-MM-DD 형식
  int recommendationCount; // 추천 생성 횟수
  int userActionCount; // 사용자 액션 횟수
  double totalRecommendationScore; // 총 추천 점수
  int apiCallCount; // API 호출 횟수
  int apiFailureCount; // API 실패 횟수
  int cacheHitCount; // 캐시 히트 횟수
  int cacheMissCount; // 캐시 미스 횟수
  Map<String, int> actionTypeCounts; // 액션 타입별 카운트
  List<int> responseTimes; // API 응답 시간 리스트 (ms)
  int errorCount; // 에러 발생 횟수

  DailyMetrics({
    required this.date,
    this.recommendationCount = 0,
    this.userActionCount = 0,
    this.totalRecommendationScore = 0.0,
    this.apiCallCount = 0,
    this.apiFailureCount = 0,
    this.cacheHitCount = 0,
    this.cacheMissCount = 0,
    Map<String, int>? actionTypeCounts,
    List<int>? responseTimes,
    this.errorCount = 0,
  })  : actionTypeCounts = actionTypeCounts ?? {},
        responseTimes = responseTimes ?? [];

  /// 평균 추천 점수
  double get averageScore {
    if (recommendationCount == 0) return 0.0;
    return totalRecommendationScore / recommendationCount;
  }

  /// API 실패율
  double get apiFailureRate {
    if (apiCallCount == 0) return 0.0;
    return apiFailureCount / apiCallCount;
  }

  /// 캐시 히트율
  double get cacheHitRate {
    final total = cacheHitCount + cacheMissCount;
    if (total == 0) return 0.0;
    return cacheHitCount / total;
  }

  /// 평균 응답 시간 (ms)
  double get averageResponseTime {
    if (responseTimes.isEmpty) return 0.0;
    return responseTimes.reduce((a, b) => a + b) / responseTimes.length;
  }

  /// P95 응답 시간 (ms)
  int get p95ResponseTime {
    if (responseTimes.isEmpty) return 0;
    final sorted = List<int>.from(responseTimes)..sort();
    final index = (sorted.length * 0.95).floor();
    return sorted[index];
  }

  /// P99 응답 시간 (ms)
  int get p99ResponseTime {
    if (responseTimes.isEmpty) return 0;
    final sorted = List<int>.from(responseTimes)..sort();
    final index = (sorted.length * 0.99).floor();
    return sorted[index];
  }

  /// CTR (Click-Through Rate) - 방문 액션 비율
  double get clickThroughRate {
    if (recommendationCount == 0) return 0.0;
    final visitCount = actionTypeCounts['visit'] ?? 0;
    return visitCount / recommendationCount;
  }

  /// 전환율 - 계획 추가 비율
  double get conversionRate {
    if (recommendationCount == 0) return 0.0;
    final addToPlanCount = actionTypeCounts['add_to_plan'] ?? 0;
    return addToPlanCount / recommendationCount;
  }

  /// 요약 정보
  Map<String, dynamic> toSummary() {
    return {
      'date': date,
      'recommendations': recommendationCount,
      'user_actions': userActionCount,
      'avg_score': averageScore.toStringAsFixed(2),
      'api_calls': apiCallCount,
      'api_failure_rate': '${(apiFailureRate * 100).toStringAsFixed(1)}%',
      'cache_hit_rate': '${(cacheHitRate * 100).toStringAsFixed(1)}%',
      'avg_response_time_ms': averageResponseTime.toStringAsFixed(0),
      'p95_response_time_ms': p95ResponseTime,
      'ctr': '${(clickThroughRate * 100).toStringAsFixed(1)}%',
      'conversion_rate': '${(conversionRate * 100).toStringAsFixed(1)}%',
      'errors': errorCount,
    };
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'recommendationCount': recommendationCount,
      'userActionCount': userActionCount,
      'totalRecommendationScore': totalRecommendationScore,
      'apiCallCount': apiCallCount,
      'apiFailureCount': apiFailureCount,
      'cacheHitCount': cacheHitCount,
      'cacheMissCount': cacheMissCount,
      'actionTypeCounts': actionTypeCounts,
      'responseTimes': responseTimes,
      'errorCount': errorCount,
    };
  }

  /// JSON에서 생성
  factory DailyMetrics.fromJson(Map<String, dynamic> json) {
    return DailyMetrics(
      date: json['date'] as String,
      recommendationCount: json['recommendationCount'] as int? ?? 0,
      userActionCount: json['userActionCount'] as int? ?? 0,
      totalRecommendationScore: (json['totalRecommendationScore'] as num?)?.toDouble() ?? 0.0,
      apiCallCount: json['apiCallCount'] as int? ?? 0,
      apiFailureCount: json['apiFailureCount'] as int? ?? 0,
      cacheHitCount: json['cacheHitCount'] as int? ?? 0,
      cacheMissCount: json['cacheMissCount'] as int? ?? 0,
      actionTypeCounts: Map<String, int>.from(json['actionTypeCounts'] as Map? ?? {}),
      responseTimes: List<int>.from(json['responseTimes'] as List? ?? []),
      errorCount: json['errorCount'] as int? ?? 0,
    );
  }
}

/// 성능 메트릭
class PerformanceMetric {
  final String operation; // 작업 이름
  final int durationMs; // 소요 시간 (ms)
  final DateTime timestamp; // 측정 시간
  final Map<String, dynamic> metadata; // 추가 정보

  PerformanceMetric({
    required this.operation,
    required this.durationMs,
    required this.timestamp,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      operation: json['operation'] as String,
      durationMs: json['durationMs'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// 에러 로그
class ErrorLog {
  final String errorType; // 에러 타입
  final String context; // 발생 위치
  final String message; // 에러 메시지
  final DateTime timestamp; // 발생 시간
  final Map<String, dynamic> additionalInfo; // 추가 정보

  ErrorLog({
    required this.errorType,
    required this.context,
    required this.message,
    required this.timestamp,
    Map<String, dynamic>? additionalInfo,
  }) : additionalInfo = additionalInfo ?? {};

  Map<String, dynamic> toJson() {
    return {
      'error_type': errorType,
      'context': context,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'additional_info': additionalInfo,
    };
  }

  factory ErrorLog.fromJson(Map<String, dynamic> json) {
    return ErrorLog(
      errorType: json['error_type'] as String,
      context: json['context'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalInfo: Map<String, dynamic>.from(json['additional_info'] as Map? ?? {}),
    );
  }
}
