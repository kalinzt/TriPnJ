import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/travel_plan_model.dart';
import '../../data/providers/travel_plan_provider.dart';
import '../widgets/travel_plan_card.dart';
import 'add_plan_screen.dart';
import 'plan_detail_screen.dart';

/// 여행 계획 화면 - 캘린더 및 목록 뷰
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final travelPlanState = ref.watch(travelPlanListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 계획'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(travelPlanListProvider.notifier).loadAllPlans();
            },
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더
          _buildCalendar(travelPlanState.plans),
          const Divider(height: 1),

          // 여행 계획 목록
          Expanded(
            child: travelPlanState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : travelPlanState.errorMessage != null
                    ? _buildErrorView(travelPlanState.errorMessage!)
                    : _buildPlanList(travelPlanState.plans),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewPlan,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '새 계획 추가',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 캘린더 빌드
  Widget _buildCalendar(List<TravelPlan> plans) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        // 한국어 설정
        locale: 'ko_KR',
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        // 특정 날짜에 여행 계획이 있는지 표시
        eventLoader: (day) {
          return plans.where((plan) {
            final dayStart = DateTime(day.year, day.month, day.day);
            final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
            final planStart = DateTime(
              plan.startDate.year,
              plan.startDate.month,
              plan.startDate.day,
            );
            final planEnd = DateTime(
              plan.endDate.year,
              plan.endDate.month,
              plan.endDate.day,
              23,
              59,
              59,
            );

            return (planStart.isBefore(dayEnd) && planEnd.isAfter(dayStart));
          }).toList();
        },
      ),
    );
  }

  /// 날짜 선택 시
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// 여행 계획 목록 빌드
  Widget _buildPlanList(List<TravelPlan> allPlans) {
    if (allPlans.isEmpty) {
      return _buildEmptyView();
    }

    // 선택된 날짜에 해당하는 여행 계획 필터링
    final selectedDatePlans = allPlans.where((plan) {
      final selectedStart = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      final selectedEnd = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        23,
        59,
        59,
      );
      final planStart = DateTime(
        plan.startDate.year,
        plan.startDate.month,
        plan.startDate.day,
      );
      final planEnd = DateTime(
        plan.endDate.year,
        plan.endDate.month,
        plan.endDate.day,
        23,
        59,
        59,
      );

      return (planStart.isBefore(selectedEnd) && planEnd.isAfter(selectedStart));
    }).toList();

    return Column(
      children: [
        // 날짜 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.background,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy년 M월 d일').format(_selectedDay),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selectedDatePlans.isNotEmpty)
                Text(
                  '${selectedDatePlans.length}개의 여행 계획',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        // 목록
        Expanded(
          child: selectedDatePlans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: AppColors.textHint.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '선택한 날짜에 여행 계획이 없습니다',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _selectedDay = DateTime.now();
                          _focusedDay = DateTime.now();
                        }),
                        icon: const Icon(Icons.today),
                        label: const Text('오늘로 이동'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedDatePlans.length,
                  itemBuilder: (context, index) {
                    final plan = selectedDatePlans[index];
                    return TravelPlanCard(
                      plan: plan,
                      onTap: () => _navigateToDetail(plan),
                      onDelete: () => _deletePlan(plan.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_note,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 24),
          const Text(
            '여행 계획이 없습니다',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '새 여행 계획을 추가해보세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewPlan,
            icon: const Icon(Icons.add),
            label: const Text('여행 계획 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              '오류 발생',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(travelPlanListProvider.notifier).loadAllPlans();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 새 여행 계획 추가
  Future<void> _addNewPlan() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddPlanScreen(),
      ),
    );

    if (result == true) {
      // 추가 성공 시 목록 새로고침은 Provider에서 자동으로 처리됨
    }
  }

  /// 여행 계획 상세 화면으로 이동
  Future<void> _navigateToDetail(TravelPlan plan) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(plan: plan),
      ),
    );

    if (result == true) {
      // 수정/삭제 후 목록 새로고침
      ref.read(travelPlanListProvider.notifier).loadAllPlans();
    }
  }

  /// 여행 계획 삭제
  Future<void> _deletePlan(String id) async {
    await ref.read(travelPlanListProvider.notifier).deleteTravelPlan(id);
  }
}
