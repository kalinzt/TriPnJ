import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/directions_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/trip_plan.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../data/models/route_option_model.dart';
import '../../data/providers/trip_provider.dart';

/// 활동 추가/편집 화면
class AddActivityScreen extends ConsumerStatefulWidget {
  final String tripId;
  final DateTime date;
  final Activity? activity; // null이면 새 활동, 있으면 수정

  const AddActivityScreen({
    super.key,
    required this.tripId,
    required this.date,
    this.activity,
  });

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  final _costController = TextEditingController();
  final _reservationController = TextEditingController();
  final _durationController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Place? _selectedPlace;
  ActivityType _selectedType = ActivityType.visit;

  bool _isLoading = false;

  // 경로 검색 관련
  final DirectionsService _directionsService = DirectionsService();
  RouteOption? _selectedRoute;
  List<RouteOption> _routeOptions = [];
  bool _isSearchingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _costController.dispose();
    _reservationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// 활동 데이터 로드 (수정 모드일 때)
  void _loadActivityData() {
    if (widget.activity != null) {
      final activity = widget.activity!;
      _titleController.text = activity.title ?? '';
      _memoController.text = activity.memo ?? '';
      _costController.text = activity.estimatedCost != null
          ? activity.estimatedCost!.toStringAsFixed(0)
          : '';
      _reservationController.text = activity.reservationInfo ?? '';
      _durationController.text = activity.durationMinutes != null
          ? activity.durationMinutes!.toString()
          : '';

      if (activity.startTime != null) {
        _startTime = TimeOfDay.fromDateTime(activity.startTime!);
      }
      if (activity.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(activity.endTime!);
      }

      _selectedPlace = activity.place;
      _selectedType = activity.type;
      _selectedRoute = activity.selectedRoute;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? '활동 추가' : '활동 수정'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.surface),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveActivity,
              child: Text(
                '저장',
                style: textStyles.bodyLarge.copyWith(
                  color: colors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 날짜 표시
            _buildDateHeader(context),
            const SizedBox(height: 24),

            // 활동 유형 선택
            _buildSectionTitle(context, '활동 유형'),
            const SizedBox(height: 8),
            _buildActivityTypeSelector(),
            const SizedBox(height: 24),

            // 시간 선택
            _buildSectionTitle(context, '시간'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    context,
                    label: '시작 시간',
                    time: _startTime,
                    onTap: () => _selectTime(isStartTime: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    context,
                    label: '종료 시간',
                    time: _endTime,
                    onTap: () => _selectTime(isStartTime: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 소요 시간 (선택사항)
            _buildSectionTitle(context, '소요 시간 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                hintText: '예상 소요 시간',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colors.surface,
                suffixText: '분',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // 장소 선택
            _buildSectionTitle(context, '장소'),
            const SizedBox(height: 8),
            _buildPlaceSelector(context),
            const SizedBox(height: 24),

            // 경로 검색 (교통 타입일 때만 표시)
            if (_selectedType == ActivityType.transportation) ...[
              _buildSectionTitle(context, '경로 검색'),
              const SizedBox(height: 8),
              _buildRouteSearchSection(),
              const SizedBox(height: 24),
            ],

            // 활동 제목 (장소가 없을 때 필수)
            if (_selectedPlace == null) ...[
              _buildSectionTitle(context, '활동 제목'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '예: 자유 시간',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colors.surface,
                ),
                validator: (value) {
                  if (_selectedPlace == null &&
                      (value == null || value.trim().isEmpty)) {
                    return '활동 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // 메모 (선택사항)
            _buildSectionTitle(context, '메모 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memoController,
              decoration: InputDecoration(
                hintText: '활동에 대한 메모를 입력하세요',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colors.surface,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 예상 비용 (선택사항)
            _buildSectionTitle(context, '예상 비용 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _costController,
              decoration: InputDecoration(
                hintText: '예상 비용',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colors.surface,
                suffixText: '원',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // 예약 정보 (선택사항)
            _buildSectionTitle(context, '예약 정보 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reservationController,
              decoration: InputDecoration(
                hintText: '예: 예약 번호 123456',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.surface,
                  disabledBackgroundColor: colors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.surface),
                        ),
                      )
                    : Text(
                        '저장',
                        style: textStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 헤더
  Widget _buildDateHeader(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (E)', 'ko');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: colors.primary),
          const SizedBox(width: 12),
          Text(
            dateFormat.format(widget.date),
            style: textStyles.labelLarge.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(BuildContext context, String title) {
    final textStyles = AppTextStyles.of(context);

    return Text(
      title,
      style: textStyles.labelLarge.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 활동 유형 선택
  Widget _buildActivityTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ActivityType.values.map((type) {
        final isSelected = _selectedType == type;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.iconName),
              const SizedBox(width: 4),
              Text(type.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = type;
            });
          },
          selectedColor: type.getColor(context).withValues(alpha: 0.2),
          checkmarkColor: type.getColor(context),
        );
      }).toList(),
    );
  }

  /// 시간 선택 위젯
  Widget _buildTimeSelector(
    BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
          color: colors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  time != null ? time.format(context) : '시간 선택',
                  style: textStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 장소 선택 위젯
  Widget _buildPlaceSelector(BuildContext context) {
    final colors = AppColors.of(context);

    if (_selectedPlace != null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.place, color: colors.primary),
          title: Text(_selectedPlace!.name),
          subtitle: Text(
            _selectedPlace!.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedPlace = null;
              });
            },
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _searchPlace,
      icon: const Icon(Icons.search),
      label: const Text('장소 검색'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }

  /// 시간 선택
  Future<void> _selectTime({required bool isStartTime}) async {
    final colors = AppColors.of(context);
    final initialTime = isStartTime
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? _startTime ?? const TimeOfDay(hour: 9, minute: 0));

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  /// 장소 검색
  void _searchPlace() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExploreScreen(isPlaceSelection: true),
      ),
    ).then((selectedPlace) {
      if (selectedPlace != null && selectedPlace is Place) {
        setState(() {
          _selectedPlace = selectedPlace;
        });
      }
    });
  }

  /// 경로 검색 섹션 위젯
  Widget _buildRouteSearchSection() {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 경로 검색 버튼
        OutlinedButton.icon(
          onPressed: _isSearchingRoute ? null : _searchRoute,
          icon: _isSearchingRoute
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.directions),
          label: Text(_isSearchingRoute ? '경로 검색 중...' : '경로 검색'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            minimumSize: const Size.fromHeight(56),
          ),
        ),

        // 선택된 경로 표시
        if (_selectedRoute != null) ...[
          const SizedBox(height: 12),
          Card(
            color: colors.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '경로 선택됨',
                        style: textStyles.bodySmall.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedRoute = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 출발지 → 도착지
                  if (_selectedRoute!.departureLocation != null &&
                      _selectedRoute!.arrivalLocation != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_selectedRoute!.departureLocation} → ${_selectedRoute!.arrivalLocation}',
                          style: textStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // 소요 시간 및 거리
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedRoute!.durationMinutes}분',
                        style: textStyles.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.straighten,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedRoute!.distance,
                        style: textStyles.bodySmall,
                      ),
                    ],
                  ),
                  // 교통 수단 정보
                  if (_selectedRoute!.transportOptions != null &&
                      _selectedRoute!.transportOptions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _selectedRoute!.transportOptions!
                          .take(3)
                          .map((step) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  step.name,
                                  style: textStyles.bodySmall.copyWith(
                                    color: colors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 경로 검색
  Future<void> _searchRoute() async {
    final colors = AppColors.of(context);

    // 출발지와 도착지가 필요함
    if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('먼저 도착 장소를 선택해주세요'),
          backgroundColor: colors.warning,
        ),
      );
      return;
    }

    // 여행 계획 정보에서 출발지 가져오기 (첫날 첫 활동의 장소 또는 여행지)
    final trips = ref.read(allTripsProvider);
    final trip = trips.firstWhere((t) => t.id == widget.tripId);

    // 출발지는 여행 목적지로 설정 (간단히)
    final origin = trip.destination;
    final destination = _selectedPlace!.name;

    setState(() {
      _isSearchingRoute = true;
    });

    try {
      Logger.info(
        '경로 검색 시작: $origin → $destination',
        'AddActivityScreen',
      );

      final routes = await _directionsService.searchRoutes(
        origin,
        destination,
        mode: TravelMode.transit,
      );

      if (routes.isEmpty) {
        if (mounted) {
          final colors = AppColors.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('경로를 찾을 수 없습니다'),
              backgroundColor: colors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _routeOptions = routes;
      });

      // 경로 선택 다이얼로그 표시
      if (mounted) {
        _showRouteSelectionDialog();
      }
    } catch (e, stackTrace) {
      Logger.error('경로 검색 실패', e, stackTrace, 'AddActivityScreen');
      if (mounted) {
        final colors = AppColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('경로 검색에 실패했습니다'),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingRoute = false;
        });
      }
    }
  }

  /// 경로 선택 다이얼로그
  void _showRouteSelectionDialog() {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('경로 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _routeOptions.length,
            itemBuilder: (context, index) {
              final route = _routeOptions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRoute = route;
                    });
                    Navigator.pop(dialogContext);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 경로 번호
                        Text(
                          '경로 ${index + 1}',
                          style: textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 출발지 → 도착지
                        if (route.departureLocation != null &&
                            route.arrivalLocation != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${route.departureLocation} → ${route.arrivalLocation}',
                                  style: textStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        // 소요 시간 및 거리
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${route.durationMinutes}분',
                              style: textStyles.bodySmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              route.distance,
                              style: textStyles.bodySmall,
                            ),
                          ],
                        ),
                        // 교통 수단
                        if (route.transportOptions != null &&
                            route.transportOptions!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: route.transportOptions!
                                .map((step) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            colors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${step.name} (${step.duration})',
                                        style: textStyles.bodySmall.copyWith(
                                          color: colors.primary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        // 상세 정보
                        if (route.details != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            route.details!,
                            style: textStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 활동 저장
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // DateTime 생성
      DateTime? startDateTime;
      DateTime? endDateTime;

      if (_startTime != null) {
        startDateTime = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }

      if (_endTime != null) {
        endDateTime = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      // 활동 생성
      final activity = Activity(
        id: widget.activity?.id ?? const Uuid().v4(),
        startTime: startDateTime,
        endTime: endDateTime,
        durationMinutes: _durationController.text.isNotEmpty
            ? int.tryParse(_durationController.text)
            : null,
        place: _selectedPlace,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        type: _selectedType,
        memo: _memoController.text.trim().isNotEmpty
            ? _memoController.text.trim()
            : null,
        estimatedCost: _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null,
        reservationInfo: _reservationController.text.trim().isNotEmpty
            ? _reservationController.text.trim()
            : null,
        isCompleted: widget.activity?.isCompleted ?? false,
        selectedRoute: _selectedRoute,
      );

      // 디버그: 저장할 활동 정보
      Logger.info(
        '활동 저장: type=${activity.type}, '
        'selectedRoute=${activity.selectedRoute != null ? "있음" : "없음"}',
        'AddActivityScreen',
      );
      if (activity.selectedRoute != null) {
        Logger.info(
          '경로 정보 저장: '
          'departure=${activity.selectedRoute!.departureLocation}, '
          'arrival=${activity.selectedRoute!.arrivalLocation}, '
          'routeId=${activity.selectedRoute!.routeId}',
          'AddActivityScreen',
        );
      }

      if (widget.activity == null) {
        // 새 활동 추가
        await ref.read(allTripsProvider.notifier).addActivity(
              tripId: widget.tripId,
              date: widget.date,
              activity: activity,
            );
      } else {
        // 기존 활동 수정
        await ref.read(allTripsProvider.notifier).updateActivity(
              tripId: widget.tripId,
              date: widget.date,
              activity: activity,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        final colors = AppColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.activity == null
                  ? '활동이 추가되었습니다'
                  : '활동이 수정되었습니다',
            ),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error('활동 저장 실패', e, stackTrace, 'AddActivityScreen');
      if (mounted) {
        final colors = AppColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('활동 저장에 실패했습니다'),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// ActivityType 확장 - 테마 기반 색상 (activity_card.dart와 동일)
extension ActivityTypeColor on ActivityType {
  Color getColor(BuildContext context) {
    final colors = AppColors.of(context);

    switch (this) {
      case ActivityType.visit:
        return colors.primary;
      case ActivityType.meal:
        return colors.warning;
      case ActivityType.accommodation:
        return colors.info;
      case ActivityType.transportation:
        return colors.textSecondary;
      case ActivityType.shopping:
        return const Color(0xFFE91E63);
      case ActivityType.activity:
        return colors.success;
      case ActivityType.rest:
        return const Color(0xFF9C27B0);
      case ActivityType.other:
        return colors.textSecondary;
    }
  }
}
