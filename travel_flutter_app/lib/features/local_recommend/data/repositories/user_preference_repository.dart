import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../models/user_preference.dart';
import '../models/preference_action.dart';

/// 사용자 선호도 저장소
///
/// Hive를 사용하여 사용자의 장소 선호도와 방문 이력을 관리합니다.
class UserPreferenceRepository {
  static const String _boxName = 'user_preferences';
  static const String _preferenceKey = 'current_user_preference';

  Box<String>? _box;

  /// Hive box 초기화
  Future<void> initialize() async {
    try {
      Logger.info('사용자 선호도 저장소 초기화 중...', 'UserPreferenceRepository');

      _box = await Hive.openBox<String>(_boxName);
      Logger.info('사용자 선호도 저장소 초기화 완료', 'UserPreferenceRepository');
    } catch (e, stackTrace) {
      Logger.error('사용자 선호도 저장소 초기화 실패', e, stackTrace, 'UserPreferenceRepository');
      rethrow;
    }
  }

  /// Box 가져오기
  Box<String> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('UserPreferenceRepository가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _box!;
  }

  // ============================================
  // UserPreference 인코딩/디코딩
  // ============================================

  /// UserPreference를 JSON으로 인코딩
  String _encodeUserPreference(UserPreference preference) {
    return jsonEncode(preference.toJson());
  }

  /// JSON을 UserPreference로 디코딩
  UserPreference _decodeUserPreference(String jsonString) {
    return UserPreference.fromJson(jsonDecode(jsonString));
  }

  // ============================================
  // READ
  // ============================================

  /// 현재 사용자 선호도 가져오기
  ///
  /// 선호도가 없으면 기본값 생성
  UserPreference getUserPreference() {
    try {
      final jsonString = box.get(_preferenceKey);

      if (jsonString == null) {
        Logger.info('선호도 없음, 기본값 생성', 'UserPreferenceRepository');
        final initialPreference = UserPreference.initial();
        _saveUserPreference(initialPreference);
        return initialPreference;
      }

      return _decodeUserPreference(jsonString);
    } catch (e, stackTrace) {
      Logger.error('선호도 조회 실패, 기본값 반환', e, stackTrace, 'UserPreferenceRepository');
      return UserPreference.initial();
    }
  }

  /// 선호도 저장 (내부용)
  void _saveUserPreference(UserPreference preference) {
    try {
      final jsonString = _encodeUserPreference(preference);
      box.put(_preferenceKey, jsonString);
    } catch (e, stackTrace) {
      Logger.error('선호도 저장 실패', e, stackTrace, 'UserPreferenceRepository');
    }
  }

  // ============================================
  // UPDATE - 행동 기반 선호도 업데이트
  // ============================================

