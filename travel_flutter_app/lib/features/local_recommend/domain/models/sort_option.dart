/// 추천 정렬 옵션
enum SortOption {
  /// 추천순 (점수 높은 순)
  recommendation,

  /// 거리순 (가까운 순)
  distance,

  /// 평점순 (높은 순)
  rating,

  /// 리뷰 많은 순
  reviewCount,
}

/// SortOption 확장 메서드
extension SortOptionExtension on SortOption {
  /// 정렬 옵션 표시 이름
  String get displayName {
    switch (this) {
      case SortOption.recommendation:
        return '추천순';
      case SortOption.distance:
        return '거리순';
      case SortOption.rating:
        return '평점순';
      case SortOption.reviewCount:
        return '리뷰 많은 순';
    }
  }

  /// 정렬 옵션 설명
  String get description {
    switch (this) {
      case SortOption.recommendation:
        return '추천 점수가 높은 순으로 정렬';
      case SortOption.distance:
        return '현재 위치에서 가까운 순으로 정렬';
      case SortOption.rating:
        return '평점이 높은 순으로 정렬';
      case SortOption.reviewCount:
        return '리뷰가 많은 순으로 정렬';
    }
  }
}
