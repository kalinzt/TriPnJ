import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/trip_plan.dart';

/// 여행 계획 데이터베이스
/// JSON 직렬화를 사용하여 Hive에 저장
class TripDatabase {
  static const String _boxName = 'trip_plans';
  Box<String>? _box;

  /// Hive box 초기화
  Future<void> initialize() async {
    try {
      Logger.info('여행 계획 데이터베이스 초기화 중...', 'TripDatabase');

      _box = await Hive.openBox<String>(_boxName);
      Logger.info('여행 계획 데이터베이스 초기화 완료', 'TripDatabase');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 데이터베이스 초기화 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  /// Box 가져오기
  Box<String> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('TripDatabase가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _box!;
  }

  /// TripPlan을 JSON으로 인코딩
  String _encodeTripPlan(TripPlan tripPlan) {
    return jsonEncode(tripPlan.toJson());
  }

  /// JSON을 TripPlan으로 디코딩
  TripPlan _decodeTripPlan(String jsonString) {
    return TripPlan.fromJson(jsonDecode(jsonString));
  }

  // ============================================
  // CREATE
  // ============================================

  /// 여행 계획 생성
  Future<TripPlan> createTripPlan(TripPlan tripPlan) async {
    try {
      Logger.info('여행 계획 생성: ${tripPlan.title}', 'TripDatabase');

      final jsonString = _encodeTripPlan(tripPlan);
      await box.put(tripPlan.id, jsonString);
      Logger.info('여행 계획 생성 완료: ${tripPlan.id}', 'TripDatabase');

      return tripPlan;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 생성 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  // ============================================
  // READ
  // ============================================

  /// 여행 계획 가져오기
  TripPlan? getTripPlan(String id) {
    try {
      final jsonString = box.get(id);
      if (jsonString == null) return null;
      return _decodeTripPlan(jsonString);
    } catch (e, stackTrace) {
      Logger.error('여행 계획 조회 실패: $id', e, stackTrace, 'TripDatabase');
      return null;
    }
  }

  /// 모든 여행 계획 가져오기
  List<TripPlan> getAllTripPlans() {
    try {
      return box.values.map((jsonString) => _decodeTripPlan(jsonString)).toList();
    } catch (e, stackTrace) {
      Logger.error('모든 여행 계획 조회 실패', e, stackTrace, 'TripDatabase');
      return [];
    }
  }

  /// 진행 중인 여행 계획 가져오기 (현재 날짜 기준)
  List<TripPlan> getOngoingTripPlans() {
    try {
      final now = DateTime.now();
      return box.values
          .map((jsonString) => _decodeTripPlan(jsonString))
          .where((trip) {
        return trip.startDate.isBefore(now) && trip.endDate.isAfter(now);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('진행 중인 여행 계획 조회 실패', e, stackTrace, 'TripDatabase');
      return [];
    }
  }

  /// 예정된 여행 계획 가져오기
  List<TripPlan> getUpcomingTripPlans() {
    try {
      final now = DateTime.now();
      final upcomingTrips = box.values
          .map((jsonString) => _decodeTripPlan(jsonString))
          .where((trip) {
        return trip.startDate.isAfter(now);
      }).toList();

      // 시작 날짜 기준 정렬
      upcomingTrips.sort((a, b) => a.startDate.compareTo(b.startDate));

      return upcomingTrips;
    } catch (e, stackTrace) {
      Logger.error('예정된 여행 계획 조회 실패', e, stackTrace, 'TripDatabase');
      return [];
    }
  }

  /// 완료된 여행 계획 가져오기
  List<TripPlan> getCompletedTripPlans() {
    try {
      final now = DateTime.now();
      final completedTrips = box.values
          .map((jsonString) => _decodeTripPlan(jsonString))
          .where((trip) {
        return trip.endDate.isBefore(now);
      }).toList();

      // 종료 날짜 기준 내림차순 정렬
      completedTrips.sort((a, b) => b.endDate.compareTo(a.endDate));

      return completedTrips;
    } catch (e, stackTrace) {
      Logger.error('완료된 여행 계획 조회 실패', e, stackTrace, 'TripDatabase');
      return [];
    }
  }

  // ============================================
  // UPDATE
  // ============================================

  /// 여행 계획 업데이트
  Future<TripPlan> updateTripPlan(TripPlan tripPlan) async {
    try {
      Logger.info('여행 계획 업데이트: ${tripPlan.title}', 'TripDatabase');

      // updatedAt 갱신
      final updatedTrip = tripPlan.copyWith(
        updatedAt: DateTime.now(),
      );

      final jsonString = _encodeTripPlan(updatedTrip);
      await box.put(updatedTrip.id, jsonString);
      Logger.info('여행 계획 업데이트 완료: ${updatedTrip.id}', 'TripDatabase');

      return updatedTrip;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 업데이트 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  /// 일별 계획에 활동 추가
  Future<TripPlan> addActivityToDailyPlan({
    required String tripId,
    required DateTime date,
    required Activity activity,
  }) async {
    try {
      final trip = getTripPlan(tripId);
      if (trip == null) {
        throw Exception('여행 계획을 찾을 수 없습니다: $tripId');
      }

      // 해당 날짜의 DailyPlan 찾기
      final dailyPlanIndex = trip.dailyPlans.indexWhere((plan) =>
          plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day);

      List<DailyPlan> updatedDailyPlans;

      if (dailyPlanIndex >= 0) {
        // 기존 DailyPlan에 활동 추가
        final dailyPlan = trip.dailyPlans[dailyPlanIndex];
        final updatedActivities = [...dailyPlan.activities, activity];
        final updatedDailyPlan =
            dailyPlan.copyWith(activities: updatedActivities);

        updatedDailyPlans = [...trip.dailyPlans];
        updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;
      } else {
        // 새로운 DailyPlan 생성
        final newDailyPlan = DailyPlan(
          date: date,
          activities: [activity],
        );
        updatedDailyPlans = [...trip.dailyPlans, newDailyPlan]
          ..sort((a, b) => a.date.compareTo(b.date));
      }

      final updatedTrip = trip.copyWith(dailyPlans: updatedDailyPlans);
      return await updateTripPlan(updatedTrip);
    } catch (e, stackTrace) {
      Logger.error('활동 추가 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  /// 일별 계획에서 활동 제거
  Future<TripPlan> removeActivityFromDailyPlan({
    required String tripId,
    required DateTime date,
    required String activityId,
  }) async {
    try {
      final trip = getTripPlan(tripId);
      if (trip == null) {
        throw Exception('여행 계획을 찾을 수 없습니다: $tripId');
      }

      // 해당 날짜의 DailyPlan 찾기
      final dailyPlanIndex = trip.dailyPlans.indexWhere((plan) =>
          plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day);

      if (dailyPlanIndex < 0) {
        throw Exception('해당 날짜의 계획을 찾을 수 없습니다');
      }

      final dailyPlan = trip.dailyPlans[dailyPlanIndex];
      final updatedActivities = dailyPlan.activities
          .where((activity) => activity.id != activityId)
          .toList();

      final updatedDailyPlan =
          dailyPlan.copyWith(activities: updatedActivities);

      final updatedDailyPlans = [...trip.dailyPlans];
      updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;

      final updatedTrip = trip.copyWith(dailyPlans: updatedDailyPlans);
      return await updateTripPlan(updatedTrip);
    } catch (e, stackTrace) {
      Logger.error('활동 제거 실패', e, stackTrace, 'TripDatabase');
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
      final trip = getTripPlan(tripId);
      if (trip == null) {
        throw Exception('여행 계획을 찾을 수 없습니다: $tripId');
      }

      final dailyPlanIndex = trip.dailyPlans.indexWhere((plan) =>
          plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day);

      if (dailyPlanIndex < 0) {
        throw Exception('해당 날짜의 계획을 찾을 수 없습니다');
      }

      final dailyPlan = trip.dailyPlans[dailyPlanIndex];
      final activityIndex =
          dailyPlan.activities.indexWhere((a) => a.id == activity.id);

      if (activityIndex < 0) {
        throw Exception('활동을 찾을 수 없습니다: ${activity.id}');
      }

      final updatedActivities = [...dailyPlan.activities];
      updatedActivities[activityIndex] = activity;

      final updatedDailyPlan =
          dailyPlan.copyWith(activities: updatedActivities);

      final updatedDailyPlans = [...trip.dailyPlans];
      updatedDailyPlans[dailyPlanIndex] = updatedDailyPlan;

      final updatedTrip = trip.copyWith(dailyPlans: updatedDailyPlans);
      return await updateTripPlan(updatedTrip);
    } catch (e, stackTrace) {
      Logger.error('활동 업데이트 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// 여행 계획 삭제
  Future<void> deleteTripPlan(String id) async {
    try {
      Logger.info('여행 계획 삭제: $id', 'TripDatabase');

      await box.delete(id);
      Logger.info('여행 계획 삭제 완료: $id', 'TripDatabase');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 삭제 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  /// 모든 여행 계획 삭제
  Future<void> deleteAllTripPlans() async {
    try {
      Logger.warning('모든 여행 계획 삭제', 'TripDatabase');

      await box.clear();
      Logger.info('모든 여행 계획 삭제 완료', 'TripDatabase');
    } catch (e, stackTrace) {
      Logger.error('모든 여행 계획 삭제 실패', e, stackTrace, 'TripDatabase');
      rethrow;
    }
  }

  // ============================================
  // UTILITIES
  // ============================================

  /// 여행 계획 존재 여부 확인
  bool exists(String id) {
    return box.containsKey(id);
  }

  /// 저장된 여행 계획 개수
  int get count => box.length;

  /// 데이터베이스 닫기
  Future<void> close() async {
    await _box?.close();
    _box = null;
    Logger.info('여행 계획 데이터베이스 닫힘', 'TripDatabase');
  }
}
