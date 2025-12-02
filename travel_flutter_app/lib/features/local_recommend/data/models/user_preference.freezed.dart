// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreference _$UserPreferenceFromJson(Map<String, dynamic> json) {
  return _UserPreference.fromJson(json);
}

/// @nodoc
mixin _$UserPreference {
  /// 카테고리별 선호도 가중치 (0.0 ~ 1.0)
  ///
  /// 예: {'restaurant': 0.7, 'cafe': 0.5, 'attraction': 0.8}
  Map<String, double> get categoryWeights => throw _privateConstructorUsedError;

  /// 방문한 장소 ID 목록
  ///
  /// Google Places ID 저장
  List<String> get visitedPlaceIds => throw _privateConstructorUsedError;

  /// 거절한 장소 ID 목록
  ///
  /// 추천에서 제외할 장소
  List<String> get rejectedPlaceIds => throw _privateConstructorUsedError;

  /// 즐겨찾기 장소 ID 목록
  ///
  /// 사용자가 즐겨찾기한 장소
  List<String> get favoritePlaceIds => throw _privateConstructorUsedError;

  /// 카테고리별 방문 횟수
  ///
  /// 예: {'restaurant': 15, 'cafe': 8, 'attraction': 12}
  Map<String, int> get categoryVisitCount => throw _privateConstructorUsedError;

  /// 마지막 업데이트 시간
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// 선호 평점 기준선 (0.0 ~ 5.0)
  ///
  /// 사용자가 방문한 장소들의 평균 평점
  double get averageRatingPreference => throw _privateConstructorUsedError;

  /// 평균 여행 반경 (킬로미터)
  ///
  /// 사용자가 주로 여행하는 거리
  double get averageTravelRadiusKm => throw _privateConstructorUsedError;

  /// Serializes this UserPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferenceCopyWith<UserPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferenceCopyWith<$Res> {
  factory $UserPreferenceCopyWith(
          UserPreference value, $Res Function(UserPreference) then) =
      _$UserPreferenceCopyWithImpl<$Res, UserPreference>;
  @useResult
  $Res call(
      {Map<String, double> categoryWeights,
      List<String> visitedPlaceIds,
      List<String> rejectedPlaceIds,
      List<String> favoritePlaceIds,
      Map<String, int> categoryVisitCount,
      DateTime lastUpdated,
      double averageRatingPreference,
      double averageTravelRadiusKm});
}

