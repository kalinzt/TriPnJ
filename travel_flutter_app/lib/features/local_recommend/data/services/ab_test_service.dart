import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/ab_test_config.dart';

/// A/B 테스트 서비스
///
/// 사용자를 그룹에 할당하고, 변형을 선택하며, 이벤트를 로깅합니다.
class ABTestService {
  final SharedPreferences _prefs;

  /// 사용자 변형 할당 저장 키
  static const String _variantAssignmentKey = 'ab_test_variant_assignments';

  /// 이벤트 로그 저장 키
  static const String _eventLogKey = 'ab_test_event_logs';

  /// 최대 이벤트 로그 개수 (메모리 관리)
  static const int _maxEventLogs = 1000;

  ABTestService(this._prefs);

  // ============================================
  // 사용자 그룹 할당
  // ============================================

  /// 사용자 ID 기반으로 변형 할당
  ///
  /// userId를 해싱하여 일관성 있게 그룹을 할당합니다.
  /// 동일한 userId는 항상 같은 변형에 할당됩니다.
  ///
  /// [userId]: 사용자 고유 ID
  /// [config]: A/B 테스트 설정
  ///
  /// Returns: 할당된 변형
  ABTestVariant assignVariant({
    required String userId,
    required ABTestConfig config,
  }) {
    // 테스트가 비활성화된 경우 첫 번째 변형 반환 (일반적으로 대조군)
    if (!config.isActive) {
      Logger.info(
        '테스트 \'${config.testId}\'가 비활성화되어 기본 변형을 사용합니다.',
        'ABTestService',
      );
      return config.variants.first;
    }

    // 이미 할당된 변형이 있는지 확인
    final existingVariantId = _getStoredVariantId(config.testId);
    if (existingVariantId != null) {
      final existingVariant = config.variants.firstWhere(
        (v) => v.variantId == existingVariantId,
        orElse: () => config.variants.first,
      );

      Logger.info(
        '사용자가 이미 테스트 \'${config.testId}\'의 변형 \'${existingVariant.variantName}\'에 할당되어 있습니다.',
        'ABTestService',
      );

      return existingVariant;
    }

    // userId 해싱을 통한 일관성 있는 그룹 할당
    final hash = _hashUserId(userId, config.testId);

    // 할당 비율에 따라 변형 선택
    double cumulativeRatio = 0.0;

    for (final variant in config.variants) {
      cumulativeRatio += variant.allocationRatio;

      if (hash <= cumulativeRatio) {
        // 선택된 변형 저장
        _storeVariantAssignment(config.testId, variant.variantId);

        Logger.info(
          '사용자를 테스트 \'${config.testId}\'의 변형 \'${variant.variantName}\'에 할당했습니다. '
          '(hash: ${hash.toStringAsFixed(4)})',
          'ABTestService',
        );

        return variant;
      }
    }

    // 기본값: 마지막 변형 반환
    final defaultVariant = config.variants.last;
    _storeVariantAssignment(config.testId, defaultVariant.variantId);

    return defaultVariant;
  }

  /// userId를 해싱하여 0.0 ~ 1.0 사이의 값으로 변환
  ///
  /// SHA-256 해시를 사용하여 일관성 있는 랜덤값을 생성합니다.
  double _hashUserId(String userId, String testId) {
    // testId를 salt로 사용하여 테스트마다 다른 해시값 생성
    final input = '$userId:$testId';
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);

    // 해시의 첫 4바이트를 int로 변환 후 0.0 ~ 1.0으로 정규화
    final hashInt = (hash.bytes[0] << 24) |
        (hash.bytes[1] << 16) |
        (hash.bytes[2] << 8) |
        hash.bytes[3];

