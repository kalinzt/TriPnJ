import 'package:flutter/material.dart';

/// 여행 앱 라이트 테마 컬러 팔레트
/// Primary: 청록색 계열 (바다, 하늘, 모험)
/// Secondary: 산호색 계열 (따뜻함, 열정, 여행의 설렘)
class AppColorsLight {
  AppColorsLight._();

  // ============================================
  // Primary Colors - 청록색 계열
  // ============================================
  /// 메인 브랜드 컬러 (청록색)
  static const Color primary = Color(0xFF00BCD4);

  /// 더 짙은 청록색 (버튼 hover, active 상태)
  static const Color primaryDark = Color(0xFF0097A7);

  /// 더 밝은 청록색 (배경, 하이라이트)
  static const Color primaryLight = Color(0xFFB2EBF2);

  // ============================================
  // Secondary Colors - 산호색 계열
  // ============================================
  /// 보조 브랜드 컬러 (산호색)
  static const Color secondary = Color(0xFFFF7043);

  /// 더 짙은 산호색 (강조, 중요 요소)
  static const Color secondaryDark = Color(0xFFE64A19);

  /// 더 밝은 산호색 (배경, 하이라이트)
  static const Color secondaryLight = Color(0xFFFFAB91);

  // ============================================
  // Background & Surface
  // ============================================
  /// 앱 전체 배경 색상 (밝은 회색)
  static const Color background = Color(0xFFFAFAFA);

  /// 카드/컨테이너 표면 색상 (순수 흰색)
  static const Color surface = Color(0xFFFFFFFF);

  /// 대체 표면 색상 (살짝 어두운 흰색)
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ============================================
  // Text Colors - 라이트 테마에서 텍스트는 어두운 색
  // ============================================
  /// 주요 텍스트 색상 (거의 검은색)
  static const Color textPrimary = Color(0xFF212121);

  /// 보조 텍스트 색상 (중간 회색)
  static const Color textSecondary = Color(0xFF757575);

  /// 3차 텍스트 색상 (밝은 회색)
  static const Color textTertiary = Color(0xFFBDBDBD);

  /// 힌트/플레이스홀더 텍스트 색상
  static const Color textHint = Color(0xFFCCCCCC);

  // ============================================
  // Status Colors
  // ============================================
  /// 에러 상태 (빨강)
  static const Color error = Color(0xFFE53935);

  /// 경고 상태 (주황)
  static const Color warning = Color(0xFFFFC107);

  /// 성공 상태 (초록)
  static const Color success = Color(0xFF4CAF50);

  /// 정보 상태 (파랑)
  static const Color info = Color(0xFF2196F3);

  // ============================================
  // Border & Divider
  // ============================================
  /// 테두리 색상 (밝은 경계선)
  static const Color border = Color(0xFFE0E0E0);

  /// 구분선 색상 (밝은 구분선)
  static const Color divider = Color(0xFFEEEEEE);

  // ============================================
  // Card & Container Background
  // ============================================
  /// 카드 배경 색상 (흰색)
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// 컨테이너 배경 색상 (밝은 회색)
  static const Color containerBackground = Color(0xFFF5F5F5);

  // ============================================
  // Status Badge Colors - 여행 계획 상태
  // ============================================
  /// 예정됨 상태 (회색)
  static const Color statusPlanned = Color(0xFFBDBDBD);

  /// 진행중 상태 (파랑)
  static const Color statusOngoing = Color(0xFF2196F3);

  /// 완료 상태 (초록)
  static const Color statusCompleted = Color(0xFF4CAF50);

  // ============================================
  // Category Colors - 여행 카테고리별 색상
  // ============================================
  /// 자연 카테고리 (녹색)
  static const Color categoryNature = Color(0xFF66BB6A);

  /// 도시 카테고리 (파랑)
  static const Color categoryCity = Color(0xFF42A5F5);

  /// 문화 카테고리 (보라)
  static const Color categoryCulture = Color(0xFFAB47BC);

  /// 음식 카테고리 (산호색)
  static const Color categoryFood = Color(0xFFFF7043);