  /// 사용자 행동에 따라 선호도 업데이트
  ///
  /// [place] - 대상 장소
  /// [action] - 사용자 행동
  Future<UserPreference> updatePreferenceFromAction({
    required Place place,
    required PreferenceAction action,
  }) async {
    try {
      Logger.info(
        '선호도 업데이트: ${place.name} - ${action.description}',
        'UserPreferenceRepository',
      );

      final preference = getUserPreference();
      final category = getCategoryFromPlaceTypes(place.types);

      // 1. 카테고리 가중치 업데이트
      final updatedWeights = Map<String, double>.from(preference.categoryWeights);
      final currentWeight = updatedWeights[category.name] ?? 0.5;
      final newWeight = (currentWeight + action.weightDelta).clamp(0.0, 1.0);
      updatedWeights[category.name] = newWeight;

      // 2. 방문 이력 업데이트
      final updatedVisited = List<String>.from(preference.visitedPlaceIds);
      if (action.shouldAddToVisited && !updatedVisited.contains(place.id)) {
        updatedVisited.add(place.id);
      }

      // 3. 거절 이력 업데이트
      final updatedRejected = List<String>.from(preference.rejectedPlaceIds);
      if (action.shouldAddToRejected && !updatedRejected.contains(place.id)) {
        updatedRejected.add(place.id);
      }

      // 4. 카테고리 방문 횟수 업데이트
      final updatedVisitCount = Map<String, int>.from(preference.categoryVisitCount);
      if (action.isPositive) {
        updatedVisitCount[category.name] = (updatedVisitCount[category.name] ?? 0) + 1;
      }

      // 5. 평균 평점 선호도 업데이트 (이동평균)
      final placeRating = place.rating ?? 4.0;
      final totalVisits = updatedVisitCount.values.fold(0, (sum, count) => sum + count);
      final newAvgRating = totalVisits > 0
          ? ((preference.averageRatingPreference * (totalVisits - 1)) + placeRating) / totalVisits
          : placeRating;

      // 6. 업데이트된 선호도 생성
      final updatedPreference = preference.copyWith(
        categoryWeights: updatedWeights,
        visitedPlaceIds: updatedVisited,
        rejectedPlaceIds: updatedRejected,
        categoryVisitCount: updatedVisitCount,
        averageRatingPreference: newAvgRating,
        lastUpdated: DateTime.now(),
      );

      _saveUserPreference(updatedPreference);

      Logger.info(
        '선호도 업데이트 완료: ${category.name} 가중치 $currentWeight → $newWeight',
        'UserPreferenceRepository',
      );

      return updatedPreference;
    } catch (e, stackTrace) {
      Logger.error('선호도 업데이트 실패', e, stackTrace, 'UserPreferenceRepository');
      return getUserPreference(); // 실패 시 현재 선호도 반환
    }
  }

  // ============================================
  // UPDATE - 가중치 계산
  // ============================================

  /// 카테고리 방문 횟수를 정규화하여 가중치 계산
  ///
  /// [categoryVisitCount] - 카테고리별 방문 횟수
  ///
  /// Returns 정규화된 카테고리 가중치 (합계 1.0)
  Map<String, double> calculateCategoryWeights({
    required Map<String, int> categoryVisitCount,
  }) {
    try {
      final totalVisits = categoryVisitCount.values.fold(0, (sum, count) => sum + count);

      if (totalVisits == 0) {
        // 방문 이력이 없으면 균등 분배
        return {
          for (final category in PlaceCategory.values)
            if (category != PlaceCategory.all) category.name: 0.5,
        };
      }

      // 방문 비율 계산
      final weights = <String, double>{};
      for (final entry in categoryVisitCount.entries) {
        weights[entry.key] = entry.value / totalVisits;
      }

      // 방문하지 않은 카테고리는 작은 가중치 부여
      for (final category in PlaceCategory.values) {
        if (category != PlaceCategory.all && !weights.containsKey(category.name)) {
          weights[category.name] = 0.05;
        }
      }

      // 재정규화 (합계 1.0)
      final sum = weights.values.fold(0.0, (a, b) => a + b);
      final normalized = <String, double>{};
      for (final entry in weights.entries) {
        normalized[entry.key] = entry.value / sum;
      }

      return normalized;
    } catch (e, stackTrace) {
      Logger.error('가중치 계산 실패', e, stackTrace, 'UserPreferenceRepository');
      return {};
    }
  }

