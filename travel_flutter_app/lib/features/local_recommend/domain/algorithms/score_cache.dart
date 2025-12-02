import '../../../../shared/models/place.dart';

/// 추천 점수 메모이제이션 캐시
///
/// 같은 장소와 파라미터에 대한 점수 계산 결과를 캐싱하여 성능 향상
class ScoreCache {
  final Map<String, double> _cache = {};
  static const int _maxCacheSize = 1000;

  /// 캐시 키 생성
  String _generateKey({
    required String placeId,
    required double userLatitude,
    required double userLongitude,
    required String preferencesHash,
  }) {
    return '$placeId:$userLatitude:$userLongitude:$preferencesHash';
  }

  /// 캐시된 점수 가져오기
  double? getScore({
    required String placeId,
    required double userLatitude,
    required double userLongitude,
    required String preferencesHash,
  }) {
    final key = _generateKey(
      placeId: placeId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      preferencesHash: preferencesHash,
    );
    return _cache[key];
  }

  /// 점수 캐싱
  void putScore({
    required String placeId,
    required double userLatitude,
    required double userLongitude,
    required String preferencesHash,
    required double score,
  }) {
    // 캐시 크기 제한
    if (_cache.length >= _maxCacheSize) {
      // 오래된 항목 절반 제거 (간단한 LRU 전략)
      final keysToRemove = _cache.keys.take(_maxCacheSize ~/ 2).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }

    final key = _generateKey(
      placeId: placeId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      preferencesHash: preferencesHash,
    );
    _cache[key] = score;
  }

  /// 캐시 초기화
  void clear() {
    _cache.clear();
  }

  /// 캐시 크기
  int get size => _cache.length;
}
