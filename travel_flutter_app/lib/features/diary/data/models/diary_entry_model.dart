/// 여행 다이어리 엔트리 모델
class DiaryEntry {
  final String id;
  final String travelPlanId;
  final DateTime date;
  final String title; // 다이어리 타이틀
  final String weather; // sunny, partly_cloudy, cloudy, rainy, snowy, windy
  final List<DiaryExpense> expenses;
  final String? notes;
  final List<DiaryPhoto> photos; // 이미지 URL과 설명 (최대 15장)
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.travelPlanId,
    required this.date,
    required this.title,
    required this.weather,
    required this.expenses,
    this.notes,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 총 지출 금액 계산
  int get totalExpense {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelPlanId': travelPlanId,
      'date': date.toIso8601String(),
      'title': title,
      'weather': weather,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'notes': notes,
      'photos': photos.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      travelPlanId: json['travelPlanId'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '', // 하위 호환성
      weather: json['weather'] as String,
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => DiaryExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      photos: json['photos'] != null
          ? (json['photos'] as List<dynamic>)
              .map((e) => DiaryPhoto.fromJson(e as Map<String, dynamic>))
              .toList()
          : (json['photoUrls'] as List<dynamic>?) // 하위 호환성
                  ?.map((e) => DiaryPhoto(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        url: e as String,
                        description: null,
                      ))
                  .toList() ??
              [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// copyWith 메서드
  DiaryEntry copyWith({
    String? id,
    String? travelPlanId,
    DateTime? date,
    String? title,
    String? weather,
    List<DiaryExpense>? expenses,
    String? notes,
    List<DiaryPhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      travelPlanId: travelPlanId ?? this.travelPlanId,
      date: date ?? this.date,
      title: title ?? this.title,
      weather: weather ?? this.weather,
      expenses: expenses ?? this.expenses,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 다이어리 사진 모델
class DiaryPhoto {
  final String id;
  final String url; // 이미지 경로 또는 URL
  final String? description; // 이미지 설명

  DiaryPhoto({
    required this.id,
    required this.url,
    this.description,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
    };
  }

  /// JSON에서 생성
  factory DiaryPhoto.fromJson(Map<String, dynamic> json) {
    return DiaryPhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
    );
  }

  /// copyWith 메서드
  DiaryPhoto copyWith({
    String? id,
    String? url,
    String? description,
  }) {
    return DiaryPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      description: description ?? this.description,
    );
  }
}

/// 다이어리 가계부 항목 모델
class DiaryExpense {
  final String id;
  final String activityName; // 품목
  final int amount; // 비용
  final String? category; // 카테고리 (선택)

  DiaryExpense({
    required this.id,
    required this.activityName,
    required this.amount,
    this.category,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'amount': amount,
      'category': category,
    };
  }

  /// JSON에서 생성
  factory DiaryExpense.fromJson(Map<String, dynamic> json) {
    return DiaryExpense(
      id: json['id'] as String,
      activityName: json['activityName'] as String,
      amount: json['amount'] as int,
      category: json['category'] as String?,
    );
  }

  /// copyWith 메서드
  DiaryExpense copyWith({
    String? id,
    String? activityName,
    int? amount,
    String? category,
  }) {
    return DiaryExpense(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
