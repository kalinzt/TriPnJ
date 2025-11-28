import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/trip_plan.dart';
import '../../data/providers/trip_provider.dart';
import '../../data/repositories/trip_repository.dart';
import '../widgets/activity_card.dart';
import 'add_activity_screen.dart';
import 'trip_plan_edit_screen.dart';

/// 일별 여행 계획 화면
class DailyPlanScreen extends ConsumerStatefulWidget {
  final TripPlan trip;

  const DailyPlanScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends ConsumerState<DailyPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<DateTime> _dates;
  final _dateFormat = DateFormat('MM/dd (E)', 'ko');

  @override
  void initState() {
    super.initState();
    _generateDates();
    _tabController = TabController(length: _dates.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 여행 기간의 모든 날짜 생성
  void _generateDates() {
    _dates = [];
    DateTime current = widget.trip.startDate;
    while (current.isBefore(widget.trip.endDate) ||
        current.isAtSameMomentAs(widget.trip.endDate)) {
      _dates.add(current);
      current = current.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 최신 여행 데이터 가져오기
    final currentTrip = ref.watch(tripProvider(widget.trip.id)) ?? widget.trip;
    final repository = ref.watch(tripRepositoryProvider);
    final status = repository.getTripStatus(currentTrip);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentTrip.title),
            Text(
              currentTrip.destination,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          // 여행 정보 수정
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTrip(currentTrip),
          ),
          // 더보기 메뉴
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _shareTrip(currentTrip);
                  break;
                case 'delete':
                  _deleteTrip(currentTrip);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('공유하기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('삭제하기', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 여행 정보 요약
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTripSummary(currentTrip, repository, status),
              ),
              const SizedBox(height: 8),
              // 날짜 탭
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _dates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  return Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Day ${index + 1}'),
                        Text(
                          _dateFormat.format(date),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _dates.map((date) {
          return _buildDailyPlanView(currentTrip, date);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addActivity(currentTrip, _dates[_tabController.index]),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 여행 정보 요약
  Widget _buildTripSummary(
    TripPlan trip,
    TripRepository repository,
    TripStatus status,
  ) {
    final duration = repository.calculateTripDuration(trip);
    final progress = repository.calculateProgress(trip);
    final totalCost = repository.calculateTotalEstimatedCost(trip);

    return Row(
      children: [
        // 기간
        _buildSummaryItem(
          icon: Icons.calendar_today,
          label: '$duration일',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        // 진행률
        if (status == TripStatus.ongoing)
          _buildSummaryItem(
            icon: Icons.check_circle,
            label: '${(progress * 100).toInt()}%',
            color: AppColors.success,
          ),
        const SizedBox(width: 16),
        // 예상 비용
        if (totalCost > 0)
          _buildSummaryItem(
            icon: Icons.payments,
            label: '${NumberFormat('#,###').format(totalCost)}원',
            color: AppColors.warning,
          ),
        // 예산 초과 경고
        if (trip.budget != null && repository.isBudgetExceeded(trip)) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.warning,
            color: AppColors.error,
            size: 20,
          ),
        ],
      ],
    );
  }

  /// 요약 항목
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 일별 계획 뷰
  Widget _buildDailyPlanView(TripPlan trip, DateTime date) {
    // 해당 날짜의 계획 찾기
    final dailyPlan = trip.dailyPlans.firstWhere(
      (plan) =>
          plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day,
      orElse: () => DailyPlan(date: date),
    );

    final activities = dailyPlan.activities;

    if (activities.isEmpty) {
      return _buildEmptyState(date);
    }

    // 시간순으로 정렬
    final sortedActivities = [...activities];
    sortedActivities.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedActivities.length,
      onReorder: (oldIndex, newIndex) {
        _reorderActivities(trip, date, oldIndex, newIndex, sortedActivities);
      },
      itemBuilder: (context, index) {
        final activity = sortedActivities[index];
        return ActivityCard(
          key: Key(activity.id),
          activity: activity,
          isReorderable: true,
          onEdit: () => _editActivity(trip, date, activity),
          onDelete: () => _deleteActivity(trip, date, activity.id),
          onToggleComplete: () => _toggleActivityComplete(trip, date, activity),
        );
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState(DateTime date) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '이날의 활동이 아직 없습니다',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _addActivity(widget.trip, date),
            icon: const Icon(Icons.add),
            label: const Text('활동 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 활동 추가
  void _addActivity(TripPlan trip, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(
          tripId: trip.id,
          date: date,
        ),
      ),
    );
  }

  /// 활동 편집
  void _editActivity(TripPlan trip, DateTime date, Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(
          tripId: trip.id,
          date: date,
          activity: activity,
        ),
      ),
    );
  }

  /// 활동 삭제
  Future<void> _deleteActivity(
    TripPlan trip,
    DateTime date,
    String activityId,
  ) async {
    try {
      await ref.read(allTripsProvider.notifier).removeActivity(
            tripId: trip.id,
            date: date,
            activityId: activityId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('활동이 삭제되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error('활동 삭제 실패', e, stackTrace, 'DailyPlanScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('활동 삭제에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 활동 완료 토글
  Future<void> _toggleActivityComplete(
    TripPlan trip,
    DateTime date,
    Activity activity,
  ) async {
    try {
      await ref.read(allTripsProvider.notifier).toggleActivityCompletion(
            tripId: trip.id,
            date: date,
            activity: activity,
          );
    } catch (e, stackTrace) {
      Logger.error('활동 완료 상태 변경 실패', e, stackTrace, 'DailyPlanScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('활동 상태 변경에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 활동 재정렬
  void _reorderActivities(
    TripPlan trip,
    DateTime date,
    int oldIndex,
    int newIndex,
    List<Activity> activities,
  ) {
    // 재정렬 로직
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final activity = activities.removeAt(oldIndex);
    activities.insert(newIndex, activity);

    // 일별 계획 업데이트
    final dailyPlanIndex = trip.dailyPlans.indexWhere((plan) =>
        plan.date.year == date.year &&
        plan.date.month == date.month &&
        plan.date.day == date.day);

    if (dailyPlanIndex >= 0) {
      final updatedDailyPlans = [...trip.dailyPlans];
      updatedDailyPlans[dailyPlanIndex] =
          updatedDailyPlans[dailyPlanIndex].copyWith(activities: activities);

      final updatedTrip = trip.copyWith(dailyPlans: updatedDailyPlans);
      ref.read(allTripsProvider.notifier).updateTrip(updatedTrip);
    }
  }

  /// 여행 정보 수정
  void _editTrip(TripPlan trip) {
    ref.read(currentEditingTripProvider.notifier).startEditingTrip(trip);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlanEditScreen(tripId: trip.id),
      ),
    );
  }

  /// 여행 공유
  void _shareTrip(TripPlan trip) {
    // TODO: 여행 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('여행 공유 기능은 추후 구현 예정입니다'),
      ),
    );
  }

  /// 여행 삭제
  Future<void> _deleteTrip(TripPlan trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행 삭제'),
        content: Text('${trip.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(allTripsProvider.notifier).deleteTrip(trip.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${trip.title}이(가) 삭제되었습니다'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e, stackTrace) {
        Logger.error('여행 삭제 실패', e, stackTrace, 'DailyPlanScreen');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('여행 삭제에 실패했습니다'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
