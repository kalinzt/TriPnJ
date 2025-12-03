import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// 추천 시스템 전용 로거
/// 개발/프로덕션 환경에 따라 로그 레벨을 자동 조정하고,
/// 민감한 정보는 로그에 포함하지 않습니다.
class RecommendationLogger {
  static final RecommendationLogger _instance = RecommendationLogger._internal();
  factory RecommendationLogger() => _instance;
  RecommendationLogger._internal();

  late final Logger _logger;

  /// 로거 초기화
  void init() {
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  /// 추천 생성 로그
  ///
  /// [recommendationCount]: 생성된 추천 개수
  /// [averageScore]: 평균 추천 점수
  /// [duration]: 추천 생성 소요 시간
  /// [algorithmType]: 사용된 알고리즘 유형
  void logRecommendationGenerated({
    required int recommendationCount,
    required double averageScore,
    required Duration duration,
    required String algorithmType,
    Map<String, dynamic>? metadata,
  }) {
    final logData = {
      'event': 'recommendation_generated',
      'count': recommendationCount,
      'avg_score': averageScore.toStringAsFixed(2),
      'duration_ms': duration.inMilliseconds,
      'algorithm': algorithmType,
      'timestamp': DateTime.now().toIso8601String(),
      if (metadata != null) 'metadata': _sanitizeMetadata(metadata),
    };

    _logger.i('추천 생성 완료: $logData');
  }

  /// 사용자 행동 로그
  ///
  /// [actionType]: 액션 타입 (visit, like, reject, add_to_plan)
  /// [placeId]: 장소 ID
  /// [placeName]: 장소 이름 (선택사항)
  /// [score]: 추천 점수 (선택사항)
  void logUserAction({
    required String actionType,
    required String placeId,
    String? placeName,
    double? score,
    Map<String, dynamic>? context,
  }) {
    final logData = {
      'event': 'user_action',
      'action': actionType,
      'place_id': placeId,
      if (placeName != null) 'place_name': _sanitizePlaceName(placeName),
      if (score != null) 'score': score.toStringAsFixed(2),
      'timestamp': DateTime.now().toIso8601String(),
      if (context != null) 'context': _sanitizeMetadata(context),
    };

    _logger.i('사용자 행동: $logData');
  }

  /// API 호출 로그
  ///
  /// [endpoint]: API 엔드포인트
  /// [method]: HTTP 메서드
  /// [responseTime]: 응답 시간
  /// [statusCode]: HTTP 상태 코드
  /// [success]: 성공 여부
  void logApiCall({
    required String endpoint,
    required String method,
    required Duration responseTime,
    required int statusCode,
    required bool success,
    Map<String, dynamic>? parameters,
    String? errorMessage,
  }) {
    final logData = {
      'event': 'api_call',
      'endpoint': _sanitizeEndpoint(endpoint),
      'method': method,
      'response_time_ms': responseTime.inMilliseconds,
      'status_code': statusCode,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
      if (parameters != null) 'params': _sanitizeApiParams(parameters),
      if (errorMessage != null) 'error': errorMessage,
    };

    if (success) {
      _logger.i('API 호출 성공: $logData');
    } else {
      _logger.w('API 호출 실패: $logData');
    }
  }

  /// 에러 로그
  ///
  /// [error]: 에러 객체
  /// [stackTrace]: 스택 트레이스
  /// [context]: 에러 발생 위치/맥락
  void logError({
    required Object error,
    StackTrace? stackTrace,
    required String context,
    Map<String, dynamic>? additionalInfo,
  }) {
    final logData = {
      'event': 'error',
      'error_type': error.runtimeType.toString(),
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalInfo != null) 'additional_info': _sanitizeMetadata(additionalInfo),
    };

    _logger.e(
      '에러 발생: $logData',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 캐시 이벤트 로그
  ///
  /// [eventType]: 이벤트 타입 (hit, miss, set, clear)
  /// [key]: 캐시 키
  /// [size]: 캐시 크기 (선택사항)
  void logCacheEvent({
    required String eventType,
    required String key,
    int? size,
    Duration? ttl,
  }) {
    final logData = {
      'event': 'cache_event',
      'type': eventType,
      'key': _sanitizeCacheKey(key),
      'timestamp': DateTime.now().toIso8601String(),
      if (size != null) 'size': size,
      if (ttl != null) 'ttl_seconds': ttl.inSeconds,
    };

    _logger.d('캐시 이벤트: $logData');
  }

  /// 성능 경고 로그
  ///
  /// [operation]: 작업 이름
  /// [duration]: 소요 시간
  /// [threshold]: 임계값
  void logPerformanceWarning({
    required String operation,
    required Duration duration,
    required Duration threshold,
    Map<String, dynamic>? details,
  }) {
    final logData = {
      'event': 'performance_warning',
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'threshold_ms': threshold.inMilliseconds,
      'exceeded_by_ms': (duration - threshold).inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
      if (details != null) 'details': _sanitizeMetadata(details),
    };

    _logger.w('성능 경고: $logData');
  }

  /// 디버그 로그 (개발 환경에서만)
  void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _logger.d('$message${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// 정보 로그
  void info(String message, {Map<String, dynamic>? data}) {
    _logger.i('$message${data != null ? ' | Data: $data' : ''}');
  }

  /// 경고 로그
  void warning(String message, {Map<String, dynamic>? data}) {
    _logger.w('$message${data != null ? ' | Data: $data' : ''}');
  }

  // ========== Private Helper Methods ==========

  /// 메타데이터에서 민감한 정보 제거
  Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    final sanitized = <String, dynamic>{};

    for (final entry in metadata.entries) {
      final key = entry.key.toLowerCase();

      // 민감한 키 필터링
      if (_isSensitiveKey(key)) {
        sanitized[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, dynamic>) {
        sanitized[entry.key] = _sanitizeMetadata(entry.value as Map<String, dynamic>);
      } else if (entry.value is String && _containsSensitiveData(entry.value as String)) {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// 민감한 키 체크
  bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      'password',
      'token',
      'secret',
      'api_key',
      'auth',
      'credential',
      'email',
      'phone',
      'ssn',
      'card',
      'account',
    ];

    return sensitiveKeys.any((sensitive) => key.contains(sensitive));
  }

  /// 민감한 데이터 패턴 체크
  bool _containsSensitiveData(String value) {
    // 이메일 패턴
    if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return true;
    }

    // 전화번호 패턴
    if (RegExp(r'^01[0-9]-?\d{3,4}-?\d{4}$').hasMatch(value)) {
      return true;
    }

    // 토큰 패턴 (긴 알파벳+숫자 문자열)
    if (value.length > 32 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return true;
    }

    return false;
  }

  /// 엔드포인트에서 민감한 정보 제거 (쿼리 파라미터 등)
  String _sanitizeEndpoint(String endpoint) {
    final uri = Uri.tryParse(endpoint);
    if (uri == null) return endpoint;

    // 쿼리 파라미터 제거
    return uri.replace(query: '').toString();
  }

  /// API 파라미터에서 민감한 정보 제거
  Map<String, dynamic> _sanitizeApiParams(Map<String, dynamic> params) {
    return _sanitizeMetadata(params);
  }

  /// 장소 이름 일부 마스킹 (개인정보 보호)
  String _sanitizePlaceName(String name) {
    // 프로덕션 환경에서는 장소 이름 길이만 기록
    if (!kDebugMode && name.length > 10) {
      return '${name.substring(0, 5)}... (${name.length} chars)';
    }
    return name;
  }

  /// 캐시 키 sanitize
  String _sanitizeCacheKey(String key) {
    // 캐시 키에 민감한 정보가 포함될 수 있으므로 해시화
    if (key.length > 50) {
      return '${key.substring(0, 20)}... (hash: ${key.hashCode})';
    }
    return key;
  }
}

/// 프로덕션 환경 필터
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // 프로덕션에서는 debug 로그 제외
    if (kReleaseMode && event.level == Level.debug) {
      return false;
    }
    return true;
  }
}
