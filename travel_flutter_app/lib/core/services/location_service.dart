import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../exceptions/app_exception.dart';
import '../utils/logger.dart';

/// 위치 서비스 래퍼
/// Geolocator를 래핑하여 위치 정보 제공 및 권한 관리
class LocationService {
  // ============================================
  // 현재 위치 가져오기
  // ============================================

  /// 현재 위치 가져오기
  ///
  /// [desiredAccuracy] - 위치 정확도 (기본값: best)
  /// [forceAndroidLocationManager] - Android에서 FusedLocationProvider 대신 LocationManager 사용 여부
  /// [timeLimit] - 위치 가져오기 타임아웃
  ///
  /// Returns [Position] - 현재 위치 정보
  /// Throws [LocationException] - 위치 서비스 오류 시
  Future<Position> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
    bool forceAndroidLocationManager = false,
    Duration? timeLimit,
  }) async {
    try {
      Logger.info('현재 위치 가져오기 시작', 'LocationService');

      final stopwatch = Logger.startPerformanceMeasure('getCurrentLocation');

      // 1. 위치 서비스 활성화 확인
      final serviceEnabled = await _checkServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException.serviceDisabled();
      }

      // 2. 위치 권한 확인 및 요청
      final permission = await _checkAndRequestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException.permissionDenied();
      }
      if (permission == LocationPermission.deniedForever) {
        throw LocationException.permissionDeniedForever();
      }

      // 3. 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        forceAndroidLocationManager: forceAndroidLocationManager,
        timeLimit: timeLimit ?? const Duration(seconds: 10),
      );

      Logger.endPerformanceMeasure('getCurrentLocation', stopwatch);

      Logger.info(
        '현재 위치: (${position.latitude}, ${position.longitude})',
        'LocationService',
      );

      return position;
    } on LocationServiceDisabledException catch (e) {
      Logger.error('위치 서비스 비활성화', e, null, 'LocationService');
      throw LocationException.serviceDisabled();
    } on PermissionDeniedException catch (e) {
      Logger.error('위치 권한 거부', e, null, 'LocationService');
      throw LocationException.permissionDenied();
    } on TimeoutException catch (e) {
      Logger.error('위치 가져오기 타임아웃', e, null, 'LocationService');
      throw LocationException.timeout();
    } catch (e, stackTrace) {
      Logger.error('위치 가져오기 실패', e, stackTrace, 'LocationService');
      throw LocationException.notAvailable();
    }
  }

  // ============================================
  // 마지막 알려진 위치 가져오기
  // ============================================

  /// 마지막 알려진 위치 가져오기 (더 빠름, 캐시된 위치)
  ///
  /// Returns [Position?] - 마지막 위치 정보 (없으면 null)
  Future<Position?> getLastKnownLocation() async {
    try {
      Logger.info('마지막 위치 가져오기', 'LocationService');

      // 권한 확인
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Logger.warning('위치 권한 없음', 'LocationService');
        return null;
      }

      final position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        Logger.info(
          '마지막 위치: (${position.latitude}, ${position.longitude})',
          'LocationService',
        );
      } else {
        Logger.info('마지막 위치 없음', 'LocationService');
      }

      return position;
    } catch (e, stackTrace) {
      Logger.error('마지막 위치 가져오기 실패', e, stackTrace, 'LocationService');
      return null;
    }
  }

  // ============================================
  // 위치 권한 확인 및 요청
  // ============================================

  /// 위치 서비스 활성화 여부 확인
  Future<bool> _checkServiceEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      Logger.info('위치 서비스 상태: ${enabled ? "활성화" : "비활성화"}', 'LocationService');
      return enabled;
    } catch (e, stackTrace) {
      Logger.error('위치 서비스 확인 실패', e, stackTrace, 'LocationService');
      return false;
    }
  }

  /// 위치 권한 확인 및 요청
  Future<LocationPermission> _checkAndRequestPermission() async {
    try {
      // 현재 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      Logger.info('현재 위치 권한: ${permission.name}', 'LocationService');

      // 권한이 거부된 경우 요청
      if (permission == LocationPermission.denied) {
        Logger.info('위치 권한 요청', 'LocationService');
        permission = await Geolocator.requestPermission();
        Logger.info('위치 권한 요청 결과: ${permission.name}', 'LocationService');
      }

      return permission;
    } catch (e, stackTrace) {
      Logger.error('위치 권한 확인 실패', e, stackTrace, 'LocationService');
      return LocationPermission.denied;
    }
  }

  /// 위치 권한 확인 (요청 없이)
  Future<LocationPermission> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      Logger.info('위치 권한 확인: ${permission.name}', 'LocationService');
      return permission;
    } catch (e, stackTrace) {
      Logger.error('위치 권한 확인 실패', e, stackTrace, 'LocationService');
      return LocationPermission.denied;
    }
  }

  /// 위치 권한 요청
  Future<LocationPermission> requestPermission() async {
    try {
      Logger.info('위치 권한 요청', 'LocationService');
      final permission = await Geolocator.requestPermission();
      Logger.info('위치 권한 요청 결과: ${permission.name}', 'LocationService');
      return permission;
    } catch (e, stackTrace) {
      Logger.error('위치 권한 요청 실패', e, stackTrace, 'LocationService');
      return LocationPermission.denied;
    }
  }

  // ============================================
  // 위치 서비스 상태 확인
  // ============================================

  /// 위치 서비스 사용 가능 여부 확인
  ///
  /// 위치 서비스가 활성화되어 있고 권한이 허용된 경우 true 반환
  Future<bool> isLocationAvailable() async {
    try {
      // 1. 서비스 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Logger.warning('위치 서비스 비활성화', 'LocationService');
        return false;
      }

      // 2. 권한 확인
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Logger.warning('위치 권한 없음', 'LocationService');
        return false;
      }

      Logger.info('위치 서비스 사용 가능', 'LocationService');
      return true;
    } catch (e, stackTrace) {
      Logger.error('위치 서비스 확인 실패', e, stackTrace, 'LocationService');
      return false;
    }
  }

  // ============================================
  // 거리 계산
  // ============================================

  /// 두 지점 간의 거리 계산 (미터)
  ///
  /// [startLatitude] - 시작 위도
  /// [startLongitude] - 시작 경도
  /// [endLatitude] - 종료 위도
  /// [endLongitude] - 종료 경도
  ///
  /// Returns [double] - 거리 (미터)
  double getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );

      Logger.debug(
        '거리 계산: ${distance.toStringAsFixed(2)}m',
        'LocationService',
      );

      return distance;
    } catch (e, stackTrace) {
      Logger.error('거리 계산 실패', e, stackTrace, 'LocationService');
      return 0.0;
    }
  }

  /// 두 Position 간의 거리 계산 (미터)
  double getDistanceBetweenPositions(Position start, Position end) {
    return getDistanceBetween(
      startLatitude: start.latitude,
      startLongitude: start.longitude,
      endLatitude: end.latitude,
      endLongitude: end.longitude,
    );
  }

  // ============================================
  // 베어링 계산
  // ============================================

  /// 두 지점 간의 방향 각도 계산 (도)
  ///
  /// Returns [double] - 방향 각도 (0-360도, 북쪽이 0도)
  double getBearingBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      final bearing = Geolocator.bearingBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );

      Logger.debug(
        '방향 계산: ${bearing.toStringAsFixed(2)}°',
        'LocationService',
      );

      return bearing;
    } catch (e, stackTrace) {
      Logger.error('방향 계산 실패', e, stackTrace, 'LocationService');
      return 0.0;
    }
  }

  // ============================================
  // 위치 스트림
  // ============================================

  /// 위치 변경 스트림 구독
  ///
  /// [desiredAccuracy] - 위치 정확도
  /// [distanceFilter] - 위치 업데이트 최소 거리 (미터)
  /// [timeLimit] - 위치 가져오기 타임아웃
  ///
  /// Returns [Stream<Position>] - 위치 변경 스트림
  Stream<Position> getPositionStream({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? timeLimit,
  }) {
    Logger.info('위치 스트림 시작', 'LocationService');

    final locationSettings = LocationSettings(
      accuracy: desiredAccuracy,
      distanceFilter: distanceFilter,
      timeLimit: timeLimit,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // ============================================
  // 앱 설정 열기
  // ============================================

  /// 앱 위치 설정 화면 열기
  ///
  /// 사용자가 위치 권한을 영구적으로 거부한 경우 설정으로 이동
  Future<bool> openAppSettings() async {
    try {
      Logger.info('앱 설정 열기', 'LocationService');
      return await Geolocator.openAppSettings();
    } catch (e, stackTrace) {
      Logger.error('앱 설정 열기 실패', e, stackTrace, 'LocationService');
      return false;
    }
  }

  /// 위치 서비스 설정 화면 열기
  Future<bool> openLocationSettings() async {
    try {
      Logger.info('위치 설정 열기', 'LocationService');
      return await Geolocator.openLocationSettings();
    } catch (e, stackTrace) {
      Logger.error('위치 설정 열기 실패', e, stackTrace, 'LocationService');
      return false;
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// 거리를 사람이 읽기 쉬운 형식으로 변환
  ///
  /// [meters] - 미터 단위 거리
  /// Returns [String] - 포맷된 거리 문자열 (예: "1.2km", "350m")
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 위치 권한 상태를 사용자 친화적 메시지로 변환
  static String getPermissionMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return '위치 권한이 거부되었습니다.';
      case LocationPermission.deniedForever:
        return '위치 권한이 영구적으로 거부되었습니다.\n설정에서 권한을 허용해주세요.';
      case LocationPermission.whileInUse:
        return '앱 사용 중에만 위치 권한이 허용되었습니다.';
      case LocationPermission.always:
        return '항상 위치 권한이 허용되었습니다.';
      case LocationPermission.unableToDetermine:
        return '위치 권한 상태를 확인할 수 없습니다.';
    }
  }
}
