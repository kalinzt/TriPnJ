import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../shared/models/trip_plan.dart';
import '../../data/providers/trip_provider.dart';

// ============================================
// Calendar State Providers
// ============================================

/// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// 포커스된 날짜 (현재 보여지는 월) Provider
final focusedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// 캘린더 포맷 Provider
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) {
  return CalendarFormat.month;
});

// ============================================
// Events Provider
// ============================================

/// 날짜별 이벤트 맵 Provider
/// Map<DateTime, List<TripPlan>> 형태로 반환
final calendarEventsProvider = Provider<Map<DateTime, List<TripPlan>>>((ref) {
  final allTrips = ref.watch(allTripsProvider);
  final eventsMap = <DateTime, List<TripPlan>>{};

  for (final trip in allTrips) {
    // 여행 시작일부터 종료일까지 각 날짜에 이벤트 추가
    DateTime currentDate = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
    );
    final endDate = DateTime(
      trip.endDate.year,
      trip.endDate.month,
      trip.endDate.day,
    );

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final key = DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (eventsMap[key] == null) {
        eventsMap[key] = [];
      }
      eventsMap[key]!.add(trip);

      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  return eventsMap;
});

/// 선택된 날짜의 이벤트 Provider
final selectedDayEventsProvider = Provider<List<TripPlan>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final eventsMap = ref.watch(calendarEventsProvider);

  final key = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  return eventsMap[key] ?? [];
});

/// 선택된 날짜의 활동 목록 Provider
final selectedDayActivitiesProvider = Provider<List<ActivityWithTrip>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final events = ref.watch(selectedDayEventsProvider);

  final activities = <ActivityWithTrip>[];

  for (final trip in events) {
    // 해당 날짜의 DailyPlan 찾기
    final dailyPlan = trip.dailyPlans.where((plan) {
      return plan.date.year == selectedDate.year &&
          plan.date.month == selectedDate.month &&
          plan.date.day == selectedDate.day;
    }).firstOrNull;

    if (dailyPlan != null) {
      for (final activity in dailyPlan.activities) {
        activities.add(
          ActivityWithTrip(
            activity: activity,
            tripPlan: trip,
            date: dailyPlan.date,
          ),
        );
      }
    }
  }

  // 시작 시간 기준 정렬
  activities.sort((a, b) {
    if (a.activity.startTime == null && b.activity.startTime == null) {
      return 0;
    }
    if (a.activity.startTime == null) return 1;
    if (b.activity.startTime == null) return -1;
    return a.activity.startTime!.compareTo(b.activity.startTime!);
  });

  return activities;
});

/// 특정 날짜의 이벤트 개수 Provider
final dateEventCountProvider = Provider.family<int, DateTime>((ref, date) {
  final eventsMap = ref.watch(calendarEventsProvider);
  final key = DateTime(date.year, date.month, date.day);
  return eventsMap[key]?.length ?? 0;
});

// ============================================
// Calendar Controller Notifier
// ============================================

/// 캘린더 컨트롤러 StateNotifier
class CalendarControllerNotifier extends StateNotifier<CalendarState> {
  final Ref ref;

  CalendarControllerNotifier(this.ref)
      : super(CalendarState(
          selectedDate: DateTime.now(),
          focusedDate: DateTime.now(),
          calendarFormat: CalendarFormat.month,
        ));

  /// 날짜 선택
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    ref.read(selectedDateProvider.notifier).state = date;
  }

  /// 포커스된 날짜 변경 (월 변경)
  void changeFocusedDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
    ref.read(focusedDateProvider.notifier).state = date;
  }

  /// 캘린더 포맷 변경
  void changeCalendarFormat(CalendarFormat format) {
    state = state.copyWith(calendarFormat: format);
    ref.read(calendarFormatProvider.notifier).state = format;
  }

  /// 오늘로 이동
  void goToToday() {
    final today = DateTime.now();
    state = state.copyWith(
      selectedDate: today,
      focusedDate: today,
    );
    ref.read(selectedDateProvider.notifier).state = today;
    ref.read(focusedDateProvider.notifier).state = today;
  }

  /// 이전 달로 이동
  void goToPreviousMonth() {
    final newDate = DateTime(
      state.focusedDate.year,
      state.focusedDate.month - 1,
    );
    changeFocusedDate(newDate);
  }

  /// 다음 달로 이동
  void goToNextMonth() {
    final newDate = DateTime(
      state.focusedDate.year,
      state.focusedDate.month + 1,
    );
    changeFocusedDate(newDate);
  }

  /// 특정 날짜로 이동
  void goToDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      focusedDate: date,
    );
    ref.read(selectedDateProvider.notifier).state = date;
    ref.read(focusedDateProvider.notifier).state = date;
  }
}

/// 캘린더 컨트롤러 Provider
final calendarControllerProvider =
    StateNotifierProvider<CalendarControllerNotifier, CalendarState>((ref) {
  return CalendarControllerNotifier(ref);
});

// ============================================
// Data Classes
// ============================================

/// 캘린더 상태
class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;

  const CalendarState({
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }
}

/// 활동과 여행 계획을 함께 담는 클래스
class ActivityWithTrip {
  final Activity activity;
  final TripPlan tripPlan;
  final DateTime date;

  const ActivityWithTrip({
    required this.activity,
    required this.tripPlan,
    required this.date,
  });

  /// 활동 제목
  String get title {
    if (activity.place != null) {
      return activity.place!.name;
    }
    return activity.title ?? '제목 없음';
  }

  /// 활동 시간 포맷
  String? get timeRange {
    if (activity.startTime == null) return null;

    final startTimeStr = _formatTime(activity.startTime!);

    if (activity.endTime != null) {
      final endTimeStr = _formatTime(activity.endTime!);
      return '$startTimeStr - $endTimeStr';
    }

    if (activity.durationMinutes != null) {
      final endTime = activity.startTime!.add(
        Duration(minutes: activity.durationMinutes!),
      );
      final endTimeStr = _formatTime(endTime);
      return '$startTimeStr - $endTimeStr';
    }

    return startTimeStr;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
