import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 앱 전체 테마 설정
/// 다크/라이트 테마 지원, Material 3 디자인 시스템 적용
class AppTheme {
  AppTheme._();

  // ============================================
  // Light Theme (밝은 테마)
  // ============================================
  /// 라이트 테마 정의
  /// - Material 3 디자인 시스템 사용
  /// - 밝은 배경에 어두운 텍스트
  /// - AppColorsLight 및 AppTextStylesLight 색상 체계 사용
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3 활성화
      useMaterial3: true,
      brightness: Brightness.light,

      // ============================================
      // Color Scheme (색상 체계)
      // ============================================
      /// Material 3 ColorScheme
      /// - primary: 주요 브랜드 색상
      /// - secondary: 보조 색상
      /// - surface: 카드, 시트 등의 표면 색상
      /// - error: 에러 상태 색상
      colorScheme: const ColorScheme.light(
        // Primary colors (주요 색상)
        primary: AppColorsLight.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColorsLight.primaryLight,
        onPrimaryContainer: AppColorsLight.primaryDark,

        // Secondary colors (보조 색상)
        secondary: AppColorsLight.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColorsLight.secondaryLight,
        onSecondaryContainer: AppColorsLight.secondaryDark,

        // Tertiary colors (3차 색상)
        tertiary: AppColorsLight.ocean,

        // Error colors (에러 색상)
        error: AppColorsLight.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),

        // Surface colors (표면 색상)
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.textPrimary,
        surfaceContainerHighest: AppColorsLight.cardBackground,

