import 'package:flutter/material.dart';
import 'app_colors.dart';

// ============================================
// Light Theme Text Styles
// ============================================

/// 라이트 테마용 텍스트 스타일 정의
/// 다크한 텍스트 색상 사용 (밝은 배경에 적합)
class AppTextStylesLight {
  AppTextStylesLight._();

  // ============================================
  // Heading Styles - 큰 제목
  // ============================================

  /// Heading 1 - 가장 큰 제목 (페이지 타이틀)
  /// 32px, 굵게, 높이 1.25
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, // 진한 검정
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Heading 2 - 큰 제목 (섹션 타이틀)
  /// 28px, 굵게, 높이 1.29
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.29,
    letterSpacing: -0.25,
  );

  /// Heading 3 - 중간 제목 (서브섹션)
  /// 24px, 중간 굵기, 높이 1.33
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  /// Heading 4 - 작은 제목 (카드 타이틀)
  /// 20px, 중간 굵기, 높이 1.4
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // ============================================
  // Body Styles - 본문 텍스트
  // ============================================

  /// Body Large - 큰 본문 (중요한 내용)
  /// 16px, 보통, 높이 1.5
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  /// Body Medium - 중간 본문 (일반 내용)
  /// 14px, 보통, 높이 1.43
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Body Small - 작은 본문 (부가 설명)
  /// 12px, 보통, 높이 1.33
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // 중간 회색
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============================================
  // Label Styles - 레이블 텍스트
  // ============================================

  /// Label Large - 큰 레이블 (버튼, 탭)
  /// 14px, 중간 굵기, 높이 1.43
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Label Medium - 중간 레이블 (폼 필드)
  /// 12px, 중간 굵기, 높이 1.33
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0.5,
  );

  /// Label Small - 작은 레이블 (뱃지, 태그)
  /// 11px, 중간 굵기, 높이 1.45
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============================================
  // Caption Styles - 캡션 텍스트
  // ============================================

  /// Caption - 기본 캡션 (이미지 설명, 메타 정보)
  /// 12px, 보통, 높이 1.33
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Caption Small - 작은 캡션 (타임스탬프, 작은 정보)
  /// 10px, 보통, 높이 1.6
  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // ============================================
  // Special Styles - 특수 용도
  // ============================================

  /// Hint - 힌트 텍스트 (플레이스홀더)
  /// 14px, 보통, 높이 1.43
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint, // 연한 회색
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Error - 에러 메시지
  /// 12px, 보통, 높이 1.33
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error, // 빨강
    height: 1.33,
    letterSpacing: 0.4,
  );
}

// ============================================
// Dark Theme Text Styles
// ============================================

/// 다크 테마용 텍스트 스타일 정의
/// 밝은 텍스트 색상 사용 (어두운 배경에 적합)
class AppTextStylesDark {
  AppTextStylesDark._();

  // ============================================
  // Heading Styles - 큰 제목
  // ============================================

