import 'package:travel_flutter_app/core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import '../models/daily_schedule_model.dart';
import '../models/activity_model.dart';

/// DailySchedule을 관리하는 Repository
class DailyScheduleRepository {
  static const String _boxName = 'daily_schedules';
  static Box<Map>? _box;

  /// Hive Box를 가져오는 메서드 (싱글톤 패턴)
  Future<Box<Map>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  /// DailySchedule을 저장합니다.
  ///
  /// [dailySchedule] 저장할 DailySchedule 객체
  ///
  /// 이미 존재하면 덮어쓰기합니다.
  Future<void> addDailySchedule(DailySchedule dailySchedule) async {
    try {
      final box = await _getBox();
      await box.put(dailySchedule.id, dailySchedule.toJson());
      appLogger.d('DailySchedule 저장 완료: ${dailySchedule.id}');
    } catch (e) {
      appLogger.d('DailyScheduleRepository 에러: $e');
      rethrow;
    }
  }

  /// 특정 여행의 모든 DailySchedule을 조회합니다.
  ///
  /// [travelPlanId] 조회할 여행 계획 ID
  ///
  /// 반환값: 날짜 순서대로 정렬된 DailySchedule 리스트
  Future<List<DailySchedule>> getDailySchedules(String travelPlanId) async {
    try {
      final box = await _getBox();
      final schedules = <DailySchedule>[];

      for (var entry in box.values) {
        try {
          final schedule =
              DailySchedule.fromJson(Map<String, dynamic>.from(entry));
          if (schedule.travelPlanId == travelPlanId) {
            schedules.add(schedule);
          }
        } catch (e) {
          appLogger.d('DailySchedule 파싱 에러: $e');
        }
      }

      // 날짜 순서대로 정렬
      schedules.sort((a, b) => a.date.compareTo(b.date));

      appLogger.d('조회된 DailySchedule 수: ${schedules.length}');
      return schedules;
    } catch (e) {
      appLogger.d('DailyScheduleRepository 에러: $e');
      return [];
    }
  }

  /// 특정 ID의 DailySchedule을 조회합니다.
  ///
  /// [dailyScheduleId] 조회할 DailySchedule의 ID
  ///
  /// 반환값: DailySchedule 객체, 없으면 null
  Future<DailySchedule?> getDailyScheduleById(String dailyScheduleId) async {
    try {
      final box = await _getBox();
      final data = box.get(dailyScheduleId);

      if (data == null) return null;

      return DailySchedule.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      appLogger.d('DailyScheduleRepository 에러: $e');
      return null;
    }
  }

  /// 기존 DailySchedule을 수정합니다.
  ///
  /// [dailySchedule] 수정할 DailySchedule 객체
  ///
  /// updatedAt 필드를 현재 시간으로 자동 업데이트합니다.
  Future<void> updateDailySchedule(DailySchedule dailySchedule) async {
    try {
      final box = await _getBox();

      // updatedAt을 현재 시간으로 업데이트
      final updatedSchedule = dailySchedule.copyWith(
        updatedAt: DateTime.now(),
      );

      await box.put(updatedSchedule.id, updatedSchedule.toJson());
      appLogger.d('DailySchedule 수정 완료: ${updatedSchedule.id}');
    } catch (e) {
      appLogger.d('DailyScheduleRepository 에러: $e');
      rethrow;
    }
  }

  /// 특정 DailySchedule을 삭제합니다.
  ///
  /// [dailyScheduleId] 삭제할 DailySchedule의 ID
  ///
  /// 삭제 전에 해당 날짜의 모든 Activity도 함께 삭제합니다.
  Future<void> deleteDailySchedule(String dailyScheduleId) async {
    try {
      final box = await _getBox();

      // DailySchedule의 Activity들도 함께 삭제
      final activityBox = await Hive.openBox<Map>('activities');
      final keysToDelete = <String>[];

      for (var key in activityBox.keys) {
        try {
          final activityData = activityBox.get(key);
          if (activityData != null) {
            final activity =
                Activity.fromJson(Map<String, dynamic>.from(activityData));
            if (activity.dailyScheduleId == dailyScheduleId) {
              keysToDelete.add(key.toString());
            }
          }
        } catch (e) {
          appLogger.d('Activity 파싱 에러: $e');
        }
      }

      // Activity 삭제
      for (var key in keysToDelete) {
        await activityBox.delete(key);
      }

      // DailySchedule 삭제
      await box.delete(dailyScheduleId);
      appLogger.d('DailySchedule 삭제 완료: $dailyScheduleId (${keysToDelete.length}개 Activity 함께 삭제)');
    } catch (e) {
      appLogger.d('DailyScheduleRepository 에러: $e');
      rethrow;
    }
  }

  /// Box를 닫습니다. (앱 종료 시 사용)
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
