import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../plan/data/models/travel_plan_model.dart';
import '../../../plan/data/providers/travel_plan_provider.dart';
import 'diary_detail_screen.dart';

/// 여행 다이어리 메인 화면
class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelPlanState = ref.watch(travelPlanListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 다이어리'),
      ),
      body: SafeArea(
        child: travelPlanState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : travelPlanState.errorMessage != null
                ? _buildErrorView(context, travelPlanState.errorMessage!)
                : travelPlanState.plans.isEmpty
                    ? _buildEmptyView(context)
                    : _buildPlanList(context, travelPlanState.plans),
      ),
    );
  }

  /// 여행 계획 목록 (상태별 카테고리화)
  Widget _buildPlanList(BuildContext context, List<TravelPlan> plans) {
    final colors = AppColors.of(context);

    // 상태별로 그룹화
    final inProgressPlans = plans.where((plan) => plan.travelStatus == TravelStatus.inProgress).toList();
    final plannedPlans = plans.where((plan) => plan.travelStatus == TravelStatus.planned).toList();
    final completedPlans = plans.where((plan) => plan.travelStatus == TravelStatus.completed).toList();

    // 각 카테고리 내에서 근접도순 정렬
    final sortedInProgress = _sortPlansByProximity(inProgressPlans);
    final sortedPlanned = _sortPlansByProximity(plannedPlans);
    final sortedCompleted = _sortPlansByProximity(completedPlans);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 진행중
        if (sortedInProgress.isNotEmpty)
          _buildCategorySection(
            context,
            title: '진행중',
            icon: Icons.flight_takeoff,
            plans: sortedInProgress,
            color: colors.primary,
          ),
        if (sortedInProgress.isNotEmpty) const SizedBox(height: 12),

        // 예정됨
        if (sortedPlanned.isNotEmpty)
          _buildCategorySection(
            context,
            title: '예정됨',
            icon: Icons.edit_calendar,
            plans: sortedPlanned,
            color: colors.textSecondary,
          ),
        if (sortedPlanned.isNotEmpty) const SizedBox(height: 12),

        // 완료됨
        if (sortedCompleted.isNotEmpty)
          _buildCategorySection(
            context,
            title: '완료됨',
            icon: Icons.done_all,
            plans: sortedCompleted,
            color: colors.textHint,
          ),
      ],
    );
  }

  /// 카테고리 섹션 위젯
  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<TravelPlan> plans,
    required Color color,
  }) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: title == '진행중' || title == '예정됨',
        shape: const Border(),  // 이 줄 추가
        collapsedShape: const Border(),  // 이 줄 추가
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: textStyles.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '여행 ${plans.length}',
          style: textStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        children: plans.map((plan) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              radius: 20,
              child: Icon(
                _getStatusIcon(plan.travelStatus),
                color: color,
                size: 18,
              ),
            ),
            title: Text(
              plan.name,
              style: textStyles.labelLarge,
            ),
            subtitle: Text(
              _formatDateRange(plan),
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailScreen(plan: plan),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// 시작날짜가 오늘과 가까운 순으로 정렬
  List<TravelPlan> _sortPlansByProximity(List<TravelPlan> plans) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sortedList = List<TravelPlan>.from(plans);
    sortedList.sort((a, b) {
      final aStart = DateTime(a.startDate.year, a.startDate.month, a.startDate.day);
      final bStart = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);

      // 오늘과의 거리 계산
      final aDiff = (aStart.difference(today).inDays).abs();
      final bDiff = (bStart.difference(today).inDays).abs();

      return aDiff.compareTo(bDiff);
    });

    return sortedList;
  }

  /// 날짜 범위 포맷: yy.mm.dd ~ yy.mm.dd (n일)
  String _formatDateRange(TravelPlan plan) {
    final dateFormat = DateFormat('yy.MM.dd');
    final startStr = dateFormat.format(plan.startDate);
    final endStr = dateFormat.format(plan.endDate);

    return '$startStr ~ $endStr (${plan.duration}일)';
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: colors.textHint,
          ),
          const SizedBox(height: 24),
          Text(
            '여행 계획이 없습니다',
            style: textStyles.heading4,
          ),
          const SizedBox(height: 12),
          Text(
            '계획 탭에서 여행 계획을\n먼저 생성해주세요',
            textAlign: TextAlign.center,
            style: textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(BuildContext context, String errorMessage) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류 발생',
              style: textStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상태별 아이콘
  IconData _getStatusIcon(TravelStatus status) {
    switch (status) {
      case TravelStatus.planned:
        return Icons.edit_calendar;
      case TravelStatus.inProgress:
        return Icons.flight_takeoff;
      case TravelStatus.completed:
        return Icons.done_all;
    }
  }
}
