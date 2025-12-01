import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 관련 상수 정의
class ApiConstants {
  ApiConstants._();

  // ============================================
  // API Keys
  // ============================================

  /// Google Places API 키
  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Anthropic API 키
  static String get anthropicApiKey =>
      dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  // ============================================
  // Google Places API
  // ============================================

  /// Google Places API 베이스 URL
  static const String googlePlacesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  /// Nearby Search - 주변 장소 검색
  static const String placesNearbySearch = '$googlePlacesBaseUrl/nearbysearch/json';

  /// Text Search - 텍스트 기반 장소 검색
  static const String placesTextSearch = '$googlePlacesBaseUrl/textsearch/json';

  /// Place Details - 장소 상세 정보
  static const String placesDetails = '$googlePlacesBaseUrl/details/json';

  /// Place Autocomplete - 자동완성
  static const String placesAutocomplete = '$googlePlacesBaseUrl/autocomplete/json';

  /// Place Photos - 장소 사진
  static const String placesPhotos = '$googlePlacesBaseUrl/photo';

  /// Find Place - 장소 찾기
  static const String placesFindPlace = '$googlePlacesBaseUrl/findplacefromtext/json';

  // ============================================
  // Google Places - Place Types
  // ============================================

  static const List<String> placeTypes = [
    'tourist_attraction', // 관광 명소
    'lodging', // 숙박
    'restaurant', // 레스토랑
    'cafe', // 카페
    'museum', // 박물관
    'park', // 공원
    'shopping_mall', // 쇼핑몰
    'airport', // 공항
    'train_station', // 기차역
    'bus_station', // 버스 정류장
    'hospital', // 병원
    'pharmacy', // 약국
    'atm', // ATM
    'bank', // 은행
    'gas_station', // 주유소
    'parking', // 주차장
    'church', // 교회
    'temple', // 사원
    'mosque', // 모스크
    'synagogue', // 회당
  ];

  // ============================================
  // Anthropic API
  // ============================================

  /// Anthropic API 베이스 URL
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';

  /// Messages - 메시지 생성
  static const String anthropicMessages = '$anthropicBaseUrl/messages';

  /// Anthropic API 버전
  static const String anthropicVersion = '2023-06-01';

  /// 사용 가능한 Claude 모델들
  static const String claudeSonnet = 'claude-3-5-sonnet-20241022';
  static const String claudeOpus = 'claude-3-opus-20240229';
  static const String claudeHaiku = 'claude-3-5-haiku-20241022';

  /// 기본 사용 모델
  static const String defaultClaudeModel = claudeSonnet;

  /// 최대 토큰 수
  static const int maxTokens = 4096;

  // ============================================
  // HTTP Configuration
  // ============================================

  /// 연결 타임아웃 (30초)
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// 수신 타임아웃 (30초)
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// 재시도 횟수
  static const int maxRetries = 3;

  /// 재시도 간격 (초)
  static const Duration retryDelay = Duration(seconds: 2);

  // ============================================
  // Request Limits
  // ============================================

  /// 한 번에 가져올 최대 장소 수
  static const int maxPlacesPerRequest = 20;

  /// 검색 반경 (미터) - 기본값
  static const int defaultSearchRadius = 5000; // 5km

  /// 검색 반경 (미터) - 최소값
  static const int minSearchRadius = 500; // 500m

  /// 검색 반경 (미터) - 최대값
  static const int maxSearchRadius = 50000; // 50km

  // ============================================
  // Headers
  // ============================================

  /// 공통 헤더
  static Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Anthropic 헤더
  static Map<String, String> get anthropicHeaders => {
        ...commonHeaders,
        'x-api-key': anthropicApiKey,
        'anthropic-version': anthropicVersion,
      };

  // ============================================
  // Cache Configuration
  // ============================================

  /// 캐시 유효 시간 (1시간)
  static const Duration cacheValidDuration = Duration(hours: 1);

  /// 이미지 캐시 유효 시간 (24시간)
  static const Duration imageCacheValidDuration = Duration(hours: 24);

  // ============================================
  // Helper Methods
  // ============================================

  /// Google Places API 키가 설정되어 있는지 확인
  static bool get hasGoogleApiKey => googlePlacesApiKey.isNotEmpty;

  /// Anthropic API 키가 설정되어 있는지 확인
  static bool get hasAnthropicApiKey => anthropicApiKey.isNotEmpty;

  /// API 키 유효성 검증
  static bool validateApiKeys() {
    if (!hasGoogleApiKey) {
      throw Exception('Google Places API 키가 설정되지 않았습니다.');
    }
    if (!hasAnthropicApiKey) {
      throw Exception('Anthropic API 키가 설정되지 않았습니다.');
    }
    return true;
  }

  /// Google Places 사진 URL 생성
  static String getPhotoUrl({
    required String photoReference,
    int maxWidth = 400,
    int? maxHeight,
  }) {
    final buffer = StringBuffer(placesPhotos);
    buffer.write('?photoreference=$photoReference');
    buffer.write('&key=$googlePlacesApiKey');
    buffer.write('&maxwidth=$maxWidth');
    if (maxHeight != null) {
      buffer.write('&maxheight=$maxHeight');
    }
    return buffer.toString();
  }

  /// 검색 반경 유효성 검증
  static int validateSearchRadius(int radius) {
    if (radius < minSearchRadius) {
      return minSearchRadius;
    }
    if (radius > maxSearchRadius) {
      return maxSearchRadius;
    }
    return radius;
  }
}

/// 추천 시스템 관련 상수
class RecommendationConstants {
  RecommendationConstants._();

  // ============================================
  // API Rate Limiting
  // ============================================

  /// 분당 최대 API 호출 횟수
  static const int maxApiCallsPerMinute = 60;

  /// Rate Limit 윈도우 (1분)
  static const Duration rateLimitWindow = Duration(minutes: 1);

  /// 최대 동시 요청 수
  static const int maxConcurrentRequests = 5;

  // ============================================
  // Cache Configuration
  // ============================================

  /// 추천 캐시 Box 이름
  static const String cacheBoxName = 'recommendations_cache';

  /// 캐시 만료 시간 (24시간)
  static const Duration cacheExpiry = Duration(hours: 24);

  // ============================================
  // Batch Processing
  // ============================================

  /// 배치 크기 (한 번에 처리할 장소 수)
  static const int batchSize = 20;

  /// 추가 로드 시 가져올 개수
  static const int loadMoreSize = 20;

  // ============================================
  // Search Configuration
  // ============================================

  /// 기본 추천 개수
  static const int defaultRecommendationCount = 20;

  /// 최대 추천 개수
  static const int maxRecommendationCount = 100;

  // ============================================
  // Helper Methods
  // ============================================

  /// Rate Limit 체크 간격 (밀리초)
  static int get rateLimitCheckIntervalMs =>
      rateLimitWindow.inMilliseconds ~/ maxApiCallsPerMinute;
}
