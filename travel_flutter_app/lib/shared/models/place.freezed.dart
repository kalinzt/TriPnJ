// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  /// Google Places ID
  String get id => throw _privateConstructorUsedError;

  /// 장소 이름
  String get name => throw _privateConstructorUsedError;

  /// 주소
  String get address => throw _privateConstructorUsedError;

  /// 위도
  double get latitude => throw _privateConstructorUsedError;

  /// 경도
  double get longitude => throw _privateConstructorUsedError;

  /// 평점 (0.0 ~ 5.0)
  double? get rating => throw _privateConstructorUsedError;

  /// 사진 URL 목록
  List<String> get photos => throw _privateConstructorUsedError;

  /// 장소 유형 (예: restaurant, tourist_attraction)
  List<String> get types => throw _privateConstructorUsedError;

  /// 가격 레벨 (0: 무료, 1: 저렴, 2: 보통, 3: 비쌈, 4: 매우 비쌈)
  int? get priceLevel => throw _privateConstructorUsedError;

  /// 영업 시간 정보
  String? get openingHours => throw _privateConstructorUsedError;

  /// 전화번호
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// 웹사이트
  String? get website => throw _privateConstructorUsedError;

  /// 리뷰 수
  int? get userRatingsTotal => throw _privateConstructorUsedError;

  /// 장소 설명
  String? get description => throw _privateConstructorUsedError;

  /// 비즈니스 상태 (OPERATIONAL, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY)
  String? get businessStatus => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      double latitude,
      double longitude,
      double? rating,
      List<String> photos,
      List<String> types,
      int? priceLevel,
      String? openingHours,
      String? phoneNumber,
      String? website,
      int? userRatingsTotal,
      String? description,
      String? businessStatus});
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? rating = freezed,
    Object? photos = null,
    Object? types = null,
    Object? priceLevel = freezed,
    Object? openingHours = freezed,
    Object? phoneNumber = freezed,
    Object? website = freezed,
    Object? userRatingsTotal = freezed,
    Object? description = freezed,
    Object? businessStatus = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _value.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _value.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      businessStatus: freezed == businessStatus
          ? _value.businessStatus
          : businessStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
          _$PlaceImpl value, $Res Function(_$PlaceImpl) then) =
      __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      double latitude,
      double longitude,
      double? rating,
      List<String> photos,
      List<String> types,
      int? priceLevel,
      String? openingHours,
      String? phoneNumber,
      String? website,
      int? userRatingsTotal,
      String? description,
      String? businessStatus});
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
      _$PlaceImpl _value, $Res Function(_$PlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? rating = freezed,
    Object? photos = null,
    Object? types = null,
    Object? priceLevel = freezed,
    Object? openingHours = freezed,
    Object? phoneNumber = freezed,
    Object? website = freezed,
    Object? userRatingsTotal = freezed,
    Object? description = freezed,
    Object? businessStatus = freezed,
  }) {
    return _then(_$PlaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      types: null == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _value.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _value.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      businessStatus: freezed == businessStatus
          ? _value.businessStatus
          : businessStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceImpl implements _Place {
  const _$PlaceImpl(
      {required this.id,
      required this.name,
      required this.address,
      required this.latitude,
      required this.longitude,
      this.rating,
      final List<String> photos = const [],
      final List<String> types = const [],
      this.priceLevel,
      this.openingHours,
      this.phoneNumber,
      this.website,
      this.userRatingsTotal,
      this.description,
      this.businessStatus})
      : _photos = photos,
        _types = types;

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  /// Google Places ID
  @override
  final String id;

  /// 장소 이름
  @override
  final String name;

  /// 주소
  @override
  final String address;

  /// 위도
  @override
  final double latitude;

  /// 경도
  @override
  final double longitude;

  /// 평점 (0.0 ~ 5.0)
  @override
  final double? rating;

  /// 사진 URL 목록
  final List<String> _photos;

  /// 사진 URL 목록
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// 장소 유형 (예: restaurant, tourist_attraction)
  final List<String> _types;

  /// 장소 유형 (예: restaurant, tourist_attraction)
  @override
  @JsonKey()
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  /// 가격 레벨 (0: 무료, 1: 저렴, 2: 보통, 3: 비쌈, 4: 매우 비쌈)
  @override
  final int? priceLevel;

  /// 영업 시간 정보
  @override
  final String? openingHours;

  /// 전화번호
  @override
  final String? phoneNumber;

  /// 웹사이트
  @override
  final String? website;

  /// 리뷰 수
  @override
  final int? userRatingsTotal;

  /// 장소 설명
  @override
  final String? description;

  /// 비즈니스 상태 (OPERATIONAL, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY)
  @override
  final String? businessStatus;

  @override
  String toString() {
    return 'Place(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, rating: $rating, photos: $photos, types: $types, priceLevel: $priceLevel, openingHours: $openingHours, phoneNumber: $phoneNumber, website: $website, userRatingsTotal: $userRatingsTotal, description: $description, businessStatus: $businessStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.userRatingsTotal, userRatingsTotal) ||
                other.userRatingsTotal == userRatingsTotal) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.businessStatus, businessStatus) ||
                other.businessStatus == businessStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      address,
      latitude,
      longitude,
      rating,
      const DeepCollectionEquality().hash(_photos),
      const DeepCollectionEquality().hash(_types),
      priceLevel,
      openingHours,
      phoneNumber,
      website,
      userRatingsTotal,
      description,
      businessStatus);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(
      this,
    );
  }
}

