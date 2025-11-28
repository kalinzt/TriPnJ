import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../config/recommendation_config.dart';

/// Cold Start 문제 해결 핸들러
///
/// 신규 사용자 또는 선호도 데이터가 부족한 사용자를 위한
/// 인기 장소 기반 추천을 제공합니다.
class ColdStartHandler {
  final RecommendationConfig config;

  const ColdStartHandler({required this.config});

  // ============================================
  // 인기 장소 추출
  // ============================================

  /// 인기 장소 필터링 및 반환
  ///
  /// [places] - 전체 장소 목록
  /// [userLatitude] - 사용자 위도 (선택)
  /// [userLongitude] - 사용자 경도 (선택)
  ///
  /// Returns 인기 장소 목록 (평점 및 리뷰 수 기준)
  List<Place> getPopularPlaces({
    required List<Place> places,
    double? userLatitude,
    double? userLongitude,
  }) {
    // 1. 인기 장소 필터링
    final popularPlaces = places.where((place) {
      // 평점 기준
      final hasGoodRating = (place.rating ?? 0.0) >= config.coldStartMinRating;

      // 리뷰 수 기준
      final hasEnoughReviews =
          (place.userRatingsTotal ?? 0) >= config.coldStartMinReviews;

      return hasGoodRating && hasEnoughReviews;
    }).toList();

    // 2. 카테고리 다양성 보장
    final diversePlaces = _ensureCategoryDiversity(popularPlaces);

    // 3. 정렬 (평점 × 리뷰 수)
    diversePlaces.sort((a, b) {
      final scoreA = _calculatePopularityScore(a);
      final scoreB = _calculatePopularityScore(b);
      return scoreB.compareTo(scoreA); // 내림차순
    });

    // 4. 최대 추천 개수만큼 반환
    return diversePlaces.take(config.maxRecommendations).toList();
  }

  // ============================================
  // 카테고리 다양성 보장
  // ============================================

  /// 카테고리 다양성을 보장하는 장소 선택
  ///
  /// [places] - 인기 장소 목록
  ///
  /// Returns 카테고리가 다양한 장소 목록
  List<Place> _ensureCategoryDiversity(List<Place> places) {
    final result = <Place>[];
    final categoryCount = <PlaceCategory, int>{};

    // 카테고리별 최대 개수 계산
    final maxPerCategory = (config.maxRecommendations / 5).ceil(); // 5개 주요 카테고리

    for (final place in places) {
      // 장소의 카테고리 추출
      final category = getCategoryFromPlaceTypes(place.types);

      // 해당 카테고리 개수 확인
      final currentCount = categoryCount[category] ?? 0;

      // 카테고리 최대 개수를 초과하지 않으면 추가
      if (currentCount < maxPerCategory) {
        result.add(place);
        categoryCount[category] = currentCount + 1;

        // 목표 개수에 도달하면 종료
        if (result.length >= config.maxRecommendations) {
          break;
        }
      }
    }

    // 목표 개수에 미달하면 나머지 추가
    if (result.length < config.maxRecommendations) {
      final remaining = places
          .where((place) => !result.contains(place))
          .take(config.maxRecommendations - result.length);
      result.addAll(remaining);
    }

    return result;
  }

  // ============================================
  // 인기도 점수 계산
  // ============================================

  /// 장소의 인기도 점수 계산
  ///
  /// [place] - 장소
  ///
  /// Returns 인기도 점수 (평점 × log(리뷰 수))
  double _calculatePopularityScore(Place place) {
    final rating = place.rating ?? 0.0;
    final reviewCount = place.userRatingsTotal ?? 0;

    // 리뷰 수가 0이면 점수 0
    if (reviewCount == 0) return 0.0;

    // 평점 × log(리뷰 수 + 1)
    // log를 사용하여 리뷰 수의 영향을 완화
    final logReviews = _log10(reviewCount + 1);

    return rating * logReviews;
  }