/// @nodoc
class _$UserPreferenceCopyWithImpl<$Res, $Val extends UserPreference>
    implements $UserPreferenceCopyWith<$Res> {
  _$UserPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryWeights = null,
    Object? visitedPlaceIds = null,
    Object? rejectedPlaceIds = null,
    Object? favoritePlaceIds = null,
    Object? categoryVisitCount = null,
    Object? lastUpdated = null,
    Object? averageRatingPreference = null,
    Object? averageTravelRadiusKm = null,
  }) {
    return _then(_value.copyWith(
      categoryWeights: null == categoryWeights
          ? _value.categoryWeights
          : categoryWeights // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      visitedPlaceIds: null == visitedPlaceIds
          ? _value.visitedPlaceIds
          : visitedPlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectedPlaceIds: null == rejectedPlaceIds
          ? _value.rejectedPlaceIds
          : rejectedPlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoritePlaceIds: null == favoritePlaceIds
          ? _value.favoritePlaceIds
          : favoritePlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryVisitCount: null == categoryVisitCount
          ? _value.categoryVisitCount
          : categoryVisitCount // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageRatingPreference: null == averageRatingPreference
          ? _value.averageRatingPreference
          : averageRatingPreference // ignore: cast_nullable_to_non_nullable
              as double,
      averageTravelRadiusKm: null == averageTravelRadiusKm
          ? _value.averageTravelRadiusKm
          : averageTravelRadiusKm // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferenceImplCopyWith<$Res>
    implements $UserPreferenceCopyWith<$Res> {
  factory _$$UserPreferenceImplCopyWith(_$UserPreferenceImpl value,
          $Res Function(_$UserPreferenceImpl) then) =
      __$$UserPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, double> categoryWeights,
      List<String> visitedPlaceIds,
      List<String> rejectedPlaceIds,
      List<String> favoritePlaceIds,
      Map<String, int> categoryVisitCount,
      DateTime lastUpdated,
      double averageRatingPreference,
      double averageTravelRadiusKm});
}

/// @nodoc
class __$$UserPreferenceImplCopyWithImpl<$Res>
    extends _$UserPreferenceCopyWithImpl<$Res, _$UserPreferenceImpl>
    implements _$$UserPreferenceImplCopyWith<$Res> {
  __$$UserPreferenceImplCopyWithImpl(
      _$UserPreferenceImpl _value, $Res Function(_$UserPreferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryWeights = null,
    Object? visitedPlaceIds = null,
    Object? rejectedPlaceIds = null,
    Object? favoritePlaceIds = null,
    Object? categoryVisitCount = null,
    Object? lastUpdated = null,
    Object? averageRatingPreference = null,
    Object? averageTravelRadiusKm = null,
  }) {
    return _then(_$UserPreferenceImpl(
      categoryWeights: null == categoryWeights
          ? _value._categoryWeights
          : categoryWeights // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      visitedPlaceIds: null == visitedPlaceIds
          ? _value._visitedPlaceIds
          : visitedPlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectedPlaceIds: null == rejectedPlaceIds
          ? _value._rejectedPlaceIds
          : rejectedPlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoritePlaceIds: null == favoritePlaceIds
          ? _value._favoritePlaceIds
          : favoritePlaceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryVisitCount: null == categoryVisitCount
          ? _value._categoryVisitCount
          : categoryVisitCount // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageRatingPreference: null == averageRatingPreference
          ? _value.averageRatingPreference
          : averageRatingPreference // ignore: cast_nullable_to_non_nullable
              as double,
      averageTravelRadiusKm: null == averageTravelRadiusKm
          ? _value.averageTravelRadiusKm
          : averageTravelRadiusKm // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferenceImpl extends _UserPreference {
  const _$UserPreferenceImpl(
      {final Map<String, double> categoryWeights = const {},
      final List<String> visitedPlaceIds = const [],
      final List<String> rejectedPlaceIds = const [],
      final List<String> favoritePlaceIds = const [],
      final Map<String, int> categoryVisitCount = const {},
      required this.lastUpdated,
      this.averageRatingPreference = 4.0,
      this.averageTravelRadiusKm = 5.0})
      : _categoryWeights = categoryWeights,
        _visitedPlaceIds = visitedPlaceIds,
        _rejectedPlaceIds = rejectedPlaceIds,
        _favoritePlaceIds = favoritePlaceIds,
        _categoryVisitCount = categoryVisitCount,
        super._();

  factory _$UserPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferenceImplFromJson(json);

  /// 카테고리별 선호도 가중치 (0.0 ~ 1.0)
  ///
  /// 예: {'restaurant': 0.7, 'cafe': 0.5, 'attraction': 0.8}
  final Map<String, double> _categoryWeights;

  /// 카테고리별 선호도 가중치 (0.0 ~ 1.0)
  ///
  /// 예: {'restaurant': 0.7, 'cafe': 0.5, 'attraction': 0.8}
  @override
  @JsonKey()
  Map<String, double> get categoryWeights {
    if (_categoryWeights is EqualUnmodifiableMapView) return _categoryWeights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryWeights);
  }

  /// 방문한 장소 ID 목록
  ///
  /// Google Places ID 저장
  final List<String> _visitedPlaceIds;

  /// 방문한 장소 ID 목록
  ///
  /// Google Places ID 저장
  @override
  @JsonKey()
  List<String> get visitedPlaceIds {
    if (_visitedPlaceIds is EqualUnmodifiableListView) return _visitedPlaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visitedPlaceIds);
  }

  /// 거절한 장소 ID 목록
  ///
  /// 추천에서 제외할 장소
  final List<String> _rejectedPlaceIds;

  /// 거절한 장소 ID 목록
  ///
  /// 추천에서 제외할 장소
  @override
  @JsonKey()
  List<String> get rejectedPlaceIds {
    if (_rejectedPlaceIds is EqualUnmodifiableListView)
      return _rejectedPlaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rejectedPlaceIds);
  }

  /// 즐겨찾기 장소 ID 목록
  ///
  /// 사용자가 즐겨찾기한 장소
  final List<String> _favoritePlaceIds;

  /// 즐겨찾기 장소 ID 목록
  ///
  /// 사용자가 즐겨찾기한 장소
  @override
  @JsonKey()
  List<String> get favoritePlaceIds {
    if (_favoritePlaceIds is EqualUnmodifiableListView)
      return _favoritePlaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoritePlaceIds);
  }

  /// 카테고리별 방문 횟수
  ///
  /// 예: {'restaurant': 15, 'cafe': 8, 'attraction': 12}
  final Map<String, int> _categoryVisitCount;

  /// 카테고리별 방문 횟수
  ///
  /// 예: {'restaurant': 15, 'cafe': 8, 'attraction': 12}
  @override
  @JsonKey()
  Map<String, int> get categoryVisitCount {
    if (_categoryVisitCount is EqualUnmodifiableMapView)
      return _categoryVisitCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryVisitCount);
  }

  /// 마지막 업데이트 시간
  @override
  final DateTime lastUpdated;

  /// 선호 평점 기준선 (0.0 ~ 5.0)
  ///
  /// 사용자가 방문한 장소들의 평균 평점
  @override
  @JsonKey()
  final double averageRatingPreference;

  /// 평균 여행 반경 (킬로미터)
  ///
  /// 사용자가 주로 여행하는 거리
  @override
  @JsonKey()
  final double averageTravelRadiusKm;

  @override
  String toString() {
    return 'UserPreference(categoryWeights: $categoryWeights, visitedPlaceIds: $visitedPlaceIds, rejectedPlaceIds: $rejectedPlaceIds, favoritePlaceIds: $favoritePlaceIds, categoryVisitCount: $categoryVisitCount, lastUpdated: $lastUpdated, averageRatingPreference: $averageRatingPreference, averageTravelRadiusKm: $averageTravelRadiusKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferenceImpl &&
            const DeepCollectionEquality()
                .equals(other._categoryWeights, _categoryWeights) &&
            const DeepCollectionEquality()
                .equals(other._visitedPlaceIds, _visitedPlaceIds) &&
            const DeepCollectionEquality()
                .equals(other._rejectedPlaceIds, _rejectedPlaceIds) &&
            const DeepCollectionEquality()
                .equals(other._favoritePlaceIds, _favoritePlaceIds) &&
            const DeepCollectionEquality()
                .equals(other._categoryVisitCount, _categoryVisitCount) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(
                    other.averageRatingPreference, averageRatingPreference) ||
                other.averageRatingPreference == averageRatingPreference) &&
            (identical(other.averageTravelRadiusKm, averageTravelRadiusKm) ||
                other.averageTravelRadiusKm == averageTravelRadiusKm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_categoryWeights),
      const DeepCollectionEquality().hash(_visitedPlaceIds),
      const DeepCollectionEquality().hash(_rejectedPlaceIds),
      const DeepCollectionEquality().hash(_favoritePlaceIds),
      const DeepCollectionEquality().hash(_categoryVisitCount),
      lastUpdated,
      averageRatingPreference,
      averageTravelRadiusKm);

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferenceImplCopyWith<_$UserPreferenceImpl> get copyWith =>
      __$$UserPreferenceImplCopyWithImpl<_$UserPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferenceImplToJson(
      this,
    );
  }
}

