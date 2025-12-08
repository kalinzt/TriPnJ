import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/travel_plan_model.dart';
import '../providers/travel_plan_provider.dart';
import '../widgets/travel_plan_card.dart';
import 'add_plan_screen.dart';
import 'plan_detail_screen.dart';

/// 여행 계획 화면 - 탭 구조로 상태별 분리
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('📅 여행 계획'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.titleSmall,
          tabs: const [
            Tab(text: '예정/진행'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlannedAndOngoingTab(),
          _buildCompletedTab(),
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

  /// 예정/진행 중인 여행 탭
  Widget _buildPlannedAndOngoingTab() {
    return Consumer(
      builder: (context, ref, child) {
        final plannedAndOngoingAsync = ref.watch(plannedAndOngoingTravelsProvider);

        return plannedAndOngoingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorView('$error'),
          data: (travels) {
            if (travels.isEmpty) {
              return _buildEmptyView(
                icon: Icons.beach_access,
                title: '예정된 여행이 없습니다',
                subtitle: '우측 하단의 + 버튼을 눌러\n새 여행 계획을 추가해보세요',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(plannedAndOngoingTravelsProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: travels.length,
                itemBuilder: (context, index) {
                  final travel = travels[index];
                  return TravelPlanCard(
                    plan: travel,
                    onTap: () => _navigateToDetail(travel),
                    onDelete: () => _deletePlan(travel.id),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 완료된 여행 탭
  Widget _buildCompletedTab() {
    return Consumer(
      builder: (context, ref, child) {
        final completedAsync = ref.watch(completedTravelsProvider);

        return completedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorView('$error'),
          data: (travels) {
            if (travels.isEmpty) {
              return _buildEmptyView(
                icon: Icons.check_circle_outline,
                title: '완료된 여행이 없습니다',
                subtitle: '여행을 마치면 이곳에 표시됩니다',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(completedTravelsProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: travels.length,
                itemBuilder: (context, index) {
                  final travel = travels[index];
                  return TravelPlanCard(
                    plan: travel,
                    onTap: () => _navigateToDetail(travel),
                    onDelete: () => _deletePlan(travel.id),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
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
                ref.invalidate(plannedAndOngoingTravelsProvider);
                ref.invalidate(completedTravelsProvider);
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
      // 추가 성공 시 목록 새로고침
      ref.invalidate(plannedAndOngoingTravelsProvider);
      ref.invalidate(completedTravelsProvider);
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
      ref.invalidate(plannedAndOngoingTravelsProvider);
      ref.invalidate(completedTravelsProvider);
    }
  }

  /// 여행 계획 삭제
  Future<void> _deletePlan(String id) async {
    await ref.read(travelPlanRepositoryProvider).deleteTravelPlan(id);
    // 삭제 후 목록 새로고침
    ref.invalidate(plannedAndOngoingTravelsProvider);
    ref.invalidate(completedTravelsProvider);
  }
}
