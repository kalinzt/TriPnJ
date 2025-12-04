import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 여행 계획 목록
  Widget _buildPlanList(BuildContext context, List<TravelPlan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(
                _getStatusIcon(plan.travelStatus),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              plan.name,
              style: AppTextStyles.titleMedium,
            ),
            subtitle: Text(
              '${plan.destination} · ${plan.duration}일',
              style: AppTextStyles.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailScreen(plan: plan),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
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
            '계획 탭에서 여행 계획을\n먼저 생성해주세요',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(BuildContext context, String errorMessage) {
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