  /// 모험 카테고리 (호박색)
  static const Color categoryAdventure = Color(0xFFFFCA28);

  /// 휴양 카테고리 (청록색)
  static const Color categoryRelax = Color(0xFF26C6DA);

  /// 액티비티 카테고리 (호박색)
  static const Color categoryActivity = Color(0xFFFFCA28);

  /// 리조트 카테고리 (청록색)
  static const Color categoryResort = Color(0xFF26C6DA);

  /// 쇼핑 카테고리 (빨강)
  static const Color categoryShopping = Color(0xFFEF5350);

  /// 명소 카테고리 (파랑)
  static const Color categoryAttraction = Color(0xFF42A5F5);

  /// 음식점 카테고리 (산호색)
  static const Color categoryRestaurant = Color(0xFFFF7043);

  /// 카페 카테고리 (갈색)
  static const Color categoryCafe = Color(0xFF8D6E63);

  /// 숙박 카테고리 (진보라)
  static const Color categoryAccommodation = Color(0xFF7E57C2);

  /// 야간 카테고리 (분홍)
  static const Color categoryNightlife = Color(0xFFEC407A);

  // ============================================
  // Rating Colors
  // ============================================
  /// 비어있는 별 (회색)
  static const Color ratingEmpty = Color(0xFFE0E0E0);

  /// 채워진 별 (호박색)
  static const Color ratingFilled = Color(0xFFFFB300);

  /// 반 채워진 별 (밝은 호박색)
  static const Color ratingHalf = Color(0xFFFFD54F);

  // ============================================
  // Accent Colors - 여행 테마
  // ============================================
  /// 바다 색상
  static const Color ocean = Color(0xFF0277BD);

  /// 하늘 색상
  static const Color sky = Color(0xFF03A9F4);

  /// 석양 색상
  static const Color sunset = Color(0xFFFF6F00);

  /// 숲 색상
  static const Color forest = Color(0xFF388E3C);

  /// 산 색상
  static const Color mountain = Color(0xFF5D4037);

  /// 해변 색상
  static const Color beach = Color(0xFFFDD835);

  // ============================================
  // UI Element Colors
  // ============================================
  /// 그림자 색상 (10% 검은색)
  static const Color shadow = Color(0x1A000000);

  /// 오버레이 색상 (50% 검은색)
  static const Color overlay = Color(0x80000000);

  /// 시머 효과 색상
  static const Color shimmer = Color(0xFFE0E0E0);
}

/// 여행 앱 다크 테마 컬러 팔레트
/// Primary: 밝은 청록색 계열 (다크 배경에서 눈에 띄게)
/// Secondary: 밝은 산호색 계열 (따뜻함, 열정)
class AppColorsDark {
  AppColorsDark._();

  // ============================================
  // Primary Colors - 밝은 청록색 계열
  // ============================================
  /// 메인 브랜드 컬러 (더 밝은 청록색, 다크 배경에서 눈에 띄게)
  static const Color primary = Color(0xFF26C6DA);

  /// 조금 더 어두운 청록색 (버튼 hover, active 상태)
  static const Color primaryDark = Color(0xFF00ACC1);

  /// 밝은 청록색 (배경, 하이라이트)
  static const Color primaryLight = Color(0xFF80DEEA);

  // ============================================
  // Secondary Colors - 밝은 산호색 계열
  // ============================================
  /// 보조 브랜드 컬러 (더 밝은 산호색)
  static const Color secondary = Color(0xFFFF8A65);

  /// 산호색 (강조, 중요 요소)
  static const Color secondaryDark = Color(0xFFFF7043);

  /// 밝은 산호색 (배경, 하이라이트)
  static const Color secondaryLight = Color(0xFFFFAB91);

  // ============================================
  // Background & Surface
  // ============================================
  /// 앱 전체 배경 색상 (다크 배경)
  static const Color background = Color(0xFF121212);

  /// 카드/컨테이너 표면 색상 (다크 서피스)
  static const Color surface = Color(0xFF1E1E1E);

  /// 대체 표면 색상 (더 밝은 다크 서피스)
  static const Color surfaceVariant = Color(0xFF272727);

