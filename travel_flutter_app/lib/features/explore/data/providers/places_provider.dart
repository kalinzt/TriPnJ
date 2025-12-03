import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/models/place_category.dart';
import '../repositories/places_repository.dart';
import '../../../local_recommend/data/services/user_action_tracker.dart';

// ============================================
// Repository Providers
// ============================================

/// PlacesRepository Provider
final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepository();
});

/// LocationService Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// ============================================
// State Providers - 검색 파라미터
// ============================================

/// 선택된 카테고리 Provider
final selectedCategoryProvider =
    StateProvider<PlaceCategory>((ref) => PlaceCategory.all);

/// 검색 반경 Provider (미터)
final searchRadiusProvider = StateProvider<int>((ref) => 5000);

/// 검색 키워드 Provider
final searchKeywordProvider = StateProvider<String?>((ref) => null);

/// 정렬 방식 Provider
enum PlaceSortType {
  distance, // 거리순
  rating, // 평점순
  none, // 정렬 없음
}

final placeSortTypeProvider =
    StateProvider<PlaceSortType>((ref) => PlaceSortType.distance);

// ============================================
// FutureProvider - 현재 위치
// ============================================

/// 현재 위치 Provider
final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

/// 현재 주소 정보 Provider (역지오코딩)
final currentAddressProvider = FutureProvider<String>((ref) async {
  try {
    final position = await ref.watch(currentLocationProvider.future);

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;

      // 한국 주소 형식: [시/도] [구/군] [동/읍/면]
      final locality = placemark.locality ?? ''; // 시/도 (예: 서울특별시)
      final subLocality = placemark.subLocality ?? ''; // 구/군 (예: 강남구)
      final thoroughfare = placemark.thoroughfare ?? ''; // 동/읍/면 (예: 역삼동)

      // 주소 조합
      final parts = [locality, subLocality, thoroughfare]
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.isEmpty) {
        return '위치 정보 없음';
      }

      return parts.join(' ');
    }

    return '위치 정보 없음';
  } catch (e) {
    return '위치 확인 중';
  }
});

// ============================================
// FutureProvider - 주변 장소 검색
// ============================================

/// 주변 장소 검색 Parameters
class NearbyPlacesParams {
  final double latitude;
  final double longitude;
  final int radius;
  final PlaceCategory category;
  final String? keyword;

