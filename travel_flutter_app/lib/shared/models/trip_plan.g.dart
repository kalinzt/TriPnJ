// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripPlanImpl _$$TripPlanImplFromJson(Map<String, dynamic> json) =>
    _$TripPlanImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      destination: json['destination'] as String,
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble(),
      dailyPlans: (json['dailyPlans'] as List<dynamic>?)
              ?.map((e) => DailyPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      memo: json['memo'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TripPlanImplToJson(_$TripPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'destination': instance.destination,
      'destinationLatitude': instance.destinationLatitude,
      'destinationLongitude': instance.destinationLongitude,
      'dailyPlans': instance.dailyPlans,
      'memo': instance.memo,
      'budget': instance.budget,
      'thumbnailUrl': instance.thumbnailUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$DailyPlanImpl _$$DailyPlanImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanImpl(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String?,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$$DailyPlanImplToJson(_$DailyPlanImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'activities': instance.activities,
      'memo': instance.memo,
    };

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    _$ActivityImpl(
      id: json['id'] as String,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      place: json['place'] == null
          ? null
          : Place.fromJson(json['place'] as Map<String, dynamic>),
      title: json['title'] as String?,
      type: $enumDecodeNullable(_$ActivityTypeEnumMap, json['type']) ??
          ActivityType.visit,
      memo: json['memo'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      reservationInfo: json['reservationInfo'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      selectedRoute: json['selectedRoute'] == null
          ? null
          : RouteOption.fromJson(json['selectedRoute'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'place': instance.place,
      'title': instance.title,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'memo': instance.memo,
      'estimatedCost': instance.estimatedCost,
      'reservationInfo': instance.reservationInfo,
      'isCompleted': instance.isCompleted,
      'selectedRoute': instance.selectedRoute,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.visit: 'visit',
  ActivityType.meal: 'meal',
  ActivityType.accommodation: 'accommodation',
  ActivityType.transportation: 'transportation',
  ActivityType.shopping: 'shopping',
  ActivityType.activity: 'activity',
  ActivityType.rest: 'rest',
  ActivityType.other: 'other',
};
