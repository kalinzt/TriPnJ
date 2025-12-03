import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/recommendation_logger.dart';
import '../../../../shared/models/place.dart';
import '../../data/providers/place_analysis_provider.dart';
import '../../data/services/place_analysis_service.dart';
import '../../data/services/recommendation_analytics.dart';
import '../../data/services/performance_monitor.dart';
import '../../domain/models/sort_option.dart';
import '../../domain/models/time_filter.dart';

/// 추천 상태
class RecommendationState {
  final List<Place> recommendations;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  // 필터 상태
  final Set<String> selectedCategories;
  final double maxDistance; // 킬로미터
  final double minRating;
  final int minReviewCount;
  final TimeFilter timeFilter;

  // 정렬 상태
  final SortOption currentSortOption;

  const RecommendationState({
    this.recommendations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0,
    this.hasMore = true,
    this.selectedCategories = const {},
    this.maxDistance = 10.0,
    this.minRating = 0.0,
    this.minReviewCount = 0,
    this.timeFilter = TimeFilter.all,
    this.currentSortOption = SortOption.recommendation,
  });

  RecommendationState copyWith({
    List<Place>? recommendations,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    Set<String>? selectedCategories,
    double? maxDistance,
    double? minRating,
    int? minReviewCount,
    TimeFilter? timeFilter,
    SortOption? currentSortOption,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      minReviewCount: minReviewCount ?? this.minReviewCount,
      timeFilter: timeFilter ?? this.timeFilter,
      currentSortOption: currentSortOption ?? this.currentSortOption,
    );
  }

  /// 활성 필터 개수
  int get activeFilterCount {
    int count = 0;
    if (selectedCategories.isNotEmpty) count++;
    if (maxDistance < 10.0) count++;
    if (minRating > 0.0) count++;
    if (minReviewCount > 0) count++;
    if (timeFilter != TimeFilter.all) count++;
    return count;
  }
}

