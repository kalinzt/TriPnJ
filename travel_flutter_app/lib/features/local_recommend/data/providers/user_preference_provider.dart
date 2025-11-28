import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preference.dart';
import '../repositories/user_preference_repository.dart';

/// UserPreferenceRepository Provider
///
/// 싱글톤으로 관리되는 저장소 인스턴스
final userPreferenceRepositoryProvider = Provider<UserPreferenceRepository>((ref) {
  final repository = UserPreferenceRepository();

  // 앱 시작 시 자동 초기화
  repository.initialize().catchError((error) {
    // 초기화 실패 시 로그만 출력하고 계속 진행
    return null;
  });

  return repository;
});

/// 현재 사용자 선호도 Provider
///
/// UserPreference를 실시간으로 관찰
final userPreferenceProvider = StateNotifierProvider<UserPreferenceNotifier, UserPreference>((ref) {
  final repository = ref.watch(userPreferenceRepositoryProvider);
  return UserPreferenceNotifier(repository);
});

/// UserPreference StateNotifier
///
/// 사용자 선호도 상태를 관리하고 업데이트를 처리합니다.
class UserPreferenceNotifier extends StateNotifier<UserPreference> {
  final UserPreferenceRepository _repository;

  UserPreferenceNotifier(this._repository) : super(UserPreference.initial()) {
    _loadPreference();
  }

  /// 저장소에서 선호도 로드
  void _loadPreference() {
    try {
      state = _repository.getUserPreference();
    } catch (e) {
      // 로드 실패 시 기본값 유지
      state = UserPreference.initial();
    }
  }

  /// 선호도 새로고침
  void refresh() {
    _loadPreference();
  }

  /// 저장소에서 직접 업데이트 (Repository 메서드 사용 후 상태 동기화)
  void syncWithRepository() {
    _loadPreference();
  }

  /// 선호도 초기화
  Future<void> reset() async {
    try {
      final newPreference = await _repository.resetPreference();
      state = newPreference;
    } catch (e) {
      // 실패 시 기본값으로 설정
      state = UserPreference.initial();
    }
  }

  /// 모든 데이터 삭제 후 초기화
  Future<void> clearAll() async {
    try {
      await _repository.clearAllData();
      state = UserPreference.initial();
    } catch (e) {
      // 실패 시 기본값으로 설정
      state = UserPreference.initial();
    }
  }
}

/// 카테고리별 선호도 가중치 Provider
///
/// Map<PlaceCategory, double> 형태로 반환
final categoryWeightsProvider = Provider<Map<String, double>>((ref) {
  final preference = ref.watch(userPreferenceProvider);
  return preference.categoryWeights;
});

/// 방문한 장소 목록 Provider
final visitedPlacesProvider = Provider<List<String>>((ref) {
  final preference = ref.watch(userPreferenceProvider);
  return preference.visitedPlaceIds;
});

/// 거절한 장소 목록 Provider
final rejectedPlacesProvider = Provider<List<String>>((ref) {
  final preference = ref.watch(userPreferenceProvider);
  return preference.rejectedPlaceIds;
});

/// Cold Start 여부 Provider
final isColdStartProvider = Provider<bool>((ref) {
  final preference = ref.watch(userPreferenceProvider);
  return preference.isColdStart;
});
