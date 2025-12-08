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

  const TransportStep({
    required this.stepId,
    this.icon,
    required this.name,
    required this.duration,
    required this.type,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'icon': icon,
      'name': name,
      'duration': duration,
      'type': type,
    };
  }

  /// JSON에서 생성
  factory TransportStep.fromJson(Map<String, dynamic> json) {
    return TransportStep(
      stepId: json['stepId'] as String,
      icon: json['icon'] as String?,
      name: json['name'] as String,
      duration: json['duration'] as String,
      type: json['type'] as String,
    );
  }

  /// 데이터 수정을 위한 copyWith 메서드
  TransportStep copyWith({
    String? stepId,
    String? icon,
    String? name,
    String? duration,
    String? type,
  }) {
    return TransportStep(
      stepId: stepId ?? this.stepId,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'TransportStep(stepId: $stepId, icon: $icon, name: $name, '
        'duration: $duration, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransportStep &&
        other.stepId == stepId &&
        other.icon == icon &&
        other.name == name &&
        other.duration == duration &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      stepId,
      icon,
      name,
      duration,
      type,
    );
  }
}
