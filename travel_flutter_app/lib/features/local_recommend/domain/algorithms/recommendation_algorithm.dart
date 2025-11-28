import '../../../../core/services/location_service.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../../../shared/models/trip_plan.dart';
import '../config/recommendation_config.dart';
import 'cold_start_handler.dart';

/// 추천 알고리즘 엔진
///
/// Google Places API 데이터를 기반으로 사용자 맞춤형 추천을 생성합니다.
/// 가중치 기반 점수 계산, MMR 다양성 보장, Cold Start 처리를 포함합니다.
class RecommendationAlgorithm {
  final RecommendationConfig config;
  final LocationService locationService;
  final ColdStartHandler coldStartHandler;

  RecommendationAlgorithm({
    required this.config,
    LocationService? locationService,
  })  : locationService = locationService ?? LocationService(),
        coldStartHandler = ColdStartHandler(config: config);

  // ============================================
  // 추천 점수 계산
  // ============================================

  /// 장소의 추천 점수 계산
  ///
  /// 점수 = (카테고리_매칭도 × config.categoryWeight)
  ///      + (평점/5 × config.ratingWeight)
  ///      + (거리_근접도 × config.distanceWeight)
  ///      + (인기도 × config.popularityWeight)
  ///
  /// [place] - 장소
  /// [userLatitude] - 사용자 위도
  /// [userLongitude] - 사용자 경도
  /// [userPreferences] - 사용자 선호도 (카테고리별 가중치)
  /// [currentTime] - 현재 시간 (시간대별 부스트용, 기본값: DateTime.now())
  ///
  /// Returns 추천 점수 (0.0 ~ 1.0)
  double calculateRecommendationScore({
    required Place place,
    required double userLatitude,
    required double userLongitude,
    required Map<PlaceCategory, double> userPreferences,
    DateTime? currentTime,
  }) {
    // 1. 카테고리 매칭도 계산
    final categoryScore = _calculateCategoryMatchScore(
      place: place,
      userPreferences: userPreferences,
      currentTime: currentTime,
    );

    // 2. 평점 점수 (0.0 ~ 1.0)
    final ratingScore = (place.rating ?? 0.0) / 5.0;

    // 3. 거리 근접도 계산
    final distanceScore = _calculateDistanceProximity(
      place: place,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );

    // 4. 인기도 계산
    final popularityScore = _calculatePopularityScore(place);

    // 5. 가중치 적용하여 최종 점수 계산
    final totalScore = (categoryScore * config.categoryWeight) +
        (ratingScore * config.ratingWeight) +
        (distanceScore * config.distanceWeight) +
        (popularityScore * config.popularityWeight);

    // 0.0 ~ 1.0 범위로 클램핑
    return totalScore.clamp(0.0, 1.0);
  }

  // ============================================
  // 사용자 선호도 분석
  // ============================================

  /// 과거 여행 기록에서 사용자 선호도 추출
  ///
  /// [tripPlans] - 사용자의 여행 계획 목록
  ///
  /// Returns 카테고리별 선호도 가중치 (합계 1.0)
  Map<PlaceCategory, double> analyzeUserPreferences({
    required List<TripPlan> tripPlans,
  }) {
    // 카테고리별 방문 횟수
    final categoryVisitCount = <PlaceCategory, int>{};
    var totalVisits = 0;

    for (final trip in tripPlans) {
      for (final dailyPlan in trip.dailyPlans) {
        for (final activity in dailyPlan.activities) {
          // 활동에 장소가 있으면 카테고리 추출
          if (activity.place != null) {
            final category =
                getCategoryFromPlaceTypes(activity.place!.types);

            categoryVisitCount[category] =
                (categoryVisitCount[category] ?? 0) + 1;
            totalVisits++;
          }
        }
      }
    }

    // 방문 횟수가 없으면 기본 가중치 반환
    if (totalVisits == 0) {
      return config.defaultCategoryWeights;
    }

    // 카테고리별 비율 계산 (정규화)
    final preferences = <PlaceCategory, double>{};
    for (final entry in categoryVisitCount.entries) {
      preferences[entry.key] = entry.value / totalVisits;
    }

    // 방문하지 않은 카테고리는 작은 가중치 부여 (다양성)
    for (final category in PlaceCategory.values) {
      if (category != PlaceCategory.all && !preferences.containsKey(category)) {
        preferences[category] = 0.05; // 5%
      }
    }

    // 재정규화 (합계 1.0)
    final sum = preferences.values.fold(0.0, (a, b) => a + b);
    final normalized = <PlaceCategory, double>{};
    for (final entry in preferences.entries) {
      normalized[entry.key] = entry.value / sum;
    }

    return normalized;
  }

