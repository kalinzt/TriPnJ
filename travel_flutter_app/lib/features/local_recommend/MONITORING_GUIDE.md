# 추천 시스템 모니터링 및 로깅 가이드

이 문서는 추천 시스템의 모니터링, 로깅, 분석 시스템 사용 방법을 설명합니다.

## 목차

1. [개요](#개요)
2. [시스템 구성](#시스템-구성)
3. [사용 방법](#사용-방법)
4. [대시보드 사용](#대시보드-사용)
5. [주의사항](#주의사항)

---

## 개요

추천 시스템의 성능과 품질을 지속적으로 개선하기 위해 다음 3가지 핵심 시스템을 구현했습니다:

- **로깅 시스템**: 모든 이벤트와 에러를 구조화된 형태로 기록
- **메트릭 수집**: 주요 지표를 로컬에 저장하고 일일 리포트 생성
- **성능 모니터링**: 각 작업의 소요 시간을 측정하고 병목 지점 감지

---

## 시스템 구성

### 1. 로깅 시스템 (`recommendation_logger.dart`)

#### 주요 기능
- 추천 생성, 사용자 액션, API 호출, 에러 등 모든 이벤트 로깅
- 개발/프로덕션 환경에 따른 로그 레벨 자동 조정
- 민감한 정보(개인정보, API 키 등) 자동 필터링

#### 사용 예시

```dart
final logger = RecommendationLogger();

// 초기화 (앱 시작 시 한 번만)
logger.init();

// 추천 생성 로그
logger.logRecommendationGenerated(
  recommendationCount: 10,
  averageScore: 4.5,
  duration: Duration(milliseconds: 250),
  algorithmType: 'hybrid',
  metadata: {'filter_count': 2},
);

// 사용자 액션 로그
logger.logUserAction(
  actionType: 'visit',
  placeId: 'ChIJ...',
  placeName: '경복궁',
  score: 4.7,
);

// API 호출 로그
logger.logApiCall(
  endpoint: '/api/recommendations',
  method: 'GET',
  responseTime: Duration(milliseconds: 350),
  statusCode: 200,
  success: true,
);

// 에러 로그
logger.logError(
  error: exception,
  stackTrace: stackTrace,
  context: 'RecommendationService.getRecommendations',
  additionalInfo: {'user_id': userId},
);
```

### 2. 메트릭 수집 시스템 (`recommendation_analytics.dart`)

#### 주요 기능
- 일일 메트릭 자동 수집 및 Hive에 저장
- 주요 지표: 추천 생성 횟수, 사용자 액션, API 호출, 캐시 효율 등
- 일일 리포트 생성 (인사이트 및 개선 권장사항 포함)

#### 사용 예시

```dart
final analytics = RecommendationAnalytics();

// 초기화 (앱 시작 시 한 번만)
await analytics.init();

// 추천 생성 메트릭 기록
await analytics.recordRecommendationGenerated(
  count: 10,
  averageScore: 4.5,
);

// 사용자 액션 메트릭 기록
await analytics.recordUserAction(
  actionType: 'visit',
);

// API 호출 메트릭 기록
await analytics.recordApiCall(
  success: true,
  responseTimeMs: 350,
);

// 캐시 이벤트 기록
await analytics.recordCacheEvent(
  isHit: true,
);

// 일일 리포트 생성
final report = analytics.generateDailyReport();
print('오늘의 주요 지표: ${report['summary']}');
print('인사이트: ${report['insights']}');
print('개선 권장사항: ${report['recommendations']}');
```

### 3. 성능 모니터링 (`performance_monitor.dart`)

#### 주요 기능
- Stopwatch로 작업 소요 시간 자동 측정
- 임계값 초과 시 경고 로그 자동 생성
- 알고리즘, API, 캐시, DB 쿼리 등 작업별 성능 추적

#### 사용 예시

```dart
final perfMonitor = PerformanceMonitor();

// 일반 작업 측정
final result = await perfMonitor.measure(
  operation: 'recommendation_generation',
  task: () async {
    return await generateRecommendations();
  },
  metadata: {'count': 20},
);

// 알고리즘 성능 측정
final recommendations = await perfMonitor.measureAlgorithmPerformance(
  algorithmName: 'collaborative_filtering',
  algorithm: () async {
    return await collaborativeFiltering();
  },
);

// API 성능 측정
final apiResult = await perfMonitor.measureApiPerformance(
  endpoint: '/api/places',
  method: 'GET',
  apiCall: () async {
    return await http.get(uri);
  },
);

// 배치 작업 측정 (순차 실행)
final results = await perfMonitor.measureBatch(
  batchName: 'fetch_all_data',
  tasks: [task1, task2, task3],
);

// 병렬 작업 측정
final parallelResults = await perfMonitor.measureParallel(
  batchName: 'parallel_fetch',
  tasks: [task1, task2, task3],
);

// 성능 통계 조회
final stats = perfMonitor.getPerformanceStats('api_call');
print('평균: ${stats['avg_ms']}ms');
print('P95: ${stats['p95_ms']}ms');
```

### 4. 사용자 액션 추적 (`user_action_tracker.dart`)

#### 주요 기능
- 사용자의 모든 액션을 간편하게 추적
- 자동으로 로깅 및 메트릭 수집

#### 사용 예시

```dart
final tracker = UserActionTracker();

// 장소 방문
await tracker.trackVisit(
  placeId: 'ChIJ...',
  placeName: '경복궁',
  score: 4.7,
);

// 좋아요
await tracker.trackLike(
  placeId: 'ChIJ...',
  placeName: '남산타워',
  score: 4.8,
);

// 일정에 추가
await tracker.trackAddToPlan(
  placeId: 'ChIJ...',
  placeName: '북촌한옥마을',
);

// 즐겨찾기 추가
await tracker.trackAddToFavorite(
  placeId: 'ChIJ...',
  placeName: '인사동',
);

// 공유
await tracker.trackShare(
  placeId: 'ChIJ...',
  placeName: '명동',
);

// 검색
await tracker.trackSearch(
  query: '카페',
  resultCount: 15,
);

// 필터 적용
await tracker.trackFilterApplied(
  filterCount: 3,
  filterTypes: ['category', 'rating', 'distance'],
);
```

---

## 사용 방법

### 기존 코드에 통합하기

#### 1. Provider에 통합 (이미 적용됨)

`recommendation_provider.dart`에서 이미 적용되어 있습니다:

```dart
class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final RecommendationLogger _recLogger = RecommendationLogger();
  final RecommendationAnalytics _analytics = RecommendationAnalytics();
  final PerformanceMonitor _perfMonitor = PerformanceMonitor();

  Future<void> loadInitialRecommendations() async {
    await _perfMonitor.measure(
      operation: 'recommendation_generation',
      task: () async {
        // 추천 로직...

        // 메트릭 기록
        await _analytics.recordRecommendationGenerated(
          count: recommendations.length,
          averageScore: avgScore,
        );
      },
    );
  }
}
```

#### 2. 화면에서 사용자 액션 추적

장소 상세 화면이나 추천 화면에서:

```dart
// 좋아요 버튼 클릭 시
void _onLikeTapped(Place place) {
  UserActionTracker().trackLike(
    placeId: place.id,
    placeName: place.name,
    score: place.rating,
  );

  // 기존 로직...
}

// 일정에 추가 버튼 클릭 시
void _onAddToPlanTapped(Place place) {
  UserActionTracker().trackAddToPlan(
    placeId: place.id,
    placeName: place.name,
  );

  // 기존 로직...
}
```

#### 3. API 서비스에 통합

```dart
class PlaceAnalysisService {
  final _perfMonitor = PerformanceMonitor();

  Future<List<Place>> getTopRecommendations() async {
    return await _perfMonitor.measureApiPerformance(
      endpoint: '/api/recommendations',
      method: 'GET',
      apiCall: () async {
        // API 호출 로직...
      },
    );
  }
}
```

---

## 대시보드 사용

### 통계 화면 접근

관리자용 통계 대시보드를 사용하려면:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const RecommendationStatsScreen(),
  ),
);
```

### 대시보드 기능

#### 1. 개요 탭
- 오늘의 주요 지표 (추천 생성, 사용자 액션, 평균 점수 등)
- AI 기반 인사이트 (높은/낮은 CTR, 전환율 등)
- 개선 권장사항
- 상위 사용자 액션 통계

#### 2. 성능 탭
- 작업별 성능 통계
- 평균, 최소, 최대, P50, P95, P99 지표
- 병목 지점 식별

#### 3. 에러 탭
- 최근 에러 로그 (최대 50개)
- 에러 타입, 발생 위치, 시간, 상세 정보

#### 4. 설정 탭
- 저장된 데이터 확인
- 30일 이전 데이터 정리
- 모든 데이터 초기화

---

## 주의사항

### 1. 개인정보 보호

로깅 시스템은 자동으로 민감한 정보를 필터링합니다:
- 이메일 주소
- 전화번호
- API 키/토큰
- 비밀번호

하지만 추가적인 개인정보가 있다면 직접 필터링해야 합니다.

### 2. 성능 오버헤드

- 로깅과 모니터링은 최소한의 오버헤드로 설계되었습니다
- 프로덕션 환경에서는 debug 로그가 자동으로 비활성화됩니다
- 성능 메트릭은 비동기로 저장되어 메인 로직을 방해하지 않습니다

### 3. 저장 공간 관리

- 에러 로그: 최대 100개 (자동 정리)
- 성능 메트릭: 최대 1000개/일 (자동 정리)
- 일일 메트릭: 30일 보관 (설정 탭에서 정리 가능)

### 4. 로그 레벨

개발 환경:
- DEBUG, INFO, WARNING, ERROR 모두 출력

프로덕션 환경:
- INFO, WARNING, ERROR만 출력
- DEBUG 로그는 자동 비활성화

---

## 임계값 설정

`performance_monitor.dart`에서 작업별 임계값을 조정할 수 있습니다:

```dart
static const Map<String, int> _thresholds = {
  'recommendation_generation': 1000,  // 1초
  'algorithm_execution': 500,         // 500ms
  'api_call': 2000,                   // 2초
  'cache_operation': 100,             // 100ms
  'database_query': 300,              // 300ms
  'data_processing': 200,             // 200ms
};
```

임계값을 초과하면 자동으로 경고 로그가 생성됩니다.

---

## 데이터 분석 활용

### 1. CTR (Click-Through Rate) 분석
```dart
final metrics = analytics.getTodayMetrics();
print('오늘의 CTR: ${metrics.clickThroughRate * 100}%');
```

### 2. 전환율 분석
```dart
print('오늘의 전환율: ${metrics.conversionRate * 100}%');
```

### 3. 캐시 효율성
```dart
print('캐시 히트율: ${metrics.cacheHitRate * 100}%');
```

### 4. API 안정성
```dart
print('API 실패율: ${metrics.apiFailureRate * 100}%');
```

---

## 문제 해결

### 로그가 보이지 않는 경우
1. `RecommendationLogger().init()`이 호출되었는지 확인
2. 로그 레벨이 적절한지 확인
3. 프로덕션 환경에서는 debug 로그가 비활성화됨

### 메트릭이 수집되지 않는 경우
1. `RecommendationAnalytics().init()`이 호출되었는지 확인
2. Hive가 제대로 초기화되었는지 확인
3. build_runner로 어댑터가 생성되었는지 확인

### 대시보드가 표시되지 않는 경우
1. 데이터가 충분히 수집되었는지 확인 (최소 1일 필요)
2. 에러 로그 탭에서 오류 확인

---

## 모범 사례

1. **앱 시작 시 초기화**: `main.dart`에서 로거와 분석 시스템을 초기화
2. **일관된 액션 타입**: 동일한 액션은 항상 같은 타입 문자열 사용
3. **의미 있는 메타데이터**: 로그에 충분한 컨텍스트 정보 포함
4. **정기적인 데이터 정리**: 매월 오래된 데이터 정리
5. **대시보드 모니터링**: 주기적으로 인사이트와 권장사항 확인

---

## 추가 개선 아이디어

1. **원격 로깅**: Firebase Analytics, Sentry 등과 통합
2. **실시간 알림**: 심각한 에러 발생 시 알림
3. **A/B 테스트**: 추천 알고리즘 A/B 테스트 자동화
4. **머신러닝**: 메트릭 데이터로 추천 품질 예측
5. **차트 시각화**: flutter_charts 등으로 시각화 강화
