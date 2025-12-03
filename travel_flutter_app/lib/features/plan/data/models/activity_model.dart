/// 여행 활동(스케줄) 모델
class Activity {
  /// 고유 ID (UUID)
  final String id;

  /// 부모 DailySchedule의 ID
  final String dailyScheduleId;

  /// 스케줄 타입 (flight: 비행, accommodation: 숙소, tour: 관광, restaurant: 식당, activity: 액티비티)
  final String type;

  /// 스케줄 제목 (예: "비행", "숙소 체크인")
  final String title;

  /// 시작 시간
  final DateTime startTime;

  /// 종료 시간
  final DateTime endTime;

  /// 출발지 (선택)
  final String? departureLocation;

  /// 도착지 (선택)
  final String? arrivalLocation;

  /// 교통편 (예: "카타르 항공 QA765", 선택)
  final String? transportation;

  /// 비용 (예: "3,600,000원", 선택)
  final String? cost;

  /// 비고 (선택)
  final String? notes;

  /// 표시 순서 (시간 순서대로 정렬하기 위한 순서)
  final int displayOrder;

  const Activity({
    required this.id,
    required this.dailyScheduleId,
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.departureLocation,
    this.arrivalLocation,
    this.transportation,
    this.cost,
    this.notes,
    required this.displayOrder,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyScheduleId': dailyScheduleId,
      'type': type,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'departureLocation': departureLocation,
      'arrivalLocation': arrivalLocation,
      'transportation': transportation,
      'cost': cost,
      'notes': notes,
      'displayOrder': displayOrder,
    };
  }

  /// JSON에서 생성
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      dailyScheduleId: json['dailyScheduleId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      departureLocation: json['departureLocation'] as String?,
      arrivalLocation: json['arrivalLocation'] as String?,
      transportation: json['transportation'] as String?,
      cost: json['cost'] as String?,
      notes: json['notes'] as String?,
      displayOrder: json['displayOrder'] as int,
    );
  }

  /// 데이터 수정을 위한 copyWith 메서드
  Activity copyWith({
    String? id,
    String? dailyScheduleId,
    String? type,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? departureLocation,
    String? arrivalLocation,
    String? transportation,
    String? cost,
    String? notes,
    int? displayOrder,
  }) {
    return Activity(
      id: id ?? this.id,
      dailyScheduleId: dailyScheduleId ?? this.dailyScheduleId,
      type: type ?? this.type,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      departureLocation: departureLocation ?? this.departureLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      transportation: transportation ?? this.transportation,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, dailyScheduleId: $dailyScheduleId, type: $type, '
        'title: $title, startTime: $startTime, endTime: $endTime, '
        'departureLocation: $departureLocation, arrivalLocation: $arrivalLocation, '
        'transportation: $transportation, cost: $cost, notes: $notes, '
        'displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Activity &&
        other.id == id &&
        other.dailyScheduleId == dailyScheduleId &&
        other.type == type &&
        other.title == title &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.departureLocation == departureLocation &&
        other.arrivalLocation == arrivalLocation &&
        other.transportation == transportation &&
        other.cost == cost &&
        other.notes == notes &&
        other.displayOrder == displayOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      dailyScheduleId,
      type,
      title,
      startTime,
      endTime,
      departureLocation,
      arrivalLocation,
      transportation,
      cost,
      notes,
      displayOrder,
    );
  }
}
