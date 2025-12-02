import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place_category.dart';

/// 추천 필터 BottomSheet
class RecommendationFilterSheet extends StatefulWidget {
  final Set<String> selectedCategories;
  final double maxDistance;
  final double minRating;
  final int minReviewCount;

  const RecommendationFilterSheet({
    super.key,
    required this.selectedCategories,
    required this.maxDistance,
    required this.minRating,
    required this.minReviewCount,
  });

  @override
  State<RecommendationFilterSheet> createState() =>
      _RecommendationFilterSheetState();
}

class _RecommendationFilterSheetState extends State<RecommendationFilterSheet> {
  late Set<String> _selectedCategories;
  late double _maxDistance;
  late double _minRating;
  late int _minReviewCount;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.selectedCategories);
    _maxDistance = widget.maxDistance;
    _minRating = widget.minRating;
    _minReviewCount = widget.minReviewCount;
  }

  /// 초기화
  void _reset() {
    setState(() {
      _selectedCategories.clear();
      _maxDistance = 10.0;
      _minRating = 0.0;
      _minReviewCount = 0;
    });
  }

  /// 적용
  void _apply() {
    Navigator.pop(context, {
      'selectedCategories': _selectedCategories,
      'maxDistance': _maxDistance,
      'minRating': _minRating,
      'minReviewCount': _minReviewCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '필터',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text('초기화'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 필터 옵션들
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 필터
                  _buildCategoryFilter(),

                  const SizedBox(height: 24),

                  // 거리 필터
                  _buildDistanceFilter(),

                  const SizedBox(height: 24),

                  // 평점 필터
                  _buildRatingFilter(),

                  const SizedBox(height: 24),

                  // 리뷰 수 필터
                  _buildReviewCountFilter(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '적용',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터
  Widget _buildCategoryFilter() {
    final categories = [
      PlaceCategory.restaurant,
      PlaceCategory.cafe,
      PlaceCategory.culture,
      PlaceCategory.nature,
      PlaceCategory.attraction,
      PlaceCategory.shopping,
      PlaceCategory.activity,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected =
                _selectedCategories.contains(category.name);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(width: 4),
                  Text(category.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category.name);
                  } else {
                    _selectedCategories.remove(category.name);
                  }
                });
              },
              selectedColor: AppColors.primary,
              backgroundColor: category.color.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : category.color.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 거리 필터
  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최대 거리',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_maxDistance.toStringAsFixed(1)}km',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: _maxDistance,
          min: 0.5,
          max: 10.0,
          divisions: 19,
          label: '${_maxDistance.toStringAsFixed(1)}km',
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _maxDistance = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.5km',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '10.0km',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 평점 필터
  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최소 평점',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 4),
                Text(
                  _minRating > 0
                      ? _minRating.toStringAsFixed(1)
                      : '제한 없음',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Slider(
          value: _minRating,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: _minRating > 0
              ? _minRating.toStringAsFixed(1)
              : '제한 없음',
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '제한 없음',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '5.0',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 리뷰 수 필터
  Widget _buildReviewCountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최소 리뷰 수',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _minReviewCount > 0
                  ? '${_minReviewCount}개 이상'
                  : '제한 없음',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: _minReviewCount.toDouble(),
          min: 0,
          max: 500,
          divisions: 10,
          label: _minReviewCount > 0
              ? '${_minReviewCount}개'
              : '제한 없음',
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _minReviewCount = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '제한 없음',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '500개 이상',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
