import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/trip_plan.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_event_marker.dart';

/// 캘린더 뷰 화면
/// 여행 계획을 캘린더 형태로 확인할 수 있는 화면
class CalendarViewScreen extends ConsumerWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedDate = ref.watch(focusedDateProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);
    final eventsMap = ref.watch(calendarEventsProvider);
    final selectedDayEvents = ref.watch(selectedDayEventsProvider);
    final selectedDayActivities = ref.watch(selectedDayActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 캘린더'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(calendarControllerProvider.notifier).goToToday();
            },
            tooltip: '오늘로 이동',
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          _buildCalendar(
            context,
            ref,
            selectedDate,
            focusedDate,
            calendarFormat,
            eventsMap,
          ),

          const Divider(height: 1),

          // 선택된 날짜의 이벤트 목록
          Expanded(
            child: _buildEventsList(
              context,
              ref,
              selectedDate,
              selectedDayEvents,
              selectedDayActivities,
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더 위젯 구성
  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    DateTime focusedDate,
    CalendarFormat calendarFormat,
    Map<DateTime, List<TripPlan>> eventsMap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<TripPlan>(
        // 기본 설정
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        calendarFormat: calendarFormat,

        // 이벤트 로더
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return eventsMap[key] ?? [];
        },

        // 날짜 선택 콜백
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(calendarControllerProvider.notifier).selectDate(selectedDay);
          ref.read(calendarControllerProvider.notifier).changeFocusedDate(focusedDay);
        },

        // 페이지 변경 콜백
        onPageChanged: (focusedDay) {
          ref.read(calendarControllerProvider.notifier).changeFocusedDate(focusedDay);
        },

        // 포맷 변경 콜백
        onFormatChanged: (format) {
          ref.read(calendarControllerProvider.notifier).changeCalendarFormat(format);
        },

        // 스타일 설정
        calendarStyle: CalendarStyle(
          // 오늘 날짜 스타일
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          todayTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),

          // 선택된 날짜 스타일
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),

          // 기본 날짜 스타일
          defaultTextStyle: AppTextStyles.bodyMedium,
          weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondary,
          ),

          // 다른 달 날짜 스타일
          outsideTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),

          // 마커 스타일
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          canMarkersOverflow: true,
        ),

        // 헤더 스타일
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: AppTextStyles.titleMedium,
          formatButtonTextStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),

        // 요일 헤더 스타일
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          weekendStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
          ),
        ),

        // 캘린더 빌더
        calendarBuilders: CalendarBuilders<TripPlan>(
          // 마커 빌더
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox.shrink();

            return Positioned(
              bottom: 2,
              child: CalendarEventMarker(
                eventCount: events.length,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 이벤트 목록 구성
  Widget _buildEventsList(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List<TripPlan> events,
    List<ActivityWithTrip> activities,
  ) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          _buildDateHeader(selectedDate, events.length),

          // 이벤트 및 활동 목록
          Expanded(
            child: events.isEmpty
                ? _buildEmptyState()
                : _buildEventsAndActivities(
                    context,
                    ref,
                    events,
                    activities,
                  ),
          ),
        ],
      ),
    );
  }

  /// 날짜 헤더
  Widget _buildDateHeader(DateTime date, int eventCount) {
    final dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(date),
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  eventCount > 0
                      ? '$eventCount개의 여행 계획'
                      : '여행 계획 없음',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (eventCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                eventCount.toString(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '이 날짜에는 여행 계획이 없습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 여행을 계획해보세요!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 및 활동 목록
  Widget _buildEventsAndActivities(
    BuildContext context,
    WidgetRef ref,
    List<TripPlan> events,
    List<ActivityWithTrip> activities,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 여행 계획 목록
        ...events.map((trip) => _buildTripCard(context, trip)),

        if (activities.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('일정'),
          const SizedBox(height: 8),
        ],

        // 활동 목록
        ...activities.map((activityWithTrip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildActivityItem(context, ref, activityWithTrip),
            )),
      ],
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 여행 계획 카드
  Widget _buildTripCard(BuildContext context, TripPlan trip) {
    final dateFormat = DateFormat('M/d');
    final tripDuration = trip.endDate.difference(trip.startDate).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 여행 상세 화면으로 이동
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTripStatusColor(trip),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTripStatusBadge(trip),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)} ($tripDuration일)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 여행 상태에 따른 색상 반환
  Color _getTripStatusColor(TripPlan trip) {
    final now = DateTime.now();

    if (trip.startDate.isBefore(now) && trip.endDate.isAfter(now)) {
      return AppColors.success; // 진행 중
    } else if (trip.startDate.isAfter(now)) {
      return AppColors.primary; // 예정됨
    } else {
      return AppColors.textSecondary; // 완료됨
    }
  }

  /// 여행 상태 배지
  Widget _buildTripStatusBadge(TripPlan trip) {
    final now = DateTime.now();
    String label;
    Color backgroundColor;
    Color textColor;

    if (trip.startDate.isBefore(now) && trip.endDate.isAfter(now)) {
      label = '진행중';
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
    } else if (trip.startDate.isAfter(now)) {
      label = '예정';
      backgroundColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
    } else {
      label = '완료';
      backgroundColor = AppColors.textSecondary.withOpacity(0.1);
      textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  /// 활동 아이템
  Widget _buildActivityItem(
    BuildContext context,
    WidgetRef ref,
    ActivityWithTrip activityWithTrip,
  ) {
    final activity = activityWithTrip.activity;
    final trip = activityWithTrip.tripPlan;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.isCompleted
              ? AppColors.success.withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 활동 상세 화면으로 이동
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 완료 체크박스
                Checkbox(
                  value: activity.isCompleted,
                  onChanged: (value) {
                    // TODO: 완료 상태 토글
                  },
                  shape: const CircleBorder(),
                  activeColor: AppColors.success,
                ),

                const SizedBox(width: 8),

                // 활동 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            activity.type.iconName,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activityWithTrip.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                decoration: activity.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: activity.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (activityWithTrip.timeRange != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activityWithTrip.timeRange!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              trip.title,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 화살표 아이콘
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
