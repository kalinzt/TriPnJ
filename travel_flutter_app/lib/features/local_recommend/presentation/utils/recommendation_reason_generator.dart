import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../../data/models/user_preference.dart';

/// 추천 근거 생성 유틸리티
///
/// 사용자 선호도와 장소 정보를 기반으로 추천 이유를 생성합니다.
class RecommendationReasonGenerator {
  /// 추천 이유 생성
  ///
  /// [place] - 추천 장소
  /// [userPreference] - 사용자 선호도
  /// [distance] - 현재 위치로부터의 거리 (미터)
  /// 최대 2개의 이유를 반환합니다.
  static List<String> generateReasons({
    required Place place,
    UserPreference? userPreference,
    double? distance,
  }) {
    final reasons = <String>[];

    // 1. 카테고리 매칭 체크
    if (userPreference != null) {
      final placeCategory = getCategoryFromPlaceTypes(place.types);

      // 사용자가 자주 방문하는 카테고리인지 확인
      final visitCount = userPreference.getVisitCount(placeCategory);
      if (visitCount >= 3) {
        reasons.add('당신이 자주 방문하는 \'${placeCategory.displayName}\'');
      }
    }

    // 2. 높은 평점
    if (place.rating != null && place.rating! >= 4.5) {
      final reviewCount = place.userRatingsTotal ?? 0;
      if (reviewCount >= 100) {
        reasons.add('평점 ${place.rating!.toStringAsFixed(1)}의 인기 장소');
      }
    }

    // 3. 가까운 거리
    if (distance != null && distance <= 500 && reasons.length < 2) {
      reasons.add('현위치에서 가까워요');
    }

    // 4. 비슷한 장소 방문 이력 (선호도 기반)
    if (userPreference != null && reasons.length < 2) {
      final visitedPlaceIds = userPreference.visitedPlaceIds;
      if (visitedPlaceIds.isNotEmpty) {
        // 최근 방문한 장소와 유사한 카테고리
        final placeCategory = getCategoryFromPlaceTypes(place.types);
        final visitCount = userPreference.getVisitCount(placeCategory);

        if (visitCount > 0 && reasons.isEmpty) {
          reasons.add('최근 방문한 장소와 유사한 분위기');
        }
      }
    }

    // 5. 기본 메시지 (이유가 하나도 없는 경우)
    if (reasons.isEmpty) {
      if (place.rating != null && place.rating! >= 4.0) {
        reasons.add('높은 평점의 추천 장소');
      } else {
        reasons.add('새로운 장소를 탐험해보세요');
      }
    }

    // 최대 2개만 반환
    return reasons.take(2).toList();
  }

  /// 거리 텍스트 생성
  ///
  /// [distanceInMeters] - 거리 (미터)
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  /// 추천 점수 텍스트 생성
  ///
  /// [score] - 추천 점수 (0.0 ~ 1.0)
  static String formatScore(double score) {
    final percentage = (score * 100).toInt();
    return '$percentage';
  }

  /// 추천 점수에 따른 색상 그라데이션
  ///
  /// [score] - 추천 점수 (0.0 ~ 1.0)
  static List<String> getScoreGradientColors(double score) {
    if (score >= 0.8) {
      // 높은 점수: 초록색 그라데이션
      return ['#4CAF50', '#66BB6A'];
    } else if (score >= 0.6) {
      // 중간 점수: 파란색 그라데이션
      return ['#2196F3', '#42A5F5'];
    } else if (score >= 0.4) {
      // 보통 점수: 노란색 그라데이션
      return ['#FFC107', '#FFD54F'];
    } else {
      // 낮은 점수: 주황색 그라데이션
      return ['#FF9800', '#FFB74D'];
    }
  }
}
