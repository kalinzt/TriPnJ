// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripPlan _$TripPlanFromJson(Map<String, dynamic> json) {
  return _TripPlan.fromJson(json);
}

/// @nodoc
mixin _$TripPlan {
  /// 고유 ID
  String get id => throw _privateConstructorUsedError;

  /// 여행 제목
  String get title => throw _privateConstructorUsedError;

  /// 여행 시작일
  DateTime get startDate => throw _privateConstructorUsedError;

  /// 여행 종료일
  DateTime get endDate => throw _privateConstructorUsedError;

  /// 목적지
  String get destination => throw _privateConstructorUsedError;

  /// 목적지 위도
  double? get destinationLatitude => throw _privateConstructorUsedError;

  /// 목적지 경도
  double? get destinationLongitude => throw _privateConstructorUsedError;

  /// 일별 계획 목록
  List<DailyPlan> get dailyPlans => throw _privateConstructorUsedError;

  /// 여행 메모
  String? get memo => throw _privateConstructorUsedError;

  /// 예산
  double? get budget => throw _privateConstructorUsedError;

  /// 썸네일 이미지 URL
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// 생성 일시
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 수정 일시
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripPlanCopyWith<TripPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripPlanCopyWith<$Res> {
  factory $TripPlanCopyWith(TripPlan value, $Res Function(TripPlan) then) =
      _$TripPlanCopyWithImpl<$Res, TripPlan>;
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime startDate,
      DateTime endDate,
      String destination,
      double? destinationLatitude,
      double? destinationLongitude,
      List<DailyPlan> dailyPlans,
      String? memo,
      double? budget,
      String? thumbnailUrl,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TripPlanCopyWithImpl<$Res, $Val extends TripPlan>
    implements $TripPlanCopyWith<$Res> {
  _$TripPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? destination = null,
    Object? destinationLatitude = freezed,
    Object? destinationLongitude = freezed,
    Object? dailyPlans = null,
    Object? memo = freezed,
    Object? budget = freezed,
    Object? thumbnailUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      destinationLatitude: freezed == destinationLatitude
          ? _value.destinationLatitude
          : destinationLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      destinationLongitude: freezed == destinationLongitude
          ? _value.destinationLongitude
          : destinationLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      dailyPlans: null == dailyPlans
          ? _value.dailyPlans
          : dailyPlans // ignore: cast_nullable_to_non_nullable
              as List<DailyPlan>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripPlanImplCopyWith<$Res>
    implements $TripPlanCopyWith<$Res> {
  factory _$$TripPlanImplCopyWith(
          _$TripPlanImpl value, $Res Function(_$TripPlanImpl) then) =
      __$$TripPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime startDate,
      DateTime endDate,
      String destination,
      double? destinationLatitude,
      double? destinationLongitude,
      List<DailyPlan> dailyPlans,
      String? memo,
      double? budget,
      String? thumbnailUrl,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$TripPlanImplCopyWithImpl<$Res>
    extends _$TripPlanCopyWithImpl<$Res, _$TripPlanImpl>
    implements _$$TripPlanImplCopyWith<$Res> {
  __$$TripPlanImplCopyWithImpl(
      _$TripPlanImpl _value, $Res Function(_$TripPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? destination = null,
    Object? destinationLatitude = freezed,
    Object? destinationLongitude = freezed,
    Object? dailyPlans = null,
    Object? memo = freezed,
    Object? budget = freezed,
    Object? thumbnailUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TripPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      destinationLatitude: freezed == destinationLatitude
          ? _value.destinationLatitude
          : destinationLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      destinationLongitude: freezed == destinationLongitude
          ? _value.destinationLongitude
          : destinationLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      dailyPlans: null == dailyPlans
          ? _value._dailyPlans
          : dailyPlans // ignore: cast_nullable_to_non_nullable
              as List<DailyPlan>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripPlanImpl implements _TripPlan {
  const _$TripPlanImpl(
      {required this.id,
      required this.title,
      required this.startDate,
      required this.endDate,
      required this.destination,
      this.destinationLatitude,
      this.destinationLongitude,
      final List<DailyPlan> dailyPlans = const [],
      this.memo,
      this.budget,
      this.thumbnailUrl,
      required this.createdAt,
      required this.updatedAt})
      : _dailyPlans = dailyPlans;

  factory _$TripPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripPlanImplFromJson(json);

  /// 고유 ID
  @override
  final String id;

  /// 여행 제목
  @override
  final String title;

  /// 여행 시작일
  @override
  final DateTime startDate;

  /// 여행 종료일
  @override
  final DateTime endDate;

  /// 목적지
  @override
  final String destination;

  /// 목적지 위도
  @override
  final double? destinationLatitude;

  /// 목적지 경도
  @override
  final double? destinationLongitude;

  /// 일별 계획 목록
  final List<DailyPlan> _dailyPlans;

  /// 일별 계획 목록
  @override
  @JsonKey()
  List<DailyPlan> get dailyPlans {
    if (_dailyPlans is EqualUnmodifiableListView) return _dailyPlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyPlans);
  }

  /// 여행 메모
  @override
  final String? memo;

  /// 예산
  @override
  final double? budget;

  /// 썸네일 이미지 URL
  @override
  final String? thumbnailUrl;

  /// 생성 일시
  @override
  final DateTime createdAt;

  /// 수정 일시
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TripPlan(id: $id, title: $title, startDate: $startDate, endDate: $endDate, destination: $destination, destinationLatitude: $destinationLatitude, destinationLongitude: $destinationLongitude, dailyPlans: $dailyPlans, memo: $memo, budget: $budget, thumbnailUrl: $thumbnailUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.destinationLatitude, destinationLatitude) ||
                other.destinationLatitude == destinationLatitude) &&
            (identical(other.destinationLongitude, destinationLongitude) ||
                other.destinationLongitude == destinationLongitude) &&
            const DeepCollectionEquality()
                .equals(other._dailyPlans, _dailyPlans) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      startDate,
      endDate,
      destination,
      destinationLatitude,
      destinationLongitude,
      const DeepCollectionEquality().hash(_dailyPlans),
      memo,
      budget,
      thumbnailUrl,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripPlanImplCopyWith<_$TripPlanImpl> get copyWith =>
      __$$TripPlanImplCopyWithImpl<_$TripPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripPlanImplToJson(
      this,
    );
  }
}

abstract class _TripPlan implements TripPlan {
  const factory _TripPlan(
      {required final String id,
      required final String title,
      required final DateTime startDate,
      required final DateTime endDate,
      required final String destination,
      final double? destinationLatitude,
      final double? destinationLongitude,
      final List<DailyPlan> dailyPlans,
      final String? memo,
      final double? budget,
      final String? thumbnailUrl,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$TripPlanImpl;

  factory _TripPlan.fromJson(Map<String, dynamic> json) =
      _$TripPlanImpl.fromJson;

  @override

  /// 고유 ID
  String get id;
  @override

  /// 여행 제목
  String get title;
  @override

  /// 여행 시작일
  DateTime get startDate;
  @override

  /// 여행 종료일
  DateTime get endDate;
  @override

  /// 목적지
  String get destination;
  @override

  /// 목적지 위도
  double? get destinationLatitude;
  @override

  /// 목적지 경도
  double? get destinationLongitude;
  @override

  /// 일별 계획 목록
  List<DailyPlan> get dailyPlans;
  @override

  /// 여행 메모
  String? get memo;
  @override

  /// 예산
  double? get budget;
  @override

  /// 썸네일 이미지 URL
  String? get thumbnailUrl;
  @override

  /// 생성 일시
  DateTime get createdAt;
  @override

  /// 수정 일시
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TripPlanImplCopyWith<_$TripPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlan _$DailyPlanFromJson(Map<String, dynamic> json) {
  return _DailyPlan.fromJson(json);
}

/// @nodoc
mixin _$DailyPlan {
  /// 날짜
  DateTime get date => throw _privateConstructorUsedError;

  /// 일정 제목 (예: "서울 첫째 날")
  String? get title => throw _privateConstructorUsedError;

  /// 활동 목록
  List<Activity> get activities => throw _privateConstructorUsedError;

  /// 일별 메모
  String? get memo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyPlanCopyWith<DailyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanCopyWith<$Res> {
  factory $DailyPlanCopyWith(DailyPlan value, $Res Function(DailyPlan) then) =
      _$DailyPlanCopyWithImpl<$Res, DailyPlan>;
  @useResult
  $Res call(
      {DateTime date, String? title, List<Activity> activities, String? memo});
}

/// @nodoc
class _$DailyPlanCopyWithImpl<$Res, $Val extends DailyPlan>
    implements $DailyPlanCopyWith<$Res> {
  _$DailyPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? title = freezed,
    Object? activities = null,
    Object? memo = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      activities: null == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyPlanImplCopyWith<$Res>
    implements $DailyPlanCopyWith<$Res> {
  factory _$$DailyPlanImplCopyWith(
          _$DailyPlanImpl value, $Res Function(_$DailyPlanImpl) then) =
      __$$DailyPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, String? title, List<Activity> activities, String? memo});
}

/// @nodoc
class __$$DailyPlanImplCopyWithImpl<$Res>
    extends _$DailyPlanCopyWithImpl<$Res, _$DailyPlanImpl>
    implements _$$DailyPlanImplCopyWith<$Res> {
  __$$DailyPlanImplCopyWithImpl(
      _$DailyPlanImpl _value, $Res Function(_$DailyPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? title = freezed,
    Object? activities = null,
    Object? memo = freezed,
  }) {
    return _then(_$DailyPlanImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      activities: null == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanImpl implements _DailyPlan {
  const _$DailyPlanImpl(
      {required this.date,
      this.title,
      final List<Activity> activities = const [],
      this.memo})
      : _activities = activities;

  factory _$DailyPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanImplFromJson(json);

  /// 날짜
  @override
  final DateTime date;

  /// 일정 제목 (예: "서울 첫째 날")
  @override
  final String? title;

  /// 활동 목록
  final List<Activity> _activities;

  /// 활동 목록
  @override
  @JsonKey()
  List<Activity> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  /// 일별 메모
  @override
  final String? memo;

  @override
  String toString() {
    return 'DailyPlan(date: $date, title: $title, activities: $activities, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, title,
      const DeepCollectionEquality().hash(_activities), memo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanImplCopyWith<_$DailyPlanImpl> get copyWith =>
      __$$DailyPlanImplCopyWithImpl<_$DailyPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanImplToJson(
      this,
    );
  }
}

abstract class _DailyPlan implements DailyPlan {
  const factory _DailyPlan(
      {required final DateTime date,
      final String? title,
      final List<Activity> activities,
      final String? memo}) = _$DailyPlanImpl;

  factory _DailyPlan.fromJson(Map<String, dynamic> json) =
      _$DailyPlanImpl.fromJson;

  @override

  /// 날짜
  DateTime get date;
  @override

  /// 일정 제목 (예: "서울 첫째 날")
  String? get title;
  @override

  /// 활동 목록
  List<Activity> get activities;
  @override

  /// 일별 메모
  String? get memo;
  @override
  @JsonKey(ignore: true)
  _$$DailyPlanImplCopyWith<_$DailyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return _Activity.fromJson(json);
}

/// @nodoc
mixin _$Activity {
  /// 고유 ID
  String get id => throw _privateConstructorUsedError;

  /// 시작 시간
  DateTime? get startTime => throw _privateConstructorUsedError;

  /// 종료 시간 (또는 소요 시간)
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// 소요 시간 (분 단위)
  int? get durationMinutes => throw _privateConstructorUsedError;

  /// 장소 (Place 모델)
  Place? get place => throw _privateConstructorUsedError;

  /// 활동 제목 (place가 없을 경우 사용)
  String? get title => throw _privateConstructorUsedError;

  /// 활동 유형
  ActivityType get type => throw _privateConstructorUsedError;

  /// 메모
  String? get memo => throw _privateConstructorUsedError;

  /// 예상 비용
  double? get estimatedCost => throw _privateConstructorUsedError;

  /// 예약 정보
  String? get reservationInfo => throw _privateConstructorUsedError;

  /// 완료 여부
  bool get isCompleted => throw _privateConstructorUsedError;

  /// 선택된 경로 정보 (교통 관련 활동에서 사용)
  RouteOption? get selectedRoute => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
  @useResult
  $Res call(
      {String id,
      DateTime? startTime,
      DateTime? endTime,
      int? durationMinutes,
      Place? place,
      String? title,
      ActivityType type,
      String? memo,
      double? estimatedCost,
      String? reservationInfo,
      bool isCompleted,
      RouteOption? selectedRoute});

  $PlaceCopyWith<$Res>? get place;
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? durationMinutes = freezed,
    Object? place = freezed,
    Object? title = freezed,
    Object? type = null,
    Object? memo = freezed,
    Object? estimatedCost = freezed,
    Object? reservationInfo = freezed,
    Object? isCompleted = null,
    Object? selectedRoute = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      place: freezed == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as Place?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      reservationInfo: freezed == reservationInfo
          ? _value.reservationInfo
          : reservationInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRoute: freezed == selectedRoute
          ? _value.selectedRoute
          : selectedRoute // ignore: cast_nullable_to_non_nullable
              as RouteOption?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PlaceCopyWith<$Res>? get place {
    if (_value.place == null) {
      return null;
    }

    return $PlaceCopyWith<$Res>(_value.place!, (value) {
      return _then(_value.copyWith(place: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$ActivityImplCopyWith(
          _$ActivityImpl value, $Res Function(_$ActivityImpl) then) =
      __$$ActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime? startTime,
      DateTime? endTime,
      int? durationMinutes,
      Place? place,
      String? title,
      ActivityType type,
      String? memo,
      double? estimatedCost,
      String? reservationInfo,
      bool isCompleted,
      RouteOption? selectedRoute});

  @override
  $PlaceCopyWith<$Res>? get place;
}

/// @nodoc
class __$$ActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$ActivityImpl>
    implements _$$ActivityImplCopyWith<$Res> {
  __$$ActivityImplCopyWithImpl(
      _$ActivityImpl _value, $Res Function(_$ActivityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? durationMinutes = freezed,
    Object? place = freezed,
    Object? title = freezed,
    Object? type = null,
    Object? memo = freezed,
    Object? estimatedCost = freezed,
    Object? reservationInfo = freezed,
    Object? isCompleted = null,
    Object? selectedRoute = freezed,
  }) {
    return _then(_$ActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      place: freezed == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as Place?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      reservationInfo: freezed == reservationInfo
          ? _value.reservationInfo
          : reservationInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRoute: freezed == selectedRoute
          ? _value.selectedRoute
          : selectedRoute // ignore: cast_nullable_to_non_nullable
              as RouteOption?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityImpl implements _Activity {
  const _$ActivityImpl(
      {required this.id,
      this.startTime,
      this.endTime,
      this.durationMinutes,
      this.place,
      this.title,
      this.type = ActivityType.visit,
      this.memo,
      this.estimatedCost,
      this.reservationInfo,
      this.isCompleted = false,
      this.selectedRoute});

  factory _$ActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityImplFromJson(json);

  /// 고유 ID
  @override
  final String id;

  /// 시작 시간
  @override
  final DateTime? startTime;

  /// 종료 시간 (또는 소요 시간)
  @override
  final DateTime? endTime;

  /// 소요 시간 (분 단위)
  @override
  final int? durationMinutes;

  /// 장소 (Place 모델)
  @override
  final Place? place;

  /// 활동 제목 (place가 없을 경우 사용)
  @override
  final String? title;

  /// 활동 유형
  @override
  @JsonKey()
  final ActivityType type;

  /// 메모
  @override
  final String? memo;

  /// 예상 비용
  @override
  final double? estimatedCost;

  /// 예약 정보
  @override
  final String? reservationInfo;

  /// 완료 여부
  @override
  @JsonKey()
  final bool isCompleted;

  /// 선택된 경로 정보 (교통 관련 활동에서 사용)
  @override
  final RouteOption? selectedRoute;

  @override
  String toString() {
    return 'Activity(id: $id, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, place: $place, title: $title, type: $type, memo: $memo, estimatedCost: $estimatedCost, reservationInfo: $reservationInfo, isCompleted: $isCompleted, selectedRoute: $selectedRoute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.place, place) || other.place == place) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.reservationInfo, reservationInfo) ||
                other.reservationInfo == reservationInfo) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.selectedRoute, selectedRoute) ||
                other.selectedRoute == selectedRoute));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startTime,
      endTime,
      durationMinutes,
      place,
      title,
      type,
      memo,
      estimatedCost,
      reservationInfo,
      isCompleted,
      selectedRoute);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      __$$ActivityImplCopyWithImpl<_$ActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityImplToJson(
      this,
    );
  }
}

abstract class _Activity implements Activity {
  const factory _Activity(
      {required final String id,
      final DateTime? startTime,
      final DateTime? endTime,
      final int? durationMinutes,
      final Place? place,
      final String? title,
      final ActivityType type,
      final String? memo,
      final double? estimatedCost,
      final String? reservationInfo,
      final bool isCompleted,
      final RouteOption? selectedRoute}) = _$ActivityImpl;

  factory _Activity.fromJson(Map<String, dynamic> json) =
      _$ActivityImpl.fromJson;

  @override

  /// 고유 ID
  String get id;
  @override

  /// 시작 시간
  DateTime? get startTime;
  @override

  /// 종료 시간 (또는 소요 시간)
  DateTime? get endTime;
  @override

  /// 소요 시간 (분 단위)
  int? get durationMinutes;
  @override

  /// 장소 (Place 모델)
  Place? get place;
  @override

  /// 활동 제목 (place가 없을 경우 사용)
  String? get title;
  @override

  /// 활동 유형
  ActivityType get type;
  @override

  /// 메모
  String? get memo;
  @override

  /// 예상 비용
  double? get estimatedCost;
  @override

  /// 예약 정보
  String? get reservationInfo;
  @override

  /// 완료 여부
  bool get isCompleted;
  @override

  /// 선택된 경로 정보 (교통 관련 활동에서 사용)
  RouteOption? get selectedRoute;
  @override
  @JsonKey(ignore: true)
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