abstract class _UserPreference extends UserPreference {
  const factory _UserPreference(
      {final Map<String, double> categoryWeights,
      final List<String> visitedPlaceIds,
      final List<String> rejectedPlaceIds,
      final List<String> favoritePlaceIds,
      final Map<String, int> categoryVisitCount,
      required final DateTime lastUpdated,
      final double averageRatingPreference,
      final double averageTravelRadiusKm}) = _$UserPreferenceImpl;
  const _UserPreference._() : super._();

  factory _UserPreference.fromJson(Map<String, dynamic> json) =
      _$UserPreferenceImpl.fromJson;

  /// 카테고리별 선호도 가중치 (0.0 ~ 1.0)
  ///
  /// 예: {'restaurant': 0.7, 'cafe': 0.5, 'attraction': 0.8}
  @override
  Map<String, double> get categoryWeights;

  /// 방문한 장소 ID 목록
  ///
  /// Google Places ID 저장
  @override
  List<String> get visitedPlaceIds;

  /// 거절한 장소 ID 목록
  ///
  /// 추천에서 제외할 장소
  @override
  List<String> get rejectedPlaceIds;

  /// 즐겨찾기 장소 ID 목록
  ///
  /// 사용자가 즐겨찾기한 장소
  @override
  List<String> get favoritePlaceIds;

  /// 카테고리별 방문 횟수
  ///
  /// 예: {'restaurant': 15, 'cafe': 8, 'attraction': 12}
  @override
  Map<String, int> get categoryVisitCount;

  /// 마지막 업데이트 시간
  @override
  DateTime get lastUpdated;

  /// 선호 평점 기준선 (0.0 ~ 5.0)
  ///
  /// 사용자가 방문한 장소들의 평균 평점
  @override
  double get averageRatingPreference;

  /// 평균 여행 반경 (킬로미터)
  ///
  /// 사용자가 주로 여행하는 거리
  @override
  double get averageTravelRadiusKm;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferenceImplCopyWith<_$UserPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
