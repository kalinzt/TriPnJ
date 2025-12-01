import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/place.dart';

part 'cached_recommendation.freezed.dart';
part 'cached_recommendation.g.dart';

/// 캐시된 추천 데이터
///
/// 추천 결과와 캐시 시간을 함께 저장하여
/// 24시간 이내에는 API 호출 없이 캐시 데이터를 사용합니다.
@freezed
class CachedRecommendation with _$CachedRecommendation {
  const factory CachedRecommendation({
    /// 추천 장소 목록
    required List<Place> places,

    /// 각 장소의 추천 점수
    ///
    /// Key: Place ID, Value: 추천 점수 (0.0 ~ 1.0)
    required Map<String, double> scores,

    /// 캐시 생성 시간
    required DateTime cachedAt,

    /// 캐시 생성 시 사용자 위치 (위도)
    required double latitude,

    /// 캐시 생성 시 사용자 위치 (경도)
    required double longitude,

    /// 캐시 생성 시 사용한 검색 반경 (미터)
    @Default(5000) int searchRadiusMeters,
  }) = _CachedRecommendation;

  factory CachedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$CachedRecommendationFromJson(json);
}

/// CachedRecommendation 확장 메서드
extension CachedRecommendationX on CachedRecommendation {
  /// 캐시가 유효한지 확인
  ///
  /// [maxAge] - 최대 캐시 유효 시간 (기본: 24시간)
  bool isValid({Duration maxAge = const Duration(hours: 24)}) {
    final now = DateTime.now();
    final age = now.difference(cachedAt);
    return age < maxAge;
  }

  /// 캐시 나이 (경과 시간)
  Duration get age {
    return DateTime.now().difference(cachedAt);
  }

  /// 캐시가 만료되었는지 확인
  bool get isExpired {
    return !isValid();
  }

  /// 특정 위치로부터의 거리 차이 (미터)
  ///
  /// 캐시된 위치와 현재 위치가 너무 멀면 캐시를 사용하지 않습니다.
  double distanceFrom({
    required double latitude,
    required double longitude,
  }) {
    // Haversine 공식 간소화 (근사값)
    const earthRadius = 6371000.0; // 미터
    final dLat = _toRadians(latitude - this.latitude);
    final dLon = _toRadians(longitude - this.longitude);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(this.latitude)) *
            math.cos(_toRadians(latitude)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  /// 도를 라디안으로 변환
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// 특정 위치에서 캐시를 사용할 수 있는지 확인
  ///
  /// [latitude] - 현재 위도
  /// [longitude] - 현재 경도
  /// [maxDistance] - 최대 허용 거리 (미터, 기본: 1km)
  bool canUseAt({
    required double latitude,
    required double longitude,
    double maxDistance = 1000.0,
  }) {
    if (isExpired) {
      return false;
    }

    final distance = distanceFrom(
      latitude: latitude,
      longitude: longitude,
    );

    return distance <= maxDistance;
  }

  /// 특정 Place ID의 점수 반환
  double? getScore(String placeId) {
    return scores[placeId];
  }

  /// 점수순으로 정렬된 장소 목록
  List<Place> get placesSortedByScore {
    final sortedPlaces = List<Place>.from(places);
    sortedPlaces.sort((a, b) {
      final scoreA = scores[a.id] ?? 0.0;
      final scoreB = scores[b.id] ?? 0.0;
      return scoreB.compareTo(scoreA); // 내림차순
    });
    return sortedPlaces;
  }

  /// 상위 N개 장소 반환
  List<Place> topPlaces(int count) {
    final sorted = placesSortedByScore;
    return sorted.take(count).toList();
  }

  /// 캐시 정보 요약
  Map<String, dynamic> getSummary() {
    return {
      'placesCount': places.length,
      'cachedAt': cachedAt.toIso8601String(),
      'age': age.inMinutes,
      'isValid': isValid(),
      'latitude': latitude,
      'longitude': longitude,
      'searchRadiusMeters': searchRadiusMeters,
    };
  }

  /// 캐시 정보 문자열
  String toDisplayString() {
    return 'CachedRecommendation('
        'places: ${places.length}, '
        'age: ${age.inMinutes}분, '
        'valid: ${isValid()}'
        ')';
  }
}

/// 위치 기반 캐시 키 생성
///
/// [latitude] - 위도
/// [longitude] - 경도
/// [searchRadius] - 검색 반경
///
/// Returns 캐시 키 문자열
String generateCacheKey({
  required double latitude,
  required double longitude,
  required int searchRadius,
}) {
  // 위치를 0.01도 단위로 반올림 (약 1km)
  final roundedLat = (latitude * 100).round() / 100;
  final roundedLon = (longitude * 100).round() / 100;

  return 'recommendation_${roundedLat}_${roundedLon}_$searchRadius';
}
