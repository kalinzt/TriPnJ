import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// 앱의 메인 위젯
/// MaterialApp.router를 사용하여 go_router로 내비게이션 관리
class TravelPlannerApp extends ConsumerWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // ============================================
      // 기본 설정
      // ============================================
      title: '여행 플래너',
      debugShowCheckedModeBanner: false,

      // ============================================
      // 라우팅 설정
      // ============================================
      routerConfig: router,

      // ============================================
      // 테마 설정
      // ============================================
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ============================================
      // 로케일 설정
      // ============================================
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ============================================
      // 스크롤 동작 설정
      // ============================================
      builder: (context, child) {
        // 시스템 폰트 크기 설정 제한 (일관된 UI 유지)
        final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedScaleFactor = textScaleFactor.clamp(0.8, 1.2);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(clampedScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 테마 모드 상태 관리
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
