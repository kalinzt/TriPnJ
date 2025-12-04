import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/recommendation_analytics.dart';
import '../../data/services/performance_monitor.dart';
import '../../data/models/analytics_metrics.dart';

/// 추천 시스템 통계 대시보드 화면 (관리자용)
class RecommendationStatsScreen extends ConsumerStatefulWidget {
  const RecommendationStatsScreen({super.key});

  @override
  ConsumerState<RecommendationStatsScreen> createState() => _RecommendationStatsScreenState();
}

class _RecommendationStatsScreenState extends ConsumerState<RecommendationStatsScreen> {
  final _analytics = RecommendationAnalytics();
  final _performanceMonitor = PerformanceMonitor();

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 시스템 통계'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          _buildTab('개요', 0),
          _buildTab('성능', 1),
          _buildTab('에러', 2),
          _buildTab('설정', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildPerformanceTab();
      case 2:
        return _buildErrorsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox();
    }
  }

  // ========== 개요 탭 ==========

  Widget _buildOverviewTab() {
    final metrics = _analytics.collectMetrics();
    final dailyReport = _analytics.generateDailyReport();

    if (metrics.isEmpty) {
      return const Center(
        child: Text('아직 수집된 데이터가 없습니다.'),
      );
    }

    final daily = metrics['daily'] as Map<String, dynamic>? ?? {};
    final insights = (dailyReport['insights'] as List?)?.cast<String>() ?? [];
    final recommendations = (dailyReport['recommendations'] as List?)?.cast<String>() ?? [];
    final topActions = (dailyReport['top_actions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘의 주요 지표
          _buildSectionTitle('오늘의 주요 지표'),
          const SizedBox(height: 12),
          _buildMetricsGrid(daily),
          const SizedBox(height: 24),

          // 인사이트
          if (insights.isNotEmpty) ...[
            _buildSectionTitle('인사이트'),
            const SizedBox(height: 12),
            ...insights.map((insight) => _buildInsightCard(insight)),
            const SizedBox(height: 24),
          ],

          // 개선 권장사항
          if (recommendations.isNotEmpty) ...[
            _buildSectionTitle('개선 권장사항'),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => _buildRecommendationCard(rec)),
            const SizedBox(height: 24),
          ],

          // 상위 사용자 액션
          if (topActions.isNotEmpty) ...[
            _buildSectionTitle('상위 사용자 액션'),
            const SizedBox(height: 12),
            _buildTopActionsTable(topActions),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> daily) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          '추천 생성',
          daily['recommendations']?.toString() ?? '0',
          Icons.recommend,
          Colors.blue,
        ),
        _buildMetricCard(
          '사용자 액션',
          daily['user_actions']?.toString() ?? '0',
          Icons.touch_app,
          Colors.green,
        ),
        _buildMetricCard(
          '평균 점수',
          daily['avg_score']?.toString() ?? '0.00',
          Icons.star,
          Colors.amber,
        ),
        _buildMetricCard(
          'API 호출',
          daily['api_calls']?.toString() ?? '0',
          Icons.cloud,
          Colors.purple,
        ),
        _buildMetricCard(
          'API 실패율',
          daily['api_failure_rate']?.toString() ?? '0%',
          Icons.error_outline,
          Colors.red,
        ),
        _buildMetricCard(
          '캐시 히트율',
          daily['cache_hit_rate']?.toString() ?? '0%',
          Icons.storage,
          Colors.teal,
        ),
        _buildMetricCard(
          '평균 응답시간',
          '${daily['avg_response_time_ms']?.toString() ?? '0'}ms',
          Icons.speed,
          Colors.orange,
        ),
        _buildMetricCard(
          'CTR',
          daily['ctr']?.toString() ?? '0%',
          Icons.ads_click,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
        title: Text(insight),
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.tips_and_updates, color: Colors.blue),
        title: Text(recommendation),
      ),
    );
  }

  Widget _buildTopActionsTable(List<Map<String, dynamic>> topActions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(flex: 2, child: Text('액션', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('횟수', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('비율', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            ...topActions.map((action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(_getActionLabel(action['action'] as String? ?? '')),
                  ),
                  Expanded(child: Text(action['count']?.toString() ?? '0')),
                  Expanded(child: Text(action['percentage']?.toString() ?? '0%')),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'visit':
        return '방문';
      case 'like':
        return '좋아요';
      case 'reject':
        return '거절';
      case 'add_to_plan':
        return '계획 추가';
      default:
        return action;
    }
  }

  // ========== 성능 탭 ==========

  Widget _buildPerformanceTab() {
    final stats = _performanceMonitor.getAllPerformanceStats();

    if (stats.isEmpty) {
      return const Center(
        child: Text('아직 수집된 성능 데이터가 없습니다.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('작업별 성능 통계'),
        const SizedBox(height: 16),
        ...stats.entries.map((entry) => _buildPerformanceCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildPerformanceCard(String operation, Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getOperationLabel(operation),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildPerformanceRow('측정 횟수', stats['count']?.toString() ?? '0'),
            _buildPerformanceRow('평균', '${stats['avg_ms'] ?? '0'}ms'),
            _buildPerformanceRow('최소', '${stats['min_ms'] ?? '0'}ms'),
            _buildPerformanceRow('최대', '${stats['max_ms'] ?? '0'}ms'),
            _buildPerformanceRow('P50', '${stats['p50_ms'] ?? '0'}ms'),
            _buildPerformanceRow('P95', '${stats['p95_ms'] ?? '0'}ms'),
            _buildPerformanceRow('P99', '${stats['p99_ms'] ?? '0'}ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getOperationLabel(String operation) {
    switch (operation) {
      case 'recommendation_generation':
        return '추천 생성';
      case 'algorithm_execution':
        return '알고리즘 실행';
      case 'api_call':
        return 'API 호출';
      case 'cache_operation':
        return '캐시 작업';
      case 'database_query':
        return '데이터베이스 쿼리';
      case 'data_processing':
        return '데이터 처리';
      default:
        return operation;
    }
  }

  // ========== 에러 탭 ==========

  Widget _buildErrorsTab() {
    final errors = _analytics.getRecentErrors(limit: 50);

    if (errors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('최근 에러가 없습니다!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return _buildErrorCard(error);
      },
    );
  }

  Widget _buildErrorCard(ErrorLog error) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: Text(error.errorType),
        subtitle: Text(
          error.timestamp.toString().substring(0, 19),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildErrorDetail('위치', error.context),
                const SizedBox(height: 8),
                _buildErrorDetail('메시지', error.message),
                if (error.additionalInfo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildErrorDetail('추가 정보', error.additionalInfo.toString()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  // ========== 설정 탭 ==========

  Widget _buildSettingsTab() {
    final metrics = _analytics.collectMetrics();
    final totalErrors = metrics['total_errors_logged'] ?? 0;
    final totalPerformance = metrics['total_performance_metrics'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('캐시 관리'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('에러 로그'),
                subtitle: Text('$totalErrors개 저장됨'),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('성능 메트릭'),
                subtitle: Text('$totalPerformance개 저장됨'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('데이터 관리'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('오래된 데이터 정리'),
                subtitle: const Text('30일 이전 데이터 삭제'),
                trailing: ElevatedButton(
                  onPressed: _cleanupOldData,
                  child: const Text('정리'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('모든 데이터 초기화'),
                subtitle: const Text('주의: 복구할 수 없습니다'),
                trailing: ElevatedButton(
                  onPressed: _clearAllData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('초기화'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _cleanupOldData() async {
    final confirmed = await _showConfirmDialog(
      '오래된 데이터를 정리하시겠습니까?',
      '30일 이전의 메트릭 데이터가 삭제됩니다.',
    );

    if (confirmed == true && mounted) {
      await _analytics.cleanupOldData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오래된 데이터를 정리했습니다.')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      '모든 데이터를 초기화하시겠습니까?',
      '이 작업은 복구할 수 없습니다.',
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      await _analytics.clearAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 데이터를 초기화했습니다.')),
        );
        setState(() {});
      }
    }
  }

  Future<bool?> _showConfirmDialog(
    String title,
    String message, {
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
