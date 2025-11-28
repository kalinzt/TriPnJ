import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/models/trip_plan.dart';
import '../database/trip_database.dart';
import '../repositories/trip_repository.dart';

// ============================================
// Database & Repository Providers
// ============================================

/// TripDatabase Provider
final tripDatabaseProvider = Provider<TripDatabase>((ref) {
  return TripDatabase();
});

/// TripRepository Provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final database = ref.watch(tripDatabaseProvider);
  return TripRepository(database);
});

// ============================================
// Trip List Providers
// ============================================

/// 모든 여행 계획 목록 Provider
final allTripsProvider = StateNotifierProvider<TripListNotifier, List<TripPlan>>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListNotifier(repository);
});

/// 진행 중인 여행 계획 Provider
final ongoingTripsProvider = Provider<List<TripPlan>>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getOngoingTripPlans();
});

/// 예정된 여행 계획 Provider
final upcomingTripsProvider = Provider<List<TripPlan>>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getUpcomingTripPlans();
});

/// 완료된 여행 계획 Provider
final completedTripsProvider = Provider<List<TripPlan>>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getCompletedTripPlans();
});

// ============================================
// Current Editing Trip Provider
// ============================================

/// 현재 편집 중인 여행 계획 Provider
final currentEditingTripProvider =
    StateNotifierProvider<CurrentEditingTripNotifier, TripPlan?>((ref) {
  return CurrentEditingTripNotifier();
});

// ============================================
// Trip Filter Provider
// ============================================

/// 여행 필터 상태
enum TripFilter {
  all,
  ongoing,
  upcoming,
  completed,
}

/// 여행 필터 Provider
final tripFilterProvider = StateProvider<TripFilter>((ref) => TripFilter.all);

/// 필터링된 여행 목록 Provider
final filteredTripsProvider = Provider<List<TripPlan>>((ref) {
  final filter = ref.watch(tripFilterProvider);
  final repository = ref.watch(tripRepositoryProvider);

  switch (filter) {
    case TripFilter.all:
      return repository.getAllTripPlans();
    case TripFilter.ongoing:
      return repository.getOngoingTripPlans();
    case TripFilter.upcoming:
      return repository.getUpcomingTripPlans();
    case TripFilter.completed:
      return repository.getCompletedTripPlans();
  }
});

// ============================================
// Search Provider
// ============================================

/// 검색 쿼리 Provider
final tripSearchQueryProvider = StateProvider<String>((ref) => '');

/// 검색된 여행 목록 Provider
final searchedTripsProvider = Provider<List<TripPlan>>((ref) {
  final query = ref.watch(tripSearchQueryProvider);
  final repository = ref.watch(tripRepositoryProvider);

  if (query.isEmpty) {
    return repository.getAllTripPlans();
  }

  return repository.searchByDestination(query);
});

// ============================================
// Individual Trip Provider
// ============================================

/// 특정 여행 계획 Provider
final tripProvider = Provider.family<TripPlan?, String>((ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTripPlan(tripId);
});

// ============================================
// Trip Statistics Provider
// ============================================

/// 여행 통계 Provider
final tripStatsProvider = Provider<TripStatistics>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  final allTrips = repository.getAllTripPlans();

  return TripStatistics(
    totalTrips: allTrips.length,
    ongoingTrips: repository.getOngoingTripPlans().length,
    upcomingTrips: repository.getUpcomingTripPlans().length,
    completedTrips: repository.getCompletedTripPlans().length,
  );
});

// ============================================
// StateNotifier Classes
// ============================================

/// 여행 계획 목록 관리 StateNotifier
class TripListNotifier extends StateNotifier<List<TripPlan>> {
  final TripRepository _repository;

  TripListNotifier(this._repository) : super([]) {
    loadTrips();
  }

  /// 여행 목록 로드
  Future<void> loadTrips() async {
    state = _repository.getAllTripPlans();
  }

