import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/models/place.dart';

// ============================================
// 지도 상태 클래스
// ============================================

/// 지도 뷰 상태
class MapViewState {
  final GoogleMapController? controller;
  final CameraPosition cameraPosition;
  final Set<Marker> markers;
  final Place? selectedPlace;
  final bool isLoading;

  const MapViewState({
    this.controller,
    required this.cameraPosition,
    this.markers = const {},
    this.selectedPlace,
    this.isLoading = false,
  });

  MapViewState copyWith({
    GoogleMapController? controller,
    CameraPosition? cameraPosition,
    Set<Marker>? markers,
    Place? selectedPlace,
    bool? isLoading,
    bool clearSelectedPlace = false,
  }) {
    return MapViewState(
      controller: controller ?? this.controller,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markers: markers ?? this.markers,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================
// 지도 StateNotifier
// ============================================

/// 지도 뷰 상태 관리 Notifier
class MapViewNotifier extends StateNotifier<MapViewState> {
  MapViewNotifier()
      : super(
          const MapViewState(
            cameraPosition: CameraPosition(
              target: LatLng(37.5665, 126.9780), // 서울 기본 위치
              zoom: 14.0,
            ),
          ),
        );

  /// 지도 컨트롤러 설정
  void setMapController(GoogleMapController controller) {
    state = state.copyWith(controller: controller);
  }

  /// 카메라 위치 업데이트
  void updateCameraPosition(CameraPosition position) {
    state = state.copyWith(cameraPosition: position);
  }

  /// 특정 위치로 카메라 이동 (애니메이션)
  Future<void> animateToPosition({
    required double latitude,
    required double longitude,
    double zoom = 15.0,
  }) async {
    if (state.controller == null) return;

    final position = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );

    await state.controller!.animateCamera(
      CameraUpdate.newCameraPosition(position),
    );

    state = state.copyWith(cameraPosition: position);
  }

  /// 여러 위치를 모두 포함하도록 카메라 조정
  Future<void> fitBounds({
    required List<LatLng> positions,
    double padding = 50.0,
  }) async {
    if (state.controller == null || positions.isEmpty) return;

    // 경계 계산
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await state.controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  /// 마커 업데이트
  void updateMarkers(Set<Marker> markers) {
    state = state.copyWith(markers: markers);
  }

  /// 마커 추가
  void addMarker(Marker marker) {
    final updatedMarkers = Set<Marker>.from(state.markers)..add(marker);
    state = state.copyWith(markers: updatedMarkers);
  }

  /// 마커 제거
  void removeMarker(String markerId) {
    final updatedMarkers = state.markers
        .where((marker) => marker.markerId.value != markerId)
        .toSet();
    state = state.copyWith(markers: updatedMarkers);
  }

  /// 모든 마커 제거
  void clearMarkers() {
    state = state.copyWith(markers: {});
  }

  /// 선택된 장소 설정
  void selectPlace(Place? place) {
    state = state.copyWith(
      selectedPlace: place,
      clearSelectedPlace: place == null,
    );

    // 장소가 선택되면 해당 위치로 카메라 이동
    if (place != null) {
      animateToPosition(
        latitude: place.latitude,
        longitude: place.longitude,
        zoom: 16.0,
      );
    }
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 컨트롤러 해제
  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

// ============================================
// Providers
// ============================================

/// 지도 뷰 상태 Provider
final mapViewProvider = StateNotifierProvider<MapViewNotifier, MapViewState>(
  (ref) => MapViewNotifier(),
);

/// 현재 카메라 위치 Provider
final currentCameraPositionProvider = Provider<CameraPosition>((ref) {
  return ref.watch(mapViewProvider).cameraPosition;
});

/// 현재 마커 목록 Provider
final currentMarkersProvider = Provider<Set<Marker>>((ref) {
  return ref.watch(mapViewProvider).markers;
});

/// 선택된 장소 Provider
final selectedPlaceProvider = Provider<Place?>((ref) {
  return ref.watch(mapViewProvider).selectedPlace;
});

/// 지도 로딩 상태 Provider
final mapLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mapViewProvider).isLoading;
});