  /// 여행 계획 데이터를 기반으로 선호도 동기화
  ///
  /// 사용자의 과거 여행 계획을 분석하여 선호도 업데이트
  Future<UserPreference> syncPreferenceFromTripHistory({
    required List<Place> visitedPlaces,
  }) async {
    try {
      Logger.info('여행 이력에서 선호도 동기화: ${visitedPlaces.length}개 장소', 'UserPreferenceRepository');

      final preference = getUserPreference();
      final categoryCount = Map<String, int>.from(preference.categoryVisitCount);
      final visitedIds = Set<String>.from(preference.visitedPlaceIds);

      // 각 장소의 카테고리별 방문 횟수 집계
      for (final place in visitedPlaces) {
        visitedIds.add(place.id);
        final category = getCategoryFromPlaceTypes(place.types);
        categoryCount[category.name] = (categoryCount[category.name] ?? 0) + 1;
      }

      // 가중치 재계산
      final newWeights = calculateCategoryWeights(categoryVisitCount: categoryCount);

      // 평균 평점 계산
      final ratingsSum = visitedPlaces
          .where((p) => p.rating != null)
          .fold(0.0, (sum, p) => sum + p.rating!);
      final ratingsCount = visitedPlaces.where((p) => p.rating != null).length;
      final avgRating = ratingsCount > 0 ? ratingsSum / ratingsCount : 4.0;

      final updatedPreference = preference.copyWith(
        categoryWeights: newWeights,
        categoryVisitCount: categoryCount,
        visitedPlaceIds: visitedIds.toList(),
        averageRatingPreference: avgRating,
        lastUpdated: DateTime.now(),
      );

      _saveUserPreference(updatedPreference);

      Logger.info('선호도 동기화 완료', 'UserPreferenceRepository');

      return updatedPreference;
    } catch (e, stackTrace) {
      Logger.error('선호도 동기화 실패', e, stackTrace, 'UserPreferenceRepository');
      return getUserPreference();
    }
  }

  // ============================================
  // 방문/거절 이력 조회
  // ============================================

  /// 방문한 장소 ID 목록 반환
  List<String> getVisitedPlaces() {
    try {
      final preference = getUserPreference();
      return preference.visitedPlaceIds;
    } catch (e, stackTrace) {
      Logger.error('방문 이력 조회 실패', e, stackTrace, 'UserPreferenceRepository');
      return [];
    }
  }

  /// 거절한 장소 ID 목록 반환
  List<String> getRejectedPlaces() {
    try {
      final preference = getUserPreference();
      return preference.rejectedPlaceIds;
    } catch (e, stackTrace) {
      Logger.error('거절 이력 조회 실패', e, stackTrace, 'UserPreferenceRepository');
      return [];
    }
  }

  /// 특정 장소를 방문했는지 확인
  bool hasVisited(String placeId) {
    return getVisitedPlaces().contains(placeId);
  }

  /// 특정 장소를 거절했는지 확인
  bool hasRejected(String placeId) {
    return getRejectedPlaces().contains(placeId);
  }

  // ============================================
  // DELETE - GDPR 준수
  // ============================================

  /// 모든 사용자 데이터 삭제 (GDPR 준수)
  Future<void> clearAllData() async {
    try {
      Logger.warning('모든 선호도 데이터 삭제', 'UserPreferenceRepository');

      await box.clear();
      Logger.info('모든 선호도 데이터 삭제 완료', 'UserPreferenceRepository');
    } catch (e, stackTrace) {
      Logger.error('선호도 데이터 삭제 실패', e, stackTrace, 'UserPreferenceRepository');
      rethrow;
    }
  }

  /// 선호도 초기화 (기본값으로 재설정)
  Future<UserPreference> resetPreference() async {
    try {
      Logger.info('선호도 초기화', 'UserPreferenceRepository');

      final initialPreference = UserPreference.initial();
      _saveUserPreference(initialPreference);

      Logger.info('선호도 초기화 완료', 'UserPreferenceRepository');
      return initialPreference;
    } catch (e, stackTrace) {
      Logger.error('선호도 초기화 실패', e, stackTrace, 'UserPreferenceRepository');
      rethrow;
    }
  }

  // ============================================
  // UTILITIES
  // ============================================

  /// 선호도 존재 여부 확인
  bool hasPreference() {
    return box.containsKey(_preferenceKey);
  }

  /// 저장소 닫기
  Future<void> close() async {
    await _box?.close();
    _box = null;
    Logger.info('사용자 선호도 저장소 닫힘', 'UserPreferenceRepository');
  }
}