  /// 여행 계획 생성
  Future<TripPlan> createTrip({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String destination,
    double? destinationLatitude,
    double? destinationLongitude,
    String? memo,
    double? budget,
    String? thumbnailUrl,
  }) async {
    final now = DateTime.now();
    final trip = TripPlan(
      id: const Uuid().v4(),
      title: title,
      startDate: startDate,
      endDate: endDate,
      destination: destination,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      memo: memo,
      budget: budget,
      thumbnailUrl: thumbnailUrl,
      createdAt: now,
      updatedAt: now,
    );

    final createdTrip = await _repository.createTripPlan(trip);
    state = [...state, createdTrip];
    return createdTrip;
  }

  /// 여행 계획 업데이트
  Future<TripPlan> updateTrip(TripPlan trip) async {
    final updatedTrip = await _repository.updateTripPlan(trip);
    state = state.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList();
    return updatedTrip;
  }

  /// 여행 계획 삭제
  Future<void> deleteTrip(String tripId) async {
    await _repository.deleteTripPlan(tripId);
    state = state.where((trip) => trip.id != tripId).toList();
  }

  /// 모든 여행 계획 삭제
  Future<void> deleteAllTrips() async {
    await _repository.deleteAllTripPlans();
    state = [];
  }

  /// 활동 추가
  Future<void> addActivity({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    final updatedTrip = await _repository.addActivityToDailyPlan(
      tripId: tripId,
      date: date,
      activity: activity,
    );
    state = state.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList();
  }

  /// 활동 제거
  Future<void> removeActivity({
    required String tripId,
    required DateTime date,
    required String activityId,
  }) async {
    final updatedTrip = await _repository.removeActivityFromDailyPlan(
      tripId: tripId,
      date: date,
      activityId: activityId,
    );
    state = state.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList();
  }

  /// 활동 업데이트
  Future<void> updateActivity({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    final updatedTrip = await _repository.updateActivity(
      tripId: tripId,
      date: date,
      activity: activity,
    );
    state = state.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList();
  }

  /// 활동 완료 상태 토글
  Future<void> toggleActivityCompletion({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    final updatedActivity = activity.copyWith(
      isCompleted: !activity.isCompleted,
    );

    await updateActivity(
      tripId: tripId,
      date: date,
      activity: updatedActivity,
    );
  }
}

/// 현재 편집 중인 여행 계획 관리 StateNotifier
class CurrentEditingTripNotifier extends StateNotifier<TripPlan?> {
  CurrentEditingTripNotifier() : super(null);

  /// 새 여행 계획 시작
  void startNewTrip() {
    final now = DateTime.now();
    state = TripPlan(
      id: const Uuid().v4(),
      title: '',
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      destination: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 기존 여행 계획 편집 시작
  void startEditingTrip(TripPlan trip) {
    state = trip;
  }

  /// 여행 계획 업데이트
  void updateTrip(TripPlan trip) {
    state = trip;
  }

  /// 제목 업데이트
  void updateTitle(String title) {
    if (state == null) return;
    state = state!.copyWith(title: title);
  }

  /// 날짜 업데이트
  void updateDates({DateTime? startDate, DateTime? endDate}) {
    if (state == null) return;
    state = state!.copyWith(
      startDate: startDate ?? state!.startDate,
      endDate: endDate ?? state!.endDate,
    );
  }

  /// 목적지 업데이트
  void updateDestination({
    String? destination,
    double? latitude,
    double? longitude,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      destination: destination ?? state!.destination,
      destinationLatitude: latitude ?? state!.destinationLatitude,
      destinationLongitude: longitude ?? state!.destinationLongitude,
    );
  }

  /// 메모 업데이트
  void updateMemo(String? memo) {
    if (state == null) return;
    state = state!.copyWith(memo: memo);
  }

  /// 예산 업데이트
  void updateBudget(double? budget) {
    if (state == null) return;
    state = state!.copyWith(budget: budget);
  }

  /// 썸네일 URL 업데이트
  void updateThumbnailUrl(String? thumbnailUrl) {
    if (state == null) return;
    state = state!.copyWith(thumbnailUrl: thumbnailUrl);
  }

  /// 일별 계획 추가
  void addDailyPlan(DailyPlan dailyPlan) {
    if (state == null) return;
    final updatedDailyPlans = [...state!.dailyPlans, dailyPlan];
    updatedDailyPlans.sort((a, b) => a.date.compareTo(b.date));
    state = state!.copyWith(dailyPlans: updatedDailyPlans);
  }

  /// 일별 계획 제거
  void removeDailyPlan(DateTime date) {
    if (state == null) return;
    final updatedDailyPlans = state!.dailyPlans.where((plan) {
      return !(plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day);
    }).toList();
    state = state!.copyWith(dailyPlans: updatedDailyPlans);
  }

  /// 활동 추가
  void addActivity({
    required DateTime date,
    required Activity activity,
  }) {
    if (state == null) return;

    // 해당 날짜의 DailyPlan 찾기
    final dailyPlanIndex = state!.dailyPlans.indexWhere((plan) =>
        plan.date.year == date.year &&
        plan.date.month == date.month &&
        plan.date.day == date.day);

    List<DailyPlan> updatedDailyPlans;

    if (dailyPlanIndex >= 0) {
      // 기존 DailyPlan에 활동 추가
      final dailyPlan = state!.dailyPlans[dailyPlanIndex];
      final updatedActivities = [...dailyPlan.activities, activity];
      final updatedDailyPlan = dailyPlan.copyWith(activities: updatedActivities);

      updatedDailyPlans = [...state!.dailyPlans];
      updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;
    } else {
      // 새로운 DailyPlan 생성
      final newDailyPlan = DailyPlan(
        date: date,
        activities: [activity],
      );
      updatedDailyPlans = [...state!.dailyPlans, newDailyPlan]
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    state = state!.copyWith(dailyPlans: updatedDailyPlans);
  }

  /// 활동 제거
  void removeActivity({
    required DateTime date,
    required String activityId,
  }) {
    if (state == null) return;

    final dailyPlanIndex = state!.dailyPlans.indexWhere((plan) =>
        plan.date.year == date.year &&
        plan.date.month == date.month &&
        plan.date.day == date.day);

    if (dailyPlanIndex < 0) return;

    final dailyPlan = state!.dailyPlans[dailyPlanIndex];
    final updatedActivities =
        dailyPlan.activities.where((activity) => activity.id != activityId).toList();

    final updatedDailyPlan = dailyPlan.copyWith(activities: updatedActivities);

    final updatedDailyPlans = [...state!.dailyPlans];
    updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;

    state = state!.copyWith(dailyPlans: updatedDailyPlans);
  }

  /// 활동 업데이트
  void updateActivity({
    required DateTime date,
    required Activity activity,
  }) {
    if (state == null) return;

    final dailyPlanIndex = state!.dailyPlans.indexWhere((plan) =>
        plan.date.year == date.year &&
        plan.date.month == date.month &&
        plan.date.day == date.day);

    if (dailyPlanIndex < 0) return;

    final dailyPlan = state!.dailyPlans[dailyPlanIndex];
    final activityIndex = dailyPlan.activities.indexWhere((a) => a.id == activity.id);

    if (activityIndex < 0) return;

    final updatedActivities = [...dailyPlan.activities];
    updatedActivities[activityIndex] = activity;

    final updatedDailyPlan = dailyPlan.copyWith(activities: updatedActivities);

    final updatedDailyPlans = [...state!.dailyPlans];
    updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;

    state = state!.copyWith(dailyPlans: updatedDailyPlans);
  }

  /// 편집 취소
  void cancel() {
    state = null;
  }

  /// 편집 완료 후 초기화
  void clear() {
    state = null;
  }
}

// ============================================
// Data Classes
// ============================================

/// 여행 통계
class TripStatistics {
  final int totalTrips;
  final int ongoingTrips;
  final int upcomingTrips;
  final int completedTrips;

  const TripStatistics({
    required this.totalTrips,
    required this.ongoingTrips,
    required this.upcomingTrips,
    required this.completedTrips,
  });
}
