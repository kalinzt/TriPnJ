# Travel Planner App

Flutter 기반 여행 플래너 애플리케이션

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 메인 앱 위젯
├── core/                        # 핵심 기능
│   ├── constants/              # 상수 정의
│   │   ├── app_colors.dart     # 색상 테마
│   │   ├── app_text_styles.dart # 텍스트 스타일
│   │   └── api_constants.dart  # API 설정
│   ├── router/                 # 라우팅
│   │   └── app_router.dart     # Go Router 설정
│   └── utils/                  # 유틸리티
│       └── logger.dart         # 로깅 도구
├── features/                   # 기능별 모듈
│   ├── home/                   # 홈 화면
│   ├── explore/                # 탐색 기능
│   ├── plan/                   # 일정 계획
│   ├── accommodation/          # 숙박 검색
│   └── ai_recommend/           # AI 추천
└── shared/                     # 공유 리소스
    ├── widgets/                # 공통 위젯
    └── models/                 # 공통 모델
```

## 설치 방법

1. 의존성 설치:
```bash
flutter pub get
```

2. 환경 변수 설정:
   - `.env` 파일에 API 키 추가:
   ```
   GOOGLE_PLACES_API_KEY=your_actual_key
   ANTHROPIC_API_KEY=your_actual_key
   ```

3. Android Google Maps API Key 설정:
   - `android/app/src/main/AndroidManifest.xml` 파일에서 `YOUR_GOOGLE_MAPS_API_KEY_HERE`를 실제 키로 교체

## 주요 패키지

- **flutter_riverpod**: 상태 관리
- **geolocator**: 위치 서비스
- **google_maps_flutter**: 구글 맵
- **http**: HTTP 요청
- **hive**: 로컬 저장소
- **table_calendar**: 달력 UI
- **go_router**: 내비게이션
- **flutter_dotenv**: 환경 변수 관리

## 개발 시작

```bash
flutter run
```

## 권한 설정

### Android
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- INTERNET

### iOS
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
