import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/travel_plan_model.dart';
import '../../data/models/daily_schedule_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/daily_schedule_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/providers/travel_plan_provider.dart';
import 'add_schedule_screen.dart';
import 'edit_schedule_screen.dart';
import 'plan_timetable_screen.dart';

/// 여행 계획 상세 화면
class PlanDetailScreen extends ConsumerStatefulWidget {
  final TravelPlan plan;

  const PlanDetailScreen({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TravelPlan _editedPlan;
  late TabController _tabController;

  // Repository
  final _dailyScheduleRepository = DailyScheduleRepository();
  final _activityRepository = ActivityRepository();

  // 데이터
  List<DailySchedule> _dailySchedules = [];
  bool _isLoadingSchedules = false;

  // 폼 필드 컨트롤러
  late TextEditingController _nameController;
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _editedPlan = widget.plan;
    _initControllers();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchedules();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _editedPlan.name);
    _destinationController = TextEditingController(text: _editedPlan.destination);
    _budgetController = TextEditingController(
      text: _editedPlan.budget != null
          ? NumberFormat('#,###').format(_editedPlan.budget!)
          : '',
    );
    _descriptionController = TextEditingController(text: _editedPlan.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ============================================
  // 스케줄 로드
  // ============================================

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
    });

    try {
      final schedules =
          await _dailyScheduleRepository.getDailySchedules(widget.plan.id);

      // 각 스케줄의 activities 로드
      for (var schedule in schedules) {
        final activities =
            await _activityRepository.getActivitiesByDate(schedule.id);
        // activities를 schedule에 포함
        schedule = schedule.copyWith(activities: activities);
        final index = schedules.indexOf(schedule);
        if (index != -1) {
          schedules[index] = schedule;
        }
      }

      if (mounted) {
        setState(() {
          _dailySchedules = schedules;
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      appLogger.e('스케줄 로드 실패', error: e);
      if (mounted) {
        setState(() {
          _isLoadingSchedules = false;
        });
      }
    }
  }

  // ============================================
  // 편집 모드
  // ============================================

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // 취소: 원래 값으로 복원
        _editedPlan = widget.plan;
        _initControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  // ============================================
  // 날짜 선택
  // ============================================

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editedPlan.startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked != null) {
      setState(() {
        _editedPlan = _editedPlan.copyWith(startDate: picked);
        // 종료 날짜가 시작 날짜보다 이전이면 조정
        if (_editedPlan.endDate.isBefore(_editedPlan.startDate)) {
          _editedPlan = _editedPlan.copyWith(endDate: picked);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editedPlan.endDate,
      firstDate: _editedPlan.startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked != null) {
      setState(() {
        _editedPlan = _editedPlan.copyWith(endDate: picked);
      });
    }
  }

  // ============================================
  // 저장
  // ============================================

  Future<void> _savePlan() async {
    final budget = _budgetController.text.trim().isNotEmpty
        ? double.tryParse(_budgetController.text.trim().replaceAll(',', ''))
        : null;

    final updatedPlan = _editedPlan.copyWith(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      budget: budget,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final success = await ref.read(travelPlanListProvider.notifier).updateTravelPlan(updatedPlan);

    if (success && mounted) {
      setState(() {
        _editedPlan = updatedPlan;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 계획이 수정되었습니다.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 계획 수정에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ============================================
  // 삭제
  // ============================================

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행 계획 삭제'),
        content: Text('${_editedPlan.name} 계획을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(travelPlanListProvider.notifier).deleteTravelPlan(_editedPlan.id);

      if (success && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('여행 계획이 삭제되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedPlan.name),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _savePlan,
              child: const Text(
                '저장',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePlan,
              tooltip: '삭제',
            ),
          ],
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: '취소',
            ),
        ],
        bottom: _isEditing
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '정보'),
                  Tab(text: '일정'),
                  Tab(text: '타임테이블'),
                ],
              ),
      ),
      body: _isEditing
          ? _buildInfoTab()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildScheduleListTab(),
                PlanTimetableScreen(
                  plan: _editedPlan,
                  dailySchedules: _dailySchedules,
                ),
              ],
            ),
    );
  }

  /// 정보 탭 (기존 내용)
  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 상태 배지
        _buildStatusBadge(),
        const SizedBox(height: 24),

        // 여행명
        _buildInfoSection(
          icon: Icons.flight_takeoff,
          label: '여행명',
          child: _isEditing
              ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '여행명 입력',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  _editedPlan.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 20),

