import 'package:flutter/material.dart';

/// 여행 앱에 어울리는 컬러 팔레트 정의
/// Primary: 청록색 계열 (바다, 하늘, 모험)
/// Secondary: 산호색 계열 (따뜻함, 열정, 여행의 설렘)
class AppColors {
  AppColors._();

  // ============================================
  // Primary Colors - 청록색 계열
  // ============================================
  static const Color primary = Color(0xFF00BCD4); // Cyan 500
  static const Color primaryLight = Color(0xFF62EFFF); // Cyan 200
  static const Color primaryDark = Color(0xFF008BA3); // Cyan 700
  static const Color primaryVariant = Color(0xFF26C6DA); // Cyan 400

  // ============================================
  // Secondary Colors - 산호색 계열
  // ============================================
  static const Color secondary = Color(0xFFFF7043); // Deep Orange 400
  static const Color secondaryLight = Color(0xFFFFAB91); // Deep Orange 200
  static const Color secondaryDark = Color(0xFFD84315); // Deep Orange 800
  static const Color secondaryVariant = Color(0xFFFF5722); // Deep Orange 500

  // ============================================
  // Background Colors
  // ============================================
  static const Color background = Color(0xFFF5F9FA); // Light cyan tinted
  static const Color backgroundDark = Color(0xFF121212); // Dark mode background
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark mode surface
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);

  // ============================================
  // Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Grey 300
  static const Color textSecondary = Color(0xFF616161); // Grey 700
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // Grey 400
  static const Color textHint = Color(0xFF9E9E9E); // Grey 500
  static const Color textHintDark = Color(0xFF757575); // Grey 600

  // ============================================
  // Status Colors
  // ============================================
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color successLight = Color(0xFF81C784); // Green 300
  static const Color error = Color(0xFFF44336); // Red 500
  static const Color errorLight = Color(0xFFE57373); // Red 300
  static const Color warning = Color(0xFFFFB300); // Amber 700
  static const Color warningLight = Color(0xFFFFD54F); // Amber 300
  static const Color info = Color(0xFF2196F3); // Blue 500
  static const Color infoLight = Color(0xFF64B5F6); // Blue 300

  // ============================================
  // Accent Colors - 여행 테마
  // ============================================
  static const Color ocean = Color(0xFF0277BD); // Light Blue 800
  static const Color sky = Color(0xFF03A9F4); // Light Blue 500
  static const Color sunset = Color(0xFFFF6F00); // Orange 900
  static const Color forest = Color(0xFF388E3C); // Green 700
  static const Color mountain = Color(0xFF5D4037); // Brown 700
  static const Color beach = Color(0xFFFDD835); // Yellow 600

  // ============================================
  // UI Element Colors
  // ============================================
  static const Color divider = Color(0xFFE0E0E0); // Grey 300
  static const Color dividerDark = Color(0xFF424242); // Grey 800
  static const Color border = Color(0xFFBDBDBD); // Grey 400
  static const Color borderDark = Color(0xFF616161); // Grey 700
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color shimmer = Color(0xFFE0E0E0);
  static const Color shimmerDark = Color(0xFF424242);

  // ============================================
  // Gradient Colors
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  // ============================================
  // Category Colors - 여행 카테고리별 색상
  // ============================================
  static const Color categoryNature = Color(0xFF66BB6A); // Green 400
  static const Color categoryCity = Color(0xFF42A5F5); // Blue 400
  static const Color categoryCulture = Color(0xFFAB47BC); // Purple 400
  static const Color categoryFood = Color(0xFFFF7043); // Deep Orange 400
  static const Color categoryAdventure = Color(0xFFFFCA28); // Amber 400
  static const Color categoryRelax = Color(0xFF26C6DA); // Cyan 400

  // ============================================
  // Rating Colors
  // ============================================
  static const Color ratingEmpty = Color(0xFFE0E0E0); // Grey 300
  static const Color ratingFilled = Color(0xFFFFB300); // Amber 700
  static const Color ratingHalf = Color(0xFFFFD54F); // Amber 300

  // ============================================
  // Helper Methods
  // ============================================

  /// 카테고리 타입에 따른 색상 반환
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
      case '자연':
        return categoryNature;
      case 'city':
      case '도시':
        return categoryCity;
      case 'culture':
      case '문화':
        return categoryCulture;
      case 'food':
      case '음식':
        return categoryFood;
      case 'adventure':
      case '모험':
        return categoryAdventure;
      case 'relax':
      case '휴양':
        return categoryRelax;
      default:
        return primary;
    }
  }

  /// 밝기에 따라 텍스트 색상 반환
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textPrimaryDark;
  }
}
