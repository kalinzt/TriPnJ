import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/travel_plan_model.dart';
import '../../data/repositories/travel_plan_repository.dart';

// ============================================
// Repository Provider
// ============================================

/// TravelPlanRepository Provider (싱글톤)
final travelPlanRepositoryProvider = Provider<TravelPlanRepository>((ref) {
  final repository = TravelPlanRepository();
  // Repository 초기화
  repository.init();
  return repository;
});

// ============================================
// Travel Plans Providers (상태별 조회)
// ============================================

/// 예정/진행 중인 여행 계획 Provider
/// - 상태: 'planned' 또는 'inProgress'
/// - 정렬: 시작날짜가 오늘과 가까운 순 (진행 중 최우선)
final plannedAndOngoingTravelsProvider = FutureProvider<List<TravelPlan>>((ref) async {
  final repository = ref.watch(travelPlanRepositoryProvider);
  return repository.getPlannedAndOngoingTravels();
});

/// 완료된 여행 계획 Provider
/// - 상태: 'completed'
/// - 정렬: 종료날짜가 오늘과 가까운 순
final completedTravelsProvider = FutureProvider<List<TravelPlan>>((ref) async {
  final repository = ref.watch(travelPlanRepositoryProvider);
  return repository.getCompletedTravels();
});

// ============================================
// Refresh Providers
// ============================================

/// 여행 계획 새로고침 Provider
/// 데이터 갱신이 필요할 때 호출
final refreshTravelPlansProvider = StateProvider<int>((ref) => 0);

/// 새로고침 후 예정/진행 중인 여행 Provider
final refreshedPlannedAndOngoingTravelsProvider = FutureProvider<List<TravelPlan>>((ref) async {
  // refreshTravelPlansProvider를 watch하여 변경 시 자동 새로고침
  ref.watch(refreshTravelPlansProvider);
  final repository = ref.watch(travelPlanRepositoryProvider);
  return repository.getPlannedAndOngoingTravels();
});

/// 새로고침 후 완료된 여행 Provider
final refreshedCompletedTravelsProvider = FutureProvider<List<TravelPlan>>((ref) async {
  // refreshTravelPlansProvider를 watch하여 변경 시 자동 새로고침
  ref.watch(refreshTravelPlansProvider);
  final repository = ref.watch(travelPlanRepositoryProvider);
  return repository.getCompletedTravels();
});