/// 추천 StateNotifier
class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final PlaceAnalysisService _placeAnalysisService;
  final LocationService _locationService;
  final Debouncer _filterDebouncer = Debouncer(duration: const Duration(milliseconds: 800));
  final RecommendationLogger _recLogger = RecommendationLogger();
  final RecommendationAnalytics _analytics = RecommendationAnalytics();
  final PerformanceMonitor _perfMonitor = PerformanceMonitor();

  RecommendationNotifier({
    required PlaceAnalysisService placeAnalysisService,
    LocationService? locationService,
  })  : _placeAnalysisService = placeAnalysisService,
        _locationService = locationService ?? LocationService(),
        super(const RecommendationState());

  @override
  void dispose() {
    _filterDebouncer.dispose();
    super.dispose();
  }

  // ============================================
  // 초기 추천 로드
  // ============================================

  /// 초기 추천 목록 로드
  Future<void> loadInitialRecommendations() async {
    if (state.isLoading) return;

    try {
      Logger.info('초기 추천 목록 로드 시작', 'RecommendationNotifier');

      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      // 성능 모니터링 적용
      await _perfMonitor.measure(
        operation: 'recommendation_generation',
        task: () async {
          // 현재 위치 가져오기
          final position = await _locationService.getCurrentLocation();

          // 추천 목록 가져오기
          final recommendations = await _placeAnalysisService.getTopRecommendations(
            latitude: position.latitude,
            longitude: position.longitude,
            count: 20,
          );

          // 추천 생성 로그 및 메트릭 기록
          if (recommendations.isNotEmpty) {
            final avgScore = recommendations
                .map((p) => p.rating ?? 0.0)
                .reduce((a, b) => a + b) / recommendations.length;

            _recLogger.logRecommendationGenerated(
              recommendationCount: recommendations.length,
              averageScore: avgScore,
              duration: const Duration(milliseconds: 0), // 실제 duration은 measure에서 측정
              algorithmType: 'hybrid',
              metadata: {
                'filter_count': state.activeFilterCount,
                'sort_option': state.currentSortOption.name,
              },
            );

            await _analytics.recordRecommendationGenerated(
              count: recommendations.length,
              averageScore: avgScore,
            );
          }

          Logger.info(
            '추천 목록 로드 완료: ${recommendations.length}개',
            'RecommendationNotifier',
          );

          state = state.copyWith(
            recommendations: recommendations,
            isLoading: false,
            currentPage: 1,
            hasMore: recommendations.length >= 20,
          );
        },
        metadata: {
          'count': 20,
          'has_filters': state.activeFilterCount > 0,
        },
      );
    } catch (e, stackTrace) {
      Logger.error('추천 목록 로드 실패', e, stackTrace, 'RecommendationNotifier');

      // 에러 로그 및 메트릭 기록
      _recLogger.logError(
        error: e,
        stackTrace: stackTrace,
        context: 'RecommendationNotifier.loadInitialRecommendations',
      );

      await _analytics.recordError(
        errorType: e.runtimeType.toString(),
        context: 'loadInitialRecommendations',
        message: e.toString(),
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: '추천 목록을 불러오는 데 실패했습니다.\n네트워크 연결을 확인해주세요.',
      );
    }
  }

  // ============================================
  // 새로고침
  // ============================================

  /// Pull-to-refresh로 새로고침
  Future<void> refresh() async {
    try {
      Logger.info('추천 목록 새로고침', 'RecommendationNotifier');

      // 캐시 클리어
      await _placeAnalysisService.clearCache();

      // 초기 상태로 리셋
      state = const RecommendationState();

      // 다시 로드
      await loadInitialRecommendations();
    } catch (e, stackTrace) {
      Logger.error('새로고침 실패', e, stackTrace, 'RecommendationNotifier');

      state = state.copyWith(
        errorMessage: '새로고침에 실패했습니다.',
      );
    }
  }

  // ============================================
  // 추가 로드 (페이지네이션)
  // ============================================

  /// 더 많은 추천 로드
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      Logger.info('추가 추천 로드: page=${state.currentPage + 1}', 'RecommendationNotifier');

      state = state.copyWith(isLoading: true);

      // 현재 위치 가져오기
      final position = await _locationService.getCurrentLocation();

      // 추가 추천 로드
      final offset = state.currentPage * 20;
      final moreRecommendations =
          await _placeAnalysisService.loadMoreRecommendations(
        latitude: position.latitude,
        longitude: position.longitude,
        offset: offset,
        count: 20,
      );

      Logger.info(
        '추가 추천 로드 완료: ${moreRecommendations.length}개',
        'RecommendationNotifier',
      );

      // 기존 목록에 추가
      final updatedList = [
        ...state.recommendations,
        ...moreRecommendations,
      ];

      state = state.copyWith(
        recommendations: updatedList,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: moreRecommendations.length >= 20,
      );
    } catch (e, stackTrace) {
      Logger.error('추가 로드 실패', e, stackTrace, 'RecommendationNotifier');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '추가 추천을 불러오는 데 실패했습니다.',
      );
    }
  }

  // ============================================
  // 필터 및 정렬
  // ============================================

  /// 필터 업데이트 (Debouncing 적용)
  Future<void> updateFilter({
    Set<String>? selectedCategories,
    double? maxDistance,
    double? minRating,
    int? minReviewCount,
    TimeFilter? timeFilter,
  }) async {
    Logger.info('필터 업데이트 (디바운싱)', 'RecommendationNotifier');

    // 먼저 상태 업데이트 (UI 즉시 반영)
    state = state.copyWith(
      selectedCategories: selectedCategories ?? state.selectedCategories,
      maxDistance: maxDistance ?? state.maxDistance,
      minRating: minRating ?? state.minRating,
      minReviewCount: minReviewCount ?? state.minReviewCount,
      timeFilter: timeFilter ?? state.timeFilter,
    );

    // 디바운싱을 적용하여 API 호출 최적화
    // 사용자가 연속으로 필터를 변경하면 마지막 변경만 API 호출
    _filterDebouncer.run(() {
      loadInitialRecommendations();
    });
  }

  /// 정렬 업데이트
  void updateSort(SortOption sortOption) {
    Logger.info('정렬 업데이트: ${sortOption.displayName}', 'RecommendationNotifier');

    state = state.copyWith(currentSortOption: sortOption);

    // 현재 목록을 정렬
    _applySorting();
  }

  /// 필터 적용 (클라이언트 사이드)
  List<Place> _applyFilters(List<Place> places) {
    var filtered = places;

    // 카테고리 필터
    if (state.selectedCategories.isNotEmpty) {
      filtered = filtered.where((place) {
        return place.types.any((type) =>
            state.selectedCategories.contains(type));
      }).toList();
    }

    // 평점 필터
    if (state.minRating > 0) {
      filtered = filtered.where((place) {
        return place.rating != null && place.rating! >= state.minRating;
      }).toList();
    }

    // 리뷰 수 필터
    if (state.minReviewCount > 0) {
      filtered = filtered.where((place) {
        return place.userRatingsTotal != null &&
            place.userRatingsTotal! >= state.minReviewCount;
      }).toList();
    }

    // TODO: 거리 필터는 현재 위치 정보가 필요하므로 나중에 구현

    return filtered;
  }

  /// 정렬 적용
  void _applySorting() {
    final sorted = List<Place>.from(state.recommendations);

    switch (state.currentSortOption) {
      case SortOption.recommendation:
        // 추천순은 이미 서버에서 정렬되어 옴
        break;

      case SortOption.distance:
        // TODO: 거리 정보가 필요하므로 나중에 구현
        Logger.warning('거리순 정렬은 아직 구현되지 않았습니다', 'RecommendationNotifier');
        break;

      case SortOption.rating:
        sorted.sort((a, b) {
          final ratingA = a.rating ?? 0.0;
          final ratingB = b.rating ?? 0.0;
          return ratingB.compareTo(ratingA); // 높은 순
        });
        break;

      case SortOption.reviewCount:
        sorted.sort((a, b) {
          final countA = a.userRatingsTotal ?? 0;
          final countB = b.userRatingsTotal ?? 0;
          return countB.compareTo(countA); // 많은 순
        });
        break;
    }

    state = state.copyWith(recommendations: sorted);
  }

  /// 필터 초기화
  Future<void> resetFilters() async {
    Logger.info('필터 초기화', 'RecommendationNotifier');

    state = state.copyWith(
      selectedCategories: const {},
      maxDistance: 10.0,
      minRating: 0.0,
      minReviewCount: 0,
      timeFilter: TimeFilter.all,
    );

    // 필터 초기화 후 재로드
    await loadInitialRecommendations();
  }

  // ============================================
  // 에러 클리어
  // ============================================

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ============================================
  // 재시도
  // ============================================

  /// 재시도
  Future<void> retry() async {
    state = const RecommendationState();
    await loadInitialRecommendations();
  }
}

/// RecommendationNotifier Provider
final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  final placeAnalysisService = ref.watch(placeAnalysisServiceProvider);

  return RecommendationNotifier(
    placeAnalysisService: placeAnalysisService,
  );
});
