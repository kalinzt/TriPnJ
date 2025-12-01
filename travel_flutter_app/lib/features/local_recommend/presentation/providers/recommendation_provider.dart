import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';
import '../../data/providers/place_analysis_provider.dart';
import '../../data/services/place_analysis_service.dart';

/// 추천 상태
class RecommendationState {
  final List<Place> recommendations;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  const RecommendationState({
    this.recommendations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0,
    this.hasMore = true,
  });

  RecommendationState copyWith({
    List<Place>? recommendations,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// 추천 StateNotifier
class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final PlaceAnalysisService _placeAnalysisService;
  final LocationService _locationService;

  RecommendationNotifier({
    required PlaceAnalysisService placeAnalysisService,
    LocationService? locationService,
  })  : _placeAnalysisService = placeAnalysisService,
        _locationService = locationService ?? LocationService(),
        super(const RecommendationState());

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

      // 현재 위치 가져오기
      final position = await _locationService.getCurrentLocation();

      // 추천 목록 가져오기
      final recommendations = await _placeAnalysisService.getTopRecommendations(
        latitude: position.latitude,
        longitude: position.longitude,
        count: 20,
      );

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
    } catch (e, stackTrace) {
      Logger.error('추천 목록 로드 실패', e, stackTrace, 'RecommendationNotifier');

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
