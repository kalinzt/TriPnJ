import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/route_option_model.dart';
import '../../../../core/constants/app_colors.dart';

/// 경로 검색 결과를 지도에 표시하는 위젯
class RouteMapView extends StatefulWidget {
  final RouteOption route;
  final VoidCallback? onSelect;

  const RouteMapView({
    super.key,
    required this.route,
    this.onSelect,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  @override
  void didUpdateWidget(RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route != widget.route) {
      _initializeMapData();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 지도 데이터 초기화
  void _initializeMapData() {
    final coordinates = widget.route.coordinates;
    if (coordinates == null) return;

    // 마커 생성
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          coordinates.startLatitude,
          coordinates.startLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: '출발지'),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          coordinates.endLatitude,
          coordinates.endLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: '도착지'),
      ),
    };

    // 경유지 마커 추가
    for (int i = 0; i < coordinates.waypoints.length; i++) {
      final waypoint = coordinates.waypoints[i];
      final lat = waypoint['lat'];
      final lng = waypoint['lng'];

      if (lat != null && lng != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('waypoint_$i'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(title: '경유지 ${i + 1}'),
          ),
        );
      }
    }

    // 경로선 생성
    final routePoints = <LatLng>[
      LatLng(coordinates.startLatitude, coordinates.startLongitude),
    ];

    // 경유지 추가
    for (final waypoint in coordinates.waypoints) {
      final lat = waypoint['lat'];
      final lng = waypoint['lng'];
      if (lat != null && lng != null) {
        routePoints.add(LatLng(lat, lng));
      }
    }

    routePoints.add(
      LatLng(coordinates.endLatitude, coordinates.endLongitude),
    );

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    };

    if (mounted) {
      setState(() {});
    }
  }

  /// 지도 생성 완료 콜백
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // 모든 마커를 포함하도록 카메라 조정
    final coordinates = widget.route.coordinates;
    if (coordinates != null) {
      final bounds = _calculateBounds(coordinates);
      Future.delayed(const Duration(milliseconds: 300), () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      });
    }
  }

  /// 좌표 경계 계산
  LatLngBounds _calculateBounds(RouteCoordinates coordinates) {
    double minLat = coordinates.startLatitude;
    double maxLat = coordinates.startLatitude;
    double minLng = coordinates.startLongitude;
    double maxLng = coordinates.startLongitude;

    // 도착지 포함
    if (coordinates.endLatitude < minLat) minLat = coordinates.endLatitude;
    if (coordinates.endLatitude > maxLat) maxLat = coordinates.endLatitude;
    if (coordinates.endLongitude < minLng) minLng = coordinates.endLongitude;
    if (coordinates.endLongitude > maxLng) maxLng = coordinates.endLongitude;

    // 경유지 포함
    for (final waypoint in coordinates.waypoints) {
      final lat = waypoint['lat'];
      final lng = waypoint['lng'];
      if (lat != null && lng != null) {
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = widget.route.coordinates;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 경로 정보
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.route.vehicleInfo ?? '정보 없음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.onSelect != null)
                      ElevatedButton(
                        onPressed: widget.onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('선택'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '소요 시간: ${widget.route.durationMinutes}분 | 거리: ${widget.route.distance}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (widget.route.details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.route.details!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 지도
          if (coordinates != null)
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      coordinates.startLatitude,
                      coordinates.startLongitude,
                    ),
                    zoom: 12,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Text(
                '지도 정보를 사용할 수 없습니다',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
