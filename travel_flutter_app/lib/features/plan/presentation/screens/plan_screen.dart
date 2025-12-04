import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/travel_plan_model.dart';
import '../../data/providers/travel_plan_provider.dart';
import '../widgets/travel_plan_card.dart';
import 'add_plan_screen.dart';
import 'plan_detail_screen.dart';

/// 여행 계획 화면 - 목록 뷰
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {

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
      body: travelPlanState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : travelPlanState.errorMessage != null
              ? _buildErrorView(travelPlanState.errorMessage!)
              : _buildPlanList(travelPlanState.plans),
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


  /// 여행 계획 목록 빌드
  Widget _buildPlanList(List<TravelPlan> allPlans) {
    if (allPlans.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPlans.length,
      itemBuilder: (context, index) {
        final plan = allPlans[index];
        return TravelPlanCard(
          plan: plan,
          onTap: () => _navigateToDetail(plan),
          onDelete: () => _deletePlan(plan.id),
        );
      },
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
            '우측 하단의 + 버튼을 눌러\n새 여행 계획을 추가해보세요',
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
