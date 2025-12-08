import 'package:flutter/foundation.dart';
import 'transport_step_model.dart';

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
    // Map<dynamic, dynamic>을 Map<String, dynamic>으로 안전하게 변환
    final safeJson = Map<String, dynamic>.from(json);

    return RouteCoordinates(
      startLatitude: safeJson['startLatitude'] as double,
      startLongitude: safeJson['startLongitude'] as double,
      endLatitude: safeJson['endLatitude'] as double,
      endLongitude: safeJson['endLongitude'] as double,
      waypoints: (safeJson['waypoints'] as List<dynamic>?)
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

  /// 출발지명 (예: "서울")
  final String? departureLocation;

  /// 도착지명 (예: "부산")
  final String? arrivalLocation;

  /// 경로의 각 단계 정보 (예: 9호선 → 공항철도)
  final List<TransportStep>? transportOptions;

  /// 예상 도착 시간 (예: "18분(정시) 후")
  final String? estimatedArrivalTime;

  /// 지연 시 도착 시간 (예: "32분(지연됨) 후")
  final String? delayedArrivalTime;

  /// 출발 정보 (예: "양천향교에서 출발")
  final String? departureNote;

  const RouteOption({
    required this.routeId,
    required this.transportMode,
    this.vehicleInfo,
    required this.durationMinutes,
    required this.distance,
    this.details,
    this.coordinates,
    this.departureLocation,
    this.arrivalLocation,
    this.transportOptions,
    this.estimatedArrivalTime,
    this.delayedArrivalTime,
    this.departureNote,
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
      'departureLocation': departureLocation,
      'arrivalLocation': arrivalLocation,
      'transportOptions': transportOptions?.map((step) => step.toJson()).toList(),
      'estimatedArrivalTime': estimatedArrivalTime,
      'delayedArrivalTime': delayedArrivalTime,
      'departureNote': departureNote,
    };
  }

  /// JSON에서 생성
  factory RouteOption.fromJson(Map<String, dynamic> json) {
    // Map<dynamic, dynamic>을 Map<String, dynamic>으로 안전하게 변환
    final safeJson = Map<String, dynamic>.from(json);

    return RouteOption(
      routeId: safeJson['routeId'] as String,
      transportMode: safeJson['transportMode'] as String,
      vehicleInfo: safeJson['vehicleInfo'] as String?,
      durationMinutes: safeJson['durationMinutes'] as int,
      distance: safeJson['distance'] as String,
      details: safeJson['details'] as String?,
      coordinates: safeJson['coordinates'] != null
          ? RouteCoordinates.fromJson(
              Map<String, dynamic>.from(safeJson['coordinates'] as Map))
          : null,
      departureLocation: safeJson['departureLocation'] as String?,
      arrivalLocation: safeJson['arrivalLocation'] as String?,
      transportOptions: safeJson['transportOptions'] != null
          ? (safeJson['transportOptions'] as List<dynamic>)
              .map((step) => TransportStep.fromJson(
                  Map<String, dynamic>.from(step as Map)))
              .toList()
          : null,
      estimatedArrivalTime: safeJson['estimatedArrivalTime'] as String?,
      delayedArrivalTime: safeJson['delayedArrivalTime'] as String?,
      departureNote: safeJson['departureNote'] as String?,
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
    String? departureLocation,
    String? arrivalLocation,
    List<TransportStep>? transportOptions,
    String? estimatedArrivalTime,
    String? delayedArrivalTime,
    String? departureNote,
  }) {
    return RouteOption(
      routeId: routeId ?? this.routeId,
      transportMode: transportMode ?? this.transportMode,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distance: distance ?? this.distance,
      details: details ?? this.details,
      coordinates: coordinates ?? this.coordinates,
      departureLocation: departureLocation ?? this.departureLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      transportOptions: transportOptions ?? this.transportOptions,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      delayedArrivalTime: delayedArrivalTime ?? this.delayedArrivalTime,
      departureNote: departureNote ?? this.departureNote,
    );
  }

  @override
  String toString() {
    return 'RouteOption(routeId: $routeId, transportMode: $transportMode, '
        'vehicleInfo: $vehicleInfo, durationMinutes: $durationMinutes, '
        'distance: $distance, details: $details, coordinates: $coordinates, '
        'departureLocation: $departureLocation, arrivalLocation: $arrivalLocation, '
        'transportOptions: $transportOptions, estimatedArrivalTime: $estimatedArrivalTime, '
        'delayedArrivalTime: $delayedArrivalTime, departureNote: $departureNote)';
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
        other.coordinates == coordinates &&
        other.departureLocation == departureLocation &&
        other.arrivalLocation == arrivalLocation &&
        listEquals(other.transportOptions, transportOptions) &&
        other.estimatedArrivalTime == estimatedArrivalTime &&
        other.delayedArrivalTime == delayedArrivalTime &&
        other.departureNote == departureNote;
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
      departureLocation,
      arrivalLocation,
      Object.hashAll(transportOptions ?? []),
      estimatedArrivalTime,
      delayedArrivalTime,
      departureNote,
    );
  }
}