    return (hashInt & 0x7FFFFFFF) / 0x7FFFFFFF; // 양수로 변환 후 정규화
  }

  /// 저장된 변형 할당 가져오기
  String? _getStoredVariantId(String testId) {
    final json = _prefs.getString(_variantAssignmentKey);
    if (json == null) return null;

    try {
      final assignments = Map<String, dynamic>.from(jsonDecode(json) as Map);
      return assignments[testId] as String?;
    } catch (e) {
      Logger.error('변형 할당 데이터 로드 실패', e, null, 'ABTestService');
      return null;
    }
  }

  /// 변형 할당 저장
  void _storeVariantAssignment(String testId, String variantId) {
    try {
      final json = _prefs.getString(_variantAssignmentKey);
      final assignments = json != null
          ? Map<String, dynamic>.from(jsonDecode(json) as Map)
          : <String, dynamic>{};

      assignments[testId] = variantId;

      _prefs.setString(_variantAssignmentKey, jsonEncode(assignments));
    } catch (e) {
      Logger.error('변형 할당 저장 실패', e, null, 'ABTestService');
    }
  }

  // ============================================
  // 이벤트 로깅
  // ============================================

  /// A/B 테스트 이벤트 로깅
  ///
  /// [testId]: 테스트 ID
  /// [variantId]: 변형 ID
  /// [eventType]: 이벤트 타입 ('impression', 'click', 'conversion', 'feedback')
  /// [metadata]: 추가 메타데이터
  Future<void> logEvent({
    required String testId,
    required String variantId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = ABTestEvent(
        testId: testId,
        variantId: variantId,
        eventType: eventType,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // 기존 로그 가져오기
      final logs = await getEventLogs();

      // 새 이벤트 추가
      logs.add(event);

      // 최대 개수 제한
      if (logs.length > _maxEventLogs) {
        logs.removeRange(0, logs.length - _maxEventLogs);
      }

      // 저장
      await _saveEventLogs(logs);

      Logger.info(
        'A/B 테스트 이벤트 로깅: testId=$testId, variantId=$variantId, eventType=$eventType',
        'ABTestService',
      );
    } catch (e, stackTrace) {
      Logger.error('이벤트 로깅 실패', e, stackTrace, 'ABTestService');
    }
  }

  /// 이벤트 로그 가져오기
  Future<List<ABTestEvent>> getEventLogs() async {
    try {
      final json = _prefs.getString(_eventLogKey);
      if (json == null) return [];

      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => ABTestEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('이벤트 로그 로드 실패', e, null, 'ABTestService');
      return [];
    }
  }

  /// 이벤트 로그 저장
  Future<void> _saveEventLogs(List<ABTestEvent> logs) async {
    try {
      final json = jsonEncode(logs.map((e) => e.toJson()).toList());
      await _prefs.setString(_eventLogKey, json);
    } catch (e) {
      Logger.error('이벤트 로그 저장 실패', e, null, 'ABTestService');
    }
  }

  /// 특정 테스트의 이벤트만 필터링
  Future<List<ABTestEvent>> getEventLogsForTest(String testId) async {
    final logs = await getEventLogs();
    return logs.where((event) => event.testId == testId).toList();
  }

  /// 특정 변형의 이벤트만 필터링
  Future<List<ABTestEvent>> getEventLogsForVariant({
    required String testId,
    required String variantId,
  }) async {
    final logs = await getEventLogs();
    return logs
        .where((event) =>
            event.testId == testId && event.variantId == variantId)
        .toList();
  }

  // ============================================
  // 통계 및 분석
  // ============================================

  /// 변형별 이벤트 개수 계산
  Future<Map<String, int>> getEventCountsByVariant({
    required String testId,
    required String eventType,
  }) async {
    final logs = await getEventLogsForTest(testId);
    final counts = <String, int>{};

    for (final event in logs) {
      if (event.eventType == eventType) {
        counts[event.variantId] = (counts[event.variantId] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// 전환율 계산
  ///
  /// 전환율 = (전환 이벤트 수) / (노출 이벤트 수)
  Future<Map<String, double>> getConversionRatesByVariant({
    required String testId,
  }) async {
    final logs = await getEventLogsForTest(testId);

    // 변형별 노출/전환 카운트
    final impressions = <String, int>{};
    final conversions = <String, int>{};

    for (final event in logs) {
      if (event.eventType == 'impression') {
        impressions[event.variantId] = (impressions[event.variantId] ?? 0) + 1;
      } else if (event.eventType == 'conversion') {
        conversions[event.variantId] = (conversions[event.variantId] ?? 0) + 1;
      }
    }

    // 전환율 계산
    final conversionRates = <String, double>{};

    for (final variantId in impressions.keys) {
      final impressionCount = impressions[variantId]!;
      final conversionCount = conversions[variantId] ?? 0;

      conversionRates[variantId] = impressionCount > 0
          ? conversionCount / impressionCount
          : 0.0;
    }

    return conversionRates;
  }

  // ============================================
  // 데이터 정리
  // ============================================

  /// 모든 A/B 테스트 데이터 초기화
  Future<void> clearAllData() async {
    await _prefs.remove(_variantAssignmentKey);
    await _prefs.remove(_eventLogKey);

    Logger.info('모든 A/B 테스트 데이터를 초기화했습니다.', 'ABTestService');
  }

  /// 특정 테스트의 데이터만 삭제
  Future<void> clearTestData(String testId) async {
    // 변형 할당 삭제
    final assignmentsJson = _prefs.getString(_variantAssignmentKey);
    if (assignmentsJson != null) {
      final assignments = Map<String, dynamic>.from(jsonDecode(assignmentsJson) as Map);
      assignments.remove(testId);
      await _prefs.setString(_variantAssignmentKey, jsonEncode(assignments));
    }

    // 이벤트 로그 필터링
    final logs = await getEventLogs();
    final filteredLogs = logs.where((event) => event.testId != testId).toList();
    await _saveEventLogs(filteredLogs);

    Logger.info('테스트 \'$testId\'의 데이터를 삭제했습니다.', 'ABTestService');
  }
}

/// A/B 테스트 이벤트
class ABTestEvent {
  final String testId;
  final String variantId;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ABTestEvent({
    required this.testId,
    required this.variantId,
    required this.eventType,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'variantId': variantId,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ABTestEvent.fromJson(Map<String, dynamic> json) {
    return ABTestEvent(
      testId: json['testId'] as String,
      variantId: json['variantId'] as String,
      eventType: json['eventType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}
