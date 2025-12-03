import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../models/travel_plan_model.dart';
import '../repositories/travel_plan_repository.dart';

// ============================================
// Repository Provider
// ============================================

/// TravelPlanRepository Provider
final travelPlanRepositoryProvider = Provider<TravelPlanRepository>((ref) {
  return TravelPlanRepository();
});

// ============================================
// StateNotifierProvider - 여행 계획 목록 관리
// ============================================

/// 여행 계획 목록 상태
class TravelPlanListState {
  final List<TravelPlan> plans;
  final bool isLoading;
  final String? errorMessage;

  const TravelPlanListState({
    this.plans = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TravelPlanListState copyWith({
    List<TravelPlan>? plans,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TravelPlanListState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 여행 계획 목록 관리 Notifier
class TravelPlanListNotifier extends StateNotifier<TravelPlanListState> {
  final TravelPlanRepository _repository;

  TravelPlanListNotifier(this._repository) : super(const TravelPlanListState()) {
    _init();
  }

  /// 초기화
  Future<void> _init() async {
    await _repository.init();
    await loadAllPlans();
  }

  // ============================================
  // 조회
  // ============================================

  /// 모든 여행 계획 로드
  Future<void> loadAllPlans() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      Logger.info('모든 여행 계획 로드 시작', 'TravelPlanListNotifier');

      final plans = await _repository.getAllTravelPlans();

      state = state.copyWith(
        plans: plans,
        isLoading: false,
      );

      Logger.info('여행 계획 ${plans.length}개 로드 완료', 'TravelPlanListNotifier');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 로드 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '여행 계획을 불러오는 데 실패했습니다.',
      );
    }
  }

  /// 특정 월의 여행 계획 로드
  Future<void> loadPlansByMonth(int year, int month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      Logger.info('$year년 $month월 여행 계획 로드', 'TravelPlanListNotifier');

      final plans = await _repository.getTravelPlansByMonth(
        year: year,
        month: month,
      );

      state = state.copyWith(
        plans: plans,
        isLoading: false,
      );

      Logger.info('$year년 $month월 여행 계획 ${plans.length}개 로드 완료', 'TravelPlanListNotifier');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 로드 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '여행 계획을 불러오는 데 실패했습니다.',
      );
    }
  }

  /// 상태별 여행 계획 로드
  Future<void> loadPlansByStatus(String status) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      Logger.info('상태별 여행 계획 로드: $status', 'TravelPlanListNotifier');

      final plans = await _repository.getTravelPlansByStatus(status);

      state = state.copyWith(
        plans: plans,
        isLoading: false,
      );

      Logger.info('상태별 여행 계획 ${plans.length}개 로드 완료', 'TravelPlanListNotifier');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 로드 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '여행 계획을 불러오는 데 실패했습니다.',
      );
    }
  }

  // ============================================
  // 추가
  // ============================================

  /// 새 여행 계획 추가
  Future<TravelPlan?> addTravelPlan({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    double? budget,
    String? description,
  }) async {
    try {
      Logger.info('여행 계획 추가: $name', 'TravelPlanListNotifier');

      final travelPlan = await _repository.createTravelPlan(
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        description: description,
      );

      // 목록 새로고침
      await loadAllPlans();

      Logger.info('여행 계획 추가 완료', 'TravelPlanListNotifier');
      return travelPlan;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 추가 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        errorMessage: '여행 계획을 추가하는 데 실패했습니다.',
      );
      return null;
    }
  }

  // ============================================
  // 수정
  // ============================================

  /// 여행 계획 수정
  Future<bool> updateTravelPlan(TravelPlan travelPlan) async {
    try {
      Logger.info('여행 계획 수정: ${travelPlan.id}', 'TravelPlanListNotifier');

      await _repository.updateTravelPlan(travelPlan);

      // 목록 새로고침
      await loadAllPlans();

      Logger.info('여행 계획 수정 완료', 'TravelPlanListNotifier');
      return true;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 수정 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        errorMessage: '여행 계획을 수정하는 데 실패했습니다.',
      );
      return false;
    }
  }

  // ============================================
  // 삭제
  // ============================================

  /// 여행 계획 삭제
  Future<bool> deleteTravelPlan(String id) async {
    try {
      Logger.info('여행 계획 삭제: $id', 'TravelPlanListNotifier');

      await _repository.deleteTravelPlan(id);

      // 목록 새로고침
      await loadAllPlans();

      Logger.info('여행 계획 삭제 완료', 'TravelPlanListNotifier');
      return true;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 삭제 실패', e, stackTrace, 'TravelPlanListNotifier');

      state = state.copyWith(
        errorMessage: '여행 계획을 삭제하는 데 실패했습니다.',
      );
      return false;
    }
  }

  // ============================================
  // 기타
  // ============================================

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// TravelPlanListNotifier Provider
final travelPlanListProvider =
    StateNotifierProvider<TravelPlanListNotifier, TravelPlanListState>((ref) {
  final repository = ref.watch(travelPlanRepositoryProvider);
  return TravelPlanListNotifier(repository);
});

// ============================================
// FutureProvider - 개별 여행 계획
// ============================================

/// 특정 여행 계획 조회 Provider
final travelPlanByIdProvider =
    FutureProvider.family<TravelPlan?, String>((ref, id) async {
  final repository = ref.watch(travelPlanRepositoryProvider);
  await repository.init();
  return await repository.getTravelPlanById(id);
});

/// 특정 날짜 범위의 여행 계획 조회 Provider
final travelPlansByDateRangeProvider = FutureProvider.family<List<TravelPlan>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final repository = ref.watch(travelPlanRepositoryProvider);
  await repository.init();
  return await repository.getTravelPlansByDateRange(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});