        // Outline & Shadow (테두리 및 그림자)
        outline: AppColorsLight.border,
        shadow: AppColorsLight.shadow,
      ),

      // ============================================
      // Scaffold (스캐폴드 배경)
      // ============================================
      /// 화면 전체 기본 배경색
      scaffoldBackgroundColor: AppColorsLight.background,

      // ============================================
      // App Bar Theme (상단 앱바)
      // ============================================
      /// 앱바 스타일 설정
      /// - 투명한 elevation
      /// - 중앙 정렬 타이틀
      /// - primary 색상 배경
      appBarTheme: const AppBarTheme(
        elevation: 0, // 그림자 제거
        centerTitle: true, // 타이틀 중앙 정렬
        backgroundColor: AppColorsLight.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light, // 상태바 아이콘 밝게
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      // ============================================
      // Card Theme (카드)
      // ============================================
      /// 카드 위젯 스타일
      /// - 둥근 모서리
      /// - 약간의 elevation
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColorsLight.cardBackground,
        shadowColor: AppColorsLight.shadow,
      ),

      // ============================================
      // Text Theme (텍스트)
      // ============================================
      /// Material 3 Typography
      /// AppTextStylesLight 사용
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ============================================
      // Button Themes (버튼)
      // ============================================

      /// Elevated Button (채워진 버튼)
      /// - primary 색상 배경
      /// - 흰색 텍스트
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColorsLight.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
        ),
      ),

      /// Outlined Button (테두리 버튼)
      /// - primary 색상 테두리
      /// - primary 색상 텍스트
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColorsLight.primary, width: 1.5),
          foregroundColor: AppColorsLight.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      /// Text Button (텍스트만 있는 버튼)
      /// - primary 색상 텍스트
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: AppColorsLight.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      // ============================================
      // Input Decoration Theme (입력 필드)
      // ============================================
      /// TextField, TextFormField 스타일
      /// - 배경색 채움
      /// - 테두리 스타일
      /// - focus 상태 색상
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // 기본 테두리
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),

        // 활성화된 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),

        // 포커스된 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),

        // 에러 테두리
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.error),
        ),

        // 포커스된 에러 테두리
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.error, width: 2),
        ),

        // 텍스트 스타일
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsLight.textHint),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColorsLight.error),
      ),

      // ============================================
      // Icon Theme (아이콘)
      // ============================================
      /// 기본 아이콘 색상 및 크기
      iconTheme: const IconThemeData(
        color: AppColorsLight.textPrimary,
        size: 24,
      ),

      // ============================================
      // Divider Theme (구분선)
      // ============================================
      /// 구분선 스타일
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.divider,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Bottom Navigation Bar Theme (하단 네비게이션)
      // ============================================
      /// 하단 네비게이션 바 스타일
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.surface,
        selectedItemColor: AppColorsLight.primary,
        unselectedItemColor: AppColorsLight.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ============================================
      // Floating Action Button Theme (플로팅 버튼)
      // ============================================
      /// FAB 스타일
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsLight.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ============================================
      // Chip Theme (칩)
      // ============================================
      /// 칩 위젯 스타일
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsLight.primaryLight,
        deleteIconColor: AppColorsLight.textPrimary,
        labelStyle: AppTextStyles.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ============================================
      // Dialog Theme (다이얼로그)
      // ============================================
      /// 다이얼로그 스타일
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsLight.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ============================================
      // Snackbar Theme (스낵바)
      // ============================================
      /// 스낵바 스타일
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ============================================
      // Progress Indicator Theme (로딩 인디케이터)
      // ============================================
      /// 프로그레스 인디케이터 색상
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsLight.primary,
        linearTrackColor: AppColorsLight.primaryLight,
      ),

      // ============================================
      // Tab Bar Theme (탭바)
      // ============================================
      /// 탭바 스타일
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColorsLight.primary,
        unselectedLabelColor: AppColorsLight.textSecondary,
        indicatorColor: AppColorsLight.primary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),

      // ============================================
      // Bottom Sheet Theme (바텀시트)
      // ============================================
      /// 바텀시트 스타일
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsLight.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }

  // ============================================
  // Dark Theme (어두운 테마)
  // ============================================
  /// 다크 테마 정의
  /// - Material 3 디자인 시스템 사용
  /// - 어두운 배경에 밝은 텍스트
  /// - AppColorsDark 및 AppTextStylesDark 색상 체계 사용
  static ThemeData get darkTheme {
    return ThemeData(
      // Material 3 활성화
      useMaterial3: true,
      brightness: Brightness.dark,

      // ============================================
      // Color Scheme (색상 체계)
      // ============================================
      /// Material 3 ColorScheme
      /// - 다크 테마용 밝은 색상 사용
      /// - 배경은 어둡게, 텍스트는 밝게
      colorScheme: const ColorScheme.dark(
        // Primary colors (주요 색상 - 밝게)
        primary: AppColorsDark.primary,
        onPrimary: AppColorsDark.background,
        primaryContainer: AppColorsDark.primaryDark,
        onPrimaryContainer: AppColorsDark.primaryLight,

        // Secondary colors (보조 색상 - 밝게)
        secondary: AppColorsDark.secondary,
        onSecondary: AppColorsDark.background,
        secondaryContainer: AppColorsDark.secondaryDark,
        onSecondaryContainer: AppColorsDark.secondaryLight,

        // Tertiary colors (3차 색상)
        tertiary: AppColorsDark.sky,

        // Error colors (에러 색상 - 밝게)
        error: AppColorsDark.error,
        onError: AppColorsDark.background,
        errorContainer: Color(0xFF93000A),

        // Surface colors (표면 색상 - 어둡게)
        surface: AppColorsDark.surface,
        onSurface: AppColorsDark.textPrimary,
        surfaceContainerHighest: AppColorsDark.cardBackground,

        // Outline & Shadow (테두리 및 그림자)
        outline: AppColorsDark.border,
        shadow: AppColorsDark.shadow,
      ),

      // ============================================
      // Scaffold (스캐폴드 배경)
      // ============================================
      /// 화면 전체 기본 배경색 (어두운 배경)
      scaffoldBackgroundColor: AppColorsDark.background,

      // ============================================
      // App Bar Theme (상단 앱바)
      // ============================================
      /// 앱바 스타일 설정 (다크 테마)
      /// - 어두운 배경
      /// - 밝은 텍스트
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColorsDark.textPrimary,
          size: 24,
        ),
      ),

      // ============================================
      // Card Theme (카드)
      // ============================================
      /// 카드 위젯 스타일 (다크)
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColorsDark.cardBackground,
        shadowColor: AppColorsDark.shadow,
      ),

      // ============================================
      // Text Theme (텍스트)
      // ============================================
      /// Material 3 Typography (다크 테마)
      /// AppTextStylesDark 사용
      textTheme: TextTheme(
        displayLarge: AppTextStyles.darkMode(AppTextStyles.displayLarge),
        displayMedium: AppTextStyles.darkMode(AppTextStyles.displayMedium),
        displaySmall: AppTextStyles.darkMode(AppTextStyles.displaySmall),
        headlineLarge: AppTextStyles.darkMode(AppTextStyles.headlineLarge),
        headlineMedium: AppTextStyles.darkMode(AppTextStyles.headlineMedium),
        headlineSmall: AppTextStyles.darkMode(AppTextStyles.headlineSmall),
        titleLarge: AppTextStyles.darkMode(AppTextStyles.titleLarge),
        titleMedium: AppTextStyles.darkMode(AppTextStyles.titleMedium),
        titleSmall: AppTextStyles.darkMode(AppTextStyles.titleSmall),
        bodyLarge: AppTextStyles.darkMode(AppTextStyles.bodyLarge),
        bodyMedium: AppTextStyles.darkMode(AppTextStyles.bodyMedium),
        bodySmall: AppTextStyles.darkMode(AppTextStyles.bodySmall),
        labelLarge: AppTextStyles.darkMode(AppTextStyles.labelLarge),
        labelMedium: AppTextStyles.darkMode(AppTextStyles.labelMedium),
        labelSmall: AppTextStyles.darkMode(AppTextStyles.labelSmall),
      ),

      // ============================================
      // Button Themes (버튼)
      // ============================================

      /// Elevated Button (채워진 버튼 - 다크)
      /// - 밝은 primary 색상 배경
      /// - 어두운 텍스트
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.background,
          textStyle: AppTextStyles.button,
        ),
      ),

      /// Outlined Button (테두리 버튼 - 다크)
      /// - 밝은 primary 색상 테두리 및 텍스트
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColorsDark.primary, width: 1.5),
          foregroundColor: AppColorsDark.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      /// Text Button (텍스트만 있는 버튼 - 다크)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: AppColorsDark.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      // ============================================
      // Input Decoration Theme (입력 필드)
      // ============================================
      /// TextField, TextFormField 스타일 (다크)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // 기본 테두리
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.border),
        ),

        // 활성화된 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.border),
        ),

        // 포커스된 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),

        // 에러 테두리
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.error),
        ),

        // 포커스된 에러 테두리
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.error, width: 2),
        ),

        // 텍스트 스타일
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textHint),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColorsDark.error),
      ),

      // ============================================
      // Icon Theme (아이콘)
      // ============================================
      /// 기본 아이콘 색상 (밝게)
      iconTheme: const IconThemeData(
        color: AppColorsDark.textPrimary,
        size: 24,
      ),

      // ============================================
      // Divider Theme (구분선)
      // ============================================
      /// 구분선 스타일 (어둡게)
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.divider,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Bottom Navigation Bar Theme (하단 네비게이션)
      // ============================================
      /// 하단 네비게이션 바 스타일 (다크)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surface,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ============================================
      // Floating Action Button Theme (플로팅 버튼)
      // ============================================
      /// FAB 스타일 (다크)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsDark.secondary,
        foregroundColor: AppColorsDark.background,
        elevation: 4,
      ),

      // ============================================
      // Chip Theme (칩)
      // ============================================
      /// 칩 위젯 스타일 (다크)
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.primaryDark,
        deleteIconColor: AppColorsDark.textPrimary,
        labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColorsDark.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ============================================
      // Dialog Theme (다이얼로그)
      // ============================================
      /// 다이얼로그 스타일 (다크)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColorsDark.textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textPrimary),
      ),

      // ============================================
      // Snackbar Theme (스낵바)
      // ============================================
      /// 스낵바 스타일 (다크)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsDark.surface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ============================================
      // Progress Indicator Theme (로딩 인디케이터)
      // ============================================
      /// 프로그레스 인디케이터 색상 (다크)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsDark.primary,
        linearTrackColor: AppColorsDark.primaryDark,
      ),

      // ============================================
      // Tab Bar Theme (탭바)
      // ============================================
      /// 탭바 스타일 (다크)
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColorsDark.primary,
        unselectedLabelColor: AppColorsDark.textSecondary,
        indicatorColor: AppColorsDark.primary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),

      // ============================================
      // Bottom Sheet Theme (바텀시트)
      // ============================================
      /// 바텀시트 스타일 (다크)
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsDark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}
