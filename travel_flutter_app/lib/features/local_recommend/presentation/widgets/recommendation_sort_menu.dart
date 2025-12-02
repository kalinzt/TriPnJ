import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/sort_option.dart';

/// 추천 정렬 메뉴
class RecommendationSortMenu extends StatelessWidget {
  final SortOption currentSortOption;
  final ValueChanged<SortOption> onSortChanged;

  const RecommendationSortMenu({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      tooltip: '정렬',
      onSelected: onSortChanged,
      itemBuilder: (context) => SortOption.values.map((option) {
        final isSelected = option == currentSortOption;
        return PopupMenuItem<SortOption>(
          value: option,
          child: Row(
            children: [
              Icon(
                _getIconForOption(option),
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      option.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 정렬 옵션에 맞는 아이콘 반환
  IconData _getIconForOption(SortOption option) {
    switch (option) {
      case SortOption.recommendation:
        return Icons.stars;
      case SortOption.distance:
        return Icons.near_me;
      case SortOption.rating:
        return Icons.star;
      case SortOption.reviewCount:
        return Icons.rate_review;
    }
  }
}
