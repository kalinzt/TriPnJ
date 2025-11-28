import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../data/providers/trip_provider.dart';

/// 여행 계획 편집 화면
class TripPlanEditScreen extends ConsumerStatefulWidget {
  final String? tripId; // null이면 새 계획, 있으면 수정

  const TripPlanEditScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<TripPlanEditScreen> createState() =>
      _TripPlanEditScreenState();
}

class _TripPlanEditScreenState extends ConsumerState<TripPlanEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _memoController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final _dateFormat = DateFormat('yyyy년 MM월 dd일');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _memoController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// 여행 데이터 로드
  void _loadTripData() {
    final editingTrip = ref.read(currentEditingTripProvider);
    if (editingTrip != null) {
      _titleController.text = editingTrip.title;
      _destinationController.text = editingTrip.destination;
      _memoController.text = editingTrip.memo ?? '';
      _budgetController.text =
          editingTrip.budget != null ? editingTrip.budget!.toStringAsFixed(0) : '';
      _startDate = editingTrip.startDate;
      _endDate = editingTrip.endDate;
    } else {
      // 새 여행 계획
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripId == null ? '새 여행 계획' : '여행 계획 수정'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveTrip,
              child: const Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
            // 여행 제목
            _buildSectionTitle('여행 제목'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '예: 제주도 힐링 여행',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '여행 제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 목적지
            _buildSectionTitle('목적지'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: '예: 제주도',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchDestination,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '목적지를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 여행 기간
            _buildSectionTitle('여행 기간'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: '시작일',
                    date: _startDate,
                    onTap: () => _selectDate(isStartDate: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    label: '종료일',
                    date: _endDate,
                    onTap: () => _selectDate(isStartDate: false),
                  ),
                ),
              ],
            ),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_endDate!.difference(_startDate!).inDays + 1}일',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),

            // 예산 (선택사항)
            _buildSectionTitle('예산 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                hintText: '예상 예산을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixText: '원',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // 메모 (선택사항)
            _buildSectionTitle('메모 (선택사항)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                hintText: '여행에 대한 메모를 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // 저장 버튼 (모바일)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
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

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 날짜 선택 위젯
  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? _dateFormat.format(date) : '날짜 선택',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate
        ? DateTime.now()
        : (_startDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // 시작일이 종료일보다 늦으면 종료일 조정
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = pickedDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  /// 목적지 검색
  void _searchDestination() {
    // TODO: 목적지 검색 기능 구현
    // explore 화면의 검색 기능을 재사용할 수 있습니다
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('목적지 검색 기능은 추후 구현 예정입니다'),
      ),
    );
  }

  /// 여행 저장
  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 기간을 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final destination = _destinationController.text.trim();
      final memo = _memoController.text.trim();
      final budgetText = _budgetController.text.trim();
      final budget = budgetText.isNotEmpty ? double.tryParse(budgetText) : null;

      if (widget.tripId == null) {
        // 새 여행 계획 생성
        await ref.read(allTripsProvider.notifier).createTrip(
              title: title,
              startDate: _startDate!,
              endDate: _endDate!,
              destination: destination,
              memo: memo.isNotEmpty ? memo : null,
              budget: budget,
            );
      } else {
        // 기존 여행 계획 수정
        final currentTrip = ref.read(currentEditingTripProvider);
        if (currentTrip != null) {
          final updatedTrip = currentTrip.copyWith(
            title: title,
            startDate: _startDate!,
            endDate: _endDate!,
            destination: destination,
            memo: memo.isNotEmpty ? memo : null,
            budget: budget,
          );
          await ref.read(allTripsProvider.notifier).updateTrip(updatedTrip);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tripId == null
                  ? '여행 계획이 생성되었습니다'
                  : '여행 계획이 수정되었습니다',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error('여행 저장 실패', e, stackTrace, 'TripPlanEditScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('여행 저장에 실패했습니다'),
            backgroundColor: AppColors.error,
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
