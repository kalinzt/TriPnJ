import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../../explore/data/providers/places_provider.dart';
import '../../../explore/presentation/screens/place_detail_screen.dart';
import '../../../plan/data/providers/trip_provider.dart';
import '../../data/providers/user_preference_provider.dart';
import '../utils/recommendation_reason_generator.dart';

/// 개선된 추천 장소 카드 위젯
///
/// Phase 2: 이미지, 점수 배지, 추천 근거, 여행 계획 추가 기능 포함
class EnhancedRecommendationCard extends ConsumerStatefulWidget {
  final Place place;
  final double? score; // 추천 점수 (0.0 ~ 1.0)

  const EnhancedRecommendationCard({
    super.key,
    required this.place,
    this.score,
  });

  @override
  ConsumerState<EnhancedRecommendationCard> createState() =>
      _EnhancedRecommendationCardState();
}

class _EnhancedRecommendationCardState
    extends ConsumerState<EnhancedRecommendationCard> {
  double? _distanceInMeters;
  bool? _userFeedback; // true=도움됨, false=도움안됨, null=피드백없음

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  /// 현재 위치로부터의 거리 계산
  Future<void> _calculateDistance() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.place.latitude,
        widget.place.longitude,
      );

      if (mounted) {
        setState(() {
          _distanceInMeters = distance;
        });
      }
    } catch (e) {
      // 거리 계산 실패 시 무시
    }
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

  /// 여행 계획에 추가
  /// TODO: Phase 3에서 AddToPlanDialog 구현 후 활성화
  Future<void> _addToPlan() async {
    final tripPlans = ref.read(allTripsProvider);

    if (tripPlans.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 여행 계획을 생성해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: 여행 계획 선택 다이얼로그 구현
    // 현재는 첫 번째 여행 계획에 임시로 추가
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.place.name}을(를) 여행 계획에 추가했습니다'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// 즐겨찾기 토글
  Future<void> _toggleFavorite() async {
    final repository = ref.read(userPreferenceRepositoryProvider);
    await repository.toggleFavorite(widget.place.id);

    final userPreference = ref.read(userPreferenceProvider);
    final isFavorite = userPreference.isFavorite(widget.place.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? '즐겨찾기에 추가했습니다' : '즐겨찾기에서 제거했습니다',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 피드백 제공
  Future<void> _provideFeedback(bool isPositive) async {
    setState(() {
      _userFeedback = isPositive;
    });

    // TODO: 피드백을 서버나 로컬 저장소에 저장
    // TODO: PreferenceLearning.updateWeightsFromFeedback() 호출
    // 현재는 사용자에게 피드백만 표시
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPositive
            ? '피드백 감사합니다! 더 나은 추천을 제공하겠습니다.'
            : '피드백 감사합니다. 추천 알고리즘을 개선하겠습니다.',
        ),
        duration: const Duration(seconds: 2),
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
    final userPreference = ref.watch(userPreferenceProvider);

    // 추천 근거 생성
    final reasons = RecommendationReasonGenerator.generateReasons(
      place: widget.place,
      userPreference: userPreference,
      distance: _distanceInMeters,
    );

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 이미지 (16:9 비율)
            _buildImageSection(photoUrl, category),

            // 중앙: 장소 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 장소 이름
                  Text(
                    widget.place.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 주소
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.place.address,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 거리, 평점
                  Row(
                    children: [
                      // 거리
                      if (_distanceInMeters != null) ...[
                        const Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '현위치에서 ${RecommendationReasonGenerator.formatDistance(_distanceInMeters!)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // 평점
                      if (widget.place.rating != null) ...[
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 추천 근거 섹션
                  _buildReasonSection(reasons),

                  const SizedBox(height: 12),

                  // 여행 계획에 추가 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addToPlan,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('여행 계획에 추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 피드백 섹션
                  _buildFeedbackSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 피드백 섹션
  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 추천이 도움이 되었나요?',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 긍정 피드백 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _userFeedback == true
                      ? null
                      : () => _provideFeedback(true),
                  icon: Icon(
                    _userFeedback == true
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 18,
                  ),
                  label: const Text('도움됨'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _userFeedback == true
                        ? Colors.white
                        : AppColors.primary,
                    backgroundColor: _userFeedback == true
                        ? AppColors.primary
                        : Colors.transparent,
                    side: BorderSide(
                      color: _userFeedback == true
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 부정 피드백 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _userFeedback == false
                      ? null
                      : () => _provideFeedback(false),
                  icon: Icon(
                    _userFeedback == false
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    size: 18,
                  ),
                  label: const Text('도움안됨'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _userFeedback == false
                        ? Colors.white
                        : AppColors.textSecondary,
                    backgroundColor: _userFeedback == false
                        ? AppColors.textSecondary
                        : Colors.transparent,
                    side: BorderSide(
                      color: _userFeedback == false
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 이미지 섹션 (16:9 비율)
  Widget _buildImageSection(String photoUrl, PlaceCategory category) {
    final userPreference = ref.watch(userPreferenceProvider);
    final isFavorite = userPreference.isFavorite(widget.place.id);

    return Stack(
      children: [
        // 메인 이미지 (최적화: 점진적 로딩, 메모리 캐싱)
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    // 최적화: 메모리 캐시 설정
                    memCacheWidth: 800, // 최대 너비 제한으로 메모리 절약
                    memCacheHeight: 450, // 16:9 비율 유지
                    // 점진적 로딩: 저화질 → 고화질
                    progressIndicatorBuilder: (context, url, progress) {
                      return Container(
                        color: category.color.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            valueColor: AlwaysStoppedAnimation(category.color),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) =>
                        _buildPlaceholder(category),
                    // 캐시 유효기간 설정 (7일)
                    cacheKey: '${widget.place.id}_card',
                  )
                : _buildPlaceholder(category),
          ),
        ),

        // 좌측 상단: 추천 점수 배지
        if (widget.score != null)
          Positioned(
            top: 12,
            left: 12,
            child: _buildScoreBadge(),
          ),

        // 우측 상단: 즐겨찾기 하트 아이콘
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleFavorite,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),

        // 우측 상단 아래: 카테고리 아이콘
        Positioned(
          top: 56,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              category.icon,
              size: 20,
              color: category.color,
            ),
          ),
        ),
      ],
    );
  }

  /// 플레이스홀더 이미지
  Widget _buildPlaceholder(PlaceCategory category) {
    return Container(
      color: category.color.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          category.icon,
          size: 64,
          color: category.color,
        ),
      ),
    );
  }

  /// 추천 점수 배지 (원형, 그라데이션)
  Widget _buildScoreBadge() {
    final score = widget.score ?? 0.0;
    final scoreText = RecommendationReasonGenerator.formatScore(score);
    final gradientColors =
        RecommendationReasonGenerator.getScoreGradientColors(score);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors
              .map((hex) => Color(int.parse(hex.substring(1, 7), radix: 16) +
                  0xFF000000))
              .toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            scoreText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '점',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 추천 근거 섹션
  Widget _buildReasonSection(List<String> reasons) {
    if (reasons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이런 이유로 추천했어요:',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reasons
              .map((reason) => Chip(
                    label: Text(
                      reason,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
