import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/data/providers/places_provider.dart';
import '../../domain/algorithms/recommendation_algorithm.dart';
import '../../domain/config/recommendation_config.dart';
import '../services/api_rate_limiter.dart';
import '../services/place_analysis_service.dart';
import 'user_preference_provider.dart';

/// RecommendationConfig Provider
final recommendationConfigProvider = Provider<RecommendationConfig>((ref) {
  return RecommendationConfig();
});

/// RecommendationAlgorithm Provider
final recommendationAlgorithmProvider = Provider<RecommendationAlgorithm>((ref) {
  final config = ref.watch(recommendationConfigProvider);
  return RecommendationAlgorithm(config: config);
});

/// ApiRateLimiter Provider
final apiRateLimiterProvider = Provider<ApiRateLimiter>((ref) {
  return ApiRateLimiter();
});

/// PlaceAnalysisService Provider
final placeAnalysisServiceProvider = Provider<PlaceAnalysisService>((ref) {
  final placesRepository = ref.watch(placesRepositoryProvider);
  final userPreferenceRepository = ref.watch(userPreferenceRepositoryProvider);
  final recommendationAlgorithm = ref.watch(recommendationAlgorithmProvider);
  final rateLimiter = ref.watch(apiRateLimiterProvider);

  final service = PlaceAnalysisService(
    placesRepository: placesRepository,
    userPreferenceRepository: userPreferenceRepository,
    recommendationAlgorithm: recommendationAlgorithm,
    rateLimiter: rateLimiter,
  );

  // 자동 초기화
  service.initialize().catchError((error) {
    // 초기화 실패 시 로그만 출력
    return null;
  });

  return service;
});
