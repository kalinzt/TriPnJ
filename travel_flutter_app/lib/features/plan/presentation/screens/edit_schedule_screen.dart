import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/daily_schedule_repository.dart';
import '../../../../core/services/directions_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../plan/data/models/route_option_model.dart';
import '../widgets/route_info_card.dart';

/// 스케줄 편집 화면
class EditScheduleScreen extends StatefulWidget {
  /// 편집할 Activity
  final Activity activity;

  /// 부모 TravelPlan ID
  final String travelPlanId;

  const EditScheduleScreen({
    required this.activity,
    required this.travelPlanId,
    super.key,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Repository
  final _activityRepository = ActivityRepository();
  final _dailyScheduleRepository = DailyScheduleRepository();
  final _directionsService = DirectionsService();

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _departureController;
  late final TextEditingController _arrivalController;
  late final TextEditingController _transportationController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  // 상태
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedType;
  TravelMode _selectedTravelMode = TravelMode.transit;

  // 경로 검색 상태
  bool _isSearching = false;
  List<RouteOption>? _routeOptions;
  RouteOption? _selectedRoute;

  @override
  void initState() {
    super.initState();

    // 기존 Activity 데이터로 초기화
    _titleController = TextEditingController(text: widget.activity.title);
    _departureController = TextEditingController(
        text: widget.activity.departureLocation ?? '');
    _arrivalController =
        TextEditingController(text: widget.activity.arrivalLocation ?? '');
    _transportationController =
        TextEditingController(text: widget.activity.transportation ?? '');
    _costController = TextEditingController(text: widget.activity.cost ?? '');
    _notesController =
        TextEditingController(text: widget.activity.notes ?? '');

    _selectedDate = widget.activity.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.activity.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.activity.endTime);
    _selectedType = widget.activity.type;
    _selectedRoute = widget.activity.selectedRoute; // 저장된 경로 로드
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
      initialDate: _selectedDate,
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
      _selectedRoute = null;
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
      _selectedRoute = route;

      // 교통편 자동 채우기
      _transportationController.text = route.vehicleInfo ?? '';

      // 종료 시간 자동 계산
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime =
          startDateTime.add(Duration(minutes: route.durationMinutes));

      _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
    });

    appLogger.i('경로 선택: ${route.routeId}, 소요 시간: ${route.durationMinutes}분');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('경로가 선택되었습니다')),
    );
  }

  /// Activity 수정
  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 시작/종료 시간 검증
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
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
      appLogger.i('Activity 수정 시작');

      // Activity 수정 (copyWith 사용)
      final updatedActivity = widget.activity.copyWith(
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
        selectedRoute: _selectedRoute, // 선택된 경로 저장
      );

      await _activityRepository.updateActivity(updatedActivity);
      appLogger.i('Activity 수정 완료: ${updatedActivity.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스케줄이 수정되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      appLogger.e('Activity 수정 실패: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  /// Activity 삭제
  Future<void> _deleteActivity() async {
    // 삭제 확인 대화상자
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스케줄 삭제'),
        content: const Text('이 스케줄을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      appLogger.i('Activity 삭제 시작: ${widget.activity.id}');

      await _activityRepository.deleteActivity(widget.activity.id);
      appLogger.i('Activity 삭제 완료');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스케줄이 삭제되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      appLogger.e('Activity 삭제 실패: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄 편집'),
        actions: [
          IconButton(
            onPressed: _deleteActivity,
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
          ),
          TextButton(
            onPressed: _updateActivity,
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // 날짜 선택
            ListTile(
              title: const Text('날짜'),
              subtitle: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
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
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: '스케줄 타입',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'flight', child: Text('비행')),
                DropdownMenuItem(value: 'transportation', child: Text('교통')),
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
              initialValue: _selectedTravelMode,
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
            if (_selectedRoute != null) ...[
              const Text(
                '선택된 경로',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RouteInfoCard(
                route: _selectedRoute!,
                onSelect: null, // 이미 선택된 경로이므로 선택 버튼 숨김
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedRoute = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('다른 경로 선택'),
              ),
              const SizedBox(height: 16),
            ] else if (_routeOptions != null && _routeOptions!.isNotEmpty) ...[
              const Text(
                '경로 옵션',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(_routeOptions!.map((route) => RouteInfoCard(
                    route: route,
                    onSelect: () => _selectRoute(route),
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
                    onPressed: _updateActivity,
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
    );
  }
}
