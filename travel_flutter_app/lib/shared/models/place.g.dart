// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      priceLevel: (json['priceLevel'] as num?)?.toInt(),
      openingHours: json['openingHours'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt(),
      description: json['description'] as String?,
      businessStatus: json['businessStatus'] as String?,
    );

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'photos': instance.photos,
      'types': instance.types,
      'priceLevel': instance.priceLevel,
      'openingHours': instance.openingHours,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'userRatingsTotal': instance.userRatingsTotal,
      'description': instance.description,
      'businessStatus': instance.businessStatus,
    };

_$PlacePhotoImpl _$$PlacePhotoImplFromJson(Map<String, dynamic> json) =>
    _$PlacePhotoImpl(
      photoReference: json['photoReference'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      htmlAttributions: (json['htmlAttributions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlacePhotoImplToJson(_$PlacePhotoImpl instance) =>
    <String, dynamic>{
      'photoReference': instance.photoReference,
      'width': instance.width,
      'height': instance.height,
      'htmlAttributions': instance.htmlAttributions,
    };

_$PlaceReviewImpl _$$PlaceReviewImplFromJson(Map<String, dynamic> json) =>
    _$PlaceReviewImpl(
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      rating: (json['rating'] as num).toInt(),
      text: json['text'] as String,
      time: (json['time'] as num).toInt(),
      language: json['language'] as String?,
    );

Map<String, dynamic> _$$PlaceReviewImplToJson(_$PlaceReviewImpl instance) =>
    <String, dynamic>{
      'authorName': instance.authorName,
      'authorPhotoUrl': instance.authorPhotoUrl,
      'rating': instance.rating,
      'text': instance.text,
      'time': instance.time,
      'language': instance.language,
    };
