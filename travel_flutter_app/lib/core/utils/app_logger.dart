import 'package:logger/logger.dart';

/// 앱 전역 Logger 인스턴스
///
/// 사용 예시:
/// ```dart
/// import 'package:travel_flutter_app/core/utils/app_logger.dart';
///
/// appLogger.d('디버그 메시지');
/// appLogger.i('정보 메시지');
/// appLogger.w('경고 메시지');
/// appLogger.e('에러 메시지', error: e, stackTrace: stackTrace);
/// ```
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 스택 트레이스 줄 수 (0 = 비활성화)
    errorMethodCount: 8, // 에러 발생 시 스택 트레이스 줄 수
    lineLength: 80, // 한 줄의 길이
    colors: true, // 콘솔 컬러 활성화
    printEmojis: true, // 이모지 사용
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 시간 포맷
  ),
  level: Level.debug, // 개발 중에는 debug 레벨
);

/// 프로덕션용 Logger (릴리스 빌드에서 사용)
final productionLogger = Logger(
  printer: SimplePrinter(),
  level: Level.warning, // 프로덕션에서는 warning 이상만 로그
);
