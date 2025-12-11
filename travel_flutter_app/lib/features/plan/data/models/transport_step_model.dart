/// 경로의 각 단계 정보를 나타내는 모델
class TransportStep {
  /// 고유 ID
  final String stepId;

  /// 아이콘 타입 (예: 'bus', 'train', 'subway', 'walking' 등)
  final String? icon;

  /// 단계명 (예: "9호선", "공항철도")
  final String name;

  /// 소요 시간 (예: "15분")
  final String duration;

  /// 타입 (예: 'transit', 'walking' 등)
  final String type;

  /// 출발역/정류장 이름 (예: "홍대입구역", "신촌역 1번 출구")
  final String? departureStop;

  /// 도착역/정류장 이름 (예: "을지로3가역", "강남역 2번 출구")
  final String? arrivalStop;

  /// 정거장 수 (예: 13개 정거장)
  final int? numStops;

  const TransportStep({
    required this.stepId,
    this.icon,
    required this.name,
    required this.duration,
    required this.type,
    this.departureStop,
    this.arrivalStop,
    this.numStops,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'icon': icon,
      'name': name,
      'duration': duration,
      'type': type,
      'departureStop': departureStop,
      'arrivalStop': arrivalStop,
      'numStops': numStops,
    };
  }

  /// JSON에서 생성
  factory TransportStep.fromJson(Map<String, dynamic> json) {
    // Map<dynamic, dynamic>을 Map<String, dynamic>으로 안전하게 변환
    final safeJson = Map<String, dynamic>.from(json);

    return TransportStep(
      stepId: safeJson['stepId'] as String,
      icon: safeJson['icon'] as String?,
      name: safeJson['name'] as String,
      duration: safeJson['duration'] as String,
      type: safeJson['type'] as String,
      departureStop: safeJson['departureStop'] as String?,
      arrivalStop: safeJson['arrivalStop'] as String?,
      numStops: safeJson['numStops'] as int?,
    );
  }

  /// 데이터 수정을 위한 copyWith 메서드
  TransportStep copyWith({
    String? stepId,
    String? icon,
    String? name,
    String? duration,
    String? type,
    String? departureStop,
    String? arrivalStop,
    int? numStops,
  }) {
    return TransportStep(
      stepId: stepId ?? this.stepId,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      departureStop: departureStop ?? this.departureStop,
      arrivalStop: arrivalStop ?? this.arrivalStop,
      numStops: numStops ?? this.numStops,
    );
  }

  @override
  String toString() {
    return 'TransportStep(stepId: $stepId, icon: $icon, name: $name, '
        'duration: $duration, type: $type, departureStop: $departureStop, '
        'arrivalStop: $arrivalStop, numStops: $numStops)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransportStep &&
        other.stepId == stepId &&
        other.icon == icon &&
        other.name == name &&
        other.duration == duration &&
        other.type == type &&
        other.departureStop == departureStop &&
        other.arrivalStop == arrivalStop &&
        other.numStops == numStops;
  }

  @override
  int get hashCode {
    return Object.hash(
      stepId,
      icon,
      name,
      duration,
      type,
      departureStop,
      arrivalStop,
      numStops,
    );
  }
}
