import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/place_category.dart';

part 'user_preference.freezed.dart';
part 'user_preference.g.dart';

/// 사용자 선호도 모델
///
/// 사용자의 여행 패턴과 선호도를 저장하여 개인화된 추천을 제공합니다.
@freezed
class UserPreference with _$UserPreference {
  const factory UserPreference({
    /// 카테고리별 선호도 가중치 (0.0 ~ 1.0)
    ///
    /// 예: {'restaurant': 0.7, 'cafe': 0.5, 'attraction': 0.8}
    @Default({}) Map<String, double> categoryWeights,

    /// 방문한 장소 ID 목록
    ///
    /// Google Places ID 저장
    @Default([]) List<String> visitedPlaceIds,

    /// 거절한 장소 ID 목록
    ///
    /// 추천에서 제외할 장소
    @Default([]) List<String> rejectedPlaceIds,

    /// 즐겨찾기 장소 ID 목록
    ///
    /// 사용자가 즐겨찾기한 장소
    @Default([]) List<String> favoritePlaceIds,

    /// 카테고리별 방문 횟수
    ///
    /// 예: {'restaurant': 15, 'cafe': 8, 'attraction': 12}
    @Default({}) Map<String, int> categoryVisitCount,

    /// 마지막 업데이트 시간
    required DateTime lastUpdated,

    /// 선호 평점 기준선 (0.0 ~ 5.0)
    ///
    /// 사용자가 방문한 장소들의 평균 평점
    @Default(4.0) double averageRatingPreference,

    /// 평균 여행 반경 (킬로미터)
    ///
    /// 사용자가 주로 여행하는 거리
    @Default(5.0) double averageTravelRadiusKm,
  }) = _UserPreference;

  const UserPreference._();

  factory UserPreference.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceFromJson(json);

  /// 기본 선호도 생성 (신규 사용자용)
  factory UserPreference.initial() {
    return UserPreference(
      categoryWeights: {
        PlaceCategory.attraction.name: 0.5,
        PlaceCategory.restaurant.name: 0.5,
        PlaceCategory.cafe.name: 0.5,
        PlaceCategory.culture.name: 0.5,
        PlaceCategory.nature.name: 0.5,
        PlaceCategory.shopping.name: 0.5,
        PlaceCategory.nightlife.name: 0.5,
        PlaceCategory.activity.name: 0.5,
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// 특정 장소를 방문했는지 확인
  bool hasVisited(String placeId) {
    return visitedPlaceIds.contains(placeId);
  }

  /// 특정 장소를 거절했는지 확인
  bool hasRejected(String placeId) {
    return rejectedPlaceIds.contains(placeId);
  }

  /// 특정 장소를 즐겨찾기했는지 확인
  bool isFavorite(String placeId) {
    return favoritePlaceIds.contains(placeId);
  }

  /// 특정 카테고리의 방문 횟수 반환
  int getVisitCount(PlaceCategory category) {
    return categoryVisitCount[category.name] ?? 0;
  }

  /// 특정 카테고리의 가중치 반환
  double getCategoryWeight(PlaceCategory category) {
    return categoryWeights[category.name] ?? 0.5;
  }

  /// 전체 방문 횟수
  int get totalVisitCount {
    return categoryVisitCount.values.fold(0, (sum, count) => sum + count);
  }

  /// Cold Start 여부 확인 (방문 이력이 부족한지)
  bool get isColdStart {
    return totalVisitCount < 3;
  }

  /// PlaceCategory를 키로 사용하는 가중치 맵 반환
  Map<PlaceCategory, double> getCategoryWeightsAsEnum() {
    final result = <PlaceCategory, double>{};
    for (final entry in categoryWeights.entries) {
      try {
        final category = PlaceCategory.values.firstWhere(
          (cat) => cat.name == entry.key,
        );
        result[category] = entry.value;
      } catch (_) {
        // 유효하지 않은 카테고리는 무시
      }
    }
    return result;
  }
}
