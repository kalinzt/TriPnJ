import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/daily_schedule_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/daily_schedule_repository.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/directions_service.dart';
import '../../../plan/data/models/route_option_model.dart';

/// 스케줄 추가 화면
class AddScheduleScreen extends StatefulWidget {
  /// 해당 날짜
  final DateTime date;

  /// 부모 TravelPlan ID
  final String travelPlanId;

  const AddScheduleScreen({
    required this.date,
    required this.travelPlanId,
    super.key,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Repository
  final _activityRepository = ActivityRepository();
  final _dailyScheduleRepository = DailyScheduleRepository();
  final _directionsService = DirectionsService();

  // Controllers
  final _titleController = TextEditingController();
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _transportationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  // 상태
  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedType = 'flight';
  TravelMode _selectedTravelMode = TravelMode.transit;

  // 경로 검색 상태
  bool _isSearching = false;
  List<RouteOption>? _routeOptions;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _transportationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 시간 선택
  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  /// 경로 검색
  Future<void> _searchRoutes() async {
    final departure = _departureController.text.trim();
    final arrival = _arrivalController.text.trim();

    if (departure.isEmpty || arrival.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출발지와 도착지를 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _routeOptions = null;
    });

    appLogger.i('경로 검색 시작: $departure → $arrival (${_selectedTravelMode.name})');

    try {
      final routes = await _directionsService.searchRoutes(
        departure,
        arrival,
        mode: _selectedTravelMode,
      );

      setState(() {
        _routeOptions = routes;
        _isSearching = false;
      });

      if (routes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('경로를 찾을 수 없습니다')),
          );
        }
      } else {
        appLogger.i('경로 검색 완료: ${routes.length}개 옵션');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      appLogger.e('경로 검색 에러: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로 검색 실패: $e')),
        );
      }
    }
  }

  /// 경로 옵션 선택
  void _selectRoute(RouteOption route) {
    setState(() {
      // 교통편 자동 채우기
      _transportationController.text = route.vehicleInfo ?? '';

      // 종료 시간 자동 계산
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime =
          startDateTime.add(Duration(minutes: route.durationMinutes));

      _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);

      // 비고에 상세 정보 추가
      if (route.details != null) {
        _notesController.text = route.details!;
      }
    });

    appLogger.i('경로 선택: ${route.routeId}, 소요 시간: ${route.durationMinutes}분');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('경로가 선택되었습니다')),
    );
  }

  /// Activity 저장
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜를 선택해주세요')),
      );
      return;
    }

    // 시작/종료 시간 검증
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시간은 시작 시간 이후여야 합니다')),
      );
      return;
    }

    try {
      appLogger.i('Activity 저장 시작');

      // DailySchedule 조회 또는 생성
      final schedules =
          await _dailyScheduleRepository.getDailySchedules(widget.travelPlanId);
      DailySchedule? dailySchedule;

      for (var schedule in schedules) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        final targetDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );

        if (scheduleDate.isAtSameMomentAs(targetDate)) {
          dailySchedule = schedule;
          break;
        }
      }

      // DailySchedule이 없으면 새로 생성
      if (dailySchedule == null) {
        dailySchedule = DailySchedule(
          id: _uuid.v4(),
          travelPlanId: widget.travelPlanId,
          date: _selectedDate!,
          activities: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _dailyScheduleRepository.addDailySchedule(dailySchedule);
        appLogger.i('새 DailySchedule 생성: ${dailySchedule.id}');
      }

      // Activity 생성
      final activity = Activity(
        id: _uuid.v4(),
        dailyScheduleId: dailySchedule.id,
        type: _selectedType,
        title: _titleController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        departureLocation: _departureController.text.trim().isEmpty
            ? null
            : _departureController.text.trim(),
        arrivalLocation: _arrivalController.text.trim().isEmpty
            ? null
            : _arrivalController.text.trim(),
        transportation: _transportationController.text.trim().isEmpty
            ? null
            : _transportationController.text.trim(),
        cost: _costController.text.trim().isEmpty
            ? null
            : _costController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        displayOrder: 0, // 자동으로 재계산됨
      );

      await _activityRepository.addActivity(activity);
      appLogger.i('Activity 저장 완료: ${activity.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스케줄이 추가되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      appLogger.e('Activity 저장 실패: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄 추가'),
        actions: [
          TextButton(
            onPressed: _saveActivity,
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 날짜 선택
            ListTile(
              title: const Text('날짜'),
              subtitle: Text(
                _selectedDate != null
                    ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                    : '날짜를 선택하세요',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const Divider(),

            // 시작 시간
            ListTile(
              title: const Text('시작 시간'),
              subtitle: Text(_startTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(true),
            ),

            // 종료 시간
            ListTile(
              title: const Text('종료 시간'),
              subtitle: Text(_endTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(false),
            ),
            const Divider(),

            // 스케줄 타입
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '스케줄 타입',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'flight', child: Text('비행')),
                DropdownMenuItem(value: 'accommodation', child: Text('숙소')),
                DropdownMenuItem(value: 'tour', child: Text('관광')),
                DropdownMenuItem(value: 'restaurant', child: Text('식당')),
                DropdownMenuItem(value: 'activity', child: Text('액티비티')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 제목
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 출발지
            TextFormField(
              controller: _departureController,
              decoration: const InputDecoration(
                labelText: '출발지',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 도착지
            TextFormField(
              controller: _arrivalController,
              decoration: const InputDecoration(
                labelText: '도착지',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 이동 수단 모드 선택
            DropdownButtonFormField<TravelMode>(
              value: _selectedTravelMode,
              decoration: const InputDecoration(
                labelText: '이동 수단',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: TravelMode.transit, child: Text('대중교통')),
                DropdownMenuItem(
                    value: TravelMode.driving, child: Text('자동차')),
                DropdownMenuItem(value: TravelMode.walking, child: Text('도보')),
                DropdownMenuItem(
                    value: TravelMode.bicycling, child: Text('자전거')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTravelMode = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 경로 검색 버튼
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchRoutes,
              icon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? '검색 중...' : '경로 검색'),
            ),
            const SizedBox(height: 16),

            // 경로 검색 결과
            if (_routeOptions != null && _routeOptions!.isNotEmpty) ...[
              const Text(
                '경로 옵션',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(_routeOptions!.map((route) => Card(
                    child: ListTile(
                      title: Text(route.vehicleInfo ?? '정보 없음'),
                      subtitle: Text(
                        '소요 시간: ${route.durationMinutes}분\n'
                        '거리: ${route.distance}\n'
                        '${route.details ?? ""}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _selectRoute(route),
                        child: const Text('선택'),
                      ),
                    ),
                  ))),
              const SizedBox(height: 16),
            ],

            // 교통편 (자동 또는 수동)
            TextFormField(
              controller: _transportationController,
              decoration: const InputDecoration(
                labelText: '교통편',
                border: OutlineInputBorder(),
                hintText: '경로 선택 시 자동 입력',
              ),
            ),
            const SizedBox(height: 16),

            // 비용
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: '비용',
                border: OutlineInputBorder(),
                hintText: '예: 100,000원',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  // 숫자, 쉼표, 원화 기호만 허용
                  final regex = RegExp(r'^[\d,]+원?$|^무료$');
                  if (!regex.hasMatch(value.trim())) {
                    return '올바른 형식으로 입력해주세요 (예: 100,000원)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 비고
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '비고',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveActivity,
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
