import 'package:flutter/material.dart';
import '../../data/models/travel_plan_model.dart';
import '../../data/models/daily_schedule_model.dart';
import '../../data/models/activity_model.dart';

/// 타임테이블 뷰 화면
class PlanTimetableScreen extends StatefulWidget {
  final TravelPlan plan;
  final List<DailySchedule> dailySchedules;

  const PlanTimetableScreen({
    required this.plan,
    required this.dailySchedules,
    super.key,
  });

  @override
  State<PlanTimetableScreen> createState() => _PlanTimetableScreenState();
}

class _PlanTimetableScreenState extends State<PlanTimetableScreen> {
  // 뷰 모드: true = 하루 보기, false = 전체 보기
  bool _isDailyView = true;

  // 선택된 날짜 (하루 보기 모드)
  late DateTime _selectedDate;

  // 시간 설정
  static const int _startHour = 6;
  static const int _endHour = 24;
  static const double _pixelsPerHour = 60.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.plan.startDate;
  }

  /// 이전 날짜로 이동
  void _previousDay() {
    if (_selectedDate.isAfter(widget.plan.startDate)) {
      setState(() {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      });
    }
  }

  /// 다음 날짜로 이동
  void _nextDay() {
    if (_selectedDate.isBefore(widget.plan.endDate)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  /// 뷰 모드 전환
  void _toggleViewMode() {
    setState(() {
      _isDailyView = !_isDailyView;
    });
  }

  /// 타입별 색상
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

  /// 타입별 아이콘
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

  /// Activity 상세 팝업
  void _showActivityDetail(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getActivityIcon(activity.type),
                color: _getActivityColor(activity.type)),
            const SizedBox(width: 8),
            Expanded(child: Text(activity.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('시간',
                  '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}'),
              if (activity.departureLocation != null)
                _buildDetailRow('출발지', activity.departureLocation!),
              if (activity.arrivalLocation != null)
                _buildDetailRow('도착지', activity.arrivalLocation!),
              if (activity.transportation != null)
                _buildDetailRow('교통편', activity.transportation!),
              if (activity.cost != null) _buildDetailRow('비용', activity.cost!),
              if (activity.notes != null)
                _buildDetailRow('비고', activity.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 토글 버튼
        _buildToggleButtons(),
        const Divider(height: 1),

        // 뷰 내용
        Expanded(
          child: _isDailyView ? _buildDailyView() : _buildOverallView(),
        ),
      ],
    );
  }

  /// 토글 버튼
  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('하루 보기', _isDailyView),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton('전체 보기', !_isDailyView),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: isSelected ? null : _toggleViewMode,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }

  /// 하루 보기
  Widget _buildDailyView() {
    // 선택된 날짜의 DailySchedule 찾기
    DailySchedule? schedule;
    for (var s in widget.dailySchedules) {
      if (_isSameDay(s.date, _selectedDate)) {
        schedule = s;
        break;
      }
    }

    return Column(
      children: [
        // 날짜 선택
        _buildDateSelector(),
        const Divider(height: 1),

        // 타임라인
        Expanded(
          child: schedule != null && schedule.activities.isNotEmpty
              ? _buildTimeline(schedule.sortedActivities)
              : const Center(
                  child: Text('이 날짜에는 일정이 없습니다'),
                ),
        ),
      ],
    );
  }

  /// 날짜 선택기
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed:
                _selectedDate.isAfter(widget.plan.startDate) ? _previousDay : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _selectedDate.isBefore(widget.plan.endDate) ? _nextDay : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  /// 타임라인 (하루 보기)
  Widget _buildTimeline(List<Activity> activities) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: (_endHour - _startHour) * _pixelsPerHour,
          child: Stack(
            children: [
              // 시간 눈금
              _buildTimeMarkers(),

              // Activity 블록들
              ...activities.map((activity) => _buildActivityBlock(activity)),
            ],
          ),
        ),
      ],
    );
  }

  /// 시간 눈금
  Widget _buildTimeMarkers() {
    return Column(
      children: List.generate(_endHour - _startHour, (index) {
        final hour = _startHour + index;
        return SizedBox(
          height: _pixelsPerHour,
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Activity 블록 (하루 보기)
  Widget _buildActivityBlock(Activity activity) {
    // 시작 위치 계산
    final startMinutes = activity.startTime.hour * 60 + activity.startTime.minute;
    // ignore: prefer_const_declarations
    final baseMinutes = _startHour * 60;
    final topOffset = ((startMinutes - baseMinutes) / 60) * _pixelsPerHour;

    // 높이 계산
    final durationMinutes =
        activity.endTime.difference(activity.startTime).inMinutes;
    final height = (durationMinutes / 60) * _pixelsPerHour;

    return Positioned(
      left: 70,
      right: 0,
      top: topOffset,
      child: GestureDetector(
        onTap: () => _showActivityDetail(activity),
        child: Container(
          height: height,
          margin: const EdgeInsets.only(right: 8, bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getActivityIcon(activity.type),
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (height > 40) ...[
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
              if (height > 60 &&
                  activity.departureLocation != null &&
                  activity.arrivalLocation != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${activity.departureLocation} → ${activity.arrivalLocation}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 전체 보기
  Widget _buildOverallView() {
    final allDates = widget.plan.allDates;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allDates.length,
      itemBuilder: (context, index) {
        final date = allDates[index];

        // 해당 날짜의 DailySchedule 찾기
        DailySchedule? schedule;
        for (var s in widget.dailySchedules) {
          if (_isSameDay(s.date, date)) {
            schedule = s;
            break;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 헤더
                Text(
                  '${date.year}/${date.month}/${date.day}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // 압축된 타임라인
                if (schedule != null && schedule.activities.isNotEmpty)
                  _buildCompressedTimeline(schedule.sortedActivities)
                else
                  const Text(
                    '일정 없음',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 압축된 타임라인 (전체 보기)
  Widget _buildCompressedTimeline(List<Activity> activities) {
    const compressedPixelsPerHour = 20.0;

    return SizedBox(
      height: (_endHour - _startHour) * compressedPixelsPerHour,
      child: Stack(
        children: [
          // 시간 눈금 (압축)
          Row(
            children: List.generate(_endHour - _startHour + 1, (index) {
              final hour = _startHour + index;
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    hour.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),

          // Activity 블록들 (압축)
          ...activities.map((activity) =>
              _buildCompressedActivityBlock(activity, compressedPixelsPerHour)),
        ],
      ),
    );
  }

  /// Activity 블록 (압축, 전체 보기)
  Widget _buildCompressedActivityBlock(
      Activity activity, double pixelsPerHour) {
    final startMinutes = activity.startTime.hour * 60 + activity.startTime.minute;
    // ignore: prefer_const_declarations
    final baseMinutes = _startHour * 60;
    // ignore: prefer_const_declarations
    final totalMinutes = (_endHour - _startHour) * 60;

    final leftOffset = ((startMinutes - baseMinutes) / totalMinutes);
    final durationMinutes =
        activity.endTime.difference(activity.startTime).inMinutes;
    final width = (durationMinutes / totalMinutes);

    return Positioned(
      left: leftOffset * (MediaQuery.of(context).size.width - 64),
      top: 24,
      child: GestureDetector(
        onTap: () => _showActivityDetail(activity),
        child: Container(
          width: width * (MediaQuery.of(context).size.width - 64),
          height: 30,
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(
              _getActivityIcon(activity.type),
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