        // 목적지
        _buildInfoSection(
          icon: Icons.location_on,
          label: '목적지',
          child: _isEditing
              ? TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: '목적지 입력',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  _editedPlan.destination,
                  style: AppTextStyles.bodyLarge,
                ),
        ),
        const SizedBox(height: 20),

        // 기간
        _buildInfoSection(
          icon: Icons.calendar_today,
          label: '기간',
          child: _isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableDateField(
                      label: '시작 날짜',
                      date: _editedPlan.startDate,
                      onTap: _selectStartDate,
                    ),
                    const SizedBox(height: 12),
                    _buildEditableDateField(
                      label: '종료 날짜',
                      date: _editedPlan.endDate,
                      onTap: _selectEndDate,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateRange(),
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_editedPlan.duration}일',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 20),

        // 예산
        _buildInfoSection(
          icon: Icons.attach_money,
          label: '예산',
          child: _isEditing
              ? TextField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    hintText: '예산 입력 (선택)',
                    border: OutlineInputBorder(),
                    suffixText: '원',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                )
              : Text(
                  _editedPlan.budget != null
                      ? '${NumberFormat('#,###').format(_editedPlan.budget!)}원'
                      : '설정 안 함',
                  style: AppTextStyles.bodyLarge,
                ),
        ),
        const SizedBox(height: 20),

        // 설명
        if (_editedPlan.description != null || _isEditing)
          _buildInfoSection(
            icon: Icons.description,
            label: '설명',
            child: _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: '설명 입력 (선택)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  )
                : Text(
                    _editedPlan.description ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
          ),
      ],
    );
  }

  /// 상태 배지
  Widget _buildStatusBadge() {
    final status = _editedPlan.travelStatus;
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case TravelStatus.planned:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        label = '계획됨';
        icon = Icons.event_note;
        break;
      case TravelStatus.inProgress:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = '진행 중';
        icon = Icons.flight;
        break;
      case TravelStatus.completed:
        backgroundColor = AppColors.textHint.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        label = '완료';
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.titleSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 섹션
  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// 편집 가능한 날짜 필드
  Widget _buildEditableDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateFormatter = DateFormat('yyyy년 M월 d일');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              dateFormatter.format(date),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// 일정 탭
  Widget _buildScheduleListTab() {
    if (_isLoadingSchedules) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dailySchedules.isEmpty) {
      return const Center(
        child: Text(
          '아직 일정이 없습니다.\n날짜를 선택하여 일정을 추가해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dailySchedules.length,
        itemBuilder: (context, index) {
          final schedule = _dailySchedules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 헤더
                  Row(
                    children: [
                      Text(
                        '${schedule.date.year}년 ${schedule.date.month}월 ${schedule.date.day}일',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _addActivity(schedule.date),
                        icon: const Icon(Icons.add),
                        tooltip: '일정 추가',
                      ),
                    ],
                  ),
                  const Divider(),

                  // 활동 목록
                  if (schedule.activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '일정 없음',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...schedule.sortedActivities.map((activity) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _getActivityIcon(activity.type),
                          color: _getActivityColor(activity.type),
                        ),
                        title: Text(activity.title),
                        subtitle: Text(
                          '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _editActivity(activity),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Activity 타입별 아이콘
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'flight':
        return Icons.flight;
      case 'accommodation':
        return Icons.hotel;
      case 'tour':
        return Icons.place;
      case 'restaurant':
        return Icons.restaurant;
      case 'activity':
        return Icons.local_activity;
      default:
        return Icons.event;
    }
  }

  /// Activity 타입별 색상
  Color _getActivityColor(String type) {
    switch (type) {
      case 'flight':
        return const Color(0xFF2196F3);
      case 'accommodation':
        return const Color(0xFF4CAF50);
      case 'tour':
        return const Color(0xFFFF9800);
      case 'restaurant':
        return const Color(0xFFE91E63);
      case 'activity':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  /// 시간 포맷
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 일정 추가
  Future<void> _addActivity(DateTime date) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(
          date: date,
          travelPlanId: widget.plan.id,
        ),
      ),
    );

    // 일정이 추가되었으면 새로고침
    if (result == true) {
      await _loadSchedules();
    }
  }

  /// 일정 편집
  Future<void> _editActivity(Activity activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScheduleScreen(
          activity: activity,
          travelPlanId: widget.plan.id,
        ),
      ),
    );

    // 일정이 수정되었으면 새로고침
    if (result == true) {
      await _loadSchedules();
    }
  }

  /// 날짜 범위 포맷
  String _formatDateRange() {
    final formatter = DateFormat('yyyy년 M월 d일');
    final start = formatter.format(_editedPlan.startDate);
    final end = formatter.format(_editedPlan.endDate);
    return '$start ~ $end';
  }
}

/// 천 단위 구분 기호 포맷터
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }

    final formattedText = _formatter.format(number);
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
