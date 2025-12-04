/// 경로 좌표 정보
class RouteCoordinates {
  /// 출발지 위도
  final double startLatitude;

  /// 출발지 경도
  final double startLongitude;

  /// 도착지 위도
  final double endLatitude;

  /// 도착지 경도
  final double endLongitude;

  /// 경유지 좌표 리스트 (위도, 경도)
  final List<Map<String, double>> waypoints;

  const RouteCoordinates({
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    this.waypoints = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'waypoints': waypoints,
    };
  }

  factory RouteCoordinates.fromJson(Map<String, dynamic> json) {
    return RouteCoordinates(
      startLatitude: json['startLatitude'] as double,
      startLongitude: json['startLongitude'] as double,
      endLatitude: json['endLatitude'] as double,
      endLongitude: json['endLongitude'] as double,
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => Map<String, double>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}

/// 경로 검색 결과 모델
class RouteOption {
  /// 고유 ID
  final String routeId;

  /// 이동 수단 (transit: 대중교통, driving: 자동차, walking: 도보 등)
  final String transportMode;

  /// 탈것 정보 (예: "카타르 항공 QA765", 선택)
  final String? vehicleInfo;

  /// 이동 시간 (분 단위)
  final int durationMinutes;

  /// 거리 (예: "9000 km")
  final String distance;

  /// 추가 정보 (예: "도하 경유 3시간", 선택)
  final String? details;

  /// 경로 좌표 정보
  final RouteCoordinates? coordinates;

  const RouteOption({
    required this.routeId,
    required this.transportMode,
    this.vehicleInfo,
    required this.durationMinutes,
    required this.distance,
    this.details,
    this.coordinates,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'transportMode': transportMode,
      'vehicleInfo': vehicleInfo,
      'durationMinutes': durationMinutes,
      'distance': distance,
      'details': details,
      'coordinates': coordinates?.toJson(),
    };
  }

  /// JSON에서 생성
  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      routeId: json['routeId'] as String,
      transportMode: json['transportMode'] as String,
      vehicleInfo: json['vehicleInfo'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      distance: json['distance'] as String,
      details: json['details'] as String?,
      coordinates: json['coordinates'] != null
          ? RouteCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 데이터 수정을 위한 copyWith 메서드
  RouteOption copyWith({
    String? routeId,
    String? transportMode,
    String? vehicleInfo,
    int? durationMinutes,
    String? distance,
    String? details,
    RouteCoordinates? coordinates,
  }) {
    return RouteOption(
      routeId: routeId ?? this.routeId,
      transportMode: transportMode ?? this.transportMode,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distance: distance ?? this.distance,
      details: details ?? this.details,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  String toString() {
    return 'RouteOption(routeId: $routeId, transportMode: $transportMode, '
        'vehicleInfo: $vehicleInfo, durationMinutes: $durationMinutes, '
        'distance: $distance, details: $details, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteOption &&
        other.routeId == routeId &&
        other.transportMode == transportMode &&
        other.vehicleInfo == vehicleInfo &&
        other.durationMinutes == durationMinutes &&
        other.distance == distance &&
        other.details == details &&
        other.coordinates == coordinates;
  }

  @override
  int get hashCode {
    return Object.hash(
      routeId,
      transportMode,
      vehicleInfo,
      durationMinutes,
      distance,
      details,
      coordinates,
    );
  }
}