  // ============================================
  // Text Colors - 다크 테마에서 텍스트는 밝은 색
  // ============================================
  /// 주요 텍스트 색상 (순수 흰색)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// 보조 텍스트 색상 (밝은 회색)
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// 3차 텍스트 색상 (중간 회색)
  static const Color textTertiary = Color(0xFF757575);

  /// 힌트/플레이스홀더 텍스트 색상
  static const Color textHint = Color(0xFF616161);

  // ============================================
  // Status Colors
  // ============================================
  /// 에러 상태 (빨강, 유지)
  static const Color error = Color(0xFFE53935);

  /// 경고 상태 (주황, 유지)
  static const Color warning = Color(0xFFFFC107);

  /// 성공 상태 (밝은 초록)
  static const Color success = Color(0xFF66BB6A);

  /// 정보 상태 (밝은 파랑)
  static const Color info = Color(0xFF42A5F5);

  // ============================================
  // Border & Divider
  // ============================================
  /// 테두리 색상 (어두운 경계선)
  static const Color border = Color(0xFF424242);

  /// 구분선 색상 (어두운 구분선)
  static const Color divider = Color(0xFF303030);

  // ============================================
  // Card & Container Background
  // ============================================
  /// 카드 배경 색상 (다크 카드)
  static const Color cardBackground = Color(0xFF1E1E1E);

  /// 컨테이너 배경 색상 (다크 컨테이너)
  static const Color containerBackground = Color(0xFF272727);

  // ============================================
  // Status Badge Colors - 여행 계획 상태
  // ============================================
  /// 예정됨 상태 (회색)
  static const Color statusPlanned = Color(0xFF757575);

  /// 진행중 상태 (밝은 파랑)
  static const Color statusOngoing = Color(0xFF42A5F5);

  /// 완료 상태 (밝은 초록)
  static const Color statusCompleted = Color(0xFF66BB6A);

  // ============================================
  // Category Colors - 여행 카테고리별 색상 (밝게 조정)
  // ============================================
  /// 자연 카테고리 (밝은 녹색)
  static const Color categoryNature = Color(0xFF66BB6A);

  /// 도시 카테고리 (밝은 파랑)
  static const Color categoryCity = Color(0xFF42A5F5);

  /// 문화 카테고리 (밝은 보라)
  static const Color categoryCulture = Color(0xFFBA68C8);

  /// 음식 카테고리 (밝은 산호색)
  static const Color categoryFood = Color(0xFFFF8A65);

  /// 모험 카테고리 (밝은 호박색)
  static const Color categoryAdventure = Color(0xFFFFD54F);

  /// 휴양 카테고리 (밝은 청록색)
  static const Color categoryRelax = Color(0xFF4DD0E1);

  /// 액티비티 카테고리 (밝은 호박색)
  static const Color categoryActivity = Color(0xFFFFD54F);

  /// 리조트 카테고리 (밝은 청록색)
  static const Color categoryResort = Color(0xFF4DD0E1);

  /// 쇼핑 카테고리 (밝은 빨강)
  static const Color categoryShopping = Color(0xFFEF5350);

  /// 명소 카테고리 (밝은 파랑)
  static const Color categoryAttraction = Color(0xFF42A5F5);

  /// 음식점 카테고리 (밝은 산호색)
  static const Color categoryRestaurant = Color(0xFFFF8A65);

  /// 카페 카테고리 (밝은 갈색)
  static const Color categoryCafe = Color(0xFFA1887F);

  /// 숙박 카테고리 (밝은 진보라)
  static const Color categoryAccommodation = Color(0xFF9575CD);

  /// 야간 카테고리 (밝은 분홍)
  static const Color categoryNightlife = Color(0xFFF06292);

  // ============================================
  // Rating Colors
  // ============================================
  /// 비어있는 별 (어두운 회색)
  static const Color ratingEmpty = Color(0xFF424242);

  /// 채워진 별 (호박색, 유지)
  static const Color ratingFilled = Color(0xFFFFB300);

  /// 반 채워진 별 (밝은 호박색)
  static const Color ratingHalf = Color(0xFFFFD54F);

