import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 캘린더 날짜에 표시되는 이벤트 마커
class CalendarEventMarker extends StatelessWidget {
  /// 이벤트 개수
  final int eventCount;

  /// 마커 크기
  final double size;

  /// 최대 표시 개수 (이 개수 초과 시 숫자로 표시)
  final int maxDots;

  const CalendarEventMarker({
    super.key,
    required this.eventCount,
    this.size = 6.0,
    this.maxDots = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (eventCount == 0) {
      return const SizedBox.shrink();
    }

    // 3개 이하인 경우 점으로 표시
    if (eventCount <= maxDots) {
      return _buildDots();
    }

    // 3개 초과인 경우 숫자로 표시
    return _buildCountBadge();
  }

  /// 점 형태 마커 (1~3개)
  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        eventCount,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.15),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  /// 숫자 배지 형태 마커 (4개 이상)
  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        eventCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 캘린더에 표시되는 선택된 날짜 장식
class CalendarSelectedDecoration extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final bool isToday;

  const CalendarSelectedDecoration({
    super.key,
    required this.child,
    this.isSelected = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected && !isToday) {
      return child;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: isToday && !isSelected
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

/// 여러 여행 계획을 색상으로 구분하여 표시하는 마커
class MultiTripMarker extends StatelessWidget {
  /// 여행 계획 개수
  final int tripCount;

  /// 마커 높이
  final double height;

  const MultiTripMarker({
    super.key,
    required this.tripCount,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (tripCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: height,
      decoration: BoxDecoration(
        color: _getColorForCount(tripCount),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  /// 여행 개수에 따른 색상 반환
  Color _getColorForCount(int count) {
    if (count == 1) {
      return AppColors.primary;
    } else if (count == 2) {
      return AppColors.secondary;
    } else {
      return AppColors.warning;
    }
  }
}

/// 여행 계획 타입별 아이콘 마커
class TripTypeMarker extends StatelessWidget {
  /// 진행 중 여부
  final bool isOngoing;

  /// 예정된 여행 여부
  final bool isUpcoming;

  /// 완료된 여행 여부
  final bool isCompleted;

  const TripTypeMarker({
    super.key,
    this.isOngoing = false,
    this.isUpcoming = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    if (isOngoing) {
      iconData = Icons.flight_takeoff;
      iconColor = AppColors.success;
    } else if (isCompleted) {
      iconData = Icons.check_circle;
      iconColor = AppColors.textSecondary;
    } else {
      iconData = Icons.event;
      iconColor = AppColors.primary;
    }

    return Icon(
      iconData,
      size: 12,
      color: iconColor,
    );
  }
}
