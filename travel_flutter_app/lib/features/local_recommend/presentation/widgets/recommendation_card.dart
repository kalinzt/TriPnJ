import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../../explore/data/providers/places_provider.dart';
import '../../../explore/presentation/screens/place_detail_screen.dart';
import '../../data/models/preference_action.dart';
import '../../data/providers/user_preference_provider.dart';

/// 추천 장소 카드 위젯
///
/// 일반 PlaceCard와 유사하지만 추천 점수와 사용자 피드백 UI가 추가됨
class RecommendationCard extends ConsumerStatefulWidget {
  final Place place;
  final double? score; // 추천 점수 (0.0 ~ 1.0)

  const RecommendationCard({
    super.key,
    required this.place,
    this.score,
  });

  @override
  ConsumerState<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<RecommendationCard> {
  bool _isLiked = false;
  bool _isRejected = false;

  @override
  void initState() {
    super.initState();
    _checkPreference();
  }

  /// 사용자 선호도 확인
  void _checkPreference() {
    final repository = ref.read(userPreferenceRepositoryProvider);
    _isLiked = repository.hasVisited(widget.place.id);
    _isRejected = repository.hasRejected(widget.place.id);
  }

  /// 좋아요 토글
  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _isRejected = false; // 좋아요 누르면 거절 취소
      }
    });

    final repository = ref.read(userPreferenceRepositoryProvider);

    if (_isLiked) {
      await repository.updatePreferenceFromAction(
        place: widget.place,
        action: PreferenceAction.like,
      );
    }

    // 상태 동기화
    ref.read(userPreferenceProvider.notifier).syncWithRepository();
  }

  /// 거절 토글
  Future<void> _toggleReject() async {
    setState(() {
      _isRejected = !_isRejected;
      if (_isRejected) {
        _isLiked = false; // 거절 누르면 좋아요 취소
      }
    });

    final repository = ref.read(userPreferenceRepositoryProvider);

    if (_isRejected) {
      await repository.updatePreferenceFromAction(
        place: widget.place,
        action: PreferenceAction.reject,
      );
    }

    // 상태 동기화
    ref.read(userPreferenceProvider.notifier).syncWithRepository();
  }

  /// 장소 상세 화면으로 이동
  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place: widget.place),
      ),
    );
  }

  /// 사진 URL 가져오기
  String _getPhotoUrl() {
    if (widget.place.photos.isEmpty) return '';

    final repository = ref.read(placesRepositoryProvider);
    return repository.getPhotoUrl(
      photoReference: widget.place.photos.first,
      maxWidth: 800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = getCategoryFromPlaceTypes(widget.place.types);
    final photoUrl = _getPhotoUrl();

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 메인 컨텐츠
            Row(
              children: [
                // 이미지
                _buildImage(photoUrl, category),

                // 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 추천 점수 배지 (있는 경우)
                        if (widget.score != null) _buildScoreBadge(),

                        const SizedBox(height: 4),

                        // 이름
                        Text(
                          widget.place.name,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // 카테고리
                        _buildCategoryChip(category),

                        const SizedBox(height: 8),

                        // 평점 및 주소
                        _buildMetadata(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 피드백 버튼들
            _buildFeedbackButtons(),
          ],
        ),
      ),
    );
  }

  /// 이미지 위젯
  Widget _buildImage(String photoUrl, PlaceCategory category) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: 120,
        height: 140,
        color: category.color.withValues(alpha: 0.2),
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(category);
                },
              )
            : _buildPlaceholder(category),
      ),
    );
  }

  /// 플레이스홀더 위젯
  Widget _buildPlaceholder(PlaceCategory category) {
    return Center(
      child: Icon(
        category.icon,
        size: 48,
        color: category.color,
      ),
    );
  }

  /// 추천 점수 배지
  Widget _buildScoreBadge() {
    final scorePercent = ((widget.score ?? 0) * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '추천도 $scorePercent%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(PlaceCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 12,
            color: category.color,
          ),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: AppTextStyles.caption.copyWith(
              color: category.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 메타데이터 (평점, 주소)
  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 평점
        if (widget.place.rating != null)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 4),
              Text(
                widget.place.rating!.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.place.userRatingsTotal != null) ...[
                const SizedBox(width: 4),
                Text(
                  '(${widget.place.userRatingsTotal})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

        const SizedBox(height: 4),

        // 주소
        Text(
          widget.place.address,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 피드백 버튼들
  Widget _buildFeedbackButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 좋아요 버튼
          Expanded(
            child: _buildFeedbackButton(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              label: '좋아요',
              isActive: _isLiked,
              onTap: _toggleLike,
            ),
          ),

          const SizedBox(width: 8),

          // 관심 없음 버튼
          Expanded(
            child: _buildFeedbackButton(
              icon: _isRejected ? Icons.close : Icons.close,
              label: '관심 없음',
              isActive: _isRejected,
              onTap: _toggleReject,
            ),
          ),
        ],
      ),
    );
  }

  /// 피드백 버튼
  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
