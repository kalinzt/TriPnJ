import 'activity_model.dart';

/// 날짜별 여행 일정 모델
class DailySchedule {
  /// 고유 ID (UUID)
  final String id;

  /// 부모 TravelPlan의 ID
  final String travelPlanId;

  /// 해당 날짜 (시간은 00:00:00)
  final DateTime date;

  /// 그 날의 모든 활동 목록
  final List<Activity> activities;

  /// 해당 날짜의 메모 (선택)
  final String? notes;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  const DailySchedule({
    required this.id,
    required this.travelPlanId,
    required this.date,
    required this.activities,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 활동 목록을 시간순으로 정렬하여 반환
  List<Activity> get sortedActivities {
    final sorted = List<Activity>.from(activities);
    sorted.sort((a, b) {
      // displayOrder가 같으면 startTime으로 비교
      final orderCompare = a.displayOrder.compareTo(b.displayOrder);
      if (orderCompare != 0) return orderCompare;
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelPlanId': travelPlanId,
      'date': date.toIso8601String(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      id: json['id'] as String,
      travelPlanId: json['travelPlanId'] as String,
      date: DateTime.parse(json['date'] as String),
      activities: (json['activities'] as List<dynamic>)
          .map((activityJson) =>
              Activity.fromJson(activityJson as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 데이터 수정을 위한 copyWith 메서드
  DailySchedule copyWith({
    String? id,
    String? travelPlanId,
    DateTime? date,
    List<Activity>? activities,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailySchedule(
      id: id ?? this.id,
      travelPlanId: travelPlanId ?? this.travelPlanId,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailySchedule(id: $id, travelPlanId: $travelPlanId, date: $date, '
        'activities: ${activities.length} items, notes: $notes, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailySchedule &&
        other.id == id &&
        other.travelPlanId == travelPlanId &&
        other.date == date &&
        _listEquals(other.activities, activities) &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      travelPlanId,
      date,
      Object.hashAll(activities),
      notes,
      createdAt,
      updatedAt,
    );
  }

  /// 리스트 동등성 검사 헬퍼 함수
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
