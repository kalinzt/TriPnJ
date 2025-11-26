import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../exceptions/app_exception.dart';
import '../utils/logger.dart';

/// HTTP API 클라이언트 래퍼
/// GET, POST 요청을 처리하고 에러 핸들링 및 로깅을 수행
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ============================================
  // GET Request
  // ============================================

  /// GET 요청
  ///
  /// [url] - 요청 URL
  /// [headers] - 추가 헤더
  /// [queryParameters] - 쿼리 파라미터
  /// [timeout] - 타임아웃 (기본값: 30초)
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    try {
      // 쿼리 파라미터 추가
      final uri = _buildUri(url, queryParameters);

      // 요청 로깅
      Logger.httpRequest(
        'GET',
        uri.toString(),
        headers: headers,
      );

      // 시작 시간 기록
      final stopwatch = Logger.startPerformanceMeasure('GET $url');

      // GET 요청 실행
      final response = await _client
          .get(
            uri,
            headers: headers ?? ApiConstants.commonHeaders,
          )
          .timeout(
            timeout ?? ApiConstants.connectionTimeout,
            onTimeout: () => throw NetworkException.timeout(),
          );

      // 성능 측정 종료
      Logger.endPerformanceMeasure('GET $url', stopwatch);

      // 응답 로깅
      Logger.httpResponse(
        'GET',
        uri.toString(),
        response.statusCode,
        response.body,
      );

      // 응답 처리
      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error('Network error on GET $url', e, null, 'ApiService');
      throw NetworkException.noInternet();
    } on HttpException catch (e) {
      Logger.error('HTTP error on GET $url', e, null, 'ApiService');
      throw NetworkException.connectionFailed(e);
    } on FormatException catch (e) {
      Logger.error('Invalid response format on GET $url', e, null, 'ApiService');
      throw ApiException.invalidResponse(e.message);
    } catch (e) {
      Logger.error('Unknown error on GET $url', e, null, 'ApiService');
      rethrow;
    }
  }

  // ============================================
  // POST Request
  // ============================================

  /// POST 요청
  ///
  /// [url] - 요청 URL
  /// [body] - 요청 바디
  /// [headers] - 추가 헤더
  /// [queryParameters] - 쿼리 파라미터
  /// [timeout] - 타임아웃 (기본값: 30초)
  Future<Map<String, dynamic>> post({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    try {
      // 쿼리 파라미터 추가
      final uri = _buildUri(url, queryParameters);

      // 요청 로깅
      Logger.httpRequest(
        'POST',
        uri.toString(),
        headers: headers,
        body: body,
      );

      // 시작 시간 기록
      final stopwatch = Logger.startPerformanceMeasure('POST $url');

      // POST 요청 실행
      final response = await _client
          .post(
            uri,
            headers: headers ?? ApiConstants.commonHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeout ?? ApiConstants.connectionTimeout,
            onTimeout: () => throw NetworkException.timeout(),
          );

      // 성능 측정 종료
      Logger.endPerformanceMeasure('POST $url', stopwatch);

      // 응답 로깅
      Logger.httpResponse(
        'POST',
        uri.toString(),
        response.statusCode,
        response.body,
      );

      // 응답 처리
      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error('Network error on POST $url', e, null, 'ApiService');
      throw NetworkException.noInternet();
    } on HttpException catch (e) {
      Logger.error('HTTP error on POST $url', e, null, 'ApiService');
      throw NetworkException.connectionFailed(e);
    } on FormatException catch (e) {
      Logger.error('Invalid response format on POST $url', e, null, 'ApiService');
      throw ApiException.invalidResponse(e.message);
    } catch (e) {
      Logger.error('Unknown error on POST $url', e, null, 'ApiService');
      rethrow;
    }
  }

  // ============================================
  // PUT Request
  // ============================================

  /// PUT 요청
  Future<Map<String, dynamic>> put({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(url, queryParameters);

      Logger.httpRequest('PUT', uri.toString(), headers: headers, body: body);

      final stopwatch = Logger.startPerformanceMeasure('PUT $url');

      final response = await _client
          .put(
            uri,
            headers: headers ?? ApiConstants.commonHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeout ?? ApiConstants.connectionTimeout,
            onTimeout: () => throw NetworkException.timeout(),
          );

      Logger.endPerformanceMeasure('PUT $url', stopwatch);
      Logger.httpResponse('PUT', uri.toString(), response.statusCode, response.body);

      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error('Network error on PUT $url', e, null, 'ApiService');
      throw NetworkException.noInternet();
    } catch (e) {
      Logger.error('Unknown error on PUT $url', e, null, 'ApiService');
      rethrow;
    }
  }

  // ============================================
  // DELETE Request
  // ============================================

  /// DELETE 요청
  Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(url, queryParameters);

      Logger.httpRequest('DELETE', uri.toString(), headers: headers);

      final stopwatch = Logger.startPerformanceMeasure('DELETE $url');

      final response = await _client
          .delete(
            uri,
            headers: headers ?? ApiConstants.commonHeaders,
          )
          .timeout(
            timeout ?? ApiConstants.connectionTimeout,
            onTimeout: () => throw NetworkException.timeout(),
          );

      Logger.endPerformanceMeasure('DELETE $url', stopwatch);
      Logger.httpResponse('DELETE', uri.toString(), response.statusCode, response.body);

      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error('Network error on DELETE $url', e, null, 'ApiService');
      throw NetworkException.noInternet();
    } catch (e) {
      Logger.error('Unknown error on DELETE $url', e, null, 'ApiService');
      rethrow;
    }
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// URI 빌더 - 쿼리 파라미터 추가
  Uri _buildUri(String url, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      // null 값 제거 및 문자열 변환
      final validParams = queryParameters.entries
          .where((entry) => entry.value != null)
          .map((entry) => MapEntry(entry.key, entry.value.toString()));

      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...Map.fromEntries(validParams),
        },
      );
    }

    return uri;
  }

  /// HTTP 응답 처리
  Map<String, dynamic> _handleResponse(http.Response response) {
    // 상태 코드에 따른 처리
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 성공 (2xx)
      return _parseJson(response.body);
    } else if (response.statusCode == 400) {
      throw ApiException.badRequest(_getErrorMessage(response));
    } else if (response.statusCode == 401) {
      throw ApiException.unauthorized(_getErrorMessage(response));
    } else if (response.statusCode == 403) {
      throw ApiException.forbidden(_getErrorMessage(response));
    } else if (response.statusCode == 404) {
      throw ApiException.notFound(_getErrorMessage(response));
    } else if (response.statusCode == 429) {
      throw ApiException.tooManyRequests(_getErrorMessage(response));
    } else if (response.statusCode >= 500) {
      throw ApiException.serverError(
        response.statusCode,
        _getErrorMessage(response),
      );
    } else {
      throw ApiException(
        message: 'HTTP ${response.statusCode}: ${_getErrorMessage(response)}',
        statusCode: response.statusCode,
      );
    }
  }

  /// JSON 파싱
  Map<String, dynamic> _parseJson(String body) {
    try {
      if (body.isEmpty) {
        return {};
      }

      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      } else {
        throw const FormatException('Invalid JSON format');
      }
    } on FormatException catch (e) {
      Logger.error('JSON parse error', e, null, 'ApiService');
      throw ApiException.invalidResponse('Failed to parse response: ${e.message}');
    }
  }

  /// 에러 메시지 추출
  String _getErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);

      // 다양한 에러 메시지 포맷 지원
      if (json is Map<String, dynamic>) {
        return json['error_message'] ??
            json['error'] ??
            json['message'] ??
            json['detail'] ??
            response.reasonPhrase ??
            'Unknown error';
      }

      return response.reasonPhrase ?? 'Unknown error';
    } catch (e) {
      return response.reasonPhrase ?? 'Unknown error';
    }
  }

  // ============================================
  // Retry Logic
  // ============================================

  /// 재시도 로직 포함 GET 요청
  Future<Map<String, dynamic>> getWithRetry({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await get(
          url: url,
          headers: headers,
          queryParameters: queryParameters,
        );
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        Logger.warning(
          'Request failed (attempt $attempt/$maxRetries), retrying...',
          'ApiService',
        );

        await Future.delayed(retryDelay);
      }
    }

    throw NetworkException.serverError('Max retries exceeded');
  }

  // ============================================
  // Cleanup
  // ============================================

  /// 클라이언트 종료
  void dispose() {
    _client.close();
  }
}
