import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../models/travel_plan_model.dart';

/// 여행 계획 Repository
/// Hive를 사용한 로컬 저장소 관리
class TravelPlanRepository {
  static const String _boxName = 'travel_plans';
  Box<TravelPlan>? _box;
  final _uuid = const Uuid();

  /// Hive Box 초기화
  Future<void> init() async {
    try {
      Logger.info('TravelPlanRepository 초기화 시작', 'TravelPlanRepository');

      // Hive 어댑터가 이미 등록되었는지 확인
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TravelPlanAdapter());
      }

      _box = await Hive.openBox<TravelPlan>(_boxName);
      Logger.info('TravelPlanRepository 초기화 완료', 'TravelPlanRepository');
    } catch (e, stackTrace) {
      Logger.error('TravelPlanRepository 초기화 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// Box 가져오기 (지연 초기화)
  Future<Box<TravelPlan>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  // ============================================
  // CREATE - 여행 계획 추가
  // ============================================

  /// 새 여행 계획 생성
  Future<TravelPlan> createTravelPlan({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    double? budget,
    String? description,
  }) async {
    try {
      Logger.info('여행 계획 생성: $name', 'TravelPlanRepository');
      Logger.info('  - 시작일: ${startDate.year}-${startDate.month}-${startDate.day}', 'TravelPlanRepository');
      Logger.info('  - 종료일: ${endDate.year}-${endDate.month}-${endDate.day}', 'TravelPlanRepository');

      final box = await _getBox();
      final now = DateTime.now();

      final travelPlan = TravelPlan(
        id: _uuid.v4(),
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        description: description,
        status: 'planned', // 초기값: 날짜 기반으로 자동 업데이트됨
        createdAt: now,
        updatedAt: now,
      );

      // 날짜 기반 상태 자동 업데이트
      final beforeStatus = travelPlan.status;
      travelPlan.updateStatusBasedOnDate();
      final afterStatus = travelPlan.status;

      Logger.info('  - 상태 자동 설정: $beforeStatus → $afterStatus', 'TravelPlanRepository');
      if (afterStatus == 'planned') {
        Logger.info('    → 예정된 여행 (시작일이 미래)', 'TravelPlanRepository');
      } else if (afterStatus == 'inProgress') {
        Logger.info('    → 진행 중인 여행 (여행 기간 중)', 'TravelPlanRepository');
      } else if (afterStatus == 'completed') {
        Logger.info('    → 완료된 여행 (종료일이 과거)', 'TravelPlanRepository');
      }

      await box.put(travelPlan.id, travelPlan);

      Logger.info('여행 계획 생성 완료: ${travelPlan.id}', 'TravelPlanRepository');
      return travelPlan;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 생성 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  // ============================================
  // READ - 여행 계획 조회
  // ============================================

  /// 모든 여행 계획 조회
  Future<List<TravelPlan>> getAllTravelPlans() async {
    try {
      Logger.info('모든 여행 계획 조회', 'TravelPlanRepository');

      final box = await _getBox();
      final plans = box.values.toList();

      // 상태 업데이트
      for (final plan in plans) {
        plan.updateStatusBasedOnDate();
      }

      // 시작 날짜 기준 정렬 (최신순)
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));

      Logger.info('여행 계획 ${plans.length}개 조회 완료', 'TravelPlanRepository');
      return plans;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 조회 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// ID로 여행 계획 조회
  Future<TravelPlan?> getTravelPlanById(String id) async {
    try {
      Logger.info('여행 계획 조회: $id', 'TravelPlanRepository');

      final box = await _getBox();
      final plan = box.get(id);

      if (plan != null) {
        plan.updateStatusBasedOnDate();
      }

      return plan;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 조회 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// 날짜 범위로 여행 계획 검색
  Future<List<TravelPlan>> getTravelPlansByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      Logger.info(
        '날짜 범위 검색: ${startDate.toString()} ~ ${endDate.toString()}',
        'TravelPlanRepository',
      );

      final box = await _getBox();
      final plans = box.values.where((plan) {
        // 여행 계획의 날짜가 검색 범위와 겹치는지 확인
        return plan.startDate.isBefore(endDate) && plan.endDate.isAfter(startDate);
      }).toList();

      // 상태 업데이트
      for (final plan in plans) {
        plan.updateStatusBasedOnDate();
      }

      // 시작 날짜 기준 정렬
      plans.sort((a, b) => a.startDate.compareTo(b.startDate));

      Logger.info('날짜 범위 검색 완료: ${plans.length}개', 'TravelPlanRepository');
      return plans;
    } catch (e, stackTrace) {
      Logger.error('날짜 범위 검색 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// 특정 월의 여행 계획 조회
  Future<List<TravelPlan>> getTravelPlansByMonth({
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return getTravelPlansByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 상태별 여행 계획 조회
  Future<List<TravelPlan>> getTravelPlansByStatus(String status) async {
    try {
      Logger.info('상태별 여행 계획 조회: $status', 'TravelPlanRepository');

      final box = await _getBox();
      final plans = box.values.where((plan) {
        plan.updateStatusBasedOnDate();
        return plan.status == status;
      }).toList();

      // 시작 날짜 기준 정렬
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));

      Logger.info('상태별 검색 완료: ${plans.length}개', 'TravelPlanRepository');
      return plans;
    } catch (e, stackTrace) {
      Logger.error('상태별 검색 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// 예정/진행 중인 여행 계획 조회 (오늘과 가까운 순 정렬)
  Future<List<TravelPlan>> getPlannedAndOngoingTravels() async {
    try {
      Logger.info('예정/진행 중인 여행 계획 조회', 'TravelPlanRepository');

      final box = await _getBox();

      // 오늘 날짜 (시간 제거)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 상태 업데이트 후 'planned' 또는 'inProgress' 필터링
      final plans = box.values.where((plan) {
        plan.updateStatusBasedOnDate();
        return plan.status == 'planned' || plan.status == 'inProgress';
      }).toList();

      // 시작날짜가 오늘과 가까운 순으로 정렬
      plans.sort((a, b) {
        // 날짜만 비교하기 위해 시간 제거
        final aStart = DateTime(a.startDate.year, a.startDate.month, a.startDate.day);
        final bStart = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);

        // 진행 중인 여행 (startDate < today < endDate)을 최우선
        final aIsOngoing = a.status == 'inProgress';
        final bIsOngoing = b.status == 'inProgress';

        if (aIsOngoing && !bIsOngoing) return -1; // a가 진행 중이면 a를 앞으로
        if (!aIsOngoing && bIsOngoing) return 1;  // b가 진행 중이면 b를 앞으로

        // 둘 다 진행 중이거나 둘 다 예정인 경우, 오늘과의 거리로 정렬
        final aDiff = (aStart.difference(today).inDays).abs();
        final bDiff = (bStart.difference(today).inDays).abs();

        return aDiff.compareTo(bDiff);
      });

      Logger.info('조회된 \'예정/진행\' 여행 수: ${plans.length}', 'TravelPlanRepository');
      return plans;
    } catch (e, stackTrace) {
      Logger.error('예정/진행 중인 여행 조회 실패', e, stackTrace, 'TravelPlanRepository');
      return [];
    }
  }

  /// 완료된 여행 계획 조회 (오늘과 가까운 순 정렬)
  Future<List<TravelPlan>> getCompletedTravels() async {
    try {
      Logger.info('완료된 여행 계획 조회', 'TravelPlanRepository');

      final box = await _getBox();

      // 오늘 날짜 (시간 제거)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 상태 업데이트 후 'completed' 필터링
      final plans = box.values.where((plan) {
        plan.updateStatusBasedOnDate();
        return plan.status == 'completed';
      }).toList();

      // 종료날짜가 오늘과 가까운 순으로 정렬
      plans.sort((a, b) {
        // 날짜만 비교하기 위해 시간 제거
        final aEnd = DateTime(a.endDate.year, a.endDate.month, a.endDate.day);
        final bEnd = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);

        // 오늘과의 거리 계산
        final aDiff = (aEnd.difference(today).inDays).abs();
        final bDiff = (bEnd.difference(today).inDays).abs();

        return aDiff.compareTo(bDiff);
      });

      Logger.info('조회된 \'완료\' 여행 수: ${plans.length}', 'TravelPlanRepository');
      return plans;
    } catch (e, stackTrace) {
      Logger.error('완료된 여행 조회 실패', e, stackTrace, 'TravelPlanRepository');
      return [];
    }
  }

  // ============================================
  // UPDATE - 여행 계획 수정
  // ============================================

  /// 여행 계획 업데이트
  Future<TravelPlan> updateTravelPlan(TravelPlan travelPlan) async {
    try {
      Logger.info('여행 계획 업데이트: ${travelPlan.id}', 'TravelPlanRepository');

      final box = await _getBox();

      // 수정 날짜 업데이트
      final updatedPlan = travelPlan.copyWith(updatedAt: DateTime.now());

      // 상태 자동 업데이트
      updatedPlan.updateStatusBasedOnDate();

      await box.put(updatedPlan.id, updatedPlan);

      Logger.info('여행 계획 업데이트 완료', 'TravelPlanRepository');
      return updatedPlan;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 업데이트 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  // ============================================
  // DELETE - 여행 계획 삭제
  // ============================================

  /// 여행 계획 삭제
  Future<void> deleteTravelPlan(String id) async {
    try {
      Logger.info('여행 계획 삭제: $id', 'TravelPlanRepository');

      final box = await _getBox();
      await box.delete(id);

      Logger.info('여행 계획 삭제 완료', 'TravelPlanRepository');
    } catch (e, stackTrace) {
      Logger.error('여행 계획 삭제 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  /// 모든 여행 계획 삭제
  Future<void> deleteAllTravelPlans() async {
    try {
      Logger.info('모든 여행 계획 삭제', 'TravelPlanRepository');

      final box = await _getBox();
      await box.clear();

      Logger.info('모든 여행 계획 삭제 완료', 'TravelPlanRepository');
    } catch (e, stackTrace) {
      Logger.error('모든 여행 계획 삭제 실패', e, stackTrace, 'TravelPlanRepository');
      rethrow;
    }
  }

  // ============================================
  // 기타
  // ============================================

  /// 여행 계획 개수 조회
  Future<int> getTravelPlanCount() async {
    try {
      final box = await _getBox();
      return box.length;
    } catch (e, stackTrace) {
      Logger.error('여행 계획 개수 조회 실패', e, stackTrace, 'TravelPlanRepository');
      return 0;
    }
  }

  /// Repository 종료
  Future<void> dispose() async {
    await _box?.close();
  }
}
