import 'package:travel_flutter_app/core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import '../models/activity_model.dart';

/// Activity를 관리하는 Repository
class ActivityRepository {
  static const String _boxName = 'activities';
  static Box<Map>? _box;

  /// Hive Box를 가져오는 메서드 (싱글톤 패턴)
  Future<Box<Map>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  /// Activity를 저장합니다.
  ///
  /// [activity] 저장할 Activity 객체
  ///
  /// 저장 후 displayOrder를 자동으로 계산합니다.
  Future<void> addActivity(Activity activity) async {
    try {
      final box = await _getBox();
      await box.put(activity.id, activity.toJson());
      appLogger.d('Activity 저장 완료: ${activity.id}');

      // displayOrder 재계산
      await recalculateDisplayOrder(activity.dailyScheduleId);
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
      rethrow;
    }
  }

  /// 특정 날짜의 모든 Activity를 조회합니다.
  ///
  /// [dailyScheduleId] 조회할 DailySchedule의 ID
  ///
  /// 반환값: startTime 기준 오름차순으로 정렬된 Activity 리스트
  Future<List<Activity>> getActivitiesByDate(String dailyScheduleId) async {
    try {
      final box = await _getBox();
      final activities = <Activity>[];

      for (var entry in box.values) {
        try {
          final activity = Activity.fromJson(Map<String, dynamic>.from(entry));
          if (activity.dailyScheduleId == dailyScheduleId) {
            activities.add(activity);
          }
        } catch (e) {
          appLogger.d('Activity 파싱 에러: $e');
        }
      }

      // startTime 기준으로 오름차순 정렬
      activities.sort((a, b) => a.startTime.compareTo(b.startTime));

      appLogger.d('조회된 Activity 수: ${activities.length}');
      return activities;
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
      return [];
    }
  }

  /// 특정 ID의 Activity를 조회합니다.
  ///
  /// [activityId] 조회할 Activity의 ID
  ///
  /// 반환값: Activity 객체, 없으면 null
  Future<Activity?> getActivityById(String activityId) async {
    try {
      final box = await _getBox();
      final data = box.get(activityId);

      if (data == null) return null;

      return Activity.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
      return null;
    }
  }

  /// 기존 Activity를 수정합니다.
  ///
  /// [activity] 수정할 Activity 객체
  ///
  /// 수정 후 다른 Activity의 displayOrder를 재계산합니다.
  Future<void> updateActivity(Activity activity) async {
    try {
      final box = await _getBox();
      await box.put(activity.id, activity.toJson());
      appLogger.d('Activity 수정 완료: ${activity.id}');

      // displayOrder 재계산
      await recalculateDisplayOrder(activity.dailyScheduleId);
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
      rethrow;
    }
  }

  /// 특정 Activity를 삭제합니다.
  ///
  /// [activityId] 삭제할 Activity의 ID
  ///
  /// 삭제 후 남은 Activity의 displayOrder를 재계산합니다.
  Future<void> deleteActivity(String activityId) async {
    try {
      final box = await _getBox();

      // 삭제하기 전에 dailyScheduleId를 가져옴
      final activity = await getActivityById(activityId);
      if (activity == null) {
        appLogger.d('삭제할 Activity를 찾을 수 없음: $activityId');
        return;
      }

      final dailyScheduleId = activity.dailyScheduleId;

      // Activity 삭제
      await box.delete(activityId);
      appLogger.d('Activity 삭제 완료: $activityId');

      // displayOrder 재계산
      await recalculateDisplayOrder(dailyScheduleId);
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
      rethrow;
    }
  }

  /// 특정 날짜의 모든 Activity를 시간순으로 정렬하고 displayOrder를 재계산합니다.
  ///
  /// [dailyScheduleId] 재계산할 DailySchedule의 ID
  ///
  /// startTime 순서대로 0부터 시작하는 displayOrder를 할당합니다.
  /// Activity 추가/삭제/수정 후 항상 호출되어야 합니다.
  Future<void> recalculateDisplayOrder(String dailyScheduleId) async {
    try {
      final activities = await getActivitiesByDate(dailyScheduleId);

      // startTime 기준으로 이미 정렬되어 있음
      final box = await _getBox();

      for (int i = 0; i < activities.length; i++) {
        final updatedActivity = activities[i].copyWith(displayOrder: i);
        await box.put(updatedActivity.id, updatedActivity.toJson());
      }

      appLogger.d('displayOrder 재계산 완료: $dailyScheduleId (${activities.length}개 Activity)');
    } catch (e) {
      appLogger.d('ActivityRepository 에러: $e');
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
