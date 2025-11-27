import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// 여행지 정보 모델
@freezed
class Place with _$Place {
  const factory Place({
    /// Google Places ID
    required String id,

    /// 장소 이름
    required String name,

    /// 주소
    required String address,

    /// 위도
    required double latitude,

    /// 경도
    required double longitude,

    /// 평점 (0.0 ~ 5.0)
    double? rating,

    /// 사진 URL 목록
    @Default([]) List<String> photos,

    /// 장소 유형 (예: restaurant, tourist_attraction)
    @Default([]) List<String> types,

    /// 가격 레벨 (0: 무료, 1: 저렴, 2: 보통, 3: 비쌈, 4: 매우 비쌈)
    int? priceLevel,

    /// 영업 시간 정보
    String? openingHours,

    /// 전화번호
    String? phoneNumber,

    /// 웹사이트
    String? website,

    /// 리뷰 수
    int? userRatingsTotal,

    /// 장소 설명
    String? description,

    /// 비즈니스 상태 (OPERATIONAL, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY)
    String? businessStatus,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  /// Google Places API 응답에서 Place 객체 생성
  factory Place.fromGooglePlaces(Map<String, dynamic> json) {
    // geometry.location에서 위치 정보 추출
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as double? ?? 0.0;
    final lng = location?['lng'] as double? ?? 0.0;

    // photos에서 photo_reference 추출
    final photosJson = json['photos'] as List<dynamic>?;
    final photos = photosJson
            ?.map((photo) => photo['photo_reference'] as String? ?? '')
            .where((ref) => ref.isNotEmpty)
            .toList() ??
        [];

    // types 추출
    final typesJson = json['types'] as List<dynamic>?;
    final types = typesJson?.map((type) => type.toString()).toList() ?? [];

    return Place(
      id: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['formatted_address'] as String? ??
          json['vicinity'] as String? ??
          '',
      latitude: lat,
      longitude: lng,
      rating: (json['rating'] as num?)?.toDouble(),
      photos: photos,
      types: types,
      priceLevel: json['price_level'] as int?,
      openingHours: json['opening_hours']?['weekday_text']?.toString(),
      phoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      userRatingsTotal: json['user_ratings_total'] as int?,
      description: json['editorial_summary']?['overview'] as String?,
      businessStatus: json['business_status'] as String?,
    );
  }
}

/// 장소 사진 정보
@freezed
class PlacePhoto with _$PlacePhoto {
  const factory PlacePhoto({
    /// 사진 참조 ID
    required String photoReference,

    /// 사진 너비
    int? width,

    /// 사진 높이
    int? height,

    /// HTML 속성
    @Default([]) List<String> htmlAttributions,
  }) = _PlacePhoto;

  factory PlacePhoto.fromJson(Map<String, dynamic> json) =>
      _$PlacePhotoFromJson(json);

  /// Google Places API 응답에서 PlacePhoto 객체 생성
  factory PlacePhoto.fromGooglePlaces(Map<String, dynamic> json) {
    final attributions = json['html_attributions'] as List<dynamic>?;
    return PlacePhoto(
      photoReference: json['photo_reference'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      htmlAttributions:
          attributions?.map((attr) => attr.toString()).toList() ?? [],
    );
  }
}

/// 장소 리뷰 정보
@freezed
class PlaceReview with _$PlaceReview {
  const factory PlaceReview({
    /// 작성자 이름
    required String authorName,

    /// 작성자 프로필 사진 URL
    String? authorPhotoUrl,

    /// 평점 (1 ~ 5)
    required int rating,

    /// 리뷰 텍스트
    required String text,

    /// 작성 시간 (Unix timestamp)
    required int time,

    /// 언어
    String? language,
  }) = _PlaceReview;

  factory PlaceReview.fromJson(Map<String, dynamic> json) =>
      _$PlaceReviewFromJson(json);

  /// Google Places API 응답에서 PlaceReview 객체 생성
  factory PlaceReview.fromGooglePlaces(Map<String, dynamic> json) {
    return PlaceReview(
      authorName: json['author_name'] as String? ?? '',
      authorPhotoUrl: json['profile_photo_url'] as String?,
      rating: json['rating'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      time: json['time'] as int? ?? 0,
      language: json['language'] as String?,
    );
  }
}
