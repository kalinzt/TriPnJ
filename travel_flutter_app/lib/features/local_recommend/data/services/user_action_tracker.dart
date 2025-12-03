import '../../../../core/utils/recommendation_logger.dart';
import 'recommendation_analytics.dart';

/// 사용자 액션 추적 서비스
/// 사용자가 추천에 대해 수행하는 액션을 로깅하고 분석합니다.
class UserActionTracker {
  static final UserActionTracker _instance = UserActionTracker._internal();
  factory UserActionTracker() => _instance;
  UserActionTracker._internal();

  final _logger = RecommendationLogger();
  final _analytics = RecommendationAnalytics();

  /// 장소 방문 액션 기록
  Future<void> trackVisit({
    required String placeId,
    String? placeName,
    double? score,
  }) async {
    await _trackAction(
      actionType: 'visit',
      placeId: placeId,
      placeName: placeName,
      score: score,
    );
  }

  /// 좋아요 액션 기록
  Future<void> trackLike({
    required String placeId,
    String? placeName,
    double? score,
  }) async {
    await _trackAction(
      actionType: 'like',
      placeId: placeId,
      placeName: placeName,
      score: score,
    );
  }

  /// 싫어요/거절 액션 기록
  Future<void> trackReject({
    required String placeId,
    String? placeName,
    double? score,
  }) async {
    await _trackAction(
      actionType: 'reject',
      placeId: placeId,
      placeName: placeName,
      score: score,
    );
  }

  /// 일정에 추가 액션 기록
  Future<void> trackAddToPlan({
    required String placeId,
    String? placeName,
    double? score,
  }) async {
    await _trackAction(
      actionType: 'add_to_plan',
      placeId: placeId,
      placeName: placeName,
      score: score,
    );
  }

  /// 즐겨찾기 추가 액션 기록
  Future<void> trackAddToFavorite({
    required String placeId,
    String? placeName,
    double? score,
  }) async {
    await _trackAction(
      actionType: 'add_to_favorite',
      placeId: placeId,
      placeName: placeName,
      score: score,
    );
  }

  /// 공유 액션 기록
  Future<void> trackShare({
    required String placeId,
    String? placeName,
  }) async {
    await _trackAction(
      actionType: 'share',
      placeId: placeId,
      placeName: placeName,
    );
  }

  /// 상세 정보 조회 액션 기록
  Future<void> trackViewDetail({
    required String placeId,
    String? placeName,
  }) async {
    await _trackAction(
      actionType: 'view_detail',
      placeId: placeId,
      placeName: placeName,
    );
  }

  /// 공통 액션 추적 로직
  Future<void> _trackAction({
    required String actionType,
    required String placeId,
    String? placeName,
    double? score,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      // 로그 기록
      _logger.logUserAction(
        actionType: actionType,
        placeId: placeId,
        placeName: placeName,
        score: score,
        context: additionalContext,
      );

      // 분석 메트릭 기록
      await _analytics.recordUserAction(
        actionType: actionType,
      );
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'UserActionTracker._trackAction',
        additionalInfo: {
          'action_type': actionType,
          'place_id': placeId,
        },
      );
    }
  }

  /// 추천 피드백 기록 (좋아요/싫어요 비율 등)
  Future<void> trackRecommendationFeedback({
    required String recommendationId,
    required bool isPositive,
    String? feedbackReason,
  }) async {
    try {
      _logger.info('추천 피드백 기록', data: {
        'recommendation_id': recommendationId,
        'is_positive': isPositive,
        if (feedbackReason != null) 'reason': feedbackReason,
      });

      await _analytics.recordUserAction(
        actionType: isPositive ? 'positive_feedback' : 'negative_feedback',
      );
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'UserActionTracker.trackRecommendationFeedback',
      );
    }
  }

  /// 검색 액션 기록
  Future<void> trackSearch({
    required String query,
    int? resultCount,
  }) async {
    try {
      _logger.info('검색 액션 기록', data: {
        'query_length': query.length,
        if (resultCount != null) 'result_count': resultCount,
      });

      await _analytics.recordUserAction(
        actionType: 'search',
      );
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'UserActionTracker.trackSearch',
      );
    }
  }

  /// 필터 적용 액션 기록
  Future<void> trackFilterApplied({
    required int filterCount,
    required List<String> filterTypes,
  }) async {
    try {
      _logger.info('필터 적용 액션 기록', data: {
        'filter_count': filterCount,
        'filter_types': filterTypes,
      });

      await _analytics.recordUserAction(
        actionType: 'apply_filter',
      );
    } catch (e, stack) {
      _logger.logError(
        error: e,
        stackTrace: stack,
        context: 'UserActionTracker.trackFilterApplied',
      );
    }
  }
}
