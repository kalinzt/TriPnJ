/// 시간대별 필터 옵션
enum TimeFilter {
  /// 전체 시간
  all,

  /// 아침 (7-11시)
  morning,

  /// 점심 (11-14시)
  lunch,

  /// 저녁 (17-22시)
  dinner,
}

/// TimeFilter 확장 메서드
extension TimeFilterExtension on TimeFilter {
  /// 표시 이름
  String get displayName {
    switch (this) {
      case TimeFilter.all:
        return '전체';
      case TimeFilter.morning:
        return '아침 (7-11시)';
      case TimeFilter.lunch:
        return '점심 (11-14시)';
      case TimeFilter.dinner:
        return '저녁 (17-22시)';
    }
  }

  /// 설명
  String get description {
    switch (this) {
      case TimeFilter.all:
        return '모든 시간대';
      case TimeFilter.morning:
        return '아침 식사, 카페';
      case TimeFilter.lunch:
        return '점심 식사, 레스토랑';
      case TimeFilter.dinner:
        return '저녁 식사, 바';
    }
  }

  /// 시간대에 맞는 카테고리 부스트 가중치
  ///
  /// 예: 아침 시간대에는 cafe, restaurant 카테고리 부스트
  Map<String, double> get categoryBoosts {
    switch (this) {
      case TimeFilter.all:
        return {};

      case TimeFilter.morning:
        return {
          'cafe': 1.3,
          'restaurant': 1.2,
          'bakery': 1.4,
        };

      case TimeFilter.lunch:
        return {
          'restaurant': 1.4,
          'cafe': 1.2,
          'food': 1.3,
        };

      case TimeFilter.dinner:
        return {
          'restaurant': 1.4,
          'bar': 1.3,
          'night_club': 1.2,
        };
    }
  }
}