  // ============================================
  // 다양성 보장 (MMR 알고리즘)
  // ============================================

  /// Maximal Marginal Relevance 알고리즘으로 다양성 보장
  ///
  /// [rankedPlaces] - 점수순으로 정렬된 장소 목록
  /// [topN] - 다양성을 적용할 상위 개수 (기본값: 10)
  ///
  /// Returns 다양성이 보장된 추천 목록
  List<Place> diversifyRecommendations({
    required List<Place> rankedPlaces,
    int topN = 10,
  }) {
    if (rankedPlaces.length <= topN) {
      return rankedPlaces;
    }

    final result = <Place>[];
    final remaining = List<Place>.from(rankedPlaces);
    final categoryCount = <PlaceCategory, int>{};

    while (result.length < topN && remaining.isNotEmpty) {
      Place? selectedPlace;
      var bestScore = double.negativeInfinity;

      for (final place in remaining) {
        final category = getCategoryFromPlaceTypes(place.types);
        final currentCount = categoryCount[category] ?? 0;

        // MMR 점수 계산
        // score = λ × relevance - (1-λ) × redundancy
        const relevance = 1.0; // 이미 점수순으로 정렬됨
        final redundancy = currentCount / config.maxSameCategoryInTop10;

        final mmrScore = (config.diversityLambda * relevance) -
            ((1 - config.diversityLambda) * redundancy);

        if (mmrScore > bestScore) {
          bestScore = mmrScore;
          selectedPlace = place;
        }
      }

      if (selectedPlace != null) {
        result.add(selectedPlace);
        remaining.remove(selectedPlace);

        final category = getCategoryFromPlaceTypes(selectedPlace.types);
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      } else {
        break;
      }
    }

    // 나머지 장소 추가 (topN 이후)
    result.addAll(remaining);

    return result;
  }

  // ============================================
  // 시간대별 부스트 적용
  // ============================================