  /// Heading 1 - 가장 큰 제목 (페이지 타이틀)
  /// 32px, 굵게, 높이 1.25
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark, // 밝은 흰색
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Heading 2 - 큰 제목 (섹션 타이틀)
  /// 28px, 굵게, 높이 1.29
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.29,
    letterSpacing: -0.25,
  );

  /// Heading 3 - 중간 제목 (서브섹션)
  /// 24px, 중간 굵기, 높이 1.33
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.33,
    letterSpacing: 0,
  );

  /// Heading 4 - 작은 제목 (카드 타이틀)
  /// 20px, 중간 굵기, 높이 1.4
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.4,
    letterSpacing: 0,
  );

  // ============================================
  // Body Styles - 본문 텍스트
  // ============================================

  /// Body Large - 큰 본문 (중요한 내용)
  /// 16px, 보통, 높이 1.5
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
    height: 1.5,
    letterSpacing: 0.5,
  );

  /// Body Medium - 중간 본문 (일반 내용)
  /// 14px, 보통, 높이 1.43
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Body Small - 작은 본문 (부가 설명)
  /// 12px, 보통, 높이 1.33
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark, // 밝은 회색
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============================================
  // Label Styles - 레이블 텍스트
  // ============================================

  /// Label Large - 큰 레이블 (버튼, 탭)
  /// 14px, 중간 굵기, 높이 1.43
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Label Medium - 중간 레이블 (폼 필드)
  /// 12px, 중간 굵기, 높이 1.33
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.33,
    letterSpacing: 0.5,
  );

  /// Label Small - 작은 레이블 (뱃지, 태그)
  /// 11px, 중간 굵기, 높이 1.45
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============================================
  // Caption Styles - 캡션 텍스트
  // ============================================

  /// Caption - 기본 캡션 (이미지 설명, 메타 정보)
  /// 12px, 보통, 높이 1.33
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Caption Small - 작은 캡션 (타임스탬프, 작은 정보)
  /// 10px, 보통, 높이 1.6
  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // ============================================
  // Special Styles - 특수 용도
  // ============================================

  /// Hint - 힌트 텍스트 (플레이스홀더)
  /// 14px, 보통, 높이 1.43
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHintDark, // 어두운 회색
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Error - 에러 메시지
  /// 12px, 보통, 높이 1.33
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.errorLight, // 밝은 빨강
    height: 1.33,
    letterSpacing: 0.4,
  );
}

// ============================================
// Text Style Set - Theme Management
// ============================================

/// 테마별 텍스트 스타일 세트를 관리하는 클래스
/// 라이트/다크 테마에 따라 적절한 텍스트 스타일 제공
class AppTextStyleSet {
  // Heading Styles
  late final TextStyle heading1;
  late final TextStyle heading2;
  late final TextStyle heading3;
  late final TextStyle heading4;

  // Body Styles
  late final TextStyle bodyLarge;
  late final TextStyle bodyMedium;
  late final TextStyle bodySmall;

  // Label Styles
  late final TextStyle labelLarge;
  late final TextStyle labelMedium;
  late final TextStyle labelSmall;

  // Caption Styles
  late final TextStyle caption;
  late final TextStyle captionSmall;

  // Special Styles
  late final TextStyle hint;
  late final TextStyle error;

  /// 라이트 테마 텍스트 스타일 세트 생성
  AppTextStyleSet.light()
      : heading1 = AppTextStylesLight.heading1,
        heading2 = AppTextStylesLight.heading2,
        heading3 = AppTextStylesLight.heading3,
        heading4 = AppTextStylesLight.heading4,
        bodyLarge = AppTextStylesLight.bodyLarge,
        bodyMedium = AppTextStylesLight.bodyMedium,
        bodySmall = AppTextStylesLight.bodySmall,
        labelLarge = AppTextStylesLight.labelLarge,
        labelMedium = AppTextStylesLight.labelMedium,
        labelSmall = AppTextStylesLight.labelSmall,
        caption = AppTextStylesLight.caption,
        captionSmall = AppTextStylesLight.captionSmall,
        hint = AppTextStylesLight.hint,
        error = AppTextStylesLight.error;

  /// 다크 테마 텍스트 스타일 세트 생성
  AppTextStyleSet.dark()
      : heading1 = AppTextStylesDark.heading1,
        heading2 = AppTextStylesDark.heading2,
        heading3 = AppTextStylesDark.heading3,
        heading4 = AppTextStylesDark.heading4,
        bodyLarge = AppTextStylesDark.bodyLarge,
        bodyMedium = AppTextStylesDark.bodyMedium,
        bodySmall = AppTextStylesDark.bodySmall,
        labelLarge = AppTextStylesDark.labelLarge,
        labelMedium = AppTextStylesDark.labelMedium,
        labelSmall = AppTextStylesDark.labelSmall,
        caption = AppTextStylesDark.caption,
        captionSmall = AppTextStylesDark.captionSmall,
        hint = AppTextStylesDark.hint,
        error = AppTextStylesDark.error;
}

