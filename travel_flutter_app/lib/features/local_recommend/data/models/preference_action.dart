/// 사용자의 선호도 관련 행동
///
/// 각 행동은 사용자 선호도 가중치에 영향을 미칩니다.
enum PreferenceAction {
  /// 장소 방문 (여행 계획에 포함)
  ///
  /// 카테고리 가중치 +0.1 (최대 1.0)
  visit,

  /// 장소 좋아요
  ///
  /// 카테고리 가중치 +0.15 (최대 1.0)
  like,

  /// 장소 거절
  ///
  /// 카테고리 가중치 -0.05 (최소 0.0)
  /// rejectedPlaceIds에 추가
  reject,

  /// 여행 계획에 추가
  ///
  /// 카테고리 가중치 +0.1 (최대 1.0)
  /// visitedPlaceIds에 추가
  addToPlan,
}

/// PreferenceAction 확장 메서드
extension PreferenceActionX on PreferenceAction {
  /// 행동에 따른 가중치 변화량
  double get weightDelta {
    switch (this) {
      case PreferenceAction.visit:
        return 0.1;
      case PreferenceAction.like:
        return 0.15;
      case PreferenceAction.reject:
        return -0.05;
      case PreferenceAction.addToPlan:
        return 0.1;
    }
  }

  /// 긍정적인 행동인지 여부
  bool get isPositive {
    return weightDelta > 0;
  }

  /// 방문 이력에 추가할 행동인지 여부
  bool get shouldAddToVisited {
    return this == PreferenceAction.visit || this == PreferenceAction.addToPlan;
  }

  /// 거절 이력에 추가할 행동인지 여부
  bool get shouldAddToRejected {
    return this == PreferenceAction.reject;
  }

  /// 행동 설명 (한글)
  String get description {
    switch (this) {
      case PreferenceAction.visit:
        return '방문';
      case PreferenceAction.like:
        return '좋아요';
      case PreferenceAction.reject:
        return '거절';
      case PreferenceAction.addToPlan:
        return '계획에 추가';
    }
  }
}
