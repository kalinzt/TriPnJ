import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/sort_option.dart';
import '../../domain/models/time_filter.dart';
import '../providers/recommendation_provider.dart';
import '../../data/providers/user_preference_provider.dart';
import '../widgets/recommendation_filter_sheet.dart';
import '../widgets/recommendation_sort_menu.dart';
import '../widgets/swipeable_recommendation_card.dart';
import '../widgets/recommendation_map_view.dart';

/// 로컬 추천 화면 (TabBar 버전)
///
/// 사용자 맞춤 장소 추천을 리스트/지도 뷰로 표시합니다.
class LocalRecommendScreen extends ConsumerStatefulWidget {
  const LocalRecommendScreen({super.key});

  @override
  ConsumerState<LocalRecommendScreen> createState() => _LocalRecommendScreenState();
}

class _LocalRecommendScreenState extends ConsumerState<LocalRecommendScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Connectivity _connectivity = Connectivity();
  late TabController _tabController;
  bool _showFavoritesOnly = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 연결 상태 모니터링
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
      }
    });

    // 초기 추천 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recommendationProvider.notifier).loadInitialRecommendations();
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh 핸들러
  Future<void> _handleRefresh() async {
    await ref.read(recommendationProvider.notifier).refresh();
  }

  /// 더 보기 버튼 클릭
  Future<void> _handleLoadMore() async {
    await ref.read(recommendationProvider.notifier).loadMore();
  }

  /// 재시도 버튼 클릭
  Future<void> _handleRetry() async {
    await ref.read(recommendationProvider.notifier).retry();
  }

  /// 인기 장소 탐색 (Explore 화면으로 이동)
  void _navigateToExplore() {
    context.go('/explore');
  }

  /// 필터 BottomSheet 표시
  Future<void> _showFilterSheet() async {
    final state = ref.read(recommendationProvider);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: RecommendationFilterSheet(
          selectedCategories: state.selectedCategories,
          maxDistance: state.maxDistance,
          minRating: state.minRating,
          minReviewCount: state.minReviewCount,
          timeFilter: state.timeFilter,
        ),
      ),
    );

    if (result != null && mounted) {
      // 필터 적용
      await ref.read(recommendationProvider.notifier).updateFilter(
            selectedCategories: result['selectedCategories'] as Set<String>,
            maxDistance: result['maxDistance'] as double,
            minRating: result['minRating'] as double,
            minReviewCount: result['minReviewCount'] as int,
            timeFilter: result['timeFilter'] as TimeFilter,
          );
    }
  }

  /// 정렬 변경
  void _handleSortChanged(SortOption option) {
    ref.read(recommendationProvider.notifier).updateSort(option);
  }

  /// 즐겨찾기 필터 토글
  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 테마 시스템 적용
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);
    final state = ref.watch(recommendationProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('맞춤 추천'),
        backgroundColor: colors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: '리스트',
            ),
            Tab(
              icon: Icon(Icons.map),
              text: '지도',
            ),
          ],
        ),
        actions: [
          // 즐겨찾기 필터 버튼
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            color: _showFavoritesOnly ? colors.primary : null,
            tooltip: '즐겨찾기만 보기',
            onPressed: _toggleFavoritesFilter,
          ),

          // 필터 버튼
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: '필터',
                onPressed: _showFilterSheet,
              ),
              if (state.activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${state.activeFilterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 정렬 버튼
          RecommendationSortMenu(
            currentSortOption: state.currentSortOption,
            onSortChanged: _handleSortChanged,
          ),
        ],
      ),
      body: Column(
        children: [
          // 오프라인 배너
          if (!_isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: colors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, size: 16, color: colors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '오프라인 모드 - 캐시된 데이터를 표시합니다',
                      style: textStyles.bodySmall.copyWith(
                        color: colors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 탭 1: 리스트 뷰
                _buildListView(state),
                // 탭 2: 지도 뷰
                _buildMapView(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 리스트 뷰
  Widget _buildListView(RecommendationState state) {
    // 즐겨찾기 필터 적용
    final userPreference = ref.watch(userPreferenceProvider);
    final filteredRecommendations = _showFavoritesOnly
        ? state.recommendations
            .where((place) => userPreference.isFavorite(place.id))
            .toList()
        : state.recommendations;

    // 에러 상태
    if (state.errorMessage != null && state.recommendations.isEmpty) {
      return _buildErrorView(state.errorMessage!);
    }

    // 로딩 중 (초기)
    if (state.isLoading && state.recommendations.isEmpty) {
      return _buildLoadingView();
    }

    // 추천 없음
    if (filteredRecommendations.isEmpty) {
      return _showFavoritesOnly
          ? _buildEmptyFavoritesView()
          : _buildEmptyView();
    }

    // 추천 목록
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecommendations.length + 1, // +1 for "더 보기" 버튼
        itemBuilder: (context, index) {
          // 마지막 아이템: "더 보기" 버튼 (즐겨찾기 모드가 아닐 때만)
          if (index == filteredRecommendations.length) {
            return _showFavoritesOnly
                ? const SizedBox.shrink()
                : _buildLoadMoreButton(state);
          }

          // 추천 카드
          final place = filteredRecommendations[index];
          return SwipeableRecommendationCard(
            place: place,
            score: null, // TODO: 점수 추가
            onDismissed: () {
              // 카드가 제거된 후 목록에서도 제거
              setState(() {});
            },
          );
        },
      ),
    );
  }

  /// 지도 뷰
  Widget _buildMapView(RecommendationState state) {
    // 즐겨찾기 필터 적용
    final userPreference = ref.watch(userPreferenceProvider);
    final filteredRecommendations = _showFavoritesOnly
        ? state.recommendations
            .where((place) => userPreference.isFavorite(place.id))
            .toList()
        : state.recommendations;

    // 에러 상태
    if (state.errorMessage != null && state.recommendations.isEmpty) {
      return _buildErrorView(state.errorMessage!);
    }

    // 로딩 중 (초기)
    if (state.isLoading && state.recommendations.isEmpty) {
      return _buildLoadingView();
    }

    // 추천 없음
    if (filteredRecommendations.isEmpty) {
      return _showFavoritesOnly
          ? _buildEmptyFavoritesView()
          : _buildEmptyView();
    }

    // 지도 표시
    return RecommendationMapView(
      places: filteredRecommendations,
      scores: null, // TODO: 점수 매핑 추가
    );
  }

  /// 로딩 뷰
  Widget _buildLoadingView() {
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '맞춤 추천을 생성하고 있습니다...',
            style: textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(String errorMessage) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: textStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('재시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView() {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 80,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 충분한 데이터가 없습니다',
              style: textStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '여행 계획을 만들고 장소를 탐색하면\n맞춤 추천을 받을 수 있습니다',
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToExplore,
              icon: const Icon(Icons.explore),
              label: const Text('인기 장소 탐색하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 즐겨찾기 뷰
  Widget _buildEmptyFavoritesView() {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '즐겨찾기한 장소가 없습니다',
              style: textStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '추천 장소의 하트 아이콘을 눌러\n즐겨찾기에 추가해보세요',
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// "더 보기" 버튼
  Widget _buildLoadMoreButton(RecommendationState state) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    // 더 이상 없으면 표시 안 함
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            '모든 추천을 확인했습니다',
            style: textStyles.bodySmall,
          ),
        ),
      );
    }

    // 로딩 중
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // "더 보기" 버튼
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _handleLoadMore,
          icon: const Icon(Icons.add),
          label: const Text('더 보기'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
