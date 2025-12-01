// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CachedRecommendationImpl _$$CachedRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$CachedRecommendationImpl(
      places: (json['places'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList(),
      scores: (json['scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      searchRadiusMeters: (json['searchRadiusMeters'] as num?)?.toInt() ?? 5000,
    );

Map<String, dynamic> _$$CachedRecommendationImplToJson(
        _$CachedRecommendationImpl instance) =>
    <String, dynamic>{
      'places': instance.places,
      'scores': instance.scores,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'searchRadiusMeters': instance.searchRadiusMeters,
    };
