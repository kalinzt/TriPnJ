import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/diary_entry_model.dart';

/// 여행 다이어리 Repository
/// TripDatabase와 동일한 방식으로 Box<String> 사용 (타입 안전성 및 데이터 영속성 보장)
class DiaryRepository {
  static const String _boxName = 'diary_entries_v2'; // v2: Box<String> 타입으로 변경
  static const String _oldBoxName = 'diary_entries'; // 이전 Box<Map> 버전
  static Box<String>? _box;
  static bool _migrationCompleted = false;

  /// Hive Box를 가져오는 메서드
  Future<Box<String>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
      appLogger.d('DiaryRepository Box 열림');

      // 첫 실행 시 마이그레이션 수행
      if (!_migrationCompleted) {
        await _migrateFromOldBox();
        _migrationCompleted = true;
      }
    }
    return _box!;
  }

  /// 기존 Box<Map> 데이터를 Box<String>으로 마이그레이션
  Future<void> _migrateFromOldBox() async {
    try {
      // 기존 box가 존재하는지 확인
      if (!await Hive.boxExists(_oldBoxName)) {
        appLogger.d('마이그레이션: 기존 데이터 없음');
        return;
      }

      appLogger.d('마이그레이션 시작: $_oldBoxName -> $_boxName');

      // 기존 Box<Map> 열기
      final oldBox = await Hive.openBox<Map>(_oldBoxName);

      if (oldBox.isEmpty) {
        appLogger.d('마이그레이션: 기존 box가 비어있음');
        await oldBox.close();
        await Hive.deleteBoxFromDisk(_oldBoxName);
        return;
      }

      int successCount = 0;
      int failCount = 0;

      // 각 항목을 마이그레이션
      for (var entry in oldBox.toMap().entries) {
        try {
          final key = entry.key as String;
          final value = entry.value;

          // Map을 DiaryEntry로 파싱
          final diaryEntry = DiaryEntry.fromJson(
            Map<String, dynamic>.from(value),
          );

          // String으로 인코딩하여 새 box에 저장
          final jsonString = _encodeDiaryEntry(diaryEntry);
          await _box!.put(key, jsonString);

          successCount++;
          appLogger.d('마이그레이션 성공: ${diaryEntry.id}');
        } catch (e) {
          failCount++;
          appLogger.e('마이그레이션 실패: ${entry.key}', error: e);
        }
      }

      appLogger.d('마이그레이션 완료: 성공 $successCount개, 실패 $failCount개');

      // 기존 box 삭제
      await oldBox.close();
      await Hive.deleteBoxFromDisk(_oldBoxName);
      appLogger.d('기존 box 삭제 완료: $_oldBoxName');

    } catch (e, stackTrace) {
      appLogger.e('마이그레이션 중 오류 발생', error: e, stackTrace: stackTrace);
      // 마이그레이션 실패해도 앱은 계속 실행
    }
  }

  /// DiaryEntry를 JSON String으로 인코딩
  String _encodeDiaryEntry(DiaryEntry entry) {
    return jsonEncode(entry.toJson());
  }

  /// JSON String을 DiaryEntry로 디코딩
  DiaryEntry _decodeDiaryEntry(String jsonString) {
    return DiaryEntry.fromJson(jsonDecode(jsonString));
  }

  /// 다이어리 엔트리 저장
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final box = await _getBox();
      final jsonString = _encodeDiaryEntry(entry);
      await box.put(entry.id, jsonString);
      appLogger.d('DiaryEntry 저장 완료: ${entry.id}');
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 저장 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 특정 여행 계획의 모든 다이어리 엔트리 조회
  Future<List<DiaryEntry>> getDiaryEntriesByPlan(String travelPlanId) async {
    try {
      final box = await _getBox();
      final entries = <DiaryEntry>[];

      for (var jsonString in box.values) {
        try {
          final diaryEntry = _decodeDiaryEntry(jsonString);
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
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 조회 실패', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// 특정 ID의 다이어리 엔트리 조회
  Future<DiaryEntry?> getDiaryEntryById(String id) async {
    try {
      final box = await _getBox();
      final jsonString = box.get(id);

      if (jsonString == null) return null;

      return _decodeDiaryEntry(jsonString);
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 조회 실패', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 조회 실패', error: e, stackTrace: stackTrace);
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

      final jsonString = _encodeDiaryEntry(updatedEntry);
      await box.put(updatedEntry.id, jsonString);
      appLogger.d('DiaryEntry 업데이트 완료: ${updatedEntry.id}');
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 업데이트 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 다이어리 엔트리 삭제
  Future<void> deleteDiaryEntry(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      appLogger.d('DiaryEntry 삭제 완료: $id');
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 삭제 실패', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      appLogger.e('DiaryEntry 일괄 삭제 실패', error: e, stackTrace: stackTrace);
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
      appLogger.d('DiaryRepository Box 닫힘');
    }
  }

  // ============================================
  // 서버 마이그레이션 관련 메서드
  // ============================================

  /// 모든 다이어리 엔트리 조회 (서버 마이그레이션용)
  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    try {
      final box = await _getBox();
      final entries = <DiaryEntry>[];

      for (var jsonString in box.values) {
        try {
          final diaryEntry = _decodeDiaryEntry(jsonString);
          entries.add(diaryEntry);
        } catch (e) {
          appLogger.d('DiaryEntry 파싱 에러: $e');
        }
      }

      // 날짜 순서대로 정렬
      entries.sort((a, b) => a.date.compareTo(b.date));

      appLogger.d('전체 DiaryEntry 조회: ${entries.length}개');
      return entries;
    } catch (e, stackTrace) {
      appLogger.e('전체 DiaryEntry 조회 실패', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// 특정 날짜 이후의 다이어리 엔트리 조회 (증분 동기화용)
  Future<List<DiaryEntry>> getDiaryEntriesAfter(DateTime date) async {
    try {
      final allEntries = await getAllDiaryEntries();
      final filteredEntries = allEntries.where((entry) {
        return entry.updatedAt.isAfter(date);
      }).toList();

      appLogger.d('${date.toIso8601String()} 이후 DiaryEntry: ${filteredEntries.length}개');
      return filteredEntries;
    } catch (e, stackTrace) {
      appLogger.e('증분 동기화 조회 실패', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// 서버로 전송할 JSON 데이터 생성
  Future<Map<String, dynamic>> exportToJson() async {
    try {
      final entries = await getAllDiaryEntries();

      return {
        'version': 'v2',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalCount': entries.length,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
    } catch (e, stackTrace) {
      appLogger.e('JSON 내보내기 실패', error: e, stackTrace: stackTrace);
      return {
        'version': 'v2',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalCount': 0,
        'entries': [],
        'error': e.toString(),
      };
    }
  }

  /// 서버에서 받은 데이터로 복원 (서버 → 로컬)
  Future<void> importFromJson(Map<String, dynamic> data) async {
    try {
      final entries = (data['entries'] as List<dynamic>)
          .map((json) => DiaryEntry.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      appLogger.d('서버에서 ${entries.length}개 DiaryEntry 가져오기 시작');

      int successCount = 0;
      int failCount = 0;

      for (var entry in entries) {
        try {
          await saveDiaryEntry(entry);
          successCount++;
        } catch (e) {
          failCount++;
          appLogger.e('DiaryEntry 복원 실패: ${entry.id}', error: e);
        }
      }

      appLogger.d('서버 데이터 복원 완료: 성공 $successCount개, 실패 $failCount개');
    } catch (e, stackTrace) {
      appLogger.e('서버 데이터 복원 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 특정 여행 계획의 다이어리 데이터를 서버로 전송할 JSON 생성
  Future<Map<String, dynamic>> exportTripDiariesToJson(String travelPlanId) async {
    try {
      final entries = await getDiaryEntriesByPlan(travelPlanId);

      return {
        'version': 'v2',
        'travelPlanId': travelPlanId,
        'exportedAt': DateTime.now().toIso8601String(),
        'totalCount': entries.length,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
    } catch (e, stackTrace) {
      appLogger.e('여행 계획 다이어리 내보내기 실패', error: e, stackTrace: stackTrace);
      return {
        'version': 'v2',
        'travelPlanId': travelPlanId,
        'exportedAt': DateTime.now().toIso8601String(),
        'totalCount': 0,
        'entries': [],
        'error': e.toString(),
      };
    }
  }

  /// 로컬 DB 통계 조회
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final box = await _getBox();
      final allEntries = await getAllDiaryEntries();

      // 여행 계획별 다이어리 개수
      final Map<String, int> entriesPerPlan = {};
      for (var entry in allEntries) {
        entriesPerPlan[entry.travelPlanId] =
            (entriesPerPlan[entry.travelPlanId] ?? 0) + 1;
      }

      // 총 사진 개수
      final totalPhotos = allEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.photos.length,
      );

      // 총 가계부 항목 개수
      final totalExpenses = allEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.expenses.length,
      );

      // 총 지출 금액
      final totalAmount = allEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.totalExpense,
      );

      return {
        'totalEntries': box.length,
        'totalPhotos': totalPhotos,
        'totalExpenses': totalExpenses,
        'totalAmount': totalAmount,
        'entriesPerPlan': entriesPerPlan,
        'oldestEntry': allEntries.isNotEmpty
            ? allEntries.first.date.toIso8601String()
            : null,
        'newestEntry': allEntries.isNotEmpty
            ? allEntries.last.date.toIso8601String()
            : null,
      };
    } catch (e, stackTrace) {
      appLogger.e('통계 조회 실패', error: e, stackTrace: stackTrace);
      return {'error': e.toString()};
    }
  }
}
