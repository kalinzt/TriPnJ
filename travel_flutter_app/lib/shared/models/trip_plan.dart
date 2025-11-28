import 'package:freezed_annotation/freezed_annotation.dart';
import 'place.dart';

part 'trip_plan.freezed.dart';
part 'trip_plan.g.dart';

/// 여행 계획
@freezed
class TripPlan with _$TripPlan {
  const factory TripPlan({
    /// 고유 ID
    required String id,

    /// 여행 제목
    required String title,

    /// 여행 시작일
    required DateTime startDate,

    /// 여행 종료일
    required DateTime endDate,

    /// 목적지
    required String destination,

    /// 목적지 위도
    double? destinationLatitude,

    /// 목적지 경도
    double? destinationLongitude,

    /// 일별 계획 목록
    @Default([]) List<DailyPlan> dailyPlans,

    /// 여행 메모
    String? memo,

    /// 예산
    double? budget,

    /// 썸네일 이미지 URL
    String? thumbnailUrl,

    /// 생성 일시
    required DateTime createdAt,

    /// 수정 일시
    required DateTime updatedAt,
  }) = _TripPlan;

  factory TripPlan.fromJson(Map<String, dynamic> json) =>
      _$TripPlanFromJson(json);
}

/// 일별 여행 계획
@freezed
class DailyPlan with _$DailyPlan {
  const factory DailyPlan({
    /// 날짜
    required DateTime date,

    /// 일정 제목 (예: "서울 첫째 날")
    String? title,

    /// 활동 목록
    @Default([]) List<Activity> activities,

    /// 일별 메모
    String? memo,
  }) = _DailyPlan;

  factory DailyPlan.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanFromJson(json);
}

/// 여행 활동
@freezed
class Activity with _$Activity {
  const factory Activity({
    /// 고유 ID
    required String id,

    /// 시작 시간
    DateTime? startTime,

    /// 종료 시간 (또는 소요 시간)
    DateTime? endTime,

    /// 소요 시간 (분 단위)
    int? durationMinutes,

    /// 장소 (Place 모델)
    Place? place,

    /// 활동 제목 (place가 없을 경우 사용)
    String? title,

    /// 활동 유형
    @Default(ActivityType.visit) ActivityType type,

    /// 메모
    String? memo,

    /// 예상 비용
    double? estimatedCost,

    /// 예약 정보
    String? reservationInfo,

    /// 완료 여부
    @Default(false) bool isCompleted,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}

/// 활동 유형
enum ActivityType {
  /// 방문
  visit,

  /// 식사
  meal,

  /// 숙박
  accommodation,

  /// 교통
  transportation,

  /// 쇼핑
  shopping,

  /// 액티비티
  activity,

  /// 휴식
  rest,

  /// 기타
  other,
}

/// ActivityType 확장 메서드
extension ActivityTypeExtension on ActivityType {
  /// 활동 유형 이름 (한글)
  String get displayName {
    switch (this) {
      case ActivityType.visit:
        return '방문';
      case ActivityType.meal:
        return '식사';
      case ActivityType.accommodation:
        return '숙박';
      case ActivityType.transportation:
        return '교통';
      case ActivityType.shopping:
        return '쇼핑';
      case ActivityType.activity:
        return '액티비티';
      case ActivityType.rest:
        return '휴식';
      case ActivityType.other:
        return '기타';
    }
  }

  /// 활동 유형 아이콘
  String get iconName {
    switch (this) {
      case ActivityType.visit:
        return '📍';
      case ActivityType.meal:
        return '🍽️';
      case ActivityType.accommodation:
        return '🏨';
      case ActivityType.transportation:
        return '🚗';
      case ActivityType.shopping:
        return '🛍️';
      case ActivityType.activity:
        return '⛷️';
      case ActivityType.rest:
        return '☕';
      case ActivityType.other:
        return '📝';
    }
  }
}
