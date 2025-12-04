/// 앱 전역 예외 클래스
/// 모든 커스텀 예외의 베이스 클래스
library;

// ============================================
// Base Exception
// ============================================

/// 앱 베이스 예외
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }

  /// 사용자에게 표시할 메시지
  String get userMessage => message;
}

// ============================================
// Network Exceptions
// ============================================

/// 네트워크 관련 예외
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'NO_INTERNET':
        return '인터넷 연결을 확인해주세요.';
      case 'TIMEOUT':
        return '서버 응답 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
      case 'SERVER_ERROR':
        return '서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      case 'CONNECTION_FAILED':
        return '서버에 연결할 수 없습니다.\n인터넷 연결을 확인해주세요.';
      default:
        return message;
    }
  }

  /// 인터넷 연결 없음
  factory NetworkException.noInternet() {
    return const NetworkException(
      message: 'No internet connection',
      code: 'NO_INTERNET',
    );
  }

  /// 타임아웃
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Connection timeout',
      code: 'TIMEOUT',
    );
  }

  /// 서버 오류
  factory NetworkException.serverError([String? details]) {
    return NetworkException(
      message: details ?? 'Server error occurred',
      code: 'SERVER_ERROR',
    );
  }

  /// 연결 실패
  factory NetworkException.connectionFailed([dynamic error]) {
    return NetworkException(
      message: 'Failed to connect to server',
      code: 'CONNECTION_FAILED',
      originalError: error,
    );
  }
}

// ============================================
// API Exceptions
// ============================================

