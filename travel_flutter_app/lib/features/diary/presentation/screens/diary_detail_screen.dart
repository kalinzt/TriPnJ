import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../plan/data/models/travel_plan_model.dart';
import '../../data/models/diary_entry_model.dart';
import '../../data/repositories/diary_repository.dart';
import 'add_diary_entry_screen.dart';
import 'edit_diary_entry_screen.dart';
import '../widgets/photo_viewer_screen.dart';

/// 여행 다이어리 상세 화면
class DiaryDetailScreen extends StatefulWidget {
  final TravelPlan plan;

  const DiaryDetailScreen({
    super.key,
    required this.plan,
  });

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final _diaryRepository = DiaryRepository();

  List<DiaryEntry> _diaryEntries = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.plan.startDate;
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _diaryRepository.getDiaryEntriesByPlan(widget.plan.id);
      if (mounted) {
        setState(() {
          _diaryEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      appLogger.e('다이어리 로드 실패', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);
    final allDates = widget.plan.allDates;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.plan.name, style: textStyles.labelLarge),
            Text(
              '${widget.plan.destination} 다이어리',
              style: textStyles.bodySmall.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 날짜 선택
                  _buildDateSelector(allDates),
                  const Divider(height: 1),

                  // 다이어리 내용
                  Expanded(
                    child: _buildDiaryContent(),
                  ),
                ],
              ),
      ),
    );
  }

  /// 날짜 선택기
  Widget _buildDateSelector(List<DateTime> allDates) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allDates.length,
        itemBuilder: (context, index) {
          final date = allDates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final hasEntry = _diaryEntries.any((e) => _isSameDay(e.date, date));

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('M/d').format(date),
                    style: textStyles.bodySmall.copyWith(
                      color: isSelected ? colors.surface : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E', 'ko_KR').format(date),
                    style: textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colors.surface : colors.textPrimary,
                    ),
                  ),
                  if (hasEntry) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.surface : colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 다이어리 내용
  Widget _buildDiaryContent() {
    final entry = _diaryEntries.firstWhere(
      (e) => _isSameDay(e.date, _selectedDate),
      orElse: () => DiaryEntry(
        id: '',
        travelPlanId: widget.plan.id,
        date: _selectedDate,
        title: '',
        weather: 'sunny',
        expenses: [],
        photos: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (entry.id.isEmpty) {
      return _buildEmptyDiaryView();
    }

    final textStyles = AppTextStyles.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀과 수정 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.title,
                  style: textStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editEntry(entry),
                tooltip: '수정',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 날씨
          _buildWeatherSection(entry),
          const SizedBox(height: 24),

          // 가계부
          _buildExpensesSection(entry),
          const SizedBox(height: 24),

          // 메모
          _buildNotesSection(entry),
          const SizedBox(height: 24),

          // 사진
          _buildPhotosSection(entry),
        ],
      ),
    );
  }

  /// 빈 다이어리 뷰
  Widget _buildEmptyDiaryView() {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 64,
            color: colors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 작성된 다이어리가 없습니다',
            style: textStyles.labelLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewEntry(),
            icon: const Icon(Icons.add),
            label: const Text('다이어리 작성하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 날씨 섹션
  Widget _buildWeatherSection(DiaryEntry entry) {
    final textStyles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날씨',
          style: textStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(_getWeatherIcon(entry.weather), size: 40),
            const SizedBox(width: 12),
            Text(
              _getWeatherText(entry.weather),
              style: textStyles.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  /// 가계부 섹션
  Widget _buildExpensesSection(DiaryEntry entry) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '가계부',
              style: textStyles.labelLarge,
            ),
            Text(
              '총 ${NumberFormat('#,###').format(entry.totalExpense)}원',
              style: textStyles.labelLarge.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entry.expenses.isEmpty)
          Text(
            '등록된 지출 내역이 없습니다',
            style: textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          )
        else
          ...entry.expenses.map((expense) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense.activityName,
                        style: textStyles.bodyMedium,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(expense.amount)}원',
                      style: textStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  /// 메모 섹션
  Widget _buildNotesSection(DiaryEntry entry) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 기록',
          style: textStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Text(
          entry.notes ?? '작성된 기록이 없습니다',
          style: textStyles.bodyMedium.copyWith(
            color: entry.notes == null ? colors.textSecondary : colors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 사진 섹션
  Widget _buildPhotosSection(DiaryEntry entry) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진',
          style: textStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        if (entry.photos.isEmpty)
          Text(
            '등록된 사진이 없습니다',
            style: textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entry.photos.length,
            itemBuilder: (context, index) {
              final photo = entry.photos[index];
              return GestureDetector(
                onTap: () {
                  // 전체화면 이미지 뷰어로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewerScreen(
                        photos: entry.photos,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 실제 이미지 표시
                      Image.file(
                        File(photo.url),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      // 설명이 있으면 하단에 표시
                      if (photo.description != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              photo.description!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// 새 다이어리 생성
  Future<void> _createNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDiaryEntryScreen(
          travelPlanId: widget.plan.id,
          date: _selectedDate,
        ),
      ),
    );

    if (result == true) {
      // 다이어리가 추가되었으면 목록 새로고침
      _loadDiaryEntries();
    }
  }

  /// 다이어리 수정
  Future<void> _editEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiaryEntryScreen(entry: entry),
      ),
    );

    if (result == true) {
      // 다이어리가 수정되었으면 목록 새로고침
      _loadDiaryEntries();
    }
  }

  /// 날씨 아이콘
  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.umbrella;
      case 'snowy':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  /// 날씨 텍스트
  String _getWeatherText(String weather) {
    switch (weather) {
      case 'sunny':
        return '맑음';
      case 'cloudy':
        return '흐림';
      case 'rainy':
        return '비';
      case 'snowy':
        return '눈';
      default:
        return '맑음';
    }
  }

  /// 같은 날짜 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
