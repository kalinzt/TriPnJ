import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/models/place.dart';
import '../../../explore/presentation/screens/place_detail_screen.dart';
import 'dart:ui' as ui;

/// 추천 장소 지도 뷰 위젯
///
/// Google Map을 사용하여 추천 장소를 마커로 표시
class RecommendationMapView extends ConsumerStatefulWidget {
  final List<Place> places;
  final Map<String, double>? scores; // placeId -> 점수 매핑

  const RecommendationMapView({
    super.key,
    required this.places,
    this.scores,
  });

  @override
  ConsumerState<RecommendationMapView> createState() => _RecommendationMapViewState();
}

class _RecommendationMapViewState extends ConsumerState<RecommendationMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Place? _selectedPlace;
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(RecommendationMapView oldWidget) {
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
    try {
      // 현재 위치 가져오기
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);

      // 마커 생성
      await _updateMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 마커 업데이트
  Future<void> _updateMarkers() async {
    final markers = <Marker>{};

    // 추천 장소 마커 추가
    for (final place in widget.places) {
      final score = widget.scores?[place.id];
      final markerIcon = await _createScoreMarker(score ?? 0.5);

      markers.add(Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        icon: markerIcon,
        onTap: () => _onMarkerTap(place),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: score != null ? '추천 점수: ${(score * 100).toInt()}%' : null,
          onTap: () => _navigateToDetail(place),
        ),
      ));
    }

    // 현재 위치 마커 추가
    if (_currentLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: '현재 위치'),
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  /// 점수에 따른 마커 생성
  ///
  /// 점수가 높을수록 초록색, 낮을수록 노란색/주황색
  Future<BitmapDescriptor> _createScoreMarker(double score) async {
    // 점수에 따른 색상 결정
    final Color color;
    if (score >= 0.7) {
      // 높은 점수: 초록색
      color = Colors.green;
    } else if (score >= 0.5) {
      // 중간 점수: 노란색
      color = Colors.orange;
    } else {
      // 낮은 점수: 주황색
      color = Colors.deepOrange;
    }

    // 커스텀 마커 생성
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = 100.0;

    // 마커 핀 그리기
    final paint = Paint()..color = color;

    // 핀 형태 그리기 (원 + 삼각형)
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 3,
      paint,
    );

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 3,
      borderPaint,
    );

    // 이미지로 변환
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// 마커 탭 처리
  void _onMarkerTap(Place place) {
    setState(() {
      _selectedPlace = place;
    });
  }

  /// 장소 상세 페이지로 이동
  void _navigateToDetail(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place: place),
      ),
    );
  }

  /// 지도 생성 완료 콜백
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // 모든 마커를 포함하도록 카메라 조정
    if (widget.places.isNotEmpty && _currentLocation != null) {
      final positions = widget.places
          .map((place) => LatLng(place.latitude, place.longitude))
          .toList();
      positions.add(_currentLocation!);

      Future.delayed(const Duration(milliseconds: 500), () {
        _fitBounds(positions);
      });
    }
  }

  /// 모든 마커를 포함하도록 카메라 조정
  void _fitBounds(List<LatLng> positions) {
    if (positions.isEmpty || _mapController == null) return;

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

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  /// 현재 위치로 이동
  void _moveToCurrentLocation() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentLocation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '위치 정보를 가져올 수 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: 14.0,
          ),
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          onTap: (_) {
            // 지도 탭 시 선택 해제
            setState(() {
              _selectedPlace = null;
            });
          },
        ),

        // 현재 위치 버튼
        Positioned(
          right: 16,
          bottom: _selectedPlace != null ? 200 : 80,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _moveToCurrentLocation,
            child: const Icon(
              Icons.my_location,
              color: AppColors.primary,
            ),
          ),
        ),

        // 선택된 장소 정보 카드
        if (_selectedPlace != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSelectedPlaceCard(_selectedPlace!),
          ),
      ],
    );
  }

  /// 선택된 장소 정보 카드
  Widget _buildSelectedPlaceCard(Place place) {
    final score = widget.scores?[place.id];

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
                  setState(() {
                    _selectedPlace = null;
                  });
                },
              ),
            ],
          ),
          if (score != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.stars, size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '추천 점수: ${(score * 100).toInt()}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
          if (place.rating != null) ...[
            const SizedBox(height: 8),
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
              onPressed: () => _navigateToDetail(place),
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
