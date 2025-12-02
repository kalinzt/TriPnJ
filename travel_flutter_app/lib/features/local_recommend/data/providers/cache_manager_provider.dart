import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cache_manager.dart';

/// CacheManager Provider
final cacheManagerProvider = Provider<RecommendationCacheManager>((ref) {
  throw UnimplementedError('CacheManager must be overridden');
});

/// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
