import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';

/// LRU 캐시 매니저
///
/// 추천 데이터를 로컬에 캐싱하여 성능을 향상시킵니다.
/// - LRU (Least Recently Used) 전략 사용
/// - 최대 캐시 크기 제한 (100MB)
/// - 백그라운드 정리 작업
class RecommendationCacheManager {
  static const String _cacheKeyPrefix = 'recommendation_cache_';
  static const String _metadataKey = 'recommendation_cache_metadata';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheEntries = 50; // 최대 캐시 항목 수
  static const Duration _cacheExpiry = Duration(hours: 24); // 24시간 후 만료

  final SharedPreferences _prefs;
  Timer? _cleanupTimer;

  RecommendationCacheManager(this._prefs) {
    _startBackgroundCleanup();
  }

  /// 백그라운드 정리 작업 시작 (1시간마다)
  void _startBackgroundCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupExpiredCache(),
    );
  }

  /// 캐시 메타데이터 가져오기
  Future<Map<String, dynamic>> _getMetadata() async {
    final metadataJson = _prefs.getString(_metadataKey);
    if (metadataJson == null) return {};

    try {
      return json.decode(metadataJson) as Map<String, dynamic>;
    } catch (e) {
      Logger.error('캐시 메타데이터 파싱 실패', e, null, 'CacheManager');
      return {};
    }
  }

  /// 캐시 메타데이터 저장
  Future<void> _saveMetadata(Map<String, dynamic> metadata) async {
    try {
      await _prefs.setString(_metadataKey, json.encode(metadata));
    } catch (e) {
      Logger.error('캐시 메타데이터 저장 실패', e, null, 'CacheManager');
    }
  }

  /// 캐시 키 생성
  String _generateCacheKey({
    required double latitude,
    required double longitude,
    required Set<String> categories,
    required double maxDistance,
    required double minRating,
  }) {
    final key = '$latitude:$longitude:${categories.join(',')}:'
        '$maxDistance:$minRating';
    return '$_cacheKeyPrefix${key.hashCode}';
  }

  /// 캐시된 추천 가져오기
  Future<List<Place>?> getCachedRecommendations({
    required double latitude,
    required double longitude,
    required Set<String> categories,
    required double maxDistance,
    required double minRating,
  }) async {
    try {
      final cacheKey = _generateCacheKey(
        latitude: latitude,
        longitude: longitude,
        categories: categories,
        maxDistance: maxDistance,
        minRating: minRating,
      );

      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson == null) {
        Logger.debug('캐시 미스: $cacheKey', 'CacheManager');
        return null;
      }

      // 메타데이터 확인
      final metadata = await _getMetadata();
      final cacheInfo = metadata[cacheKey] as Map<String, dynamic>?;

      if (cacheInfo == null) {
        Logger.debug('캐시 메타데이터 없음: $cacheKey', 'CacheManager');
        return null;
      }

      // 만료 확인
      final timestamp = DateTime.parse(cacheInfo['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        Logger.debug('캐시 만료: $cacheKey', 'CacheManager');
        await _removeCache(cacheKey);
        return null;
      }

      // 액세스 시간 업데이트 (LRU)
      cacheInfo['lastAccessed'] = DateTime.now().toIso8601String();
      await _saveMetadata(metadata);

      // 데이터 파싱
      final data = json.decode(cachedJson) as List<dynamic>;
      final places = data.map((item) => Place.fromJson(item)).toList();

      Logger.info('캐시 히트: $cacheKey (${places.length}개)', 'CacheManager');
      return places;
    } catch (e, stackTrace) {
      Logger.error('캐시 읽기 실패', e, stackTrace, 'CacheManager');
      return null;
    }
  }

  /// 추천 캐싱
  Future<void> saveCachedRecommendations({
    required double latitude,
    required double longitude,
    required Set<String> categories,
    required double maxDistance,
    required double minRating,
    required List<Place> recommendations,
  }) async {
    try {
      final cacheKey = _generateCacheKey(
        latitude: latitude,
        longitude: longitude,
        categories: categories,
        maxDistance: maxDistance,
        minRating: minRating,
      );

      // 데이터 직렬화
      final placesJson = recommendations.map((p) => p.toJson()).toList();
      final dataJson = json.encode(placesJson);
      final dataSize = dataJson.length;

      // 캐시 크기 확인 및 정리
      await _ensureCacheSpace(dataSize);

      // 데이터 저장
      await _prefs.setString(cacheKey, dataJson);

      // 메타데이터 업데이트
      final metadata = await _getMetadata();
      final now = DateTime.now().toIso8601String();
      metadata[cacheKey] = {
        'timestamp': now,
        'lastAccessed': now,
        'size': dataSize,
        'count': recommendations.length,
      };
      await _saveMetadata(metadata);

      Logger.info(
        '캐시 저장: $cacheKey (${recommendations.length}개, ${(dataSize / 1024).toStringAsFixed(1)}KB)',
        'CacheManager',
      );
    } catch (e, stackTrace) {
      Logger.error('캐시 저장 실패', e, stackTrace, 'CacheManager');
    }
  }

  /// 캐시 공간 확보 (LRU 전략)
  Future<void> _ensureCacheSpace(int requiredSize) async {
    final metadata = await _getMetadata();

    // 총 캐시 크기 계산
    int totalSize = 0;
    for (final info in metadata.values) {
      if (info is Map<String, dynamic> && info.containsKey('size')) {
        totalSize += info['size'] as int;
      }
    }

    // 크기나 항목 수 초과 시 오래된 캐시 제거
    if (totalSize + requiredSize > _maxCacheSize ||
        metadata.length >= _maxCacheEntries) {

      // 마지막 액세스 시간 기준으로 정렬
      final sortedEntries = metadata.entries.toList()
        ..sort((a, b) {
          final aAccessed = DateTime.parse(
            (a.value as Map<String, dynamic>)['lastAccessed'] as String,
          );
          final bAccessed = DateTime.parse(
            (b.value as Map<String, dynamic>)['lastAccessed'] as String,
          );
          return aAccessed.compareTo(bAccessed); // 오래된 것부터
        });

      // 충분한 공간이 확보될 때까지 제거
      int removedSize = 0;
      int removedCount = 0;

      for (final entry in sortedEntries) {
        if (totalSize - removedSize + requiredSize <= _maxCacheSize * 0.8 &&
            metadata.length - removedCount < _maxCacheEntries * 0.8) {
          break;
        }

        final cacheKey = entry.key;
        final info = entry.value as Map<String, dynamic>;
        removedSize += info['size'] as int;
        removedCount++;

        await _removeCache(cacheKey);
      }

      if (removedCount > 0) {
        Logger.info(
          'LRU 캐시 정리: $removedCount개 항목 제거 (${(removedSize / 1024).toStringAsFixed(1)}KB)',
          'CacheManager',
        );
      }
    }
  }

  /// 만료된 캐시 정리
  Future<void> _cleanupExpiredCache() async {
    try {
      final metadata = await _getMetadata();
      final now = DateTime.now();
      int removedCount = 0;

      final expiredKeys = <String>[];

      for (final entry in metadata.entries) {
        final info = entry.value as Map<String, dynamic>;
        final timestamp = DateTime.parse(info['timestamp'] as String);

        if (now.difference(timestamp) > _cacheExpiry) {
          expiredKeys.add(entry.key);
        }
      }

      for (final key in expiredKeys) {
        await _removeCache(key);
        removedCount++;
      }

      if (removedCount > 0) {
        Logger.info('만료된 캐시 정리: $removedCount개', 'CacheManager');
      }
    } catch (e, stackTrace) {
      Logger.error('캐시 정리 실패', e, stackTrace, 'CacheManager');
    }
  }

  /// 특정 캐시 제거
  Future<void> _removeCache(String cacheKey) async {
    await _prefs.remove(cacheKey);

    final metadata = await _getMetadata();
    metadata.remove(cacheKey);
    await _saveMetadata(metadata);
  }

  /// 모든 캐시 무효화
  Future<void> invalidateCache() async {
    try {
      final metadata = await _getMetadata();

      for (final key in metadata.keys) {
        await _prefs.remove(key);
      }

      await _prefs.remove(_metadataKey);

      Logger.info('모든 캐시 무효화', 'CacheManager');
    } catch (e, stackTrace) {
      Logger.error('캐시 무효화 실패', e, stackTrace, 'CacheManager');
    }
  }

  /// 캐시 통계 가져오기
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final metadata = await _getMetadata();

      int totalSize = 0;
      int totalCount = 0;

      for (final info in metadata.values) {
        if (info is Map<String, dynamic>) {
          totalSize += (info['size'] as int?) ?? 0;
          totalCount += (info['count'] as int?) ?? 0;
        }
      }

      return {
        'entries': metadata.length,
        'totalSize': totalSize,
        'totalSizeKB': (totalSize / 1024).toStringAsFixed(1),
        'totalPlaces': totalCount,
        'maxSizeMB': (_maxCacheSize / (1024 * 1024)).toStringAsFixed(0),
      };
    } catch (e, stackTrace) {
      Logger.error('캐시 통계 가져오기 실패', e, stackTrace, 'CacheManager');
      return {};
    }
  }

  /// 리소스 해제
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
