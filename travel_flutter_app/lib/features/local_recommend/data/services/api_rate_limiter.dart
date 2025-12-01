import 'dart:collection';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/logger.dart';

/// API Rate Limiter
///
/// Google Places API의 분당 60회 제한을 준수하기 위한 Rate Limiting 클래스입니다.
/// Queue를 사용하여 API 호출 기록을 관리하고, 제한을 초과하지 않도록 조절합니다.
class ApiRateLimiter {
  /// API 호출 기록 큐
  final Queue<DateTime> _callHistory = Queue<DateTime>();

  /// 분당 최대 호출 횟수
  final int maxCallsPerMinute;

  /// Rate Limit 윈도우
  final Duration rateLimitWindow;

  ApiRateLimiter({
    this.maxCallsPerMinute = RecommendationConstants.maxApiCallsPerMinute,
    this.rateLimitWindow = RecommendationConstants.rateLimitWindow,
  });

  // ============================================
  // Rate Limiting
  // ============================================

  /// API 호출 전 Rate Limit 체크 및 대기
  ///
  /// 호출 가능한 상태가 될 때까지 대기합니다.
  /// Returns 대기한 시간 (밀리초)
  Future<int> throttle() async {
    final startTime = DateTime.now();

    // 현재 요청 가능한지 확인
    while (!canMakeRequest()) {
      // 가장 오래된 호출이 윈도우를 벗어날 때까지 대기
      final oldestCall = _callHistory.first;
      final timeSinceOldest = DateTime.now().difference(oldestCall);
      final waitTime = rateLimitWindow - timeSinceOldest;

      if (waitTime.inMilliseconds > 0) {
        Logger.warning(
          'Rate Limit 도달, ${waitTime.inMilliseconds}ms 대기',
          'ApiRateLimiter',
        );
        await Future.delayed(waitTime);
      }

      // 만료된 호출 기록 정리
      _cleanupExpiredCalls();
    }

    // 호출 기록 추가
    _recordCall();

    final waitedMs = DateTime.now().difference(startTime).inMilliseconds;

    if (waitedMs > 0) {
      Logger.info('Rate Limit 대기 완료: ${waitedMs}ms', 'ApiRateLimiter');
    }

    return waitedMs;
  }

  /// 현재 요청 가능 여부 확인
  ///
  /// Returns true면 즉시 요청 가능, false면 대기 필요
  bool canMakeRequest() {
    _cleanupExpiredCalls();
    return _callHistory.length < maxCallsPerMinute;
  }

  /// API 호출 기록
  void _recordCall() {
    _callHistory.add(DateTime.now());
    Logger.debug(
      '현재 호출 수: ${_callHistory.length}/$maxCallsPerMinute',
      'ApiRateLimiter',
    );
  }

  /// 만료된 호출 기록 정리
  ///
  /// Rate Limit 윈도우를 벗어난 오래된 기록을 제거합니다.
  void _cleanupExpiredCalls() {
    final now = DateTime.now();
    final cutoffTime = now.subtract(rateLimitWindow);

    // 윈도우를 벗어난 오래된 기록 제거
    while (_callHistory.isNotEmpty && _callHistory.first.isBefore(cutoffTime)) {
      _callHistory.removeFirst();
    }
  }

  // ============================================
  // 통계 및 유틸리티
  // ============================================

  /// 현재 윈도우 내 호출 횟수
  int get currentCallCount {
    _cleanupExpiredCalls();
    return _callHistory.length;
  }

  /// 남은 호출 가능 횟수
  int get remainingCalls {
    return maxCallsPerMinute - currentCallCount;
  }

  /// Rate Limit 사용률 (0.0 ~ 1.0)
  double get usageRate {
    return currentCallCount / maxCallsPerMinute;
  }

  /// 다음 호출 가능 시간까지 남은 시간
  ///
  /// Returns null이면 즉시 호출 가능
  Duration? get timeUntilNextCall {
    if (canMakeRequest()) {
      return null;
    }

    final oldestCall = _callHistory.first;
    final timeSinceOldest = DateTime.now().difference(oldestCall);
    return rateLimitWindow - timeSinceOldest;
  }

  /// Rate Limiter 초기화 (테스트용)
  void reset() {
    _callHistory.clear();
    Logger.info('Rate Limiter 초기화', 'ApiRateLimiter');
  }

  /// Rate Limiter 상태 정보
  Map<String, dynamic> getStatus() {
    return {
      'currentCalls': currentCallCount,
      'maxCalls': maxCallsPerMinute,
      'remainingCalls': remainingCalls,
      'usageRate': usageRate,
      'timeUntilNextCall': timeUntilNextCall?.inMilliseconds,
      'canMakeRequest': canMakeRequest(),
    };
  }

  @override
  String toString() {
    return 'ApiRateLimiter('
        'calls: $currentCallCount/$maxCallsPerMinute, '
        'usage: ${(usageRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}
