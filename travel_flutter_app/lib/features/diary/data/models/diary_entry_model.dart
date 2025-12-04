/// 여행 다이어리 엔트리 모델
class DiaryEntry {
  final String id;
  final String travelPlanId;
  final DateTime date;
  final String weather; // sunny, cloudy, rainy, snowy, etc.
  final List<DiaryExpense> expenses;
  final String? notes;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.travelPlanId,
    required this.date,
    required this.weather,
    required this.expenses,
    this.notes,
    required this.photoUrls,
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
      'weather': weather,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'notes': notes,
      'photoUrls': photoUrls,
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
      weather: json['weather'] as String,
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => DiaryExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// copyWith 메서드
  DiaryEntry copyWith({
    String? id,
    String? travelPlanId,
    DateTime? date,
    String? weather,
    List<DiaryExpense>? expenses,
    String? notes,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      travelPlanId: travelPlanId ?? this.travelPlanId,
      date: date ?? this.date,
      weather: weather ?? this.weather,
      expenses: expenses ?? this.expenses,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 다이어리 가계부 항목 모델
class DiaryExpense {
  final String id;
  final String activityName;
  final int amount;
  final String? category; // food, transport, shopping, etc.

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
