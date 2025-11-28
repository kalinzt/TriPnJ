import 'package:flutter/material.dart';
import '../../../../shared/models/place_category.dart';

/// 추천 알고리즘 설정
///
/// 추천 점수 계산 가중치 및 검색 파라미터를 관리합니다.
/// 모든 가중치는 동적으로 조정 가능하며, A/B 테스트를 지원합니다.
class RecommendationConfig {
  // ============================================
  // 추천 점수 가중치 (합계 1.0)
  // ============================================

  /// 카테고리 매칭도 가중치 (기본값: 0.3)
  ///
  /// 사용자가 선호하는 카테고리와 얼마나 일치하는지
  final double categoryWeight;

  /// 평점 가중치 (기본값: 0.3)
  ///
  /// Google Places 평점 (0.0 ~ 5.0)
  final double ratingWeight;

  /// 거리 근접도 가중치 (기본값: 0.2)
  ///
  /// 사용자 위치로부터의 거리
  final double distanceWeight;

  /// 인기도 가중치 (기본값: 0.2)
  ///
  /// 리뷰 수 기반 인기도
  final double popularityWeight;

  // ============================================
  // 검색 파라미터
  // ============================================

  /// 검색 반경 (킬로미터, 기본값: 5.0)
  final double searchRadiusKm;

  /// 최대 추천 개수 (기본값: 20)
  final int maxRecommendations;

  // ============================================
  // 다양성 설정
  // ============================================

  /// 상위 10개 추천 중 같은 카테고리 최대 개수 (기본값: 3)
  ///
  /// 예: 상위 10개 중 레스토랑이 최대 3개까지만 포함
  final int maxSameCategoryInTop10;

  /// MMR 알고리즘의 lambda 파라미터 (기본값: 0.7)
  ///
  /// 0.0 = 다양성 우선, 1.0 = 관련성 우선
  final double diversityLambda;

  // ============================================
  // 캐시 설정
  // ============================================

  /// 캐시 유효 기간 (기본값: 24시간)
  final Duration cacheValidDuration;

  // ============================================
  // 시간대별 카테고리 부스트
  // ============================================

  /// 시간대별 카테고리 가중치 부스트
  ///
  /// 예: 아침 시간대에 카페 추천 점수를 1.5배 증가
  final Map<TimeOfDay, Map<PlaceCategory, double>> timeBasedBoost;

  // ============================================
  // Cold Start 처리
  // ============================================

  /// 신규 사용자용 기본 카테고리 가중치
  ///
  /// 사용자 선호도 데이터가 없을 때 사용
  final Map<PlaceCategory, double> defaultCategoryWeights;

  /// Cold Start 시 최소 평점 (기본값: 4.5)
  final double coldStartMinRating;

  /// Cold Start 시 최소 리뷰 수 (기본값: 100)
  final int coldStartMinReviews;

  // ============================================
  // 생성자
  // ============================================

  RecommendationConfig({
    // 가중치
    this.categoryWeight = 0.3,
    this.ratingWeight = 0.3,
    this.distanceWeight = 0.2,
    this.popularityWeight = 0.2,

    // 검색 파라미터
    this.searchRadiusKm = 5.0,
    this.maxRecommendations = 20,

    // 다양성
    this.maxSameCategoryInTop10 = 3,
    this.diversityLambda = 0.7,

    // 캐시
    this.cacheValidDuration = const Duration(hours: 24),

    // 시간대별 부스트
    Map<TimeOfDay, Map<PlaceCategory, double>>? timeBasedBoost,

    // Cold Start
    this.defaultCategoryWeights = _defaultCategoryWeights,
    this.coldStartMinRating = 4.5,
    this.coldStartMinReviews = 100,
  }) : timeBasedBoost = timeBasedBoost ?? _defaultTimeBasedBoost;

  // ============================================
  // 기본값 상수
  // ============================================

  /// 기본 시간대별 카테고리 부스트
  static final Map<TimeOfDay, Map<PlaceCategory, double>> _defaultTimeBasedBoost = {
    // 아침 (7:00 AM) - 카페 부스트
    const TimeOfDay(hour: 7, minute: 0): const {
      PlaceCategory.cafe: 1.5,
      PlaceCategory.restaurant: 0.8,
    },

    // 점심 (12:00 PM) - 레스토랑 부스트
    const TimeOfDay(hour: 12, minute: 0): const {
      PlaceCategory.restaurant: 1.5,
      PlaceCategory.cafe: 1.2,
    },

    // 저녁 (18:00 PM) - 레스토랑 + 야간 부스트
    const TimeOfDay(hour: 18, minute: 0): const {
      PlaceCategory.restaurant: 1.5,
      PlaceCategory.nightlife: 1.3,
      PlaceCategory.cafe: 0.8,
    },
  };

