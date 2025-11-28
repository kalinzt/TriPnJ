import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/widgets/map_marker_builder.dart';
import '../providers/map_provider.dart';
import '../screens/place_detail_screen.dart';

/// 여행지 지도 뷰 위젯
class PlacesMapView extends ConsumerStatefulWidget {
  final List<Place> places;
  final double? currentLatitude;
  final double? currentLongitude;

  const PlacesMapView({
    super.key,
    required this.places,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  ConsumerState<PlacesMapView> createState() => _PlacesMapViewState();
}

class _PlacesMapViewState extends ConsumerState<PlacesMapView> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(PlacesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.places != oldWidget.places) {
      _updateMarkers();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 지도 초기화
  Future<void> _initializeMap() async {
    // 마커 생성
    await _updateMarkers();

    // 초기 카메라 위치 설정
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mapViewProvider.notifier).animateToPosition(
              latitude: widget.currentLatitude!,
              longitude: widget.currentLongitude!,
              zoom: 14.0,
            );
      });
    }
  }

  /// 마커 업데이트
  Future<void> _updateMarkers() async {
    final selectedPlace = ref.read(mapViewProvider).selectedPlace;
    final markers = await MapMarkerBuilder.createMarkersFromPlaces(
      places: widget.places,
      onMarkerTap: _onMarkerTap,
      selectedPlace: selectedPlace,
    );

    // 현재 위치 마커 추가
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      final currentMarker =
          await MapMarkerBuilder.createCurrentPositionMarker(
        latitude: widget.currentLatitude!,
        longitude: widget.currentLongitude!,
      );
      markers.add(currentMarker);
    }

    ref.read(mapViewProvider.notifier).updateMarkers(markers);
  }

  /// 마커 탭 처리
  void _onMarkerTap(Place place) {
    ref.read(mapViewProvider.notifier).selectPlace(place);
  }

  /// 지도 생성 완료 콜백
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    ref.read(mapViewProvider.notifier).setMapController(controller);

    // 모든 마커를 포함하도록 카메라 조정
    if (widget.places.isNotEmpty) {
      final positions = widget.places
          .map((place) => LatLng(place.latitude, place.longitude))
          .toList();

      // 현재 위치도 포함
      if (widget.currentLatitude != null && widget.currentLongitude != null) {
        positions.add(LatLng(
          widget.currentLatitude!,
          widget.currentLongitude!,
        ));
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(mapViewProvider.notifier).fitBounds(
              positions: positions,
              padding: 80,
            );
      });
    }
  }

  /// 카메라 이동 콜백
  void _onCameraMove(CameraPosition position) {
    ref.read(mapViewProvider.notifier).updateCameraPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapViewProvider);
    final selectedPlace = mapState.selectedPlace;

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: mapState.cameraPosition,
          markers: mapState.markers,
          onCameraMove: _onCameraMove,
          myLocationEnabled: false, // 커스텀 마커 사용
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          mapType: MapType.normal,
          onTap: (_) {
            // 지도 탭 시 선택 해제
            ref.read(mapViewProvider.notifier).selectPlace(null);
          },
        ),

        // 현재 위치 버튼
        if (widget.currentLatitude != null && widget.currentLongitude != null)
          Positioned(
            right: 16,
            bottom: selectedPlace != null ? 240 : 100,
            child: _buildMyLocationButton(),
          ),

        // 줌 컨트롤
        Positioned(
          right: 16,
          bottom: selectedPlace != null ? 320 : 180,
          child: _buildZoomControls(),
        ),

        // 선택된 장소 정보 카드
        if (selectedPlace != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSelectedPlaceCard(selectedPlace),
          ),

        // 로딩 인디케이터
        if (mapState.isLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  /// 현재 위치 버튼
  Widget _buildMyLocationButton() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.white,
      onPressed: () {
        if (widget.currentLatitude != null && widget.currentLongitude != null) {
          ref.read(mapViewProvider.notifier).animateToPosition(
                latitude: widget.currentLatitude!,
                longitude: widget.currentLongitude!,
                zoom: 15.0,
              );
        }
      },
      child: const Icon(
        Icons.my_location,
        color: AppColors.primary,
      ),
    );
  }

  /// 줌 컨트롤
  Widget _buildZoomControls() {
    return Column(
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () async {
            final controller = _mapController;
            if (controller != null) {
              final currentZoom = await controller.getZoomLevel();
              controller.animateCamera(
                CameraUpdate.zoomTo(currentZoom + 1),
              );
            }
          },
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () async {
            final controller = _mapController;
            if (controller != null) {
              final currentZoom = await controller.getZoomLevel();
              controller.animateCamera(
                CameraUpdate.zoomTo(currentZoom - 1),
              );
            }
          },
          child: const Icon(Icons.remove, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  /// 선택된 장소 정보 카드
  Widget _buildSelectedPlaceCard(Place place) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(mapViewProvider.notifier).selectPlace(null);
                },
              ),
            ],
          ),
          if (place.rating != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  place.rating!.toStringAsFixed(1),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (place.userRatingsTotal != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${place.userRatingsTotal})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceDetailScreen(place: place),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('상세 정보 보기'),
            ),
          ),
        ],
      ),
    );
  }
}
