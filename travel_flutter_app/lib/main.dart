import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'core/utils/recommendation_logger.dart';
import 'features/local_recommend/data/services/recommendation_analytics.dart';
import 'features/plan/data/models/travel_plan_model.dart';

/// 앱의 진입점
/// 필요한 초기화 작업을 수행한 후 앱 실행
void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 초기화 시작 로그
  Logger.info('앱 초기화 시작', 'main');

  try {
    // ============================================
    // 1. 환경 변수 로드
    // ============================================
    await _loadEnvironmentVariables();

    // ============================================
    // 2. Hive 초기화 (로컬 저장소)
    // ============================================
    await _initializeHive();

    // ============================================
    // 3. 로깅 및 분석 시스템 초기화
    // ============================================
    await _initializeLoggingAndAnalytics();

    // ============================================
    // 4. 시스템 UI 설정
    // ============================================
    _configureSystemUI();

    // ============================================
    // 4. 앱 실행
    // ============================================
    Logger.info('앱 실행 중...', 'main');
    runApp(
      const ProviderScope(
        child: TravelPlannerApp(),
      ),
    );
  } catch (e, stackTrace) {
    // 초기화 중 오류 발생 시 로깅
    Logger.error('앱 초기화 실패', e, stackTrace, 'main');

    // 오류 화면 표시
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화 중 오류가 발생했습니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 환경 변수 로드
Future<void> _loadEnvironmentVariables() async {
  try {
    Logger.info('환경 변수 로드 중...', 'main');
    await dotenv.load(fileName: '.env');
    Logger.info('환경 변수 로드 완료', 'main');

    // API 키 존재 여부 확인 (값은 로깅하지 않음)
    final hasGoogleApiKey = dotenv.env['GOOGLE_PLACES_API_KEY']?.isNotEmpty ?? false;
    final hasAnthropicApiKey = dotenv.env['ANTHROPIC_API_KEY']?.isNotEmpty ?? false;

    if (!hasGoogleApiKey) {
      Logger.warning('Google Places API 키가 설정되지 않았습니다', 'main');
    }

    if (!hasAnthropicApiKey) {
      Logger.warning('Anthropic API 키가 설정되지 않았습니다', 'main');
    }
  } catch (e) {
    Logger.warning('.env 파일을 찾을 수 없습니다. 기본 설정으로 진행합니다.', 'main');
  }
}

/// Hive 초기화
Future<void> _initializeHive() async {
  try {
    Logger.info('Hive 초기화 중...', 'main');
    await Hive.initFlutter();

    // Hive 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TravelPlanAdapter());
      Logger.info('TravelPlanAdapter 등록 완료', 'main');
    }

    Logger.info('Hive 초기화 완료', 'main');
  } catch (e, stackTrace) {
    Logger.error('Hive 초기화 실패', e, stackTrace, 'main');
    rethrow;
  }
}

/// 로깅 및 분석 시스템 초기화
Future<void> _initializeLoggingAndAnalytics() async {
  try {
    Logger.info('로깅 및 분석 시스템 초기화 중...', 'main');

    // 추천 로거 초기화
    final recLogger = RecommendationLogger();
    recLogger.init();

    // 추천 분석 시스템 초기화
    final analytics = RecommendationAnalytics();
    await analytics.init();

    Logger.info('로깅 및 분석 시스템 초기화 완료', 'main');
  } catch (e, stackTrace) {
    Logger.error('로깅 및 분석 시스템 초기화 실패', e, stackTrace, 'main');
    // 로깅 시스템 실패는 앱 실행을 막지 않음
  }
}

/// 시스템 UI 설정
void _configureSystemUI() {
  Logger.info('시스템 UI 설정 중...', 'main');

  // 상태바, 네비게이션바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Android 상태바 설정
      statusBarColor: Colors.transparent, // 투명 상태바
      statusBarIconBrightness: Brightness.dark, // 밝은 배경에 어두운 아이콘
      statusBarBrightness: Brightness.light, // iOS용

      // Android 네비게이션바 설정
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 기기 방향 설정 (세로 모드만 허용)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Logger.info('시스템 UI 설정 완료', 'main');
}