  /// 기본 카테고리 가중치 (Cold Start용)
  static const Map<PlaceCategory, double> _defaultCategoryWeights = {
    PlaceCategory.attraction: 0.3, // 관광 명소
    PlaceCategory.restaurant: 0.25, // 음식점
    PlaceCategory.cafe: 0.2, // 카페
    PlaceCategory.culture: 0.15, // 문화
    PlaceCategory.nature: 0.1, // 자연
  };

  // ============================================
  // 유틸리티 메서드
  // ============================================

  /// 가중치 합계 검증 (디버그용)
  bool get isWeightSumValid {
    final sum = categoryWeight + ratingWeight + distanceWeight + popularityWeight;
    return (sum - 1.0).abs() < 0.001; // 부동소수점 오차 허용
  }

  /// 검색 반경을 미터로 변환
  double get searchRadiusMeters => searchRadiusKm * 1000;

  /// 현재 시간에 맞는 카테고리 부스트 가져오기
  ///
  /// [currentTime] - 현재 시간 (기본값: DateTime.now())
  /// [category] - 카테고리
  ///
  /// Returns 부스트 배수 (기본값: 1.0)
  double getTimeBasedBoost({
    DateTime? currentTime,
    required PlaceCategory category,
  }) {
    final now = currentTime ?? DateTime.now();
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);

    // 현재 시간과 가장 가까운 시간대 찾기
    TimeOfDay? closestTime;
    int minDiff = 24 * 60; // 분 단위

    for (final timeKey in timeBasedBoost.keys) {
      final diff = _getTimeDifferenceInMinutes(currentTimeOfDay, timeKey).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestTime = timeKey;
      }
    }

    // 2시간(120분) 이내면 부스트 적용
    if (closestTime != null && minDiff <= 120) {
      final boosts = timeBasedBoost[closestTime]!;
      return boosts[category] ?? 1.0;
    }

    return 1.0; // 부스트 없음
  }

  /// 두 TimeOfDay 간의 차이를 분 단위로 계산
  int _getTimeDifferenceInMinutes(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 - minutes2;
  }

  /// Cold Start 여부 확인
  ///
  /// [userPreferenceCount] - 사용자 선호도 데이터 개수
  ///
  /// Returns 사용자 데이터가 부족하면 true
  bool isColdStart(int userPreferenceCount) {
    return userPreferenceCount < 3; // 최소 3개의 선호도 필요
  }

  /// copyWith 메서드
  RecommendationConfig copyWith({
    double? categoryWeight,
    double? ratingWeight,
    double? distanceWeight,
    double? popularityWeight,
    double? searchRadiusKm,
    int? maxRecommendations,
    int? maxSameCategoryInTop10,
    double? diversityLambda,
    Duration? cacheValidDuration,
    Map<TimeOfDay, Map<PlaceCategory, double>>? timeBasedBoost,
    Map<PlaceCategory, double>? defaultCategoryWeights,
    double? coldStartMinRating,
    int? coldStartMinReviews,
  }) {
    return RecommendationConfig(
      categoryWeight: categoryWeight ?? this.categoryWeight,
      ratingWeight: ratingWeight ?? this.ratingWeight,
      distanceWeight: distanceWeight ?? this.distanceWeight,
      popularityWeight: popularityWeight ?? this.popularityWeight,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      maxRecommendations: maxRecommendations ?? this.maxRecommendations,
      maxSameCategoryInTop10: maxSameCategoryInTop10 ?? this.maxSameCategoryInTop10,
      diversityLambda: diversityLambda ?? this.diversityLambda,
      cacheValidDuration: cacheValidDuration ?? this.cacheValidDuration,
      timeBasedBoost: timeBasedBoost ?? this.timeBasedBoost,
      defaultCategoryWeights: defaultCategoryWeights ?? this.defaultCategoryWeights,
      coldStartMinRating: coldStartMinRating ?? this.coldStartMinRating,
      coldStartMinReviews: coldStartMinReviews ?? this.coldStartMinReviews,
    );
  }

  @override
  String toString() {
    return 'RecommendationConfig('
        'weights: [category:$categoryWeight, rating:$ratingWeight, '
        'distance:$distanceWeight, popularity:$popularityWeight], '
        'searchRadius: ${searchRadiusKm}km, '
        'maxRecommendations: $maxRecommendations, '
        'diversityLambda: $diversityLambda'
        ')';
  }
}
