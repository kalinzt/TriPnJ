import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../../explore/data/repositories/places_repository.dart';
import '../../domain/algorithms/recommendation_algorithm.dart';
import '../models/cached_recommendation.dart';
import '../repositories/user_preference_repository.dart';
import 'api_rate_limiter.dart';

/// Google Places API 데이터 분석 서비스
///
/// 장소 검색, 점수 계산, 캐싱을 통합 관리합니다.
class PlaceAnalysisService {
  final PlacesRepository _placesRepository;
  final UserPreferenceRepository _userPreferenceRepository;
  final RecommendationAlgorithm _recommendationAlgorithm;
  final ApiRateLimiter _rateLimiter;

  Box<String>? _cacheBox;

  PlaceAnalysisService({
    required PlacesRepository placesRepository,
    required UserPreferenceRepository userPreferenceRepository,
    required RecommendationAlgorithm recommendationAlgorithm,
    ApiRateLimiter? rateLimiter,
  })  : _placesRepository = placesRepository,
        _userPreferenceRepository = userPreferenceRepository,
        _recommendationAlgorithm = recommendationAlgorithm,
        _rateLimiter = rateLimiter ?? ApiRateLimiter();

  /// 캐시 Box 초기화
  Future<void> initialize() async {
    try {
      Logger.info('PlaceAnalysisService 초기화 중...', 'PlaceAnalysisService');
      _cacheBox = await Hive.openBox<String>(RecommendationConstants.cacheBoxName);
      Logger.info('PlaceAnalysisService 초기화 완료', 'PlaceAnalysisService');
    } catch (e, stackTrace) {
      Logger.error('PlaceAnalysisService 초기화 실패', e, stackTrace, 'PlaceAnalysisService');
      rethrow;
    }
  }

