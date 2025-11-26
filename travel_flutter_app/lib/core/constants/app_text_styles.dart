import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전체에서 사용되는 텍스트 스타일 정의
/// 반응형 폰트 크기 적용
class AppTextStyles {
  AppTextStyles._();

  // Base font family
  static const String fontFamily = 'Pretendard';

  // ============================================
  // Display Styles - 대형 헤더
  // ============================================
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

  // ============================================
  // Headline Styles - 헤드라인
  // ============================================
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

  // ============================================
  // Title Styles - 타이틀
  // ============================================
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

  // ============================================
  // Body Styles - 본문
  // ============================================
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

  // ============================================
  // Label Styles - 레이블
  // ============================================
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

  // ============================================
  // Caption & Overline - 캡션
  // ============================================
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

  // ============================================
  // Button Styles - 버튼
  // ============================================
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

  // ============================================
  // Special Styles - 특수 스타일
  // ============================================
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