abstract class _Place implements Place {
  const factory _Place(
      {required final String id,
      required final String name,
      required final String address,
      required final double latitude,
      required final double longitude,
      final double? rating,
      final List<String> photos,
      final List<String> types,
      final int? priceLevel,
      final String? openingHours,
      final String? phoneNumber,
      final String? website,
      final int? userRatingsTotal,
      final String? description,
      final String? businessStatus}) = _$PlaceImpl;

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  /// Google Places ID
  @override
  String get id;

  /// 장소 이름
  @override
  String get name;

  /// 주소
  @override
  String get address;

  /// 위도
  @override
  double get latitude;

  /// 경도
  @override
  double get longitude;

  /// 평점 (0.0 ~ 5.0)
  @override
  double? get rating;

  /// 사진 URL 목록
  @override
  List<String> get photos;

  /// 장소 유형 (예: restaurant, tourist_attraction)
  @override
  List<String> get types;

  /// 가격 레벨 (0: 무료, 1: 저렴, 2: 보통, 3: 비쌈, 4: 매우 비쌈)
  @override
  int? get priceLevel;

  /// 영업 시간 정보
  @override
  String? get openingHours;

  /// 전화번호
  @override
  String? get phoneNumber;

  /// 웹사이트
  @override
  String? get website;

  /// 리뷰 수
  @override
  int? get userRatingsTotal;

  /// 장소 설명
  @override
  String? get description;