// ============================================
// Main Text Styles Class
// ============================================

/// 앱 전체에서 사용되는 텍스트 스타일 정의
/// 다크/라이트 테마 자동 감지 및 적용
class AppTextStyles {
  AppTextStyles._();

  // Base font family
  static const String fontFamily = 'Pretendard';

  // ============================================
  // Theme-aware Text Styles Access
  // ============================================

  /// 현재 테마에 맞는 텍스트 스타일 세트 반환
  ///
  /// 사용 예시:
  /// ```dart
  /// Text(
  ///   '제목',
  ///   style: AppTextStyles.of(context).heading1,
  /// )
  /// ```
  static AppTextStyleSet of(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark
        ? AppTextStyleSet.dark()
        : AppTextStyleSet.light();
  }

  // ============================================
  // Static Text Styles - Backward Compatibility
  // ============================================
  // 기존 코드와의 호환성을 위한 정적 필드
  // 새로운 코드에서는 AppTextStyles.of(context) 사용 권장

  // Display Styles - 대형 헤더 (Material 3 호환성 유지)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.16,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.22,
    letterSpacing: 0,
  );

  // Headline Styles - 헤드라인 (Material 3 호환성 유지)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.29,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  // Title Styles - 타이틀 (Material 3 호환성 유지)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.27,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body Styles - 본문
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label Styles - 레이블
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Caption & Overline - 캡션
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Button Styles - 버튼
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.43,
    letterSpacing: 1.25,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.5,
    letterSpacing: 1.25,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.33,
    letterSpacing: 1.25,
  );

  // Special Styles - 특수 스타일
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle rating = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ratingFilled,
    height: 1.43,
    letterSpacing: 0,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // ============================================
  // Responsive Text Styles
  // ============================================

  /// 화면 크기에 따라 적절한 헤드라인 스타일 반환
  static TextStyle getResponsiveHeadline(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return headlineSmall;
    } else if (width < 600) {
      return headlineMedium;
    } else {
      return headlineLarge;
    }
  }

  /// 화면 크기에 따라 적절한 타이틀 스타일 반환
  static TextStyle getResponsiveTitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return titleSmall;
    } else if (width < 600) {
      return titleMedium;
    } else {
      return titleLarge;
    }
  }

  /// 화면 크기에 따라 적절한 본문 스타일 반환
  static TextStyle getResponsiveBody(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return bodySmall;
    } else if (width < 600) {
      return bodyMedium;
    } else {
      return bodyLarge;
    }
  }

  /// 텍스트 스케일 팩터 적용
  static TextStyle withScale(TextStyle style, double scale) {
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scale,
    );
  }

  // ============================================
  // Dark Mode Variants
  // ============================================

  /// 다크 모드용 텍스트 색상 적용
  static TextStyle darkMode(TextStyle style) {
    Color newColor;
    if (style.color == AppColors.textPrimary) {
      newColor = AppColors.textPrimaryDark;
    } else if (style.color == AppColors.textSecondary) {
      newColor = AppColors.textSecondaryDark;
    } else if (style.color == AppColors.textHint) {
      newColor = AppColors.textHintDark;
    } else {
      newColor = style.color ?? AppColors.textPrimaryDark;
    }

    return style.copyWith(color: newColor);
  }

  // ============================================
  // Color Variants
  // ============================================

  /// 특정 색상 적용
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Primary 색상 적용
  static TextStyle withPrimary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// Secondary 색상 적용
  static TextStyle withSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.secondary);
  }

  /// Error 색상 적용
  static TextStyle withError(TextStyle style) {
    return style.copyWith(color: AppColors.error);
  }

  /// Success 색상 적용
  static TextStyle withSuccess(TextStyle style) {
    return style.copyWith(color: AppColors.success);
  }

  // ============================================
  // Weight Variants
  // ============================================

  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle regular(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w400);
  }

  static TextStyle light(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w300);
  }
}
