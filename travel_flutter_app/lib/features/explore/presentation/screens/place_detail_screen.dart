import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../data/providers/places_provider.dart';

/// 여행지 상세 화면
class PlaceDetailScreen extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  bool _isFavorite = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: 즐겨찾기 상태를 로컬 저장소에 저장
  }

  void _sharePlace() {
    final text = '${widget.place.name}\n${widget.place.address}';
    Share.share(text);
  }

  void _addToTrip() {
    // TODO: 여행 계획에 추가 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('여행 계획에 추가되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getPhotoUrl(String photoReference) {
    final repository = ref.read(placesRepositoryProvider);
    return repository.getPhotoUrl(
      photoReference: photoReference,
      maxWidth: 1200,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = getCategoryFromPlaceTypes(widget.place.types);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 앱바와 이미지 캐러셀
          _buildSliverAppBar(category),

          // 상세 정보
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 기본 정보
                _buildBasicInfo(category),

                const Divider(height: 32),

                // 위치 정보
                _buildLocationInfo(),

                const Divider(height: 32),

                // 추가 정보
                _buildAdditionalInfo(),

                const Divider(height: 32),

                // 리뷰 섹션 (추후 구현)
                _buildReviewSection(),

                const SizedBox(height: 100), // 하단 버튼 공간
              ],
            ),
          ),
        ],
      ),
      // 하단 고정 버튼
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// SliverAppBar와 이미지 캐러셀
  Widget _buildSliverAppBar(PlaceCategory category) {
    final hasPhotos = widget.place.photos.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : Colors.white,
            ),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: _sharePlace,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasPhotos
            ? Stack(
                children: [
                  // 이미지 캐러셀
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPhotoIndex = index;
                      });
                    },
                    itemCount: widget.place.photos.length,
                    itemBuilder: (context, index) {
                      final photoUrl = _getPhotoUrl(widget.place.photos[index]);
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(category);
                        },
                      );
                    },
                  ),

                  // 페이지 인디케이터
                  if (widget.place.photos.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPhotoIndex + 1}/${widget.place.photos.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : _buildPlaceholderImage(category),
      ),
    );
  }

  /// 플레이스홀더 이미지
  Widget _buildPlaceholderImage(PlaceCategory category) {
    return Container(
      color: category.color.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          category.icon,
          size: 80,
          color: category.color.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// 기본 정보
  Widget _buildBasicInfo(PlaceCategory category) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: category.color),
                const SizedBox(width: 6),
                Text(
                  category.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 이름
          Text(
            widget.place.name,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 평점과 리뷰 수
          if (widget.place.rating != null)
            Row(
              children: [
                const Icon(Icons.star, size: 20, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  widget.place.rating!.toStringAsFixed(1),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.place.userRatingsTotal != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.place.userRatingsTotal}개의 리뷰)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 16),

          // 주소
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.place.address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 위치 정보
  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 지도 플레이스홀더 (추후 Google Maps 통합)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '지도 기능은 곧 제공됩니다',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '위도: ${widget.place.latitude.toStringAsFixed(6)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  Text(
                    '경도: ${widget.place.longitude.toStringAsFixed(6)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 추가 정보
  Widget _buildAdditionalInfo() {
    final hasAnyInfo = widget.place.phoneNumber != null ||
        widget.place.website != null ||
        widget.place.openingHours != null ||
        widget.place.priceLevel != null;

    if (!hasAnyInfo) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추가 정보',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 전화번호
          if (widget.place.phoneNumber != null)
            _buildInfoRow(
              Icons.phone,
              '전화번호',
              widget.place.phoneNumber!,
            ),

          // 웹사이트
          if (widget.place.website != null)
            _buildInfoRow(
              Icons.language,
              '웹사이트',
              widget.place.website!,
            ),

          // 가격 레벨
          if (widget.place.priceLevel != null)
            _buildInfoRow(
              Icons.attach_money,
              '가격대',
              '\$' * widget.place.priceLevel!,
            ),

          // 영업 상태
          if (widget.place.businessStatus != null)
            _buildInfoRow(
              Icons.info_outline,
              '영업 상태',
              _getBusinessStatusText(widget.place.businessStatus!),
            ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 리뷰 섹션
  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '리뷰',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                '리뷰 기능은 곧 제공됩니다',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼 바
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _addToTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline),
              const SizedBox(width: 8),
              Text(
                '여행 계획에 추가',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 영업 상태 텍스트 변환
  String _getBusinessStatusText(String status) {
    switch (status) {
      case 'OPERATIONAL':
        return '영업 중';
      case 'CLOSED_TEMPORARILY':
        return '임시 휴업';
      case 'CLOSED_PERMANENTLY':
        return '영구 폐업';
      default:
        return status;
    }
  }
}