  const NearbyPlacesParams({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.category,
    this.keyword,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyPlacesParams &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radius == other.radius &&
          category == other.category &&
          keyword == other.keyword;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      radius.hashCode ^
      category.hashCode ^
      keyword.hashCode;
}

/// 주변 장소 검색 Provider (파라미터 기반)
final nearbyPlacesProvider =
    FutureProvider.family<List<Place>, NearbyPlacesParams>(
  (ref, params) async {
    final repository = ref.watch(placesRepositoryProvider);
    final sortType = ref.watch(placeSortTypeProvider);

    var places = await repository.getNearbyPlaces(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
      category: params.category,
      keyword: params.keyword,
    );

    // 정렬 적용
    switch (sortType) {
      case PlaceSortType.distance:
        places = repository.sortPlacesByDistance(
          places: places,
          latitude: params.latitude,
          longitude: params.longitude,
        );
        break;
      case PlaceSortType.rating:
        places = repository.sortPlacesByRating(places);
        break;
      case PlaceSortType.none:
        break;
    }

    return places;
  },
);

/// 현재 위치 기반 주변 장소 검색 Provider
final nearbyPlacesFromCurrentLocationProvider =
    FutureProvider<List<Place>>((ref) async {
  // 현재 위치 가져오기
  final location = await ref.watch(currentLocationProvider.future);

  // 검색 파라미터 가져오기
  final category = ref.watch(selectedCategoryProvider);
  final radius = ref.watch(searchRadiusProvider);
  final keyword = ref.watch(searchKeywordProvider);

  // 주변 장소 검색
  final params = NearbyPlacesParams(
    latitude: location.latitude,
    longitude: location.longitude,
    radius: radius,
    category: category,
    keyword: keyword,
  );

  return ref.watch(nearbyPlacesProvider(params).future);
});

// ============================================
// FutureProvider - 텍스트 검색
// ============================================

/// 텍스트 검색 Parameters
class SearchPlacesParams {
  final String query;
  final double? latitude;
  final double? longitude;
  final int? radius;

  const SearchPlacesParams({
    required this.query,
    this.latitude,
    this.longitude,
    this.radius,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchPlacesParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radius == other.radius;

  @override
  int get hashCode =>
      query.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      radius.hashCode;
}

/// 텍스트 검색 Provider
final searchPlacesProvider =
    FutureProvider.family<List<Place>, SearchPlacesParams>(
  (ref, params) async {
    final repository = ref.watch(placesRepositoryProvider);

    return await repository.searchPlaces(
      query: params.query,
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
    );
  },
);

// ============================================
// FutureProvider - 장소 상세 정보
// ============================================

/// 장소 상세 정보 Provider
final placeDetailsProvider = FutureProvider.family<Place, String>(
  (ref, placeId) async {
    final repository = ref.watch(placesRepositoryProvider);
    return await repository.getPlaceDetails(placeId: placeId);
  },
);

// ============================================
// FutureProvider - 자동완성
// ============================================

/// 자동완성 Parameters
class AutocompleteParams {
  final String input;
  final double? latitude;
  final double? longitude;
  final int? radius;

  const AutocompleteParams({
    required this.input,
    this.latitude,
    this.longitude,
    this.radius,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteParams &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radius == other.radius;

  @override
  int get hashCode =>
      input.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      radius.hashCode;
}

/// 자동완성 Provider
final autocompleteSuggestionsProvider = FutureProvider.family<
    List<Map<String, dynamic>>, AutocompleteParams>(
  (ref, params) async {
    final repository = ref.watch(placesRepositoryProvider);

    return await repository.getAutocompleteSuggestions(
      input: params.input,
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
    );
  },
);

// ============================================
// StateNotifierProvider - 장소 목록 관리
// ============================================

/// 장소 목록 상태
class PlacesState {
  final List<Place> places;
  final bool isLoading;
  final String? error;

  const PlacesState({
    this.places = const [],
    this.isLoading = false,
    this.error,
  });

  PlacesState copyWith({
    List<Place>? places,
    bool? isLoading,
    String? error,
  }) {
    return PlacesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 장소 목록 관리 Notifier
class PlacesNotifier extends StateNotifier<PlacesState> {
  final PlacesRepository _repository;
  final LocationService _locationService;
  final UserActionTracker _actionTracker = UserActionTracker();

  PlacesNotifier(this._repository, this._locationService)
      : super(const PlacesState());

  /// 주변 장소 검색
  Future<void> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000,
    PlaceCategory category = PlaceCategory.all,
    String? keyword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final places = await _repository.getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        category: category,
        keyword: keyword,
      );

      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 현재 위치 기반 주변 장소 검색
  Future<void> searchNearbyPlacesFromCurrentLocation({
    int radius = 5000,
    PlaceCategory category = PlaceCategory.all,
    String? keyword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 현재 위치 가져오기
      final position = await _locationService.getCurrentLocation();

      // 주변 장소 검색
      await searchNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: radius,
        category: category,
        keyword: keyword,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 텍스트로 장소 검색
  Future<void> searchPlacesByText({
    required String query,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final places = await _repository.searchPlaces(
        query: query,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      // 검색 액션 추적
      await _actionTracker.trackSearch(
        query: query,
        resultCount: places.length,
      );

      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 장소 상세 조회 추적
  Future<void> trackPlaceView(Place place) async {
    await _actionTracker.trackViewDetail(
      placeId: place.id,
      placeName: place.name,
    );
  }

  /// 즐겨찾기 추가 추적
  Future<void> trackAddToFavorite(Place place) async {
    await _actionTracker.trackAddToFavorite(
      placeId: place.id,
      placeName: place.name,
      score: place.rating,
    );
  }

  /// 일정에 추가 추적
  Future<void> trackAddToPlan(Place place) async {
    await _actionTracker.trackAddToPlan(
      placeId: place.id,
      placeName: place.name,
      score: place.rating,
    );
  }

  /// 공유 추적
  Future<void> trackShare(Place place) async {
    await _actionTracker.trackShare(
      placeId: place.id,
      placeName: place.name,
    );
  }

  /// 거리 기준 정렬
  void sortByDistance(double latitude, double longitude) {
    final sortedPlaces = _repository.sortPlacesByDistance(
      places: state.places,
      latitude: latitude,
      longitude: longitude,
    );

    state = state.copyWith(places: sortedPlaces);
  }

  /// 평점 기준 정렬
  void sortByRating() {
    final sortedPlaces = _repository.sortPlacesByRating(state.places);
    state = state.copyWith(places: sortedPlaces);
  }

  /// 상태 초기화
  void reset() {
    state = const PlacesState();
  }
}

/// PlacesNotifier Provider
final placesNotifierProvider =
    StateNotifierProvider<PlacesNotifier, PlacesState>((ref) {
  final repository = ref.watch(placesRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  return PlacesNotifier(repository, locationService);
});