  /// 비즈니스 상태 (OPERATIONAL, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY)
  @override
  String? get businessStatus;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlacePhoto _$PlacePhotoFromJson(Map<String, dynamic> json) {
  return _PlacePhoto.fromJson(json);
}

/// @nodoc
mixin _$PlacePhoto {
  /// 사진 참조 ID
  String get photoReference => throw _privateConstructorUsedError;

  /// 사진 너비
  int? get width => throw _privateConstructorUsedError;

  /// 사진 높이
  int? get height => throw _privateConstructorUsedError;

  /// HTML 속성
  List<String> get htmlAttributions => throw _privateConstructorUsedError;

  /// Serializes this PlacePhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlacePhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlacePhotoCopyWith<PlacePhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacePhotoCopyWith<$Res> {
  factory $PlacePhotoCopyWith(
          PlacePhoto value, $Res Function(PlacePhoto) then) =
      _$PlacePhotoCopyWithImpl<$Res, PlacePhoto>;
  @useResult
  $Res call(
      {String photoReference,
      int? width,
      int? height,
      List<String> htmlAttributions});
}

/// @nodoc
class _$PlacePhotoCopyWithImpl<$Res, $Val extends PlacePhoto>
    implements $PlacePhotoCopyWith<$Res> {
  _$PlacePhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlacePhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoReference = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? htmlAttributions = null,
  }) {
    return _then(_value.copyWith(
      photoReference: null == photoReference
          ? _value.photoReference
          : photoReference // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      htmlAttributions: null == htmlAttributions
          ? _value.htmlAttributions
          : htmlAttributions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlacePhotoImplCopyWith<$Res>
    implements $PlacePhotoCopyWith<$Res> {
  factory _$$PlacePhotoImplCopyWith(
          _$PlacePhotoImpl value, $Res Function(_$PlacePhotoImpl) then) =
      __$$PlacePhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String photoReference,
      int? width,
      int? height,
      List<String> htmlAttributions});
}

/// @nodoc
class __$$PlacePhotoImplCopyWithImpl<$Res>
    extends _$PlacePhotoCopyWithImpl<$Res, _$PlacePhotoImpl>
    implements _$$PlacePhotoImplCopyWith<$Res> {
  __$$PlacePhotoImplCopyWithImpl(
      _$PlacePhotoImpl _value, $Res Function(_$PlacePhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlacePhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoReference = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? htmlAttributions = null,
  }) {
    return _then(_$PlacePhotoImpl(
      photoReference: null == photoReference
          ? _value.photoReference
          : photoReference // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      htmlAttributions: null == htmlAttributions
          ? _value._htmlAttributions
          : htmlAttributions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlacePhotoImpl implements _PlacePhoto {
  const _$PlacePhotoImpl(
      {required this.photoReference,
      this.width,
      this.height,
      final List<String> htmlAttributions = const []})
      : _htmlAttributions = htmlAttributions;

  factory _$PlacePhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlacePhotoImplFromJson(json);

  /// 사진 참조 ID
  @override
  final String photoReference;

  /// 사진 너비
  @override
  final int? width;

  /// 사진 높이
  @override
  final int? height;

  /// HTML 속성
  final List<String> _htmlAttributions;

  /// HTML 속성
  @override
  @JsonKey()
  List<String> get htmlAttributions {
    if (_htmlAttributions is EqualUnmodifiableListView)
      return _htmlAttributions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_htmlAttributions);
  }

  @override
  String toString() {
    return 'PlacePhoto(photoReference: $photoReference, width: $width, height: $height, htmlAttributions: $htmlAttributions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacePhotoImpl &&
            (identical(other.photoReference, photoReference) ||
                other.photoReference == photoReference) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality()
                .equals(other._htmlAttributions, _htmlAttributions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, photoReference, width, height,
      const DeepCollectionEquality().hash(_htmlAttributions));

  /// Create a copy of PlacePhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacePhotoImplCopyWith<_$PlacePhotoImpl> get copyWith =>
      __$$PlacePhotoImplCopyWithImpl<_$PlacePhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlacePhotoImplToJson(
      this,
    );
  }
}

abstract class _PlacePhoto implements PlacePhoto {
  const factory _PlacePhoto(
      {required final String photoReference,
      final int? width,
      final int? height,
      final List<String> htmlAttributions}) = _$PlacePhotoImpl;

  factory _PlacePhoto.fromJson(Map<String, dynamic> json) =
      _$PlacePhotoImpl.fromJson;

  /// 사진 참조 ID
  @override
  String get photoReference;

  /// 사진 너비
  @override
  int? get width;

  /// 사진 높이
  @override
  int? get height;

  /// HTML 속성
  @override
  List<String> get htmlAttributions;

  /// Create a copy of PlacePhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlacePhotoImplCopyWith<_$PlacePhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaceReview _$PlaceReviewFromJson(Map<String, dynamic> json) {
  return _PlaceReview.fromJson(json);
}

/// @nodoc
mixin _$PlaceReview {
  /// 작성자 이름
  String get authorName => throw _privateConstructorUsedError;

  /// 작성자 프로필 사진 URL
  String? get authorPhotoUrl => throw _privateConstructorUsedError;

  /// 평점 (1 ~ 5)
  int get rating => throw _privateConstructorUsedError;

  /// 리뷰 텍스트
  String get text => throw _privateConstructorUsedError;

  /// 작성 시간 (Unix timestamp)
  int get time => throw _privateConstructorUsedError;

  /// 언어
  String? get language => throw _privateConstructorUsedError;

  /// Serializes this PlaceReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceReviewCopyWith<PlaceReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceReviewCopyWith<$Res> {
  factory $PlaceReviewCopyWith(
          PlaceReview value, $Res Function(PlaceReview) then) =
      _$PlaceReviewCopyWithImpl<$Res, PlaceReview>;
  @useResult
  $Res call(
      {String authorName,
      String? authorPhotoUrl,
      int rating,
      String text,
      int time,
      String? language});
}

/// @nodoc
class _$PlaceReviewCopyWithImpl<$Res, $Val extends PlaceReview>
    implements $PlaceReviewCopyWith<$Res> {
  _$PlaceReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorName = null,
    Object? authorPhotoUrl = freezed,
    Object? rating = null,
    Object? text = null,
    Object? time = null,
    Object? language = freezed,
  }) {
    return _then(_value.copyWith(
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaceReviewImplCopyWith<$Res>
    implements $PlaceReviewCopyWith<$Res> {
  factory _$$PlaceReviewImplCopyWith(
          _$PlaceReviewImpl value, $Res Function(_$PlaceReviewImpl) then) =
      __$$PlaceReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String authorName,
      String? authorPhotoUrl,
      int rating,
      String text,
      int time,
      String? language});
}

/// @nodoc
class __$$PlaceReviewImplCopyWithImpl<$Res>
    extends _$PlaceReviewCopyWithImpl<$Res, _$PlaceReviewImpl>
    implements _$$PlaceReviewImplCopyWith<$Res> {
  __$$PlaceReviewImplCopyWithImpl(
      _$PlaceReviewImpl _value, $Res Function(_$PlaceReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaceReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorName = null,
    Object? authorPhotoUrl = freezed,
    Object? rating = null,
    Object? text = null,
    Object? time = null,
    Object? language = freezed,
  }) {
    return _then(_$PlaceReviewImpl(
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceReviewImpl implements _PlaceReview {
  const _$PlaceReviewImpl(
      {required this.authorName,
      this.authorPhotoUrl,
      required this.rating,
      required this.text,
      required this.time,
      this.language});

  factory _$PlaceReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceReviewImplFromJson(json);

  /// 작성자 이름
  @override
  final String authorName;

  /// 작성자 프로필 사진 URL
  @override
  final String? authorPhotoUrl;

  /// 평점 (1 ~ 5)
  @override
  final int rating;

  /// 리뷰 텍스트
  @override
  final String text;

  /// 작성 시간 (Unix timestamp)
  @override
  final int time;

  /// 언어
  @override
  final String? language;

  @override
  String toString() {
    return 'PlaceReview(authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, rating: $rating, text: $text, time: $time, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceReviewImpl &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorPhotoUrl, authorPhotoUrl) ||
                other.authorPhotoUrl == authorPhotoUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, authorName, authorPhotoUrl, rating, text, time, language);

  /// Create a copy of PlaceReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceReviewImplCopyWith<_$PlaceReviewImpl> get copyWith =>
      __$$PlaceReviewImplCopyWithImpl<_$PlaceReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceReviewImplToJson(
      this,
    );
  }
}

abstract class _PlaceReview implements PlaceReview {
  const factory _PlaceReview(
      {required final String authorName,
      final String? authorPhotoUrl,
      required final int rating,
      required final String text,
      required final int time,
      final String? language}) = _$PlaceReviewImpl;

  factory _PlaceReview.fromJson(Map<String, dynamic> json) =
      _$PlaceReviewImpl.fromJson;

  /// 작성자 이름
  @override
  String get authorName;

  /// 작성자 프로필 사진 URL
  @override
  String? get authorPhotoUrl;

  /// 평점 (1 ~ 5)
  @override
  int get rating;

  /// 리뷰 텍스트
  @override
  String get text;

  /// 작성 시간 (Unix timestamp)
  @override
  int get time;

  /// 언어
  @override
  String? get language;

  /// Create a copy of PlaceReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceReviewImplCopyWith<_$PlaceReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