  /// 현재 시간대에 맞는 카테고리 부스트 적용
  ///
  /// [places] - 장소 목록
  /// [scores] - 각 장소의 점수
  /// [currentTime] - 현재 시간 (기본값: DateTime.now())
  ///
  /// Returns 부스트가 적용된 점수 맵
  Map<Place, double> applyTimeBasedBoost({
    required List<Place> places,
    required Map<Place, double> scores,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final boostedScores = <Place, double>{};

    for (final place in places) {
      final category = getCategoryFromPlaceTypes(place.types);
      final boost = config.getTimeBasedBoost(
        currentTime: now,
        category: category,
      );

      final originalScore = scores[place] ?? 0.0;
      boostedScores[place] = (originalScore * boost).clamp(0.0, 1.0);
    }

    return boostedScores;
  }

  // ============================================
  // Cold Start 처리
  // ============================================

  /// 신규 사용자용 추천 (Cold Start)
  ///
  /// [places] - 전체 장소 목록
  ///
  /// Returns 인기 장소 기반 추천
  List<Place> handleColdStart({
    required List<Place> places,
  }) {
    return coldStartHandler.getDefaultRecommendations(places: places);
  }

  /// Cold Start 여부 확인
  ///
  /// [tripPlans] - 사용자의 여행 계획 목록
  ///
  /// Returns 여행 계획이 부족하면 true
  bool isColdStart({
    required List<TripPlan> tripPlans,
  }) {
    // 여행 계획 수 확인
    if (tripPlans.length < 2) {
      return true;
    }

    // 활동 수 확인
    var activityCount = 0;
    for (final trip in tripPlans) {
      for (final dailyPlan in trip.dailyPlans) {
        activityCount += dailyPlan.activities.length;
      }
    }

    return config.isColdStart(activityCount);
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 카테고리 매칭도 계산
  double _calculateCategoryMatchScore({
    required Place place,
    required Map<PlaceCategory, double> userPreferences,
    DateTime? currentTime,
  }) {
    final category = getCategoryFromPlaceTypes(place.types);

    // 사용자 선호도에서 해당 카테고리 가중치
    final baseScore = userPreferences[category] ?? 0.0;

    // 시간대별 부스트 적용
    final boost = config.getTimeBasedBoost(
      currentTime: currentTime,
      category: category,
    );

    return (baseScore * boost).clamp(0.0, 1.0);
  }

  /// 거리 근접도 계산
  ///
  /// Returns 1.0 (매우 가까움) ~ 0.0 (매우 멀음)
  double _calculateDistanceProximity({
    required Place place,
    required double userLatitude,
    required double userLongitude,
  }) {
    // 거리 계산 (미터)
    final distance = locationService.getDistanceBetween(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude: place.latitude,
      endLongitude: place.longitude,
    );

    // 최대 검색 반경 대비 비율
    final maxDistance = config.searchRadiusMeters;

    // 거리가 가까울수록 높은 점수
    // 1.0 - (실제거리 / 최대거리)
    final proximity = 1.0 - (distance / maxDistance);

    return proximity.clamp(0.0, 1.0);
  }

  /// 인기도 계산
  ///
  /// Returns 0.0 ~ 1.0
  double _calculatePopularityScore(Place place) {
    final reviewCount = place.userRatingsTotal ?? 0;

    // 리뷰 수를 1000으로 나눠서 정규화
    // 1000개 이상이면 1.0
    final normalized = reviewCount / 1000.0;

    return normalized.clamp(0.0, 1.0);
  }

  // ============================================
  // 통합 추천 생성
  // ============================================

  /// 종합 추천 목록 생성
  ///
  /// [places] - 전체 장소 목록
  /// [tripPlans] - 사용자의 여행 계획
  /// [userLatitude] - 사용자 위도
  /// [userLongitude] - 사용자 경도
  /// [currentTime] - 현재 시간 (기본값: DateTime.now())
  ///
  /// Returns 추천 장소 목록 (점수순)
  Future<List<Place>> generateRecommendations({
    required List<Place> places,
    required List<TripPlan> tripPlans,
    required double userLatitude,
    required double userLongitude,
    DateTime? currentTime,
  }) async {
    // 1. Cold Start 확인
    if (isColdStart(tripPlans: tripPlans)) {
      return handleColdStart(places: places);
    }

    // 2. 사용자 선호도 분석
    final userPreferences = analyzeUserPreferences(tripPlans: tripPlans);

    // 3. 각 장소의 추천 점수 계산
    final scores = <Place, double>{};
    for (final place in places) {
      scores[place] = calculateRecommendationScore(
        place: place,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        userPreferences: userPreferences,
        currentTime: currentTime,
      );
    }

    // 4. 시간대별 부스트 적용
    final boostedScores = applyTimeBasedBoost(
      places: places,
      scores: scores,
      currentTime: currentTime,
    );

    // 5. 점수순 정렬
    final rankedPlaces = places.toList()
      ..sort((a, b) {
        final scoreA = boostedScores[a] ?? 0.0;
        final scoreB = boostedScores[b] ?? 0.0;
        return scoreB.compareTo(scoreA); // 내림차순
      });

    // 6. 다양성 보장
    final diversePlaces = diversifyRecommendations(
      rankedPlaces: rankedPlaces,
      topN: config.maxRecommendations,
    );

    // 7. 최대 추천 개수만큼 반환
    return diversePlaces.take(config.maxRecommendations).toList();
  }
}

/// 추천 결과 (점수 포함)
class RecommendationResult {
  final Place place;
  final double score;
  final Map<String, double> scoreBreakdown; // 점수 세부 내역

  const RecommendationResult({
    required this.place,
    required this.score,
    required this.scoreBreakdown,
  });

  @override
  String toString() {
    return 'RecommendationResult(place: ${place.name}, score: ${score.toStringAsFixed(2)})';
  }
}