/// API 호출 관련 예외
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String get userMessage {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return '잘못된 요청입니다.';
        case 401:
          return '인증이 필요합니다.\nAPI 키를 확인해주세요.';
        case 403:
          return '접근 권한이 없습니다.';
        case 404:
          return '요청한 정보를 찾을 수 없습니다.';
        case 429:
          return 'API 요청 한도를 초과했습니다.\n잠시 후 다시 시도해주세요.';
        case 500:
        case 502:
        case 503:
        case 504:
          return '서버에 일시적인 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';
        default:
          return message;
      }
    }
    return message;
  }

  /// 잘못된 요청
  factory ApiException.badRequest([String? details]) {
    return ApiException(
      message: details ?? 'Bad request',
      code: 'BAD_REQUEST',
      statusCode: 400,
    );
  }

  /// 인증 실패
  factory ApiException.unauthorized([String? details]) {
    return ApiException(
      message: details ?? 'Unauthorized',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  /// 권한 없음
  factory ApiException.forbidden([String? details]) {
    return ApiException(
      message: details ?? 'Forbidden',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  /// 찾을 수 없음
  factory ApiException.notFound([String? details]) {
    return ApiException(
      message: details ?? 'Not found',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  /// API 요청 한도 초과
  factory ApiException.tooManyRequests([String? details]) {
    return ApiException(
      message: details ?? 'Too many requests',
      code: 'TOO_MANY_REQUESTS',
      statusCode: 429,
    );
  }

  /// 서버 오류
  factory ApiException.serverError([int? statusCode, String? details]) {
    return ApiException(
      message: details ?? 'Server error',
      code: 'SERVER_ERROR',
      statusCode: statusCode ?? 500,
    );
  }

  /// API 키 누락
  factory ApiException.missingApiKey(String apiName) {
    return ApiException(
      message: '$apiName API key is missing',
      code: 'MISSING_API_KEY',
    );
  }

  /// 잘못된 응답
  factory ApiException.invalidResponse([String? details]) {
    return ApiException(
      message: details ?? 'Invalid response format',
      code: 'INVALID_RESPONSE',
    );
  }
}

// ============================================
// Location Exceptions
// ============================================

/// 위치 서비스 관련 예외
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'SERVICE_DISABLED':
        return '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.';
      case 'PERMISSION_DENIED':
        return '위치 권한이 거부되었습니다.\n앱 설정에서 위치 권한을 허용해주세요.';
      case 'PERMISSION_DENIED_FOREVER':
        return '위치 권한이 영구적으로 거부되었습니다.\n설정 > 앱 > 여행 플래너에서 위치 권한을 허용해주세요.';
      case 'LOCATION_NOT_AVAILABLE':
        return '현재 위치를 가져올 수 없습니다.\n잠시 후 다시 시도해주세요.';
      case 'LOCATION_TIMEOUT':
        return '위치 정보를 가져오는데 시간이 초과되었습니다.\n다시 시도해주세요.';
      default:
        return message;
    }
  }

  /// 위치 서비스 비활성화
  factory LocationException.serviceDisabled() {
    return const LocationException(
      message: 'Location services are disabled',
      code: 'SERVICE_DISABLED',
    );
  }

  /// 위치 권한 거부
  factory LocationException.permissionDenied() {
    return const LocationException(
      message: 'Location permission denied',
      code: 'PERMISSION_DENIED',
    );
  }

  /// 위치 권한 영구 거부
  factory LocationException.permissionDeniedForever() {
    return const LocationException(
      message: 'Location permission permanently denied',
      code: 'PERMISSION_DENIED_FOREVER',
    );
  }

  /// 위치 정보 없음
  factory LocationException.notAvailable() {
    return const LocationException(
      message: 'Location not available',
      code: 'LOCATION_NOT_AVAILABLE',
    );
  }

  /// 위치 가져오기 타임아웃
  factory LocationException.timeout() {
    return const LocationException(
      message: 'Location request timeout',
      code: 'LOCATION_TIMEOUT',
    );
  }
}

// ============================================
// Data Exceptions
// ============================================

/// 데이터 관련 예외
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'PARSE_ERROR':
        return '데이터를 처리하는 중 오류가 발생했습니다.';
      case 'NOT_FOUND':
        return '요청한 데이터를 찾을 수 없습니다.';
      case 'CACHE_ERROR':
        return '캐시된 데이터를 불러오는데 실패했습니다.';
      case 'STORAGE_ERROR':
        return '데이터 저장에 실패했습니다.';
      default:
        return message;
    }
  }

  /// 파싱 오류
  factory DataException.parseError([dynamic error]) {
    return DataException(
      message: 'Failed to parse data',
      code: 'PARSE_ERROR',
      originalError: error,
    );
  }

  /// 데이터 없음
  factory DataException.notFound([String? details]) {
    return DataException(
      message: details ?? 'Data not found',
      code: 'NOT_FOUND',
    );
  }

  /// 캐시 오류
  factory DataException.cacheError([dynamic error]) {
    return DataException(
      message: 'Cache error occurred',
      code: 'CACHE_ERROR',
      originalError: error,
    );
  }

  /// 저장소 오류
  factory DataException.storageError([dynamic error]) {
    return DataException(
      message: 'Storage error occurred',
      code: 'STORAGE_ERROR',
      originalError: error,
    );
  }
}

// ============================================
// Validation Exceptions
// ============================================

/// 유효성 검증 예외
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  String get userMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return fieldErrors!.values.first;
    }
    return message;
  }

  /// 필수 필드 누락
  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      message: '$fieldName is required',
      code: 'REQUIRED_FIELD',
      fieldErrors: {fieldName: '$fieldName을(를) 입력해주세요.'},
    );
  }

  /// 잘못된 형식
  factory ValidationException.invalidFormat(String fieldName) {
    return ValidationException(
      message: 'Invalid $fieldName format',
      code: 'INVALID_FORMAT',
      fieldErrors: {fieldName: '올바른 형식으로 입력해주세요.'},
    );
  }

  /// 범위 초과
  factory ValidationException.outOfRange(String fieldName, {String? details}) {
    return ValidationException(
      message: '$fieldName is out of range',
      code: 'OUT_OF_RANGE',
      fieldErrors: {fieldName: details ?? '올바른 범위의 값을 입력해주세요.'},
    );
  }
}

// ============================================
// Unknown Exception
// ============================================

/// 알 수 없는 예외
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.originalError,
  }) : super(code: 'UNKNOWN');

  @override
  String get userMessage => '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';

  factory UnknownException.fromError(dynamic error) {
    return UnknownException(
      message: error.toString(),
      originalError: error,
    );
  }
}
