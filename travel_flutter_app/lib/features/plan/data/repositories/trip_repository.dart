import '../../../../core/utils/logger.dart';
import '../../../../shared/models/trip_plan.dart';
import '../database/trip_database.dart';

/// 여행 계획 Repository
/// TripDatabase를 래핑하여 비즈니스 로직을 추가
class TripRepository {
  final TripDatabase _database;

  TripRepository(this._database);

  // ============================================
  // CREATE
  // ============================================

  /// 여행 계획 생성
  /// 날짜 유효성 검사 및 비즈니스 로직 적용
  Future<TripPlan> createTripPlan(TripPlan tripPlan) async {
    try {
      // 날짜 유효성 검사
      _validateDates(tripPlan.startDate, tripPlan.endDate);

      // 중복 ID 검사
      if (_database.exists(tripPlan.id)) {
        throw Exception('이미 존재하는 여행 계획 ID입니다: ${tripPlan.id}');
      }

      // 생성
      return await _database.createTripPlan(tripPlan);
    } catch (e, stackTrace) {
      Logger.error('여행 계획 생성 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  // ============================================
  // READ
  // ============================================

  /// 여행 계획 조회
  TripPlan? getTripPlan(String id) {
    try {
      return _database.getTripPlan(id);
    } catch (e, stackTrace) {
      Logger.error('여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return null;
    }
  }

  /// 모든 여행 계획 조회
  List<TripPlan> getAllTripPlans() {
    try {
      return _database.getAllTripPlans();
    } catch (e, stackTrace) {
      Logger.error('모든 여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  /// 진행 중인 여행 계획 조회
  List<TripPlan> getOngoingTripPlans() {
    try {
      return _database.getOngoingTripPlans();
    } catch (e, stackTrace) {
      Logger.error('진행 중인 여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  /// 예정된 여행 계획 조회
  List<TripPlan> getUpcomingTripPlans() {
    try {
      return _database.getUpcomingTripPlans();
    } catch (e, stackTrace) {
      Logger.error('예정된 여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  /// 완료된 여행 계획 조회
  List<TripPlan> getCompletedTripPlans() {
    try {
      return _database.getCompletedTripPlans();
    } catch (e, stackTrace) {
      Logger.error('완료된 여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  /// 날짜 범위로 여행 계획 조회
  List<TripPlan> getTripPlansByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      _validateDates(startDate, endDate);

      return _database.getAllTripPlans().where((trip) {
        // 여행 기간이 조회 기간과 겹치는지 확인
        return trip.startDate.isBefore(endDate) && trip.endDate.isAfter(startDate);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('날짜 범위 여행 계획 조회 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  /// 목적지로 여행 계획 검색
  List<TripPlan> searchByDestination(String keyword) {
    try {
      if (keyword.isEmpty) return getAllTripPlans();

      final lowerKeyword = keyword.toLowerCase();
      return _database.getAllTripPlans().where((trip) {
        return trip.destination.toLowerCase().contains(lowerKeyword) ||
            trip.title.toLowerCase().contains(lowerKeyword);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('목적지 검색 실패', e, stackTrace, 'TripRepository');
      return [];
    }
  }

  // ============================================
  // UPDATE
  // ============================================

  /// 여행 계획 업데이트
  Future<TripPlan> updateTripPlan(TripPlan tripPlan) async {
    try {
      // 날짜 유효성 검사
      _validateDates(tripPlan.startDate, tripPlan.endDate);

      // 존재 여부 확인
      if (!_database.exists(tripPlan.id)) {
        throw Exception('존재하지 않는 여행 계획입니다: ${tripPlan.id}');
      }

      return await _database.updateTripPlan(tripPlan);
    } catch (e, stackTrace) {
      Logger.error('여행 계획 업데이트 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  /// 활동 추가
  Future<TripPlan> addActivityToDailyPlan({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    try {
      // 여행 계획 존재 여부 확인
      final trip = getTripPlan(tripId);
      if (trip == null) {
        throw Exception('존재하지 않는 여행 계획입니다: $tripId');
      }

      // 날짜가 여행 기간 내에 있는지 확인
      _validateDateInTripPeriod(trip, date);

      // 시간 유효성 검사
      if (activity.startTime != null && activity.endTime != null) {
        _validateActivityTimes(activity.startTime!, activity.endTime!);
      }

      return await _database.addActivityToDailyPlan(
        tripId: tripId,
        date: date,
        activity: activity,
      );
    } catch (e, stackTrace) {
      Logger.error('활동 추가 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  /// 활동 제거
  Future<TripPlan> removeActivityFromDailyPlan({
    required String tripId,
    required DateTime date,
    required String activityId,
  }) async {
    try {
      return await _database.removeActivityFromDailyPlan(
        tripId: tripId,
        date: date,
        activityId: activityId,
      );
    } catch (e, stackTrace) {
      Logger.error('활동 제거 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  /// 활동 업데이트
  Future<TripPlan> updateActivity({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    try {
      // 시간 유효성 검사
      if (activity.startTime != null && activity.endTime != null) {
        _validateActivityTimes(activity.startTime!, activity.endTime!);
      }

      return await _database.updateActivity(
        tripId: tripId,
        date: date,
        activity: activity,
      );
    } catch (e, stackTrace) {
      Logger.error('활동 업데이트 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// 여행 계획 삭제
  Future<void> deleteTripPlan(String id) async {
    try {
      if (!_database.exists(id)) {
        throw Exception('존재하지 않는 여행 계획입니다: $id');
      }

      await _database.deleteTripPlan(id);
    } catch (e, stackTrace) {
      Logger.error('여행 계획 삭제 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  /// 모든 여행 계획 삭제
  Future<void> deleteAllTripPlans() async {
    try {
      await _database.deleteAllTripPlans();
    } catch (e, stackTrace) {
      Logger.error('모든 여행 계획 삭제 실패', e, stackTrace, 'TripRepository');
      rethrow;
    }
  }

  // ============================================
  // BUSINESS LOGIC
  // ============================================

  /// 여행 기간 계산 (일 단위)
  int calculateTripDuration(TripPlan trip) {
    return trip.endDate.difference(trip.startDate).inDays + 1;
  }

  /// 총 예상 비용 계산
  double calculateTotalEstimatedCost(TripPlan trip) {
    double total = 0.0;

    for (final dailyPlan in trip.dailyPlans) {
      for (final activity in dailyPlan.activities) {
        if (activity.estimatedCost != null) {
          total += activity.estimatedCost!;
        }
      }
    }

    return total;
  }

  /// 예산 초과 여부 확인
  bool isBudgetExceeded(TripPlan trip) {
    if (trip.budget == null) return false;
    return calculateTotalEstimatedCost(trip) > trip.budget!;
  }

  /// 예산 초과 금액
  double getBudgetOverage(TripPlan trip) {
    if (trip.budget == null) return 0.0;
    final overage = calculateTotalEstimatedCost(trip) - trip.budget!;
    return overage > 0 ? overage : 0.0;
  }

  /// 예산 남은 금액
  double getRemainingBudget(TripPlan trip) {
    if (trip.budget == null) return 0.0;
    final remaining = trip.budget! - calculateTotalEstimatedCost(trip);
    return remaining > 0 ? remaining : 0.0;
  }

  /// 특정 날짜의 활동 개수
  int getActivityCountForDate(TripPlan trip, DateTime date) {
    try {
      final dailyPlan = trip.dailyPlans.firstWhere(
        (plan) =>
            plan.date.year == date.year &&
            plan.date.month == date.month &&
            plan.date.day == date.day,
      );
      return dailyPlan.activities.length;
    } catch (e) {
      // 해당 날짜의 계획이 없으면 0 반환
      return 0;
    }
  }

  /// 완료된 활동 개수
  int getCompletedActivityCount(TripPlan trip) {
    int count = 0;
    for (final dailyPlan in trip.dailyPlans) {
      count += dailyPlan.activities.where((a) => a.isCompleted).length;
    }
    return count;
  }

  /// 전체 활동 개수
  int getTotalActivityCount(TripPlan trip) {
    int count = 0;
    for (final dailyPlan in trip.dailyPlans) {
      count += dailyPlan.activities.length;
    }
    return count;
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double calculateProgress(TripPlan trip) {
    final total = getTotalActivityCount(trip);
    if (total == 0) return 0.0;

    final completed = getCompletedActivityCount(trip);
    return completed / total;
  }

  /// 여행 상태 확인
  TripStatus getTripStatus(TripPlan trip) {
    final now = DateTime.now();

    if (trip.startDate.isAfter(now)) {
      return TripStatus.upcoming;
    } else if (trip.endDate.isBefore(now)) {
      return TripStatus.completed;
    } else {
      return TripStatus.ongoing;
    }
  }

  /// 날짜 충돌 확인
  bool hasDateConflict(TripPlan newTrip, {String? excludeTripId}) {
    final allTrips = getAllTripPlans();

    for (final trip in allTrips) {
      // 본인은 제외
      if (excludeTripId != null && trip.id == excludeTripId) continue;

      // 날짜가 겹치는지 확인
      if (newTrip.startDate.isBefore(trip.endDate) &&
          newTrip.endDate.isAfter(trip.startDate)) {
        return true;
      }
    }

    return false;
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// 날짜 유효성 검사
  void _validateDates(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('종료일은 시작일 이후여야 합니다');
    }
  }

  /// 날짜가 여행 기간 내에 있는지 검사
  void _validateDateInTripPeriod(TripPlan trip, DateTime date) {
    if (date.isBefore(trip.startDate) || date.isAfter(trip.endDate)) {
      throw ArgumentError('날짜가 여행 기간(${trip.startDate} ~ ${trip.endDate}) 내에 없습니다');
    }
  }

  /// 활동 시간 유효성 검사
  void _validateActivityTimes(DateTime startTime, DateTime endTime) {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError('종료 시간은 시작 시간 이후여야 합니다');
    }
  }

  // ============================================
  // UTILITIES
  // ============================================

  /// 여행 계획 존재 여부
  bool exists(String id) {
    return _database.exists(id);
  }

  /// 저장된 여행 계획 개수
  int get count => _database.count;
}

/// 여행 상태
enum TripStatus {
  /// 예정
  upcoming,

  /// 진행 중
  ongoing,

  /// 완료
  completed,
}

/// TripStatus 확장 메서드
extension TripStatusExtension on TripStatus {
  /// 상태 이름 (한글)
  String get displayName {
    switch (this) {
      case TripStatus.upcoming:
        return '예정';
      case TripStatus.ongoing:
        return '진행 중';
      case TripStatus.completed:
        return '완료';
    }
  }

  /// 상태 색상
  String get colorName {
    switch (this) {
      case TripStatus.upcoming:
        return 'primary';
      case TripStatus.ongoing:
        return 'success';
      case TripStatus.completed:
        return 'textSecondary';
    }
  }
}
