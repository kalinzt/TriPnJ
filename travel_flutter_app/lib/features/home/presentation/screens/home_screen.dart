import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// 홈 화면 - 여행 정보 메인 대시보드
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 테마 시스템 적용
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 플래너'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 80,
              color: colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '홈',
              style: textStyles.heading2,
            ),
            const SizedBox(height: 12),
            Text(
              '여행 정보를 한눈에 확인하세요',
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '곧 다양한 여행 정보와\n추천 여행지를 만나보실 수 있습니다!',
                textAlign: TextAlign.center,
                style: textStyles.bodySmall.copyWith(
                  color: colors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