  /// 캐시 Box 가져오기
  Box<String> get _cache {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      throw Exception('PlaceAnalysisService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _cacheBox!;
  }

  // ============================================
  // 장소 검색 (캐시 포함)
  // ============================================

  /// 캐시를 활용한 주변 장소 검색
  ///
  /// [latitude] - 현재 위도
  /// [longitude] - 현재 경도
  /// [searchRadius] - 검색 반경 (미터, 기본값: 5000)
  /// [forceRefresh] - 캐시 무시하고 강제 새로고침 (기본값: false)
  ///
  /// Returns 검색된 장소 목록
  Future<List<Place>> searchNearbyPlacesWithCache({
    required double latitude,
    required double longitude,
    int searchRadius = 5000,
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info(
        '캐시 기반 장소 검색 시작: ($latitude, $longitude), 반경: ${searchRadius}m',
        'PlaceAnalysisService',
      );

      // 1. 캐시 키 생성
      final cacheKey = generateCacheKey(
        latitude: latitude,
        longitude: longitude,
        searchRadius: searchRadius,
      );

      // 2. 캐시 확인 (강제 새로고침이 아닌 경우)
      if (!forceRefresh) {
        final cachedData = await _getCachedRecommendation(cacheKey);

        if (cachedData != null &&
            cachedData.canUseAt(
              latitude: latitude,
              longitude: longitude,
              maxDistance: 1000.0, // 1km 이내면 캐시 사용
            )) {
          Logger.info(
            '캐시 데이터 사용: ${cachedData.places.length}개 장소 (나이: ${cachedData.age.inMinutes}분)',
            'PlaceAnalysisService',
          );
          return cachedData.places;
        }
      }

      // 3. API 호출하여 새로운 데이터 가져오기
      Logger.info('API 호출하여 새로운 데이터 가져오기', 'PlaceAnalysisService');

      final allPlaces = <Place>[];

      // 카테고리별 병렬 검색
      final categories = [
        PlaceCategory.attraction,
        PlaceCategory.restaurant,
        PlaceCategory.cafe,
        PlaceCategory.culture,
        PlaceCategory.nature,
      ];

      // Rate Limiting을 고려하여 순차적으로 호출
      for (final category in categories) {
        // Rate Limit 체크
        await _rateLimiter.throttle();

        try {
          final places = await _placesRepository.getNearbyPlaces(
            latitude: latitude,
            longitude: longitude,
            radius: searchRadius,
            category: category,
          );

          allPlaces.addAll(places);

          Logger.info(
            '${category.displayName}: ${places.length}개 장소 검색',
            'PlaceAnalysisService',
          );
        } catch (e) {
          Logger.warning(
            '${category.displayName} 검색 실패: $e',
            'PlaceAnalysisService',
          );
          // 한 카테고리 실패해도 계속 진행
          continue;
        }
      }

      // 중복 제거 (Place ID 기준)
      final uniquePlaces = _removeDuplicates(allPlaces);

      Logger.info(
        '총 ${uniquePlaces.length}개 고유 장소 발견',
        'PlaceAnalysisService',
      );

      // 4. 캐시에 저장 (점수는 나중에 계산)
      await _saveToCacheWithoutScores(
        cacheKey: cacheKey,
        places: uniquePlaces,
        latitude: latitude,
        longitude: longitude,
        searchRadius: searchRadius,
      );

      return uniquePlaces;
    } catch (e, stackTrace) {
      Logger.error('장소 검색 실패', e, stackTrace, 'PlaceAnalysisService');

      // 오프라인 또는 에러 시 캐시 데이터 반환 (만료되어도)
      final cacheKey = generateCacheKey(
        latitude: latitude,
        longitude: longitude,
        searchRadius: searchRadius,
      );

      final cachedData = await _getCachedRecommendation(cacheKey);
      if (cachedData != null) {
        Logger.info(
          '오프라인 모드: 캐시 데이터 사용 (${cachedData.places.length}개)',
          'PlaceAnalysisService',
        );
        return cachedData.places;
      }

      rethrow;
    }
  }

  // ============================================
  // 장소 분석 및 점수 계산
  // ============================================

  /// 장소 분석 및 점수 계산
  ///
  /// [places] - 분석할 장소 목록
  /// [userLatitude] - 사용자 위도
  /// [userLongitude] - 사용자 경도
  /// [currentTime] - 현재 시간 (시간대별 부스트용)
  ///
  /// Returns 장소별 점수 맵 (Place ID -> 점수)
  Future<Map<String, double>> analyzeAndScorePlaces({
    required List<Place> places,
    required double userLatitude,
    required double userLongitude,
    DateTime? currentTime,
  }) async {
    try {
      Logger.info(
        '장소 분석 및 점수 계산 시작: ${places.length}개 장소',
        'PlaceAnalysisService',
      );

      // 1. 사용자 선호도 가져오기
      final userPreference = _userPreferenceRepository.getUserPreference();
      final userPreferences = userPreference.getCategoryWeightsAsEnum();

      // 2. 방문/거절 이력 확인
      final visitedIds = Set<String>.from(userPreference.visitedPlaceIds);
      final rejectedIds = Set<String>.from(userPreference.rejectedPlaceIds);

      // 3. 필터링: 방문/거절한 장소 제외
      final filteredPlaces = places.where((place) {
        return !visitedIds.contains(place.id) && !rejectedIds.contains(place.id);
      }).toList();

      Logger.info(
        '필터링 후: ${filteredPlaces.length}개 장소 (방문: ${visitedIds.length}, 거절: ${rejectedIds.length})',
        'PlaceAnalysisService',
      );

      // 4. 각 장소의 추천 점수 계산
      final scores = <String, double>{};

      for (final place in filteredPlaces) {
        final score = _recommendationAlgorithm.calculateRecommendationScore(
          place: place,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          userPreferences: userPreferences,
          currentTime: currentTime,
        );

        scores[place.id] = score;
      }

      // 5. 시간대별 부스트 적용
      final boostedScores = _recommendationAlgorithm.applyTimeBasedBoost(
        places: filteredPlaces,
        scores: scores.map((id, score) {
          final place = filteredPlaces.firstWhere((p) => p.id == id);
          return MapEntry(place, score);
        }),
        currentTime: currentTime,
      );

      // Place ID로 다시 변환
      final finalScores = <String, double>{};
      for (final entry in boostedScores.entries) {
        finalScores[entry.key.id] = entry.value;
      }

      Logger.info(
        '점수 계산 완료: ${finalScores.length}개 장소',
        'PlaceAnalysisService',
      );

      return finalScores;
    } catch (e, stackTrace) {
      Logger.error('장소 분석 실패', e, stackTrace, 'PlaceAnalysisService');
      rethrow;
    }
  }

  // ============================================
  // 상위 추천 장소 가져오기
  // ============================================

  /// 상위 추천 장소 가져오기
  ///
  /// [latitude] - 현재 위도
  /// [longitude] - 현재 경도
  /// [count] - 가져올 개수 (기본값: 20)
  /// [searchRadius] - 검색 반경 (기본값: 5000m)
  ///
  /// Returns 추천 장소 목록 (점수 순)
  Future<List<Place>> getTopRecommendations({
    required double latitude,
    required double longitude,
    int count = RecommendationConstants.defaultRecommendationCount,
    int searchRadius = 5000,
  }) async {
    try {
      Logger.info(
        '상위 추천 장소 가져오기: $count개',
        'PlaceAnalysisService',
      );

      // 1. 장소 검색 (캐시 포함)
      final places = await searchNearbyPlacesWithCache(
        latitude: latitude,
        longitude: longitude,
        searchRadius: searchRadius,
      );

      if (places.isEmpty) {
        Logger.warning('검색된 장소 없음', 'PlaceAnalysisService');
        return [];
      }

      // 2. 점수 계산
      final scores = await analyzeAndScorePlaces(
        places: places,
        userLatitude: latitude,
        userLongitude: longitude,
      );

      // 3. 점수순 정렬
      final placesWithScores = places
          .where((place) => scores.containsKey(place.id))
          .map((place) => MapEntry(place, scores[place.id]!))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final sortedPlaces = placesWithScores.map((e) => e.key).toList();

      // 4. 다양성 보장 (MMR 알고리즘)
      final diversePlaces = _recommendationAlgorithm.diversifyRecommendations(
        rankedPlaces: sortedPlaces,
        topN: count,
      );

      Logger.info(
        '상위 추천 완료: ${diversePlaces.length}개 장소',
        'PlaceAnalysisService',
      );

      return diversePlaces.take(count).toList();
    } catch (e, stackTrace) {
      Logger.error('상위 추천 가져오기 실패', e, stackTrace, 'PlaceAnalysisService');
      rethrow;
    }
  }

  /// 추가 추천 장소 로드 (페이지네이션)
  ///
  /// [latitude] - 현재 위도
  /// [longitude] - 현재 경도
  /// [offset] - 건너뛸 개수
  /// [count] - 가져올 개수 (기본값: 20)
  ///
  /// Returns 추가 추천 장소 목록
  Future<List<Place>> loadMoreRecommendations({
    required double latitude,
    required double longitude,
    required int offset,
    int count = RecommendationConstants.loadMoreSize,
  }) async {
    try {
      Logger.info(
        '추가 추천 로드: offset=$offset, count=$count',
        'PlaceAnalysisService',
      );

      // 전체 추천 장소 가져오기
      final allRecommendations = await getTopRecommendations(
        latitude: latitude,
        longitude: longitude,
        count: offset + count,
      );

      // offset부터 count개 반환
      if (allRecommendations.length <= offset) {
        return [];
      }

      return allRecommendations.skip(offset).take(count).toList();
    } catch (e, stackTrace) {
      Logger.error('추가 추천 로드 실패', e, stackTrace, 'PlaceAnalysisService');
      rethrow;
    }
  }

  // ============================================
  // 캐시 관리
  // ============================================

  /// 캐시에서 추천 데이터 가져오기
  Future<CachedRecommendation?> _getCachedRecommendation(String cacheKey) async {
    try {
      final jsonString = _cache.get(cacheKey);

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CachedRecommendation.fromJson(json);
    } catch (e, stackTrace) {
      Logger.error('캐시 읽기 실패', e, stackTrace, 'PlaceAnalysisService');
      return null;
    }
  }

  /// 캐시에 저장 (점수 없이)
  Future<void> _saveToCacheWithoutScores({
    required String cacheKey,
    required List<Place> places,
    required double latitude,
    required double longitude,
    required int searchRadius,
  }) async {
    try {
      final cachedData = CachedRecommendation(
        places: places,
        scores: {}, // 점수는 나중에 계산
        cachedAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        searchRadiusMeters: searchRadius,
      );

      final jsonString = jsonEncode(cachedData.toJson());
      await _cache.put(cacheKey, jsonString);

      Logger.info(
        '캐시 저장 완료: ${places.length}개 장소',
        'PlaceAnalysisService',
      );
    } catch (e, stackTrace) {
      Logger.error('캐시 저장 실패', e, stackTrace, 'PlaceAnalysisService');
    }
  }

  /// 캐시 클리어
  Future<void> clearCache() async {
    try {
      await _cache.clear();
      Logger.info('캐시 클리어 완료', 'PlaceAnalysisService');
    } catch (e, stackTrace) {
      Logger.error('캐시 클리어 실패', e, stackTrace, 'PlaceAnalysisService');
    }
  }

  // ============================================
  // 유틸리티
  // ============================================

  /// 중복 제거 (Place ID 기준)
  List<Place> _removeDuplicates(List<Place> places) {
    final seen = <String>{};
    return places.where((place) => seen.add(place.id)).toList();
  }

  /// 서비스 종료
  Future<void> close() async {
    await _cacheBox?.close();
    _cacheBox = null;
    Logger.info('PlaceAnalysisService 종료', 'PlaceAnalysisService');
  }
}