  // ============================================
  // Accent Colors - 여행 테마 (밝게 조정)
  // ============================================
  /// 바다 색상
  static const Color ocean = Color(0xFF039BE5);

  /// 하늘 색상
  static const Color sky = Color(0xFF29B6F6);

  /// 석양 색상
  static const Color sunset = Color(0xFFFF8F00);

  /// 숲 색상
  static const Color forest = Color(0xFF66BB6A);

  /// 산 색상
  static const Color mountain = Color(0xFF8D6E63);

  /// 해변 색상
  static const Color beach = Color(0xFFFFEE58);

  // ============================================
  // UI Element Colors
  // ============================================
  /// 그림자 색상 (20% 검은색, 다크에서 더 진하게)
  static const Color shadow = Color(0x33000000);

  /// 오버레이 색상 (60% 검은색)
  static const Color overlay = Color(0x99000000);

  /// 시머 효과 색상
  static const Color shimmer = Color(0xFF424242);
}

/// 테마별 컬러셋
/// BuildContext를 통해 현재 디바이스 테마를 감지하고 적절한 색상 반환
class _AppColorSet {
  /// Primary 색상
  late final Color primary;

  /// Primary Dark 색상
  late final Color primaryDark;

  /// Primary Light 색상
  late final Color primaryLight;

  /// Secondary 색상
  late final Color secondary;

  /// Secondary Dark 색상
  late final Color secondaryDark;

  /// Secondary Light 색상
  late final Color secondaryLight;

  /// 배경 색상
  late final Color background;

  /// 표면 색상
  late final Color surface;

  /// 대체 표면 색상
  late final Color surfaceVariant;

  /// 주요 텍스트 색상
  late final Color textPrimary;

  /// 보조 텍스트 색상
  late final Color textSecondary;

  /// 3차 텍스트 색상
  late final Color textTertiary;

  /// 힌트 텍스트 색상
  late final Color textHint;

  /// 에러 색상
  late final Color error;

  /// 경고 색상
  late final Color warning;

  /// 성공 색상
  late final Color success;

  /// 정보 색상
  late final Color info;

  /// 테두리 색상
  late final Color border;

  /// 구분선 색상
  late final Color divider;

  /// 카드 배경 색상
  late final Color cardBackground;

  /// 컨테이너 배경 색상
  late final Color containerBackground;

  /// 예정됨 상태 색상
  late final Color statusPlanned;

  /// 진행중 상태 색상
  late final Color statusOngoing;

  /// 완료 상태 색상
  late final Color statusCompleted;

  /// 자연 카테고리 색상
  late final Color categoryNature;

  /// 도시 카테고리 색상
  late final Color categoryCity;

  /// 문화 카테고리 색상
  late final Color categoryCulture;

  /// 음식 카테고리 색상
  late final Color categoryFood;

  /// 모험 카테고리 색상
  late final Color categoryAdventure;

  /// 휴양 카테고리 색상
  late final Color categoryRelax;

  /// 액티비티 카테고리 색상
  late final Color categoryActivity;

  /// 리조트 카테고리 색상
  late final Color categoryResort;

  /// 쇼핑 카테고리 색상
  late final Color categoryShopping;

  /// 명소 카테고리 색상
  late final Color categoryAttraction;

  /// 음식점 카테고리 색상
  late final Color categoryRestaurant;

  /// 카페 카테고리 색상
  late final Color categoryCafe;

  /// 숙박 카테고리 색상
  late final Color categoryAccommodation;

  /// 야간 카테고리 색상
  late final Color categoryNightlife;

  /// 비어있는 별 색상
  late final Color ratingEmpty;

  /// 채워진 별 색상
  late final Color ratingFilled;

  /// 반 채워진 별 색상
  late final Color ratingHalf;

  /// 바다 색상
  late final Color ocean;

  /// 하늘 색상
  late final Color sky;

  /// 석양 색상
  late final Color sunset;

  /// 숲 색상
  late final Color forest;

  /// 산 색상
  late final Color mountain;

  /// 해변 색상
  late final Color beach;

  /// 그림자 색상
  late final Color shadow;

  /// 오버레이 색상
  late final Color overlay;

