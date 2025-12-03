import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../data/providers/places_provider.dart';
import '../widgets/category_filter.dart';
import '../widgets/place_card.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/places_map_view.dart';

/// 탐색 화면 - 위치 기반 여행지 검색 및 둘러보기
class ExploreScreen extends ConsumerStatefulWidget {
  final bool isPlaceSelection; // 장소 선택 모드 (여행 계획에서 사용)

  const ExploreScreen({
    super.key,
    this.isPlaceSelection = false,
  });

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 현재 위치 기반으로 주변 장소 검색
    Future.microtask(() {
      final notifier = ref.read(placesNotifierProvider.notifier);
      notifier.searchNearbyPlacesFromCurrentLocation();
    });
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(placesNotifierProvider.notifier);
    await notifier.searchNearbyPlacesFromCurrentLocation(
      radius: ref.read(searchRadiusProvider),
      category: ref.read(selectedCategoryProvider),
      keyword: ref.read(searchKeywordProvider),
    );
  }

  void _toggleView() {
    setState(() {
      _isMapView = !_isMapView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final placesState = ref.watch(placesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            _buildHeader(context),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExploreSearchBar(
                onSearch: (query) {
                  if (query.isNotEmpty) {
                    ref.read(placesNotifierProvider.notifier).searchPlacesByText(
                          query: query,
                        );
                  }
                },
              ),
            ),

            // 카테고리 필터
            CategoryFilter(
              selectedCategory: ref.watch(selectedCategoryProvider),
              onCategorySelected: (category) {
                ref.read(selectedCategoryProvider.notifier).state = category;
                ref
                    .read(placesNotifierProvider.notifier)
                    .searchNearbyPlacesFromCurrentLocation(
                      category: category,
                    );
              },
            ),

            const SizedBox(height: 8),

            // 여행지 목록 또는 지도
            Expanded(
              child: placesState.isLoading
                  ? _buildLoadingView()
                  : placesState.error != null
                      ? _buildErrorView(placesState.error!)
                      : placesState.places.isEmpty
                          ? _buildEmptyView()
                          : _isMapView
                              ? _buildMapView(placesState.places)
                              : _buildListView(placesState.places),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader(BuildContext context) {
    final currentAddress = ref.watch(currentAddressProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여행지 탐색',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                currentAddress.when(
                  data: (address) => Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          address,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '위치 확인 중...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  error: (_, __) => Text(
                    '주변의 멋진 여행지를 찾아보세요',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 지도/목록 토글 버튼
          IconButton(
            onPressed: _toggleView,
            icon: Icon(
              _isMapView ? Icons.list : Icons.map,
              color: AppColors.primary,
            ),
            tooltip: _isMapView ? '목록 보기' : '지도 보기',
          ),
        ],
      ),
    );
  }

  /// 목록 뷰
  Widget _buildListView(List<dynamic> places) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlaceCard(
              place: place,
              onTap: widget.isPlaceSelection
                  ? () => Navigator.pop(context, place)
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// 지도 뷰
  Widget _buildMapView(List<Place> places) {
    return ref.watch(currentLocationProvider).when(
          data: (position) {
            return PlacesMapView(
              places: places,
              currentLatitude: position.latitude,
              currentLongitude: position.longitude,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) {
            // 위치를 가져오지 못해도 지도는 표시
            return PlacesMapView(
              places: places,
            );
          },
        );
  }

  /// 로딩 뷰
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('주변 여행지를 검색 중...'),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              '오류 발생',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 결과 뷰
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore_off,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              '여행지를 찾을 수 없습니다',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 카테고리나 검색어를 시도해보세요',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(selectedCategoryProvider.notifier).state =
                    PlaceCategory.all;
                _onRefresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('전체 카테고리로 검색'),
            ),
          ],
        ),
      ),
    );
  }
}
