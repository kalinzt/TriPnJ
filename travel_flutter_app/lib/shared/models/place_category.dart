import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 여행지 카테고리
enum PlaceCategory {
  /// 액티비티 (스포츠, 레저 활동)
  activity,

  /// 휴양지 (해변, 리조트)
  resort,

  /// 쇼핑 (쇼핑몰, 백화점, 시장)
  shopping,

  /// 명소 (관광 명소, 랜드마크)
  attraction,

  /// 음식점 (레스토랑, 카페, 바)
  restaurant,

  /// 카페 (커피숍, 디저트 카페)
  cafe,

  /// 숙박 (호텔, 게스트하우스)
  accommodation,

  /// 문화 (박물관, 미술관, 극장)
  culture,

  /// 자연 (공원, 산, 호수)
  nature,

  /// 야간 명소 (나이트라이프, 바, 클럽)
  nightlife,

  /// 모든 카테고리
  all,
}

/// PlaceCategory 확장 메서드
extension PlaceCategoryExtension on PlaceCategory {
  /// 카테고리 이름 (한글)
  String get displayName {
    switch (this) {
      case PlaceCategory.activity:
        return '액티비티';
      case PlaceCategory.resort:
        return '휴양지';
      case PlaceCategory.shopping:
        return '쇼핑';
      case PlaceCategory.attraction:
        return '명소';
      case PlaceCategory.restaurant:
        return '음식점';
      case PlaceCategory.cafe:
        return '카페';
      case PlaceCategory.accommodation:
        return '숙박';
      case PlaceCategory.culture:
        return '문화';
      case PlaceCategory.nature:
        return '자연';
      case PlaceCategory.nightlife:
        return '야간';
      case PlaceCategory.all:
        return '전체';
    }
  }

  /// 카테고리 아이콘
  IconData get icon {
    switch (this) {
      case PlaceCategory.activity:
        return Icons.sports_tennis;
      case PlaceCategory.resort:
        return Icons.beach_access;
      case PlaceCategory.shopping:
        return Icons.shopping_bag;
      case PlaceCategory.attraction:
        return Icons.location_city;
      case PlaceCategory.restaurant:
        return Icons.restaurant;
      case PlaceCategory.cafe:
        return Icons.local_cafe;
      case PlaceCategory.accommodation:
        return Icons.hotel;
      case PlaceCategory.culture:
        return Icons.museum;
      case PlaceCategory.nature:
        return Icons.park;
      case PlaceCategory.nightlife:
        return Icons.nightlife;
      case PlaceCategory.all:
        return Icons.explore;
    }
  }

  /// 카테고리 색상
  Color get color {
    switch (this) {
      case PlaceCategory.activity:
        return AppColors.categoryActivity;
      case PlaceCategory.resort:
        return AppColors.categoryResort;
      case PlaceCategory.shopping:
        return AppColors.categoryShopping;
      case PlaceCategory.attraction:
        return AppColors.categoryAttraction;
      case PlaceCategory.restaurant:
        return AppColors.categoryRestaurant;
      case PlaceCategory.cafe:
        return AppColors.categoryCafe;
      case PlaceCategory.accommodation:
        return AppColors.categoryAccommodation;
      case PlaceCategory.culture:
        return AppColors.categoryCulture;
      case PlaceCategory.nature:
        return AppColors.categoryNature;
      case PlaceCategory.nightlife:
        return AppColors.categoryNightlife;
      case PlaceCategory.all:
        return AppColors.primary;
    }
  }

  /// Google Places API types 매핑
  /// https://developers.google.com/maps/documentation/places/web-service/supported_types
  List<String> get googlePlacesTypes {
    switch (this) {
      case PlaceCategory.activity:
        return [
          'amusement_park',
          'aquarium',
          'zoo',
          'bowling_alley',
          'gym',
          'stadium',
          'spa',
        ];

      case PlaceCategory.resort:
        return [
          'campground',
          'rv_park',
          'lodging',
        ];

      case PlaceCategory.shopping:
        return [
          'shopping_mall',
          'department_store',
          'clothing_store',
          'jewelry_store',
          'shoe_store',
          'supermarket',
          'convenience_store',
        ];

      case PlaceCategory.attraction:
        return [
          'tourist_attraction',
          'point_of_interest',
          'landmark',
          'city_hall',
          'art_gallery',
        ];

      case PlaceCategory.restaurant:
        return [
          'restaurant',
          'meal_delivery',
          'meal_takeaway',
          'bakery',
        ];

      case PlaceCategory.cafe:
        return [
          'cafe',
          'coffee_shop',
          'bakery',
        ];

      case PlaceCategory.accommodation:
        return [
          'lodging',
          'hotel',
          'motel',
        ];

      case PlaceCategory.culture:
        return [
          'museum',
          'art_gallery',
          'library',
          'movie_theater',
        ];

      case PlaceCategory.nature:
        return [
          'park',
          'natural_feature',
          'campground',
        ];

      case PlaceCategory.nightlife:
        return [
          'night_club',
          'bar',
        ];

      case PlaceCategory.all:
        return [];
    }
  }

  /// 카테고리의 첫 번째 Google Places type 반환
  /// (단일 type이 필요한 API 호출에 사용)
  String? get primaryGooglePlaceType {
    final types = googlePlacesTypes;
    return types.isNotEmpty ? types.first : null;
  }

  /// Google Places API type으로 Google Places 검색 쿼리 문자열 생성
  String get searchQuery {
    switch (this) {
      case PlaceCategory.activity:
        return 'activity OR amusement park OR sports';
      case PlaceCategory.resort:
        return 'resort OR beach OR spa';
      case PlaceCategory.shopping:
        return 'shopping mall OR store OR market';
      case PlaceCategory.attraction:
        return 'tourist attraction OR landmark OR sightseeing';
      case PlaceCategory.restaurant:
        return 'restaurant OR dining';
      case PlaceCategory.cafe:
        return 'cafe OR coffee shop';
      case PlaceCategory.accommodation:
        return 'hotel OR lodging OR accommodation';
      case PlaceCategory.culture:
        return 'museum OR art gallery OR theater';
      case PlaceCategory.nature:
        return 'park OR nature OR garden';
      case PlaceCategory.nightlife:
        return 'nightclub OR bar OR nightlife';
      case PlaceCategory.all:
        return 'tourist attraction OR point of interest';
    }
  }
}

/// Place type을 카테고리로 변환하는 유틸리티 함수
PlaceCategory? getCategoryFromPlaceType(String type) {
  for (final category in PlaceCategory.values) {
    if (category.googlePlacesTypes.contains(type)) {
      return category;
    }
  }
  return null;
}

/// Place types 목록에서 가장 관련성 높은 카테고리 추출
PlaceCategory getCategoryFromPlaceTypes(List<String> types) {
  if (types.isEmpty) return PlaceCategory.attraction;

  // 각 타입에 대해 카테고리 매칭
  for (final type in types) {
    final category = getCategoryFromPlaceType(type);
    if (category != null && category != PlaceCategory.all) {
      return category;
    }
  }

  // 매칭되는 카테고리가 없으면 기본값
  return PlaceCategory.attraction;
}
