// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cached_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CachedRecommendation _$CachedRecommendationFromJson(Map<String, dynamic> json) {
  return _CachedRecommendation.fromJson(json);
}

/// @nodoc
mixin _$CachedRecommendation {
  /// 추천 장소 목록
  List<Place> get places => throw _privateConstructorUsedError;

  /// 각 장소의 추천 점수
  ///
  /// Key: Place ID, Value: 추천 점수 (0.0 ~ 1.0)
  Map<String, double> get scores => throw _privateConstructorUsedError;

  /// 캐시 생성 시간
  DateTime get cachedAt => throw _privateConstructorUsedError;

  /// 캐시 생성 시 사용자 위치 (위도)
  double get latitude => throw _privateConstructorUsedError;

  /// 캐시 생성 시 사용자 위치 (경도)
  double get longitude => throw _privateConstructorUsedError;

  /// 캐시 생성 시 사용한 검색 반경 (미터)
  int get searchRadiusMeters => throw _privateConstructorUsedError;

  /// Serializes this CachedRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CachedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CachedRecommendationCopyWith<CachedRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachedRecommendationCopyWith<$Res> {
  factory $CachedRecommendationCopyWith(CachedRecommendation value,
          $Res Function(CachedRecommendation) then) =
      _$CachedRecommendationCopyWithImpl<$Res, CachedRecommendation>;
  @useResult
  $Res call(
      {List<Place> places,
      Map<String, double> scores,
      DateTime cachedAt,
      double latitude,
      double longitude,
      int searchRadiusMeters});
}

/// @nodoc
class _$CachedRecommendationCopyWithImpl<$Res,
        $Val extends CachedRecommendation>
    implements $CachedRecommendationCopyWith<$Res> {
  _$CachedRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CachedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? scores = null,
    Object? cachedAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? searchRadiusMeters = null,
  }) {
    return _then(_value.copyWith(
      places: null == places
          ? _value.places
          : places // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      scores: null == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      cachedAt: null == cachedAt
          ? _value.cachedAt
          : cachedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      searchRadiusMeters: null == searchRadiusMeters
          ? _value.searchRadiusMeters
          : searchRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CachedRecommendationImplCopyWith<$Res>
    implements $CachedRecommendationCopyWith<$Res> {
  factory _$$CachedRecommendationImplCopyWith(_$CachedRecommendationImpl value,
          $Res Function(_$CachedRecommendationImpl) then) =
      __$$CachedRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Place> places,
      Map<String, double> scores,
      DateTime cachedAt,
      double latitude,
      double longitude,
      int searchRadiusMeters});
}

/// @nodoc
class __$$CachedRecommendationImplCopyWithImpl<$Res>
    extends _$CachedRecommendationCopyWithImpl<$Res, _$CachedRecommendationImpl>
    implements _$$CachedRecommendationImplCopyWith<$Res> {
  __$$CachedRecommendationImplCopyWithImpl(_$CachedRecommendationImpl _value,
      $Res Function(_$CachedRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of CachedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? scores = null,
    Object? cachedAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? searchRadiusMeters = null,
  }) {
    return _then(_$CachedRecommendationImpl(
      places: null == places
          ? _value._places
          : places // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      scores: null == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      cachedAt: null == cachedAt
          ? _value.cachedAt
          : cachedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      searchRadiusMeters: null == searchRadiusMeters
          ? _value.searchRadiusMeters
          : searchRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CachedRecommendationImpl implements _CachedRecommendation {
  const _$CachedRecommendationImpl(
      {required final List<Place> places,
      required final Map<String, double> scores,
      required this.cachedAt,
      required this.latitude,
      required this.longitude,
      this.searchRadiusMeters = 5000})
      : _places = places,
        _scores = scores;

  factory _$CachedRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CachedRecommendationImplFromJson(json);

  /// 추천 장소 목록
  final List<Place> _places;

  /// 추천 장소 목록
  @override
  List<Place> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  /// 각 장소의 추천 점수
  ///
  /// Key: Place ID, Value: 추천 점수 (0.0 ~ 1.0)
  final Map<String, double> _scores;

  /// 각 장소의 추천 점수
  ///
  /// Key: Place ID, Value: 추천 점수 (0.0 ~ 1.0)
  @override
  Map<String, double> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

  /// 캐시 생성 시간
  @override
  final DateTime cachedAt;

  /// 캐시 생성 시 사용자 위치 (위도)
  @override
  final double latitude;

  /// 캐시 생성 시 사용자 위치 (경도)
  @override
  final double longitude;

  /// 캐시 생성 시 사용한 검색 반경 (미터)
  @override
  @JsonKey()
  final int searchRadiusMeters;

  @override
  String toString() {
    return 'CachedRecommendation(places: $places, scores: $scores, cachedAt: $cachedAt, latitude: $latitude, longitude: $longitude, searchRadiusMeters: $searchRadiusMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachedRecommendationImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.searchRadiusMeters, searchRadiusMeters) ||
                other.searchRadiusMeters == searchRadiusMeters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_places),
      const DeepCollectionEquality().hash(_scores),
      cachedAt,
      latitude,
      longitude,
      searchRadiusMeters);

  /// Create a copy of CachedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CachedRecommendationImplCopyWith<_$CachedRecommendationImpl>
      get copyWith =>
          __$$CachedRecommendationImplCopyWithImpl<_$CachedRecommendationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CachedRecommendationImplToJson(
      this,
    );
  }
}

abstract class _CachedRecommendation implements CachedRecommendation {
  const factory _CachedRecommendation(
      {required final List<Place> places,
      required final Map<String, double> scores,
      required final DateTime cachedAt,
      required final double latitude,
      required final double longitude,
      final int searchRadiusMeters}) = _$CachedRecommendationImpl;

  factory _CachedRecommendation.fromJson(Map<String, dynamic> json) =
      _$CachedRecommendationImpl.fromJson;

  /// 추천 장소 목록
  @override
  List<Place> get places;

  /// 각 장소의 추천 점수
  ///
  /// Key: Place ID, Value: 추천 점수 (0.0 ~ 1.0)
  @override
  Map<String, double> get scores;

  /// 캐시 생성 시간
  @override
  DateTime get cachedAt;

  /// 캐시 생성 시 사용자 위치 (위도)
  @override
  double get latitude;

  /// 캐시 생성 시 사용자 위치 (경도)
  @override
  double get longitude;

  /// 캐시 생성 시 사용한 검색 반경 (미터)
  @override
  int get searchRadiusMeters;

  /// Create a copy of CachedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CachedRecommendationImplCopyWith<_$CachedRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
