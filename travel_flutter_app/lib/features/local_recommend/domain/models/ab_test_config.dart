/// A/B 테스트 설정
///
/// 서로 다른 추천 전략을 테스트하기 위한 변형(variant) 설정을 정의합니다.
class ABTestConfig {
  /// 테스트 ID
  final String testId;

  /// 테스트 이름
  final String testName;

  /// 테스트 설명
  final String description;

  /// 테스트가 활성화되었는지 여부
  final bool isEnabled;

  /// 변형 목록
  final List<ABTestVariant> variants;

  /// 테스트 시작 시간
  final DateTime startTime;

  /// 테스트 종료 시간 (null이면 무기한)
  final DateTime? endTime;

  const ABTestConfig({
    required this.testId,
    required this.testName,
    required this.description,
    required this.isEnabled,
    required this.variants,
    required this.startTime,
    this.endTime,
  });

  /// 현재 테스트가 진행 중인지 확인
  bool get isActive {
    if (!isEnabled) return false;

    final now = DateTime.now();
    if (now.isBefore(startTime)) return false;
    if (endTime != null && now.isAfter(endTime!)) return false;

    return true;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'description': description,
      'isEnabled': isEnabled,
      'variants': variants.map((v) => v.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory ABTestConfig.fromJson(Map<String, dynamic> json) {
    return ABTestConfig(
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool,
      variants: (json['variants'] as List<dynamic>)
          .map((v) => ABTestVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  ABTestConfig copyWith({
    String? testId,
    String? testName,
    String? description,
    bool? isEnabled,
    List<ABTestVariant>? variants,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ABTestConfig(
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      variants: variants ?? this.variants,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// A/B 테스트 변형
///
/// 각 변형은 서로 다른 추천 전략을 나타냅니다.
class ABTestVariant {
  /// 변형 ID
  final String variantId;

  /// 변형 이름
  final String variantName;

  /// 할당 비율 (0.0 ~ 1.0)
  /// 예: 0.5 = 50% 사용자에게 할당
  final double allocationRatio;

  /// 카테고리별 가중치 조정
  /// 예: {'restaurant': 1.2, 'cafe': 0.8}
  final Map<String, double> categoryWeightMultipliers;

  /// 거리 가중치 조정 (1.0 = 기본값)
  final double distanceWeightMultiplier;

  /// 평점 가중치 조정 (1.0 = 기본값)
  final double ratingWeightMultiplier;

  /// 리뷰 수 가중치 조정 (1.0 = 기본값)
  final double reviewCountWeightMultiplier;

  /// 개인화 가중치 조정 (1.0 = 기본값)
  final double personalizationWeightMultiplier;

  const ABTestVariant({
    required this.variantId,
    required this.variantName,
    required this.allocationRatio,
    this.categoryWeightMultipliers = const {},
    this.distanceWeightMultiplier = 1.0,
    this.ratingWeightMultiplier = 1.0,
    this.reviewCountWeightMultiplier = 1.0,
    this.personalizationWeightMultiplier = 1.0,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'variantName': variantName,
      'allocationRatio': allocationRatio,
      'categoryWeightMultipliers': categoryWeightMultipliers,
      'distanceWeightMultiplier': distanceWeightMultiplier,
      'ratingWeightMultiplier': ratingWeightMultiplier,
      'reviewCountWeightMultiplier': reviewCountWeightMultiplier,
      'personalizationWeightMultiplier': personalizationWeightMultiplier,
    };
  }

  /// JSON에서 생성
  factory ABTestVariant.fromJson(Map<String, dynamic> json) {
    return ABTestVariant(
      variantId: json['variantId'] as String,
      variantName: json['variantName'] as String,
      allocationRatio: (json['allocationRatio'] as num).toDouble(),
      categoryWeightMultipliers:
          Map<String, double>.from(json['categoryWeightMultipliers'] as Map? ?? {}),
      distanceWeightMultiplier:
          (json['distanceWeightMultiplier'] as num?)?.toDouble() ?? 1.0,
      ratingWeightMultiplier:
          (json['ratingWeightMultiplier'] as num?)?.toDouble() ?? 1.0,
      reviewCountWeightMultiplier:
          (json['reviewCountWeightMultiplier'] as num?)?.toDouble() ?? 1.0,
      personalizationWeightMultiplier:
          (json['personalizationWeightMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// 기본 A/B 테스트 설정 예시
class DefaultABTestConfigs {
  /// 예시 1: 개인화 vs 인기도 기반 추천
  static ABTestConfig get personalizationVsPopularity {
    return ABTestConfig(
      testId: 'personalization_vs_popularity_2024',
      testName: '개인화 vs 인기도 기반 추천',
      description: '개인화된 추천과 인기도 기반 추천의 효과를 비교합니다.',
      isEnabled: true,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(days: 30)),
      variants: [
        // 대조군: 기본 추천 (50:50 균형)
        const ABTestVariant(
          variantId: 'control',
          variantName: '대조군 (균형)',
          allocationRatio: 0.33,
          personalizationWeightMultiplier: 1.0,
          ratingWeightMultiplier: 1.0,
        ),
        // 변형 A: 개인화 강화
        const ABTestVariant(
          variantId: 'variant_a',
          variantName: '변형 A (개인화 강화)',
          allocationRatio: 0.33,
          personalizationWeightMultiplier: 1.5, // 개인화 50% 증가
          ratingWeightMultiplier: 0.7, // 평점 30% 감소
        ),
        // 변형 B: 인기도 강화
        const ABTestVariant(
          variantId: 'variant_b',
          variantName: '변형 B (인기도 강화)',
          allocationRatio: 0.34,
          personalizationWeightMultiplier: 0.7, // 개인화 30% 감소
          ratingWeightMultiplier: 1.5, // 평점 50% 증가
        ),
      ],
    );
  }

  /// 예시 2: 카테고리 균형 테스트
  static ABTestConfig get categoryBalanceTest {
    return ABTestConfig(
      testId: 'category_balance_2024',
      testName: '카테고리 다양성 테스트',
      description: '다양한 카테고리 노출이 사용자 만족도에 미치는 영향을 측정합니다.',
      isEnabled: false,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(days: 30)),
      variants: [
        // 대조군: 기본 추천
        const ABTestVariant(
          variantId: 'control',
          variantName: '대조군',
          allocationRatio: 0.5,
        ),
        // 변형: 카테고리 다양성 강화
        const ABTestVariant(
          variantId: 'variant_diversity',
          variantName: '변형 (다양성 강화)',
          allocationRatio: 0.5,
          categoryWeightMultipliers: {
            'restaurant': 1.0,
            'cafe': 1.2,
            'tourist_attraction': 1.2,
            'park': 1.2,
            'museum': 1.2,
            'shopping_mall': 1.2,
          },
        ),
      ],
    );
  }

  /// 모든 기본 설정 가져오기
  static List<ABTestConfig> get all {
    return [
      personalizationVsPopularity,
      categoryBalanceTest,
    ];
  }
}
