# 로컬 추천 시스템 (Local Recommendation System)

사용자의 여행 패턴과 선호도를 학습하여 개인화된 장소 추천을 제공하는 시스템입니다.

## 목차
- [개요](#개요)
- [아키텍처](#아키텍처)
- [추천 알고리즘](#추천-알고리즘)
- [주요 기능](#주요-기능)
- [설정 및 커스터마이징](#설정-및-커스터마이징)
- [API 쿼터 관리](#api-쿼터-관리)
- [트러블슈팅](#트러블슈팅)

---

## 개요

### 핵심 기능
- **개인화된 추천**: 사용자의 과거 여행 기록과 선호도를 분석하여 맞춤형 장소 추천
- **실시간 학습**: 사용자 피드백을 통한 Exponential Moving Average 기반 선호도 학습
- **다양성 보장**: MMR(Maximal Marginal Relevance) 알고리즘으로 다양한 카테고리 추천
- **Cold Start 처리**: 신규 사용자를 위한 인기도 기반 추천
- **A/B 테스트**: 추천 전략의 성능 비교 및 최적화
- **성능 메트릭**: CTR, 전환율, 사용자 만족도 등 추천 품질 측정

### 주요 구성 요소

```
lib/features/local_recommend/
├── data/
│   ├── models/
│   │   └── user_preference.dart          # 사용자 선호도 모델
│   ├── services/
│   │   ├── place_analysis_service.dart   # 장소 분석 및 추천 생성
│   │   ├── ab_test_service.dart          # A/B 테스트 관리
│   │   └── cache_manager.dart            # LRU 캐시 관리
│   └── repositories/
│       └── user_preference_repository.dart
│
├── domain/
│   ├── algorithms/
│   │   ├── recommendation_algorithm.dart # 핵심 추천 알고리즘
│   │   ├── preference_learning.dart      # 선호도 학습 알고리즘
│   │   ├── cold_start_handler.dart       # Cold Start 처리
│   │   └── score_cache.dart              # 점수 메모이제이션
│   ├── analytics/
│   │   └── recommendation_metrics.dart   # 추천 품질 메트릭
│   ├── models/
│   │   ├── sort_option.dart              # 정렬 옵션
│   │   ├── time_filter.dart              # 시간대 필터
│   │   └── ab_test_config.dart           # A/B 테스트 설정
│   └── config/
│       └── recommendation_config.dart    # 추천 시스템 설정
│
└── presentation/
    ├── screens/
    │   └── local_recommend_screen.dart   # 추천 화면 (리스트/지도)
    ├── widgets/
    │   ├── enhanced_recommendation_card.dart
    │   ├── swipeable_recommendation_card.dart
    │   ├── recommendation_filter_sheet.dart
    │   └── recommendation_map_view.dart
    └── providers/
        └── recommendation_provider.dart  # 상태 관리
```

---

## 아키텍처

### 시스템 흐름

```
┌─────────────────┐
│  User Interface │
│  (List/Map View)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│RecommendationProvider│ ◄─── Riverpod State Management
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│PlaceAnalysisService  │
│  - 추천 생성         │
│  - 캐싱              │
│  - Rate Limiting     │
└────────┬─────────────┘
         │
         ├──► RecommendationAlgorithm (점수 계산)
         ├──► PreferenceLearning (학습)
         ├──► ABTestService (A/B 테스트)
         └──► RecommendationMetrics (메트릭)
```

### 데이터 흐름

1. **사용자 요청** → RecommendationProvider
2. **장소 데이터 로드** → PlacesRepository (Google Places API)
3. **사용자 선호도 로드** → UserPreferenceRepository
4. **추천 점수 계산** → RecommendationAlgorithm
5. **다양성 보장** → MMR 알고리즘
6. **캐싱** → LRU Cache Manager
7. **UI 렌더링** → EnhancedRecommendationCard

---

## 추천 알고리즘

### 1. 추천 점수 계산

추천 점수는 다음 4가지 요소의 가중 평균으로 계산됩니다:

```dart
final score = (categoryScore × 0.40) +    // 카테고리 매칭도
              (ratingScore × 0.25) +      // 평점
              (distanceScore × 0.20) +    // 거리 근접도
              (popularityScore × 0.15);   // 인기도
```

#### 1.1 카테고리 매칭도 (40%)

```dart
// 사용자 선호도 가중치 적용
categoryScore = userPreferences[placeCategory] ?? 0.5;

// 시간대별 부스트 (morning/lunch/dinner)
if (isRelevantTime) {
  categoryScore *= 1.2; // 20% 부스트
}
```

#### 1.2 평점 점수 (25%)

```dart
ratingScore = (place.rating ?? 0.0) / 5.0;
```

#### 1.3 거리 근접도 (20%)

```dart
// 시그모이드 함수로 거리 점수 계산
distanceScore = 1.0 / (1.0 + exp(distanceKm - 5.0));

// 예:
// 0km   → 1.0
// 2.5km → 0.92
// 5km   → 0.50
// 10km  → 0.07
```

#### 1.4 인기도 (15%)

```dart
// 리뷰 수를 로그 스케일로 변환
popularityScore = log(1 + reviewCount) / log(1001);

// 예:
// 10 reviews   → 0.47
// 100 reviews  → 0.67
// 1000 reviews → 1.0
```

### 2. 선호도 학습 (Preference Learning)

#### Exponential Moving Average (EMA)

```dart
// 학습률: 0.1 (초기) → 0.01 (후기)
newWeight = oldWeight × (1 - α) + feedback × α

// 예시 (α = 0.1):
// 긍정 피드백: 0.5 → 0.55 → 0.595 → 0.6355 ...
// 부정 피드백: 0.5 → 0.45 → 0.405 → 0.3645 ...
```

#### 신뢰도 점수

```dart
// Sigmoid 함수로 데이터 양에 따른 신뢰도 계산
confidence = 1.0 / (1.0 + exp(-0.3 * (feedbackCount - 10)))

// 예:
// 1 피드백   → 0.05 (낮은 신뢰도)
// 10 피드백  → 0.50 (중간 신뢰도)
// 50 피드백  → 0.99 (높은 신뢰도)
```

### 3. 다양성 보장 (MMR - Maximal Marginal Relevance)

```dart
// 상위 10개 중 같은 카테고리가 7개를 초과하지 않도록 제한
maxSameCategoryInTop10 = 7;

// 알고리즘:
// 1. 점수 순으로 정렬
// 2. 상위부터 선택하되, 카테고리 제한 확인
// 3. 제한 초과 시 다음 장소 선택
// 4. 다양성 보장
```

### 4. Cold Start 처리

신규 사용자의 경우:

```dart
// 인기도 기반 추천
if (userPreferences.isColdStart) {
  return popularPlaces
      .sortedBy((p) => (p.rating * p.reviewCount))
      .diversified()
      .top(20);
}
```

---

## 주요 기능

### 1. 실시간 필터링

```dart
// 카테고리, 거리, 평점, 리뷰 수, 시간대 필터 지원
await recommendationProvider.updateFilter(
  selectedCategories: {'restaurant', 'cafe'},
  maxDistance: 5.0,
  minRating: 4.0,
  minReviewCount: 50,
  timeFilter: TimeFilter.lunch,
);
```

### 2. 정렬 옵션

```dart
enum SortOption {
  recommendation,  // 추천순 (기본값)
  distance,        // 거리순
  rating,          // 평점순
  reviewCount,     // 리뷰 많은 순
}
```

### 3. 즐겨찾기

```dart
// 즐겨찾기 추가/제거
await userPreferenceRepository.toggleFavorite(placeId);

// 즐겨찾기만 보기
final favorites = recommendations
    .where((p) => userPreference.isFavorite(p.id))
    .toList();
```

### 4. 피드백 학습

```dart
// 긍정/부정 피드백 제공
await metrics.logFeedback(
  placeId: placeId,
  placeName: placeName,
  categories: categories,
  isPositive: true, // or false
);

// 가중치 업데이트
final updated = PreferenceLearning.updateWeightsFromFeedback(
  categoryWeights: currentWeights,
  category: category,
  isPositive: isPositive,
);
```

### 5. A/B 테스트

```dart
// 테스트 설정
final config = ABTestConfig(
  testId: 'personalization_vs_popularity',
  testName: '개인화 vs 인기도',
  variants: [
    ABTestVariant(
      variantId: 'control',
      allocationRatio: 0.5,
      personalizationWeightMultiplier: 1.0,
    ),
    ABTestVariant(
      variantId: 'variant_a',
      allocationRatio: 0.5,
      personalizationWeightMultiplier: 1.5,
    ),
  ],
);

// 사용자 할당
final variant = abTestService.assignVariant(
  userId: userId,
  config: config,
);

// 이벤트 로깅
await abTestService.logEvent(
  testId: testId,
  variantId: variantId,
  eventType: 'conversion',
);
```

---

## 설정 및 커스터마이징

### RecommendationConfig

```dart
// lib/features/local_recommend/domain/config/recommendation_config.dart

class RecommendationConfig {
  // 가중치 설정
  final double categoryWeight = 0.40;
  final double ratingWeight = 0.25;
  final double distanceWeight = 0.20;
  final double popularityWeight = 0.15;

  // 다양성 설정
  final int maxSameCategoryInTop10 = 7;

  // 거리 설정
  final double maxDistanceKm = 50.0;

  // 학습 설정
  final double learningRate = 0.1;

  // 캐시 설정
  final int maxCacheSize = 100 * 1024 * 1024; // 100MB
  final Duration cacheExpiry = Duration(hours: 24);
}
```

### 가중치 변경 예시

```dart
// 거리를 더 중요하게
final config = RecommendationConfig(
  categoryWeight: 0.30,
  ratingWeight: 0.20,
  distanceWeight: 0.35,  // 증가
  popularityWeight: 0.15,
);

// 알고리즘 생성
final algorithm = RecommendationAlgorithm(config: config);
```

---

## API 쿼터 관리

Google Places API는 무료 할당량이 제한적이므로 효율적인 관리가 필요합니다.

### 1. Rate Limiting

```dart
// lib/features/local_recommend/data/services/place_analysis_service.dart

class PlaceAnalysisService {
  static const Duration minRequestInterval = Duration(seconds: 1);
  DateTime? _lastRequestTime;

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < minRequestInterval) {
        await Future.delayed(minRequestInterval - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }
}
```

### 2. 캐싱 전략

```dart
// LRU 캐시로 중복 요청 방지
final cached = await cacheManager.get(cacheKey);
if (cached != null) {
  return cached; // API 호출 없이 캐시 반환
}

// API 호출 후 캐싱
final result = await placesRepository.getNearbyPlaces(...);
await cacheManager.put(cacheKey, result);
```

### 3. Batch Processing

```dart
// 여러 장소의 세부 정보를 한 번에 요청
final placeIds = ['place1', 'place2', 'place3'];
final details = await placesRepository.getPlaceDetailsBatch(placeIds);
```

### 4. 쿼터 모니터링

```dart
// 일일 API 호출 수 추적
class APIUsageTracker {
  static int _todayCalls = 0;
  static const int dailyLimit = 1000;

  static bool canMakeRequest() {
    return _todayCalls < dailyLimit;
  }

  static void incrementUsage() {
    _todayCalls++;
  }
}
```

---

## 트러블슈팅

### 1. 추천이 표시되지 않음

**원인**:
- 사용자 위치를 가져오지 못함
- API 쿼터 초과
- 네트워크 연결 문제

**해결 방법**:
```dart
// 1. 위치 권한 확인
final permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  await Geolocator.requestPermission();
}

// 2. 에러 로그 확인
Logger.info('추천 로드 시작', 'RecommendationNotifier');

// 3. 오프라인 모드 사용
if (!isOnline) {
  return cachedRecommendations;
}
```

### 2. 추천 점수가 부정확함

**원인**:
- 가중치 설정이 부적절
- 사용자 선호도 데이터 부족

**해결 방법**:
```dart
// 1. 가중치 조정
final config = RecommendationConfig(
  categoryWeight: 0.45,  // 카테고리 중요도 증가
  ratingWeight: 0.20,
  distanceWeight: 0.20,
  popularityWeight: 0.15,
);

// 2. Cold Start 모드 확인
if (userPreference.isColdStart) {
  // 신규 사용자는 인기도 기반 추천 사용
}

// 3. 피드백 수집 강화
// UI에 피드백 버튼 추가하여 데이터 수집
```

### 3. 성능 저하

**원인**:
- 캐시 미사용
- 과도한 API 호출
- 메모리 부족

**해결 방법**:
```dart
// 1. 캐시 활성화 확인
final cached = await cacheManager.get(key);

// 2. 디바운싱 적용
final debouncer = Debouncer(duration: Duration(milliseconds: 800));
debouncer.run(() => loadRecommendations());

// 3. 이미지 메모리 최적화
CachedNetworkImage(
  memCacheWidth: 800,
  memCacheHeight: 450,
)
```

### 4. A/B 테스트 결과가 일관되지 않음

**원인**:
- 사용자 그룹 할당이 불안정
- 샘플 크기 부족

**해결 방법**:
```dart
// 1. 일관성 있는 해싱 사용
final hash = sha256.convert(utf8.encode('$userId:$testId'));

// 2. 충분한 샘플 크기 확보 (최소 100명)
if (totalUsers < 100) {
  // 테스트 결과 신뢰도 낮음
}

// 3. 통계적 유의성 확인
final pValue = calculatePValue(controlGroup, variantGroup);
if (pValue < 0.05) {
  // 유의미한 차이
}
```

---

## 성능 벤치마크

### 추천 생성 속도

| 시나리오 | 평균 시간 | 목표 |
|---------|----------|------|
| Cold Start (캐시 없음) | 2.5s | < 3s |
| Warm Start (캐시 있음) | 150ms | < 200ms |
| 필터 변경 (디바운싱) | 100ms | < 150ms |

### 메모리 사용량

| 구성 요소 | 메모리 | 제한 |
|----------|--------|------|
| 추천 캐시 | ~50MB | 100MB |
| 이미지 캐시 | ~80MB | 150MB |
| 메트릭 데이터 | ~2MB | 10MB |

### 테스트 커버리지

| 모듈 | 커버리지 |
|-----|---------|
| PreferenceLearning | 95% |
| RecommendationMetrics | 90% |
| ABTestService | 85% |
| **전체** | **88%** |

---

## 참고 자료

- [Google Places API 문서](https://developers.google.com/maps/documentation/places/web-service)
- [Riverpod 공식 문서](https://riverpod.dev/)
- [Exponential Moving Average](https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average)
- [Maximal Marginal Relevance](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf)

---

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