  /// 시머 효과 색상
  late final Color shimmer;

  /// 라이트 테마 컬러셋 생성
  _AppColorSet.light()
      : primary = AppColorsLight.primary,
        primaryDark = AppColorsLight.primaryDark,
        primaryLight = AppColorsLight.primaryLight,
        secondary = AppColorsLight.secondary,
        secondaryDark = AppColorsLight.secondaryDark,
        secondaryLight = AppColorsLight.secondaryLight,
        background = AppColorsLight.background,
        surface = AppColorsLight.surface,
        surfaceVariant = AppColorsLight.surfaceVariant,
        textPrimary = AppColorsLight.textPrimary,
        textSecondary = AppColorsLight.textSecondary,
        textTertiary = AppColorsLight.textTertiary,
        textHint = AppColorsLight.textHint,
        error = AppColorsLight.error,
        warning = AppColorsLight.warning,
        success = AppColorsLight.success,
        info = AppColorsLight.info,
        border = AppColorsLight.border,
        divider = AppColorsLight.divider,
        cardBackground = AppColorsLight.cardBackground,
        containerBackground = AppColorsLight.containerBackground,
        statusPlanned = AppColorsLight.statusPlanned,
        statusOngoing = AppColorsLight.statusOngoing,
        statusCompleted = AppColorsLight.statusCompleted,
        categoryNature = AppColorsLight.categoryNature,
        categoryCity = AppColorsLight.categoryCity,
        categoryCulture = AppColorsLight.categoryCulture,
        categoryFood = AppColorsLight.categoryFood,
        categoryAdventure = AppColorsLight.categoryAdventure,
        categoryRelax = AppColorsLight.categoryRelax,
        categoryActivity = AppColorsLight.categoryActivity,
        categoryResort = AppColorsLight.categoryResort,
        categoryShopping = AppColorsLight.categoryShopping,
        categoryAttraction = AppColorsLight.categoryAttraction,
        categoryRestaurant = AppColorsLight.categoryRestaurant,
        categoryCafe = AppColorsLight.categoryCafe,
        categoryAccommodation = AppColorsLight.categoryAccommodation,
        categoryNightlife = AppColorsLight.categoryNightlife,
        ratingEmpty = AppColorsLight.ratingEmpty,
        ratingFilled = AppColorsLight.ratingFilled,
        ratingHalf = AppColorsLight.ratingHalf,
        ocean = AppColorsLight.ocean,
        sky = AppColorsLight.sky,
        sunset = AppColorsLight.sunset,
        forest = AppColorsLight.forest,
        mountain = AppColorsLight.mountain,
        beach = AppColorsLight.beach,
        shadow = AppColorsLight.shadow,
        overlay = AppColorsLight.overlay,
        shimmer = AppColorsLight.shimmer;

