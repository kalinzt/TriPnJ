// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferenceImpl _$$UserPreferenceImplFromJson(Map<String, dynamic> json) =>
    _$UserPreferenceImpl(
      categoryWeights: (json['categoryWeights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      visitedPlaceIds: (json['visitedPlaceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectedPlaceIds: (json['rejectedPlaceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoritePlaceIds: (json['favoritePlaceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      categoryVisitCount:
          (json['categoryVisitCount'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      averageRatingPreference:
          (json['averageRatingPreference'] as num?)?.toDouble() ?? 4.0,
      averageTravelRadiusKm:
          (json['averageTravelRadiusKm'] as num?)?.toDouble() ?? 5.0,
    );

Map<String, dynamic> _$$UserPreferenceImplToJson(
        _$UserPreferenceImpl instance) =>
    <String, dynamic>{
      'categoryWeights': instance.categoryWeights,
      'visitedPlaceIds': instance.visitedPlaceIds,
      'rejectedPlaceIds': instance.rejectedPlaceIds,
      'favoritePlaceIds': instance.favoritePlaceIds,
      'categoryVisitCount': instance.categoryVisitCount,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'averageRatingPreference': instance.averageRatingPreference,
      'averageTravelRadiusKm': instance.averageTravelRadiusKm,
    };
