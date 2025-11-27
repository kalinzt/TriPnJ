import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../data/providers/places_provider.dart';
import '../screens/place_detail_screen.dart';

/// 여행지 카드 위젯
class PlaceCard extends ConsumerStatefulWidget {
  final Place place;

  const PlaceCard({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends ConsumerState<PlaceCard> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: 즐겨찾기 상태를 로컬 저장소에 저장
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place: widget.place),
      ),
    );
  }

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
        height: 120,
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
        child: Row(
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
                    // 이름과 즐겨찾기 버튼
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.place.name,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildFavoriteButton(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 주소
                    Text(
                      widget.place.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // 하단 정보 (평점, 카테고리)
                    Row(
                      children: [
                        // 평점
                        if (widget.place.rating != null) ...[
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.place.rating!.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.place.userRatingsTotal != null) ...[
                            const SizedBox(width: 2),
                            Text(
                              '(${widget.place.userRatingsTotal})',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                        ],

                        // 카테고리
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
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
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: category.color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지
  Widget _buildImage(String photoUrl, PlaceCategory category) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: 120,
        height: 120,
        color: category.color.withValues(alpha: 0.1),
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage(category);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
              )
            : _buildPlaceholderImage(category),
      ),
    );
  }

  /// 플레이스홀더 이미지
  Widget _buildPlaceholderImage(PlaceCategory category) {
    return Container(
      color: category.color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          category.icon,
          size: 40,
          color: category.color.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// 즐겨찾기 버튼
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: _isFavorite ? AppColors.error : AppColors.textSecondary,
        ),
      ),
    );
  }
}
