import 'package:hive/hive.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/diary_entry_model.dart';

/// 여행 다이어리 Repository
class DiaryRepository {
  static const String _boxName = 'diary_entries';
  static Box<Map>? _box;

  /// Hive Box를 가져오는 메서드
  Future<Box<Map>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  /// 다이어리 엔트리 저장
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final box = await _getBox();
      await box.put(entry.id, entry.toJson());
      appLogger.d('DiaryEntry 저장 완료: ${entry.id}');
    } catch (e) {
      appLogger.e('DiaryEntry 저장 실패', error: e);
      rethrow;
    }
  }

  /// 특정 여행 계획의 모든 다이어리 엔트리 조회
  Future<List<DiaryEntry>> getDiaryEntriesByPlan(String travelPlanId) async {
    try {
      final box = await _getBox();
      final entries = <DiaryEntry>[];

      for (var entry in box.values) {
        try {
          final diaryEntry = DiaryEntry.fromJson(
            Map<String, dynamic>.from(entry),
          );
          if (diaryEntry.travelPlanId == travelPlanId) {
            entries.add(diaryEntry);
          }
        } catch (e) {
          appLogger.d('DiaryEntry 파싱 에러: $e');
        }
      }

      // 날짜 순서대로 정렬
      entries.sort((a, b) => a.date.compareTo(b.date));

      appLogger.d('조회된 DiaryEntry 수: ${entries.length}');
      return entries;
    } catch (e) {
      appLogger.e('DiaryEntry 조회 실패', error: e);
      return [];
    }
  }

  /// 특정 ID의 다이어리 엔트리 조회
  Future<DiaryEntry?> getDiaryEntryById(String id) async {
    try {
      final box = await _getBox();
      final data = box.get(id);

      if (data == null) return null;

      return DiaryEntry.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      appLogger.e('DiaryEntry 조회 실패', error: e);
      return null;
    }
  }

  /// 특정 날짜의 다이어리 엔트리 조회
  Future<DiaryEntry?> getDiaryEntryByDate(
    String travelPlanId,
    DateTime date,
  ) async {
    try {
      final entries = await getDiaryEntriesByPlan(travelPlanId);

      for (var entry in entries) {
        if (_isSameDay(entry.date, date)) {
          return entry;
        }
      }

      return null;
    } catch (e) {
      appLogger.e('DiaryEntry 조회 실패', error: e);
      return null;
    }
  }

  /// 다이어리 엔트리 업데이트
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    try {
      final box = await _getBox();

      final updatedEntry = entry.copyWith(
        updatedAt: DateTime.now(),
      );

      await box.put(updatedEntry.id, updatedEntry.toJson());
      appLogger.d('DiaryEntry 업데이트 완료: ${updatedEntry.id}');
    } catch (e) {
      appLogger.e('DiaryEntry 업데이트 실패', error: e);
      rethrow;
    }
  }

  /// 다이어리 엔트리 삭제
  Future<void> deleteDiaryEntry(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      appLogger.d('DiaryEntry 삭제 완료: $id');
    } catch (e) {
      appLogger.e('DiaryEntry 삭제 실패', error: e);
      rethrow;
    }
  }

  /// 여행 계획의 모든 다이어리 엔트리 삭제
  Future<void> deleteDiaryEntriesByPlan(String travelPlanId) async {
    try {
      final entries = await getDiaryEntriesByPlan(travelPlanId);
      final box = await _getBox();

      for (var entry in entries) {
        await box.delete(entry.id);
      }

      appLogger.d('여행 계획의 모든 DiaryEntry 삭제 완료: $travelPlanId');
    } catch (e) {
      appLogger.e('DiaryEntry 일괄 삭제 실패', error: e);
      rethrow;
    }
  }

  /// 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Box 닫기
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