  /// 다크 테마 컬러셋 생성
  _AppColorSet.dark()
      : primary = AppColorsDark.primary,
        primaryDark = AppColorsDark.primaryDark,
        primaryLight = AppColorsDark.primaryLight,
        secondary = AppColorsDark.secondary,
        secondaryDark = AppColorsDark.secondaryDark,
        secondaryLight = AppColorsDark.secondaryLight,
        background = AppColorsDark.background,
        surface = AppColorsDark.surface,
        surfaceVariant = AppColorsDark.surfaceVariant,
        textPrimary = AppColorsDark.textPrimary,
        textSecondary = AppColorsDark.textSecondary,
        textTertiary = AppColorsDark.textTertiary,
        textHint = AppColorsDark.textHint,
        error = AppColorsDark.error,
        warning = AppColorsDark.warning,
        success = AppColorsDark.success,
        info = AppColorsDark.info,
        border = AppColorsDark.border,
        divider = AppColorsDark.divider,
        cardBackground = AppColorsDark.cardBackground,
        containerBackground = AppColorsDark.containerBackground,
        statusPlanned = AppColorsDark.statusPlanned,
        statusOngoing = AppColorsDark.statusOngoing,
        statusCompleted = AppColorsDark.statusCompleted,
        categoryNature = AppColorsDark.categoryNature,
        categoryCity = AppColorsDark.categoryCity,
        categoryCulture = AppColorsDark.categoryCulture,
        categoryFood = AppColorsDark.categoryFood,
        categoryAdventure = AppColorsDark.categoryAdventure,
        categoryRelax = AppColorsDark.categoryRelax,
        categoryActivity = AppColorsDark.categoryActivity,
        categoryResort = AppColorsDark.categoryResort,
        categoryShopping = AppColorsDark.categoryShopping,
        categoryAttraction = AppColorsDark.categoryAttraction,
        categoryRestaurant = AppColorsDark.categoryRestaurant,
        categoryCafe = AppColorsDark.categoryCafe,
        categoryAccommodation = AppColorsDark.categoryAccommodation,
        categoryNightlife = AppColorsDark.categoryNightlife,
        ratingEmpty = AppColorsDark.ratingEmpty,
        ratingFilled = AppColorsDark.ratingFilled,
        ratingHalf = AppColorsDark.ratingHalf,
        ocean = AppColorsDark.ocean,
        sky = AppColorsDark.sky,
        sunset = AppColorsDark.sunset,
        forest = AppColorsDark.forest,
        mountain = AppColorsDark.mountain,
        beach = AppColorsDark.beach,
        shadow = AppColorsDark.shadow,
        overlay = AppColorsDark.overlay,
        shimmer = AppColorsDark.shimmer;
}

/// 앱 전체 컬러 시스템
/// 디바이스 테마(다크/라이트)를 자동 감지하여 적절한 색상 제공
class AppColors {
  AppColors._();

  // ============================================
  // Static Colors - 기존 코드 호환성을 위한 기본 색상 (라이트 테마 기본값)
  // ============================================

  /// Primary 색상 (라이트 테마 기본값)
  static const Color primary = AppColorsLight.primary;

  /// Primary Dark 색상
  static const Color primaryDark = AppColorsLight.primaryDark;

  /// Primary Light 색상
  static const Color primaryLight = AppColorsLight.primaryLight;

  /// Secondary 색상
  static const Color secondary = AppColorsLight.secondary;

  /// Secondary Dark 색상
  static const Color secondaryDark = AppColorsLight.secondaryDark;

  /// Secondary Light 색상
  static const Color secondaryLight = AppColorsLight.secondaryLight;

  /// 배경 색상
  static const Color background = AppColorsLight.background;

  /// 표면 색상
  static const Color surface = AppColorsLight.surface;

  /// 대체 표면 색상
  static const Color surfaceVariant = AppColorsLight.surfaceVariant;

  /// 주요 텍스트 색상
  static const Color textPrimary = AppColorsLight.textPrimary;

  /// 보조 텍스트 색상
  static const Color textSecondary = AppColorsLight.textSecondary;

  /// 3차 텍스트 색상
  static const Color textTertiary = AppColorsLight.textTertiary;

  /// 힌트 텍스트 색상
  static const Color textHint = AppColorsLight.textHint;

  /// 에러 색상
  static const Color error = AppColorsLight.error;

  /// 경고 색상
  static const Color warning = AppColorsLight.warning;

  /// 성공 색상
  static const Color success = AppColorsLight.success;

  /// 정보 색상
  static const Color info = AppColorsLight.info;

  /// 테두리 색상
  static const Color border = AppColorsLight.border;

  /// 구분선 색상
  static const Color divider = AppColorsLight.divider;

  /// 카드 배경 색상
  static const Color cardBackground = AppColorsLight.cardBackground;

  /// 컨테이너 배경 색상
  static const Color containerBackground = AppColorsLight.containerBackground;

  /// 예정됨 상태 색상
  static const Color statusPlanned = AppColorsLight.statusPlanned;

  /// 진행중 상태 색상
  static const Color statusOngoing = AppColorsLight.statusOngoing;

  /// 완료 상태 색상
  static const Color statusCompleted = AppColorsLight.statusCompleted;

  /// 자연 카테고리 색상
  static const Color categoryNature = AppColorsLight.categoryNature;

  /// 도시 카테고리 색상
  static const Color categoryCity = AppColorsLight.categoryCity;

