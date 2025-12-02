import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/sort_option.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/recommendation_filter_sheet.dart';
import '../widgets/recommendation_sort_menu.dart';
import '../widgets/swipeable_recommendation_card.dart';

/// 로컬 추천 화면
///
/// 사용자 맞춤 장소 추천을 표시합니다.
class LocalRecommendScreen extends ConsumerStatefulWidget {
  const LocalRecommendScreen({super.key});

  @override
  ConsumerState<LocalRecommendScreen> createState() => _LocalRecommendScreenState();
}

class _LocalRecommendScreenState extends ConsumerState<LocalRecommendScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 추천 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recommendationProvider.notifier).loadInitialRecommendations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          );
    }
  }

  /// 정렬 변경
  void _handleSortChanged(SortOption option) {
    ref.read(recommendationProvider.notifier).updateSort(option);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('맞춤 추천'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
                      color: AppColors.primary,
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
      body: _buildBody(state),
    );
  }

  /// Body 위젯
  Widget _buildBody(RecommendationState state) {
    // 에러 상태
    if (state.errorMessage != null && state.recommendations.isEmpty) {
      return _buildErrorView(state.errorMessage!);
    }

    // 로딩 중 (초기)
    if (state.isLoading && state.recommendations.isEmpty) {
      return _buildLoadingView();
    }

    // 추천 없음
    if (state.recommendations.isEmpty) {
      return _buildEmptyView();
    }

    // 추천 목록
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.recommendations.length + 1, // +1 for "더 보기" 버튼
        itemBuilder: (context, index) {
          // 마지막 아이템: "더 보기" 버튼
          if (index == state.recommendations.length) {
            return _buildLoadMoreButton(state);
          }

          // 추천 카드
          final place = state.recommendations[index];
          return SwipeableRecommendationCard(
            place: place,
            score: null, // TODO: 점수 추가 (Phase 2)
            onDismissed: () {
              // 카드가 제거된 후 목록에서도 제거
              // Provider의 상태는 이미 업데이트되어 있으므로 UI 새로고침만 필요
              setState(() {});
            },
          );
        },
      ),
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
          Text(
            '맞춤 추천을 생성하고 있습니다...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('재시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 충분한 데이터가 없습니다',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '여행 계획을 만들고 장소를 탐색하면\n맞춤 추천을 받을 수 있습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToExplore,
              icon: const Icon(Icons.explore),
              label: const Text('인기 장소 탐색하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "더 보기" 버튼
  Widget _buildLoadMoreButton(RecommendationState state) {
    // 더 이상 없으면 표시 안 함
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '모든 추천을 확인했습니다',
            style: AppTextStyles.bodySmall,
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
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
