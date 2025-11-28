import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/trip_plan.dart';
import '../../data/providers/trip_provider.dart';
import '../../data/repositories/trip_repository.dart';
import 'daily_plan_screen.dart';
import 'trip_plan_edit_screen.dart';

/// 여행 계획 목록 화면
class PlanListScreen extends ConsumerStatefulWidget {
  const PlanListScreen({super.key});

  @override
  ConsumerState<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends ConsumerState<PlanListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 계획'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '진행 중'),
            Tab(text: '예정'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripList(TripFilter.all),
          _buildTripList(TripFilter.ongoing),
          _buildTripList(TripFilter.upcoming),
          _buildTripList(TripFilter.completed),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTrip,
        icon: const Icon(Icons.add),
        label: const Text('새 여행 계획'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 여행 목록 빌드
  Widget _buildTripList(TripFilter filter) {
    return Consumer(
      builder: (context, ref, child) {
        // 필터 상태 설정
        Future.microtask(() {
          ref.read(tripFilterProvider.notifier).state = filter;
        });

        final trips = ref.watch(filteredTripsProvider);

        if (trips.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(allTripsProvider.notifier).loadTrips();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(trips[index]);
            },
          ),
        );
      },
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(TripFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case TripFilter.all:
        message = '아직 여행 계획이 없습니다.\n새로운 여행을 계획해보세요!';
        icon = Icons.explore;
        break;
      case TripFilter.ongoing:
        message = '현재 진행 중인 여행이 없습니다';
        icon = Icons.flight_takeoff;
        break;
      case TripFilter.upcoming:
        message = '예정된 여행이 없습니다';
        icon = Icons.event;
        break;
      case TripFilter.completed:
        message = '완료된 여행이 없습니다';
        icon = Icons.done_all;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (filter == TripFilter.all) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createNewTrip,
              icon: const Icon(Icons.add),
              label: const Text('새 여행 계획 만들기'),
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
        ],
      ),
    );
  }

  /// 여행 계획 카드
  Widget _buildTripCard(TripPlan trip) {
    final repository = ref.read(tripRepositoryProvider);
    final status = repository.getTripStatus(trip);
    final duration = repository.calculateTripDuration(trip);

    return Dismissible(
      key: Key(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('여행 계획 삭제'),
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
      },
      onDismissed: (direction) {
        _deleteTrip(trip);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _openTripDetail(trip),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일
              if (trip.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    trip.thumbnailUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultThumbnail();
                    },
                  ),
                )
              else
                _buildDefaultThumbnail(),

              // 정보
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목과 상태
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(status),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 목적지
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.destination,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 날짜
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_dateFormat.format(trip.startDate)} - ${_dateFormat.format(trip.endDate)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$duration일',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // 진행률 (진행 중인 여행만)
                    if (status == TripStatus.ongoing) ...[
                      const SizedBox(height: 12),
                      _buildProgressBar(trip),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 기본 썸네일
  Widget _buildDefaultThumbnail() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.7),
            AppColors.primary,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.flight_takeoff,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(TripStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case TripStatus.upcoming:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        label = '예정';
        break;
      case TripStatus.ongoing:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = '진행 중';
        break;
      case TripStatus.completed:
        backgroundColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        label = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 진행률 바
  Widget _buildProgressBar(TripPlan trip) {
    final repository = ref.read(tripRepositoryProvider);
    final progress = repository.calculateProgress(trip);
    final completed = repository.getCompletedActivityCount(trip);
    final total = repository.getTotalActivityCount(trip);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}% ($completed/$total)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 새 여행 계획 만들기
  void _createNewTrip() {
    ref.read(currentEditingTripProvider.notifier).startNewTrip();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TripPlanEditScreen(),
      ),
    ).then((_) {
      // 편집 완료 후 목록 새로고침
      ref.read(allTripsProvider.notifier).loadTrips();
    });
  }

  /// 여행 상세 화면 열기
  void _openTripDetail(TripPlan trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyPlanScreen(trip: trip),
      ),
    ).then((_) {
      // 상세 화면에서 돌아온 후 목록 새로고침
      ref.read(allTripsProvider.notifier).loadTrips();
    });
  }

  /// 여행 삭제
  void _deleteTrip(TripPlan trip) {
    try {
      ref.read(allTripsProvider.notifier).deleteTrip(trip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${trip.title}이(가) 삭제되었습니다'),
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('여행 삭제 실패', e, stackTrace, 'PlanListScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 삭제에 실패했습니다'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
