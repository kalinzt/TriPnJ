import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/plan/data/models/route_option_model.dart';
import '../../features/plan/data/models/transport_step_model.dart';
import '../utils/app_logger.dart';

/// 이동 수단 모드 enum
enum TravelMode {
  transit, // 대중교통
  driving, // 자동차
  walking, // 도보
  bicycling, // 자전거
}

/// 경로 검색 결과 캐시 항목
class _CachedRoute {
  final List<RouteOption> routes;
  final DateTime cachedAt;

  _CachedRoute(this.routes, this.cachedAt);

  /// 캐시가 유효한지 확인 (1시간 이내)
  bool isValid() {
    final now = DateTime.now();
    return now.difference(cachedAt).inHours < 1;
  }
}

/// Google Directions API를 사용하여 경로를 검색하는 서비스
class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const Duration _timeout = Duration(seconds: 10);

  /// 경로 검색 캐시 (키: "origin|destination|mode", 값: 캐시된 경로)
  final Map<String, _CachedRoute> _cache = {};

  /// Google Directions API 키를 .env 파일에서 로드
  String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// TravelMode enum을 API 파라미터 문자열로 변환
  String _getModeString(TravelMode mode) {
    switch (mode) {
      case TravelMode.transit:
        return 'transit';
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
    }
  }

  /// 캐시 키 생성
  String _getCacheKey(String origin, String destination, TravelMode mode) {
    return '$origin|$destination|${_getModeString(mode)}';
  }

  /// 차량 타입을 한글로 번역
  String _translateVehicleType(String type) {
    switch (type.toUpperCase()) {
      case 'BUS':
        return '버스';
      case 'SUBWAY':
        return '지하철';
      case 'TRAIN':
        return '기차';
      case 'TRAM':
        return '트램';
      case 'RAIL':
        return '철도';
      case 'HEAVY_RAIL':
        return '고속철';
      case 'COMMUTER_TRAIN':
        return '통근열차';
      case 'HIGH_SPEED_TRAIN':
        return '고속열차';
      case 'LONG_DISTANCE_TRAIN':
        return '장거리열차';
      case 'FERRY':
        return '페리';
      case 'CABLE_CAR':
        return '케이블카';
      case 'GONDOLA_LIFT':
        return '곤돌라';
      case 'FUNICULAR':
        return '푸니쿨라';
      case 'AIRPLANE':
        return '항공';
      default:
        return type;
    }
  }

  /// 주소에서 시/도 추출 (예: "서울 강남구 ..." → "서울")
  String _extractCity(String address) {
    if (address.isEmpty) return address;

    final parts = address.split(' ');
    if (parts.isEmpty) return address;

    // 첫 번째 단어 반환 (시/도)
    return parts[0];
  }

  /// 차량 타입을 아이콘 이름으로 매핑
  String _mapVehicleTypeToIcon(String vehicleType) {
    switch (vehicleType.toUpperCase()) {
      case 'SUBWAY':
        return 'subway';
      case 'BUS':
        return 'bus';
      case 'TRAIN':
      case 'RAIL':
      case 'HEAVY_RAIL':
      case 'COMMUTER_TRAIN':
      case 'HIGH_SPEED_TRAIN':
      case 'LONG_DISTANCE_TRAIN':
        return 'train';
      case 'AIRPLANE':
        return 'flight';
      case 'FERRY':
        return 'ferry';
      case 'CABLE_CAR':
      case 'GONDOLA_LIFT':
      case 'FUNICULAR':
        return 'cable_car';
      case 'TRAM':
        return 'tram';
      case 'WALKING':
        return 'walking';
      default:
        return 'transit';
    }
  }

  /// 도착 시간 텍스트 포맷팅
  /// API에서 받은 "오후 2:28" 같은 텍스트를 간단하게 변환
  String _formatArrivalTime(String? arrivalTimeText) {
    if (arrivalTimeText == null || arrivalTimeText.isEmpty) {
      return '';
    }

    // "오전"/"오후" 제거하고 시간만 반환
    return arrivalTimeText
        .replaceAll(RegExp(r'오전\s*'), '')
        .replaceAll(RegExp(r'오후\s*'), '')
        .trim();
  }

  /// 출발지에서 도착지까지의 경로를 검색합니다.
  ///
  /// [origin] 출발지 주소 또는 좌표 (예: "인천공항" 또는 "37.46,126.40")
  /// [destination] 도착지 주소 또는 좌표 (예: "취리히공항" 또는 "47.45,8.56")
  /// [mode] 이동 수단 모드 (기본값: transit)
  /// [useCache] 캐시 사용 여부 (기본값: true)
  ///
  /// 반환값: 최대 3개의 경로 옵션 리스트. 실패 시 빈 리스트 반환.
  ///
  /// API 요청 형식:
  /// GET https://maps.googleapis.com/maps/api/directions/json?origin=출발지&destination=도착지&mode=모드&key=API_KEY
  ///
  /// 응답 파싱:
  /// - routes[].legs[].duration.value: 이동 시간 (초 단위 → 분 단위로 변환)
  /// - routes[].legs[].distance.text: 거리
  /// - routes[].legs[].steps[]: 모든 경유 단계 정보
  /// - routes[].legs[].steps[].transit_details: 대중교통 상세 정보
  /// - routes[].legs[].steps[].html_instructions: 경로 안내
  Future<List<RouteOption>> searchRoutes(
    String origin,
    String destination, {
    TravelMode mode = TravelMode.transit,
    bool useCache = true,
  }) async {
    try {
      // API 키 확인
      if (_apiKey.isEmpty) {
        appLogger.e('경로 검색 실패: API 키가 설정되지 않았습니다');
        return [];
      }

      // 캐시 확인
      if (useCache) {
        final cacheKey = _getCacheKey(origin, destination, mode);
        final cached = _cache[cacheKey];

        if (cached != null && cached.isValid()) {
          appLogger.d('캐시에서 경로 로드: $origin → $destination (${_getModeString(mode)})');
          return cached.routes;
        }
      }

      // API 요청 URL 구성
      final modeString = _getModeString(mode);
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'origin': origin,
        'destination': destination,
        'mode': modeString,
        'key': _apiKey,
        'alternatives': 'true', // 여러 경로 옵션 요청
      });

      appLogger.i('경로 검색 요청: $origin → $destination ($modeString)');

      // HTTP GET 요청 (10초 타임아웃)
      final response = await http.get(uri).timeout(_timeout);

      // 응답 상태 코드 확인
      if (response.statusCode != 200) {
        appLogger.w('경로 검색 실패: HTTP ${response.statusCode}');
        return [];
      }

      // JSON 파싱
      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      // API 응답 상태 확인
      if (status != 'OK') {
        appLogger.w('경로 검색 실패: API 상태 $status');
        return [];
      }

      // routes 배열 추출
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        appLogger.i('경로 검색 결과: 경로를 찾을 수 없습니다');
        return [];
      }

      // 최대 3개의 경로 옵션으로 변환
      final routeOptions = <RouteOption>[];
      final maxRoutes = routes.length > 3 ? 3 : routes.length;

      for (int i = 0; i < maxRoutes; i++) {
        try {
          final route = routes[i] as Map<String, dynamic>;
          final legs = route['legs'] as List<dynamic>?;

          if (legs == null || legs.isEmpty) continue;

          final leg = legs[0] as Map<String, dynamic>;

          // 이동 시간 추출 (초 → 분)
          final duration = leg['duration'] as Map<String, dynamic>?;
          final durationSeconds = duration?['value'] as int? ?? 0;
          final durationMinutes = (durationSeconds / 60).round();

          // 거리 추출
          final distanceData = leg['distance'] as Map<String, dynamic>?;
          final distanceText = distanceData?['text'] as String? ?? 'Unknown';

          // 출발지/도착지 주소 추출
          final startAddress = leg['start_address'] as String? ?? '';
          final endAddress = leg['end_address'] as String? ?? '';
          final departureLocation = _extractCity(startAddress);
          final arrivalLocation = _extractCity(endAddress);

          appLogger.d('출발지: $departureLocation, 도착지: $arrivalLocation');

          // 도착 시간 정보 추출
          final arrivalTimeData = leg['arrival_time'] as Map<String, dynamic>?;
          final arrivalTimeText = arrivalTimeData?['text'] as String?;
          final estimatedArrivalTime = _formatArrivalTime(arrivalTimeText);

          // 출발 정보 추출
          final departureStop = leg['departure_stop'] as Map<String, dynamic>?;
          final departureStopName = departureStop?['name'] as String?;
          final departureNote = departureStopName != null
              ? '$departureStopName에서 출발'
              : startAddress.isNotEmpty
                  ? '$startAddress에서 출발'
                  : null;

          // 좌표 정보 추출
          final startLocation = leg['start_location'] as Map<String, dynamic>?;
          final endLocation = leg['end_location'] as Map<String, dynamic>?;
          RouteCoordinates? coordinates;

          if (startLocation != null && endLocation != null) {
            final startLat = startLocation['lat'] as double?;
            final startLng = startLocation['lng'] as double?;
            final endLat = endLocation['lat'] as double?;
            final endLng = endLocation['lng'] as double?;

            if (startLat != null && startLng != null && endLat != null && endLng != null) {
              // 경유지 좌표 추출
              final steps = leg['steps'] as List<dynamic>?;
              final waypoints = <Map<String, double>>[];

              if (steps != null) {
                for (var step in steps) {
                  final stepMap = step as Map<String, dynamic>;
                  final stepStartLoc = stepMap['start_location'] as Map<String, dynamic>?;
                  if (stepStartLoc != null) {
                    final lat = stepStartLoc['lat'] as double?;
                    final lng = stepStartLoc['lng'] as double?;
                    if (lat != null && lng != null) {
                      waypoints.add({'lat': lat, 'lng': lng});
                    }
                  }
                }
              }

              coordinates = RouteCoordinates(
                startLatitude: startLat,
                startLongitude: startLng,
                endLatitude: endLat,
                endLongitude: endLng,
                waypoints: waypoints,
              );
            }
          }

          // 경로 단계(steps) 추출 및 상세 정보 파싱
          final steps = leg['steps'] as List<dynamic>?;
          String? vehicleInfo;
          String? details;
          String transportMode = _getModeString(mode);
          final transportSteps = <TransportStep>[];

          if (steps != null && steps.isNotEmpty) {
            final detailsList = <String>[];
            final vehicleList = <String>[];

            // 모든 단계를 순회하며 상세 정보 수집
            for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
              final stepMap = steps[stepIndex] as Map<String, dynamic>;
              final travelMode = stepMap['travel_mode'] as String?;

              if (travelMode == 'TRANSIT') {
                final transitDetails =
                    stepMap['transit_details'] as Map<String, dynamic>?;

                if (transitDetails != null) {
                  // 차량 정보 추출
                  final line = transitDetails['line'] as Map<String, dynamic>?;
                  if (line != null) {
                    final lineName = line['name'] as String?;
                    final shortName = line['short_name'] as String?;
                    final vehicle = line['vehicle'] as Map<String, dynamic>?;
                    final vehicleType = vehicle?['type'] as String?;

                    String? vehicleDesc;
                    if (lineName != null) {
                      vehicleDesc = lineName;
                    } else if (shortName != null) {
                      vehicleDesc = shortName;
                    }

                    if (vehicleDesc != null) {
                      if (vehicleType != null) {
                        final typeKr = _translateVehicleType(vehicleType);
                        vehicleList.add('$typeKr $vehicleDesc');
                      } else {
                        vehicleList.add(vehicleDesc);
                      }
                    }

                    // TransportStep 생성 (대중교통)
                    final stepDuration = stepMap['duration'] as Map<String, dynamic>?;
                    final durationText = stepDuration?['text'] as String? ?? '';
                    final stepName = vehicleDesc ?? '버스';
                    final icon = vehicleType != null
                        ? _mapVehicleTypeToIcon(vehicleType)
                        : 'transit';

                    transportSteps.add(TransportStep(
                      stepId: 'step_$stepIndex',
                      icon: icon,
                      name: stepName,
                      duration: durationText,
                      type: 'transit',
                    ));

                    appLogger.d(
                        'TransportStep 추가: $stepName ($icon) - $durationText');
                  }

                  // 경유지 정보 추출 (출발역 → 도착역)
                  final departureStop =
                      transitDetails['departure_stop'] as Map<String, dynamic>?;
                  final arrivalStop =
                      transitDetails['arrival_stop'] as Map<String, dynamic>?;
                  final numStops = transitDetails['num_stops'] as int?;

                  if (departureStop != null && arrivalStop != null) {
                    final depName = departureStop['name'] as String?;
                    final arrName = arrivalStop['name'] as String?;

                    if (depName != null && arrName != null) {
                      if (numStops != null && numStops > 0) {
                        detailsList
                            .add('$depName → $arrName ($numStops개 정거장)');
                      } else {
                        detailsList.add('$depName → $arrName');
                      }
                    }
                  }

                  // 환승 시간 정보
                  final departureTime = transitDetails['departure_time']
                      as Map<String, dynamic>?;
                  final arrivalTime =
                      transitDetails['arrival_time'] as Map<String, dynamic>?;

                  if (departureTime != null && arrivalTime != null) {
                    final depTimeText = departureTime['text'] as String?;
                    final arrTimeText = arrivalTime['text'] as String?;
                    if (depTimeText != null && arrTimeText != null) {
                      detailsList.add('출발: $depTimeText, 도착: $arrTimeText');
                    }
                  }
                }
              } else if (travelMode == 'WALKING') {
                // 도보 구간 정보
                final walkDuration =
                    stepMap['duration'] as Map<String, dynamic>?;
                if (walkDuration != null) {
                  final walkText = walkDuration['text'] as String?;
                  if (walkText != null) {
                    detailsList.add('도보 $walkText');

                    // TransportStep 생성 (도보)
                    transportSteps.add(TransportStep(
                      stepId: 'step_$stepIndex',
                      icon: 'walking',
                      name: '도보',
                      duration: walkText,
                      type: 'walking',
                    ));

                    appLogger.d('TransportStep 추가: 도보 - $walkText');
                  }
                }
              }
            }

            // 차량 정보 조합 (최대 3개)
            if (vehicleList.isNotEmpty) {
              final maxVehicles = vehicleList.length > 3 ? 3 : vehicleList.length;
              vehicleInfo = vehicleList.take(maxVehicles).join(' → ');
              if (vehicleList.length > 3) {
                vehicleInfo = '$vehicleInfo 외 ${vehicleList.length - 3}개';
              }
            }

            // 상세 정보 조합 (최대 5개)
            if (detailsList.isNotEmpty) {
              final maxDetails = detailsList.length > 5 ? 5 : detailsList.length;
              details = detailsList.take(maxDetails).join(' | ');
            }
          }

          // RouteOption 객체 생성
          final routeOption = RouteOption(
            routeId: 'route_${i + 1}',
            transportMode: transportMode,
            vehicleInfo: vehicleInfo,
            durationMinutes: durationMinutes,
            distance: distanceText,
            details: details,
            coordinates: coordinates,
            // 새로 추가된 필드들
            departureLocation: departureLocation.isNotEmpty ? departureLocation : null,
            arrivalLocation: arrivalLocation.isNotEmpty ? arrivalLocation : null,
            transportOptions: transportSteps.isNotEmpty ? transportSteps : null,
            estimatedArrivalTime: estimatedArrivalTime.isNotEmpty ? estimatedArrivalTime : null,
            delayedArrivalTime: null, // 지연 정보는 실시간 API가 필요하므로 null
            departureNote: departureNote,
          );

          appLogger.d('RouteOption 생성: ${routeOption.routeId}, '
              'TransportSteps: ${transportSteps.length}개');

          routeOptions.add(routeOption);
        } catch (e) {
          appLogger.w('경로 파싱 에러', error: e);
          continue;
        }
      }

      appLogger.i('경로 검색 결과: ${routeOptions.length}개');

      // 캐시에 저장
      if (useCache && routeOptions.isNotEmpty) {
        final cacheKey = _getCacheKey(origin, destination, mode);
        _cache[cacheKey] = _CachedRoute(routeOptions, DateTime.now());
        appLogger.d('캐시에 저장: $cacheKey');
      }

      return routeOptions;
    } catch (e) {
      appLogger.e('경로 검색 실패', error: e);
      return [];
    }
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
    appLogger.i('경로 캐시 초기화 완료');
  }

  /// 특정 캐시 항목 삭제
  void removeCachedRoute(
      String origin, String destination, TravelMode mode) {
    final cacheKey = _getCacheKey(origin, destination, mode);
    _cache.remove(cacheKey);
    appLogger.d('캐시 항목 삭제: $cacheKey');
  }

  /// 만료된 캐시 항목 정리
  void cleanExpiredCache() {
    final keysToRemove = <String>[];

    for (var entry in _cache.entries) {
      if (!entry.value.isValid()) {
        keysToRemove.add(entry.key);
      }
    }

    for (var key in keysToRemove) {
      _cache.remove(key);
    }

    appLogger.i('만료된 캐시 ${keysToRemove.length}개 항목 삭제');
  }
}