  /// log10 계산 (dart:math 없이)
  double _log10(int value) {
    if (value <= 0) return 0.0;

    // 근사 계산: log10(x) ≈ 자릿수 - 1
    // 더 정확한 계산을 위해 간단한 이진 탐색 사용
    var result = 0.0;
    var val = value.toDouble();

    while (val >= 10) {
      val /= 10;
      result += 1;
    }

    return result + (val - 1) / 9; // 소수점 근사
  }

  // ============================================
  // 카테고리별 인기 장소
  // ============================================

  /// 특정 카테고리의 인기 장소 가져오기
  ///
  /// [places] - 전체 장소 목록
  /// [category] - 카테고리
  /// [limit] - 최대 개수 (기본값: 10)
  ///
  /// Returns 해당 카테고리의 인기 장소
  List<Place> getPopularPlacesByCategory({
    required List<Place> places,
    required PlaceCategory category,
    int limit = 10,
  }) {
    // 1. 카테고리 필터링
    final categoryPlaces = places.where((place) {
      final placeCategory = getCategoryFromPlaceTypes(place.types);
      return placeCategory == category;
    }).toList();

    // 2. 인기 장소 필터링
    final popularPlaces = categoryPlaces.where((place) {
      final hasGoodRating = (place.rating ?? 0.0) >= config.coldStartMinRating;
      final hasEnoughReviews =
          (place.userRatingsTotal ?? 0) >= config.coldStartMinReviews;
      return hasGoodRating && hasEnoughReviews;
    }).toList();

    // 3. 인기도 점수로 정렬
    popularPlaces.sort((a, b) {
      final scoreA = _calculatePopularityScore(a);
      final scoreB = _calculatePopularityScore(b);
      return scoreB.compareTo(scoreA);
    });

    // 4. 상위 N개 반환
    return popularPlaces.take(limit).toList();
  }

  // ============================================
  // 기본 카테고리별 추천
  // ============================================

  /// Cold Start 시 기본 카테고리 가중치를 적용한 추천
  ///
  /// [places] - 전체 장소 목록
  ///
  /// Returns 카테고리 가중치를 고려한 추천 목록
  List<Place> getDefaultRecommendations({
    required List<Place> places,
  }) {
    final recommendations = <Place>[];

    // 기본 카테고리 가중치 순서대로 처리
    final sortedCategories = config.defaultCategoryWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 가중치 내림차순

    for (final entry in sortedCategories) {
      final category = entry.key;
      final weight = entry.value;

      // 가중치에 비례한 개수 계산
      final count = (config.maxRecommendations * weight).round();

      // 해당 카테고리의 인기 장소 가져오기
      final categoryPlaces = getPopularPlacesByCategory(
        places: places,
        category: category,
        limit: count,
      );

      recommendations.addAll(categoryPlaces);

      // 목표 개수 도달 시 종료
      if (recommendations.length >= config.maxRecommendations) {
        break;
      }
    }

    // 목표 개수만큼만 반환
    return recommendations.take(config.maxRecommendations).toList();
  }

  // ============================================
  // 통계 정보
  // ============================================

  /// Cold Start 적용 가능한 장소 통계
  ///
  /// [places] - 전체 장소 목록
  ///
  /// Returns {totalPlaces, popularPlaces, categoryDistribution}
  Map<String, dynamic> getStatistics({
    required List<Place> places,
  }) {
    // 인기 장소 개수
    final popularPlaces = places.where((place) {
      final hasGoodRating = (place.rating ?? 0.0) >= config.coldStartMinRating;
      final hasEnoughReviews =
          (place.userRatingsTotal ?? 0) >= config.coldStartMinReviews;
      return hasGoodRating && hasEnoughReviews;
    }).toList();

    // 카테고리별 분포
    final categoryDistribution = <PlaceCategory, int>{};
    for (final place in popularPlaces) {
      final category = getCategoryFromPlaceTypes(place.types);
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
    }

    return {
      'totalPlaces': places.length,
      'popularPlaces': popularPlaces.length,
      'categoryDistribution': categoryDistribution,
      'coverage': popularPlaces.length / places.length,
    };
  }
}
