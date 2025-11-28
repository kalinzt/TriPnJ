import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place.dart';
import '../models/place_category.dart';

/// 지도 마커 생성 유틸리티
class MapMarkerBuilder {
  /// 현재 위치 마커 생성
  static Future<BitmapDescriptor> createCurrentLocationMarker() async {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  /// 여행지 마커 생성 (카테고리별 색상)
  static Future<BitmapDescriptor> createPlaceMarker({
    required PlaceCategory category,
    bool isSelected = false,
  }) async {
    final hue = _categoryToHue(category);
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  /// 커스텀 마커 생성 (Canvas 사용)
  static Future<BitmapDescriptor> createCustomMarker({
    required PlaceCategory category,
    required String label,
    bool isSelected = false,
    double size = 120.0,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = category.color;

    final markerSize = isSelected ? size * 1.2 : size;
    final radius = markerSize / 2;

    // 그림자 그리기
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      Offset(radius, radius + 4),
      radius * 0.8,
      shadowPaint,
    );

    // 마커 원 그리기
    canvas.drawCircle(
      Offset(radius, radius),
      radius * 0.7,
      paint,
    );

    // 테두리 그리기
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4.0 : 3.0;
    canvas.drawCircle(
      Offset(radius, radius),
      radius * 0.7,
      borderPaint,
    );

    // 아이콘 그리기
    final icon = category.icon;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: radius * 0.6,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    // 그림을 이미지로 변환
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      markerSize.toInt(),
      markerSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }

  /// 라벨이 있는 마커 생성
  static Future<BitmapDescriptor> createLabeledMarker({
    required String label,
    required Color backgroundColor,
    Color textColor = Colors.white,
    double width = 100.0,
    double height = 40.0,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // 배경 그리기
    final paint = Paint()..color = backgroundColor;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);

    // 테두리 그리기
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rect, borderPaint);

    // 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: width, maxWidth: width);
    textPainter.paint(
      canvas,
      Offset(0, (height - textPainter.height) / 2),
    );

    // 그림을 이미지로 변환
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }

  /// Asset 이미지로부터 마커 생성
  static Future<BitmapDescriptor> createMarkerFromAsset({
    required String assetPath,
    int width = 100,
    int height = 100,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final uint8List = byteData.buffer.asUint8List();

    // 이미지 리사이징
    final codec = await ui.instantiateImageCodec(
      uint8List,
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    final resizedByteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      resizedByteData!.buffer.asUint8List(),
    );
  }

  /// 여행지 목록으로부터 마커 세트 생성
  static Future<Set<Marker>> createMarkersFromPlaces({
    required List<Place> places,
    required Function(Place) onMarkerTap,
    Place? selectedPlace,
  }) async {
    final markers = <Marker>{};

    for (final place in places) {
      final category = getCategoryFromPlaceTypes(place.types);
      final isSelected = selectedPlace?.id == place.id;

      final marker = Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        icon: await createPlaceMarker(
          category: category,
          isSelected: isSelected,
        ),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
          onTap: () => onMarkerTap(place),
        ),
        onTap: () => onMarkerTap(place),
      );

      markers.add(marker);
    }

    return markers;
  }

  /// 현재 위치 마커 생성
  static Future<Marker> createCurrentPositionMarker({
    required double latitude,
    required double longitude,
    String title = '현재 위치',
  }) async {
    return Marker(
      markerId: const MarkerId('current_position'),
      position: LatLng(latitude, longitude),
      icon: await createCurrentLocationMarker(),
      infoWindow: InfoWindow(title: title),
      zIndexInt: 1, // 다른 마커 위에 표시
    );
  }

  /// 카테고리를 Google Maps Hue 값으로 변환
  static double _categoryToHue(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.activity:
        return BitmapDescriptor.hueOrange;
      case PlaceCategory.resort:
        return BitmapDescriptor.hueCyan;
      case PlaceCategory.shopping:
        return BitmapDescriptor.hueMagenta;
      case PlaceCategory.attraction:
        return BitmapDescriptor.hueRed;
      case PlaceCategory.restaurant:
        return BitmapDescriptor.hueYellow;
      case PlaceCategory.cafe:
        return BitmapDescriptor.hueRose;
      case PlaceCategory.accommodation:
        return BitmapDescriptor.hueViolet;
      case PlaceCategory.culture:
        return BitmapDescriptor.hueAzure;
      case PlaceCategory.nature:
        return BitmapDescriptor.hueGreen;
      case PlaceCategory.nightlife:
        return BitmapDescriptor.hueViolet;
      case PlaceCategory.all:
        return BitmapDescriptor.hueRed;
    }
  }
}

/// 마커 클러스터링 헬퍼 (추후 구현)
class MarkerClusterHelper {
  /// 줌 레벨에 따라 마커 클러스터링 여부 결정
  static bool shouldCluster(double zoomLevel) {
    return zoomLevel < 12.0;
  }

  /// 근처 마커들을 그룹화
  static List<List<Marker>> groupNearbyMarkers({
    required Set<Marker> markers,
    required double distance, // 미터 단위
  }) {
    // TODO: 실제 클러스터링 로직 구현
    // 현재는 단순히 모든 마커를 개별 그룹으로 반환
    return markers.map((marker) => [marker]).toList();
  }
}