  /// 문화 카테고리 색상
  static const Color categoryCulture = AppColorsLight.categoryCulture;

  /// 음식 카테고리 색상
  static const Color categoryFood = AppColorsLight.categoryFood;

  /// 모험 카테고리 색상
  static const Color categoryAdventure = AppColorsLight.categoryAdventure;

  /// 휴양 카테고리 색상
  static const Color categoryRelax = AppColorsLight.categoryRelax;

  /// 액티비티 카테고리 색상
  static const Color categoryActivity = AppColorsLight.categoryActivity;

  /// 리조트 카테고리 색상
  static const Color categoryResort = AppColorsLight.categoryResort;

  /// 쇼핑 카테고리 색상
  static const Color categoryShopping = AppColorsLight.categoryShopping;

  /// 명소 카테고리 색상
  static const Color categoryAttraction = AppColorsLight.categoryAttraction;

  /// 음식점 카테고리 색상
  static const Color categoryRestaurant = AppColorsLight.categoryRestaurant;

  /// 카페 카테고리 색상
  static const Color categoryCafe = AppColorsLight.categoryCafe;

  /// 숙박 카테고리 색상
  static const Color categoryAccommodation = AppColorsLight.categoryAccommodation;

  /// 야간 카테고리 색상
  static const Color categoryNightlife = AppColorsLight.categoryNightlife;

  /// 비어있는 별 색상
  static const Color ratingEmpty = AppColorsLight.ratingEmpty;

  /// 채워진 별 색상
  static const Color ratingFilled = AppColorsLight.ratingFilled;

  /// 반 채워진 별 색상
  static const Color ratingHalf = AppColorsLight.ratingHalf;

  /// 바다 색상
  static const Color ocean = AppColorsLight.ocean;

  /// 하늘 색상
  static const Color sky = AppColorsLight.sky;

  /// 석양 색상
  static const Color sunset = AppColorsLight.sunset;

  /// 숲 색상
  static const Color forest = AppColorsLight.forest;

  /// 산 색상
  static const Color mountain = AppColorsLight.mountain;

  /// 해변 색상
  static const Color beach = AppColorsLight.beach;

  /// 그림자 색상
  static const Color shadow = AppColorsLight.shadow;

  /// 오버레이 색상
  static const Color overlay = AppColorsLight.overlay;

  /// 시머 효과 색상
  static const Color shimmer = AppColorsLight.shimmer;

  // ============================================
  // Dark Mode Colors - 다크 모드 전용 색상 (기존 코드 호환성)
  // ============================================

  /// 다크 모드 배경 색상
  static const Color backgroundDark = AppColorsDark.background;

  /// 다크 모드 표면 색상
  static const Color surfaceDark = AppColorsDark.surface;

  /// 다크 모드 카드 배경 색상
  static const Color cardBackgroundDark = AppColorsDark.cardBackground;

  /// 다크 모드 주요 텍스트 색상
  static const Color textPrimaryDark = AppColorsDark.textPrimary;

  /// 다크 모드 보조 텍스트 색상
  static const Color textSecondaryDark = AppColorsDark.textSecondary;

  /// 다크 모드 힌트 텍스트 색상
  static const Color textHintDark = AppColorsDark.textHint;

  /// 다크 모드 테두리 색상
  static const Color borderDark = AppColorsDark.border;

  /// 다크 모드 구분선 색상
  static const Color dividerDark = AppColorsDark.divider;

  /// 밝은 에러 색상 (다크 모드용)
  static const Color errorLight = Color(0xFFE57373);

  /// 밝은 성공 색상 (다크 모드용)
  static const Color successLight = AppColorsDark.success;

  /// BuildContext를 통해 현재 테마에 맞는 컬러셋 반환
  ///
  /// 사용 예:
  /// ```dart
  /// final colors = AppColors.of(context);
  /// Text('Hello', style: TextStyle(color: colors.textPrimary));
  /// Container(color: colors.background);
  /// ```
  static _AppColorSet of(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    if (brightness == Brightness.dark) {
      return _AppColorSet.dark();
    } else {
      return _AppColorSet.light();
    }
  }

