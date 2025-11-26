import 'package:flutter/foundation.dart';

/// 앱 전역 로거 유틸리티
/// 디버그 모드에서만 로그를 출력하여 프로덕션 성능에 영향을 주지 않음
class Logger {
  Logger._();

  // 로그 활성화 여부 (프로덕션에서는 자동으로 비활성화)
  static bool _enabled = kDebugMode;

  /// 로그 활성화/비활성화 설정
  static void setEnabled(bool enabled) {
    _enabled = enabled && kDebugMode;
  }

  /// 현재 시간을 포맷팅
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// 로그 메시지 포맷팅
  static String _formatMessage(String level, String message, String? tag) {
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    return '$timestamp [$level] $tagStr $message';
  }

  // ============================================
  // Debug Level - 상세한 디버그 정보
  // ============================================

  /// 디버그 로그 출력
  /// 개발 중 상세한 정보를 기록할 때 사용
  static void debug(String message, [String? tag]) {
    if (!_enabled) return;
    debugPrint(_formatMessage('DEBUG', message, tag));
  }

  // ============================================
  // Info Level - 일반 정보
  // ============================================

  /// 정보 로그 출력
  /// 앱의 일반적인 동작 흐름을 기록할 때 사용
  static void info(String message, [String? tag]) {
    if (!_enabled) return;
    debugPrint(_formatMessage('INFO', message, tag));
  }

  // ============================================
  // Warning Level - 경고
  // ============================================

  /// 경고 로그 출력
  /// 문제가 될 수 있는 상황을 기록할 때 사용
  static void warning(String message, [String? tag]) {
    if (!_enabled) return;
    debugPrint('⚠️ ${_formatMessage('WARNING', message, tag)}');
  }

  // ============================================
  // Error Level - 오류
  // ============================================

  /// 에러 로그 출력
  /// 오류 상황과 스택 트레이스를 기록할 때 사용
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (!_enabled) return;

    debugPrint('❌ ${_formatMessage('ERROR', message, tag)}');

    if (error != null) {
      debugPrint('   Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('   Stack trace:');
      final lines = stackTrace.toString().split('\n');
      // 스택 트레이스 출력 (처음 5줄만)
      for (var i = 0; i < lines.length && i < 5; i++) {
        debugPrint('   ${lines[i]}');
      }
      if (lines.length > 5) {
        debugPrint('   ... (${lines.length - 5} more lines)');
      }
    }
  }

  // ============================================
  // Network Level - 네트워크 관련 로그
  // ============================================

  /// HTTP 요청 로그
  static void httpRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!_enabled) return;

    debugPrint(_formatMessage('HTTP', '→ $method $url', 'Network'));

    if (headers != null && headers.isNotEmpty) {
      debugPrint('   Headers: $headers');
    }

    if (body != null) {
      debugPrint('   Body: $body');
    }
  }

  /// HTTP 응답 로그
  static void httpResponse(
    String method,
    String url,
    int statusCode,
    dynamic body,
  ) {
    if (!_enabled) return;

    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    debugPrint(
      '$emoji ${_formatMessage('HTTP', '← $method $url ($statusCode)', 'Network')}',
    );

    if (body != null) {
      final bodyStr = body.toString();
      if (bodyStr.length > 200) {
        debugPrint('   Body: ${bodyStr.substring(0, 200)}...');
      } else {
        debugPrint('   Body: $bodyStr');
      }
    }
  }

  // ============================================
  // State Level - 상태 관리 로그
  // ============================================

  /// 상태 변경 로그
  static void stateChange(String stateName, dynamic oldValue, dynamic newValue) {
    if (!_enabled) return;

    debugPrint(_formatMessage('STATE', '$stateName changed', 'State'));
    debugPrint('   Old: $oldValue');
    debugPrint('   New: $newValue');
  }

  // ============================================
  // Performance Level - 성능 측정
  // ============================================

  /// 성능 측정 시작
  static Stopwatch startPerformanceMeasure(String operationName) {
    if (!_enabled) return Stopwatch();

    debugPrint(_formatMessage('PERF', 'Started: $operationName', 'Performance'));
    return Stopwatch()..start();
  }

  /// 성능 측정 종료
  static void endPerformanceMeasure(String operationName, Stopwatch stopwatch) {
    if (!_enabled) return;

    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final emoji = duration < 100 ? '⚡' : duration < 1000 ? '⏱️' : '🐌';
    debugPrint(
      '$emoji ${_formatMessage('PERF', 'Completed: $operationName in ${duration}ms', 'Performance')}',
    );
  }

  // ============================================
  // Navigation Level - 내비게이션 로그
  // ============================================

  /// 화면 전환 로그
  static void navigation(String from, String to) {
    if (!_enabled) return;

    debugPrint(_formatMessage('NAV', '$from → $to', 'Navigation'));
  }

  // ============================================
  // Lifecycle Level - 생명주기 로그
  // ============================================

  /// 위젯 생명주기 로그
  static void lifecycle(String widgetName, String event) {
    if (!_enabled) return;

    debugPrint(_formatMessage('LIFECYCLE', '$widgetName: $event', 'Lifecycle'));
  }

  // ============================================
  // Custom Level - 커스텀 로그
  // ============================================

  /// 커스텀 로그 (특수한 상황에 사용)
  static void custom(String level, String message, [String? tag]) {
    if (!_enabled) return;

    debugPrint(_formatMessage(level.toUpperCase(), message, tag));
  }
}
