import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/diary_entry_model.dart';
import '../../data/repositories/diary_repository.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../widgets/weather_selector.dart';

/// 다이어리 엔트리 추가 화면
class AddDiaryEntryScreen extends StatefulWidget {
  final String travelPlanId;
  final DateTime date;

  const AddDiaryEntryScreen({
    required this.travelPlanId,
    required this.date,
    super.key,
  });

  @override
  State<AddDiaryEntryScreen> createState() => _AddDiaryEntryScreenState();
}

class _AddDiaryEntryScreenState extends State<AddDiaryEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _diaryRepository = DiaryRepository();
  final _imageService = ImageService();

  // Controllers
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  String _selectedWeather = 'sunny';
  final List<DiaryPhoto> _photos = [];
  final List<DiaryExpense> _expenses = [];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 이미지 추가 (다중 선택)
  Future<void> _addImage() async {
    final remainingSlots = 15 - _photos.length;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 15장까지만 추가할 수 있습니다')),
      );
      return;
    }

    final imagePaths = await _imageService.pickMultipleImages(
      maxImages: remainingSlots,
    );

    if (imagePaths.isNotEmpty) {
      setState(() {
        for (final imagePath in imagePaths) {
          _photos.add(DiaryPhoto(
            id: _uuid.v4(),
            url: imagePath,
            description: null,
          ));
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${imagePaths.length}장의 사진이 추가되었습니다')),
        );
      }
    }
  }

  /// 이미지 설명 수정
  void _editImageDescription(int index) {
    final photo = _photos[index];
    final controller = TextEditingController(text: photo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 설명'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '이미지에 대한 설명을 입력하세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _photos[index] = photo.copyWith(
                  description: controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim(),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 이미지 삭제
  void _deleteImage(int index) {
    final photo = _photos[index];
    setState(() {
      _photos.removeAt(index);
    });
    _imageService.deleteImage(photo.url);
  }

  /// 가계부 항목 추가
  void _addExpense() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지출 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '품목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: '비용 (원)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amountText = amountController.text.trim();

              if (name.isEmpty || amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('품목과 비용을 모두 입력해주세요')),
                );
                return;
              }

              final amount = int.tryParse(amountText);
              if (amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올바른 금액을 입력해주세요')),
                );
                return;
              }

              setState(() {
                _expenses.add(DiaryExpense(
                  id: _uuid.v4(),
                  activityName: name,
                  amount: amount,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  /// 가계부 항목 삭제
  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  /// 총 지출 계산
  int get _totalExpense {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  /// 다이어리 저장
  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final entry = DiaryEntry(
        id: _uuid.v4(),
        travelPlanId: widget.travelPlanId,
        date: widget.date,
        title: _titleController.text.trim(),
        weather: _selectedWeather,
        expenses: _expenses,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photos: _photos,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _diaryRepository.saveDiaryEntry(entry);
      appLogger.i('다이어리 저장 완료: ${entry.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('다이어리가 저장되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      appLogger.e('다이어리 저장 실패', error: e);

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
        title: const Text('다이어리 작성'),
        actions: [
          TextButton(
            onPressed: _saveDiary,
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
              // 날짜 표시
              Text(
                '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 타이틀
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '타이틀 *',
                  hintText: '오늘의 일정을 요약해보세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '타이틀을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 날씨 선택
              WeatherSelector(
                selectedWeather: _selectedWeather,
                onWeatherSelected: (weather) {
                  setState(() {
                    _selectedWeather = weather;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 이미지 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '사진 (${_photos.length}/15)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('사진 추가'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_photos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '사진을 추가해주세요',
                      style: TextStyle(color: Colors.grey),
                    ),
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
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () => _editImageDescription(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(photo.url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (photo.description != null)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
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
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _deleteImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 24),

              // 가계부 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '가계부',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('지출 추가'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_expenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '지출 내역이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return Card(
                      child: ListTile(
                        title: Text(expense.activityName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${expense.amount.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  )}원',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExpense(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 지출',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_totalExpense.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // 일과 작성
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '일과 작성',
                  hintText: '오늘의 일과를 작성해보세요.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // 저장 버튼
              ElevatedButton(
                onPressed: _saveDiary,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
