import 'package:hive/hive.dart';
import 'daily_schedule_model.dart';

part 'travel_plan_model.g.dart';

/// 여행 상태
enum TravelStatus {
  planned, // 계획됨
  inProgress, // 진행 중
  completed, // 완료
}

/// 여행 계획 모델
@HiveType(typeId: 0)
class TravelPlan extends HiveObject {
  /// 고유 ID
  @HiveField(0)
  final String id;

  /// 여행명
  @HiveField(1)
  String name;

  /// 목적지
  @HiveField(2)
  String destination;

  /// 시작 날짜
  @HiveField(3)
  DateTime startDate;

  /// 종료 날짜
  @HiveField(4)
  DateTime endDate;

  /// 예산 (선택)
  @HiveField(5)
  double? budget;

  /// 설명 (선택)
  @HiveField(6)
  String? description;

  /// 상태
  @HiveField(7)
  String status;

  /// 생성 날짜
  @HiveField(8)
  DateTime createdAt;

  /// 수정 날짜
  @HiveField(9)
  DateTime updatedAt;

  /// 날짜별 일정 목록
  @HiveField(10)
  List<DailySchedule> dailySchedules;

  TravelPlan({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.budget,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    List<DailySchedule>? dailySchedules,
  }) : dailySchedules = dailySchedules ?? [];

  /// 여행 기간 (일수)
  int get duration {
    return endDate.difference(startDate).inDays + 1;
  }

  /// startDate부터 endDate까지의 모든 날짜 리스트
  List<DateTime> get allDates {
    final dates = <DateTime>[];
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    for (var date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }

    return dates;
  }

  /// 특정 날짜의 DailySchedule 조회
  DailySchedule? getDailyScheduleByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    try {
      return dailySchedules.firstWhere((schedule) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        return scheduleDate.isAtSameMomentAs(targetDate);
      });
    } catch (e) {
      return null;
    }
  }

  /// 상태를 TravelStatus enum으로 변환
  TravelStatus get travelStatus {
    switch (status) {
      case 'planned':
        return TravelStatus.planned;
      case 'inProgress':
        return TravelStatus.inProgress;
      case 'completed':
        return TravelStatus.completed;
      default:
        return TravelStatus.planned;
    }
  }

  /// 상태 업데이트 (날짜 기반 자동 판단)
  void updateStatusBasedOnDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (today.isBefore(start)) {
      status = 'planned';
    } else if (today.isAfter(end)) {
      status = 'completed';
    } else {
      status = 'inProgress';
    }
  }

  /// copyWith 메서드
  TravelPlan copyWith({
    String? id,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DailySchedule>? dailySchedules,
  }) {
    return TravelPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dailySchedules: dailySchedules ?? this.dailySchedules,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dailySchedules':
          dailySchedules.map((schedule) => schedule.toJson()).toList(),
    };
  }

  /// JSON에서 생성
  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      budget: json['budget'] as double?,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dailySchedules: json['dailySchedules'] != null
          ? (json['dailySchedules'] as List<dynamic>)
              .map((scheduleJson) =>
                  DailySchedule.fromJson(scheduleJson as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  @override
  String toString() {
    return 'TravelPlan(id: $id, name: $name, destination: $destination, '
        'startDate: $startDate, endDate: $endDate, status: $status)';
  }
}
