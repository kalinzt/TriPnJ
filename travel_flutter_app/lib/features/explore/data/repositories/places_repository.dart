import 'dart:math' show sin, cos, sqrt, asin;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';

/// Google Places API를 사용하여 여행지 정보를 제공하는 Repository
class PlacesRepository {
  final ApiService _apiService;
  late final String _apiKey;

  PlacesRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      Logger.warning('Google Places API 키가 설정되지 않았습니다', 'PlacesRepository');
    }
  }

  // ============================================
  // Nearby Search - 주변 장소 검색
  // ============================================

  /// 주변 여행지 검색
  ///
  /// [latitude] - 위도
  /// [longitude] - 경도
  /// [radius] - 검색 반경 (미터, 기본값: 5000)
  /// [category] - 장소 카테고리 (기본값: all)
  /// [keyword] - 추가 검색 키워드 (선택)
  ///
  /// Returns [List<Place>] - 검색된 장소 목록
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000,
    PlaceCategory category = PlaceCategory.all,
    String? keyword,
  }) async {
    try {
      Logger.info(
        '주변 장소 검색: ($latitude, $longitude), 반경: ${radius}m, 카테고리: ${category.displayName}',
        'PlacesRepository',
      );

      // API 키 확인
      if (_apiKey.isEmpty) {
        throw ApiException.missingApiKey('Google Places');
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'location': '$latitude,$longitude',
        'radius': radius,
        'key': _apiKey,
        'language': 'ko', // 한국어 응답
      };

      // 카테고리별 type 추가
      if (category != PlaceCategory.all) {
        final type = category.primaryGooglePlaceType;
        if (type != null) {
          queryParams['type'] = type;
        }
      }

      // 키워드 추가
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      // API 호출
      final response = await _apiService.get(
        url: ApiConstants.placesNearbySearch,
        queryParameters: queryParams,
      );

      // 응답 파싱
      final results = response['results'] as List<dynamic>? ?? [];

      Logger.info(
        '주변 장소 검색 완료: ${results.length}개 장소 발견',
        'PlacesRepository',
      );

      // Place 객체로 변환
      return results
          .map((json) => Place.fromGooglePlaces(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('주변 장소 검색 실패', e, stackTrace, 'PlacesRepository');
      throw DataException.parseError(e);
    }
  }

  // ============================================
  // Text Search - 텍스트 기반 장소 검색
  // ============================================

  /// 텍스트로 장소 검색
  ///
  /// [query] - 검색 쿼리 (예: "서울 맛집", "부산 해운대")
  /// [latitude] - 위도 (선택, 위치 기반 정렬에 사용)
  /// [longitude] - 경도 (선택, 위치 기반 정렬에 사용)
  /// [radius] - 검색 반경 (미터, 선택)
  ///
  /// Returns [List<Place>] - 검색된 장소 목록
  Future<List<Place>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    try {
      Logger.info('장소 검색: $query', 'PlacesRepository');

      // API 키 확인
      if (_apiKey.isEmpty) {
        throw ApiException.missingApiKey('Google Places');
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'query': query,
        'key': _apiKey,
        'language': 'ko',
      };

      // 위치 정보가 있으면 추가
      if (latitude != null && longitude != null) {
        queryParams['location'] = '$latitude,$longitude';
        if (radius != null) {
          queryParams['radius'] = radius;
        }
      }

      // API 호출
      final response = await _apiService.get(
        url: ApiConstants.placesTextSearch,
        queryParameters: queryParams,
      );

      // 응답 파싱
      final results = response['results'] as List<dynamic>? ?? [];

      Logger.info(
        '장소 검색 완료: ${results.length}개 장소 발견',
        'PlacesRepository',
      );

      // Place 객체로 변환
      return results
          .map((json) => Place.fromGooglePlaces(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('장소 검색 실패', e, stackTrace, 'PlacesRepository');
      throw DataException.parseError(e);
    }
  }

  // ============================================
  // Place Details - 장소 상세 정보
  // ============================================

  /// 장소 상세 정보 가져오기
  ///
  /// [placeId] - Google Place ID
  ///
  /// Returns [Place] - 장소 상세 정보
  Future<Place> getPlaceDetails({
    required String placeId,
  }) async {
    try {
      Logger.info('장소 상세 정보 요청: $placeId', 'PlacesRepository');

      // API 키 확인
      if (_apiKey.isEmpty) {
        throw ApiException.missingApiKey('Google Places');
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'place_id': placeId,
        'key': _apiKey,
        'language': 'ko',
        'fields': [
          'place_id',
          'name',
          'formatted_address',
          'geometry',
          'rating',
          'user_ratings_total',
          'price_level',
          'photos',
          'types',
          'opening_hours',
          'formatted_phone_number',
          'website',
          'editorial_summary',
          'business_status',
          'reviews',
        ].join(','),
      };

      // API 호출
      final response = await _apiService.get(
        url: ApiConstants.placesDetails,
        queryParameters: queryParams,
      );

      // 응답 파싱
      final result = response['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw DataException.notFound('장소를 찾을 수 없습니다');
      }

      Logger.info('장소 상세 정보 로드 완료', 'PlacesRepository');

      // Place 객체로 변환
      return Place.fromGooglePlaces(result);
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('장소 상세 정보 로드 실패', e, stackTrace, 'PlacesRepository');
      throw DataException.parseError(e);
    }
  }

  // ============================================
  // Autocomplete - 자동완성
  // ============================================

  /// 장소 자동완성 검색
  ///
  /// [input] - 검색 입력 텍스트
  /// [latitude] - 위도 (선택, 검색 우선순위에 사용)
  /// [longitude] - 경도 (선택, 검색 우선순위에 사용)
  /// [radius] - 검색 반경 (미터, 선택)
  ///
  /// Returns [List<Map<String, dynamic>>] - 자동완성 제안 목록
  Future<List<Map<String, dynamic>>> getAutocompleteSuggestions({
    required String input,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    try {
      Logger.info('자동완성 검색: $input', 'PlacesRepository');

      // API 키 확인
      if (_apiKey.isEmpty) {
        throw ApiException.missingApiKey('Google Places');
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'input': input,
        'key': _apiKey,
        'language': 'ko',
      };

      // 위치 정보가 있으면 추가
      if (latitude != null && longitude != null) {
        queryParams['location'] = '$latitude,$longitude';
        if (radius != null) {
          queryParams['radius'] = radius;
        }
      }

      // API 호출
      final response = await _apiService.get(
        url: ApiConstants.placesAutocomplete,
        queryParameters: queryParams,
      );

      // 응답 파싱
      final predictions = response['predictions'] as List<dynamic>? ?? [];

      Logger.info(
        '자동완성 검색 완료: ${predictions.length}개 제안',
        'PlacesRepository',
      );

      return predictions
          .map((prediction) => prediction as Map<String, dynamic>)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('자동완성 검색 실패', e, stackTrace, 'PlacesRepository');
      throw DataException.parseError(e);
    }
  }

  // ============================================
  // Photo - 장소 사진
  // ============================================

  /// 장소 사진 URL 생성
  ///
  /// [photoReference] - Google Places API에서 반환된 photo_reference
  /// [maxWidth] - 최대 너비 (픽셀, 기본값: 400)
  /// [maxHeight] - 최대 높이 (픽셀, 선택)
  ///
  /// Returns [String] - 사진 URL
  String getPhotoUrl({
    required String photoReference,
    int maxWidth = 400,
    int? maxHeight,
  }) {
    if (_apiKey.isEmpty) {
      Logger.warning('Google Places API 키가 없어 사진 URL을 생성할 수 없습니다', 'PlacesRepository');
      return '';
    }

    final params = <String, dynamic>{
      'photo_reference': photoReference,
      'maxwidth': maxWidth,
      'key': _apiKey,
    };

    if (maxHeight != null) {
      params['maxheight'] = maxHeight;
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return '${ApiConstants.placesPhotos}?$queryString';
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// 거리 기반으로 장소 정렬
  List<Place> sortPlacesByDistance({
    required List<Place> places,
    required double latitude,
    required double longitude,
  }) {
    return places
      ..sort((a, b) {
        final distanceA = _calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = _calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
  }

  /// 평점 기반으로 장소 정렬
  List<Place> sortPlacesByRating(List<Place> places) {
    return places
      ..sort((a, b) {
        final ratingA = a.rating ?? 0.0;
        final ratingB = b.rating ?? 0.0;
        return ratingB.compareTo(ratingA); // 높은 평점 우선
      });
  }

  /// 두 좌표 간의 거리 계산 (미터)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  /// 도를 라디안으로 변환
  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  /// Repository 종료
  void dispose() {
    _apiService.dispose();
  }
}