  // ============================================
  // Gradient Colors (테마 독립적)
  // ============================================

  /// Primary 그라디언트 (라이트 테마)
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsLight.primary, AppColorsLight.primaryDark],
  );

  /// Primary 그라디언트 (다크 테마)
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsDark.primary, AppColorsDark.primaryDark],
  );

  /// Secondary 그라디언트 (라이트 테마)
  static const LinearGradient secondaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsLight.secondary, AppColorsLight.secondaryDark],
  );

  /// Secondary 그라디언트 (다크 테마)
  static const LinearGradient secondaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsDark.secondary, AppColorsDark.secondaryDark],
  );

  /// 석양 그라디언트
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
  );

  /// 바다 그라디언트
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  // ============================================
  // Helper Methods
  // ============================================

  /// 카테고리 타입에 따른 색상 반환
  ///
  /// [category]: 카테고리 이름 (영문 또는 한글)
  /// [isDark]: 다크 테마 여부
  static Color getCategoryColor(String category, {bool isDark = false}) {
    switch (category.toLowerCase()) {
      case 'nature':
      case '자연':
        return isDark ? AppColorsDark.categoryNature : AppColorsLight.categoryNature;
      case 'city':
      case '도시':
        return isDark ? AppColorsDark.categoryCity : AppColorsLight.categoryCity;
      case 'culture':
      case '문화':
        return isDark ? AppColorsDark.categoryCulture : AppColorsLight.categoryCulture;
      case 'food':
      case '음식':
        return isDark ? AppColorsDark.categoryFood : AppColorsLight.categoryFood;
      case 'adventure':
      case '모험':
        return isDark ? AppColorsDark.categoryAdventure : AppColorsLight.categoryAdventure;
      case 'relax':
      case '휴양':
        return isDark ? AppColorsDark.categoryRelax : AppColorsLight.categoryRelax;
      case 'activity':
      case '액티비티':
        return isDark ? AppColorsDark.categoryActivity : AppColorsLight.categoryActivity;
      case 'resort':
      case '리조트':
        return isDark ? AppColorsDark.categoryResort : AppColorsLight.categoryResort;
      case 'shopping':
      case '쇼핑':
        return isDark ? AppColorsDark.categoryShopping : AppColorsLight.categoryShopping;
      case 'attraction':
      case '명소':
        return isDark ? AppColorsDark.categoryAttraction : AppColorsLight.categoryAttraction;
      case 'restaurant':
      case '음식점':
        return isDark ? AppColorsDark.categoryRestaurant : AppColorsLight.categoryRestaurant;
      case 'cafe':
      case '카페':
        return isDark ? AppColorsDark.categoryCafe : AppColorsLight.categoryCafe;
      case 'accommodation':
      case '숙박':
        return isDark ? AppColorsDark.categoryAccommodation : AppColorsLight.categoryAccommodation;
      case 'nightlife':
      case '야간':
        return isDark ? AppColorsDark.categoryNightlife : AppColorsLight.categoryNightlife;
      default:
        return isDark ? AppColorsDark.primary : AppColorsLight.primary;
    }
  }

  /// BuildContext를 통해 카테고리 색상 반환 (테마 자동 감지)
  static Color getCategoryColorWithContext(
    BuildContext context,
    String category,
  ) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return getCategoryColor(category, isDark: brightness == Brightness.dark);
  }

  /// 배경색에 따라 적절한 텍스트 색상 반환
  ///
  /// [backgroundColor]: 배경 색상
  /// 밝은 배경이면 어두운 텍스트, 어두운 배경이면 밝은 텍스트 반환
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5
        ? AppColorsLight.textPrimary
        : AppColorsDark.textPrimary;
  }

  /// BuildContext를 통해 Primary 그라디언트 반환 (테마 자동 감지)
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark
        ? primaryGradientDark
        : primaryGradientLight;
  }

  /// BuildContext를 통해 Secondary 그라디언트 반환 (테마 자동 감지)
  static LinearGradient getSecondaryGradient(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark
        ? secondaryGradientDark
        : secondaryGradientLight;
  }
}
