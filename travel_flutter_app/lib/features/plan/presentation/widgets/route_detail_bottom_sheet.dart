import 'package:flutter/material.dart';
import '../../data/models/route_option_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// 경로 상세 정보를 보여주는 바텀시트 (구글 맵 스타일)
class RouteDetailBottomSheet extends StatelessWidget {
  final RouteOption route;

  const RouteDetailBottomSheet({
    super.key,
    required this.route,
  });

  /// 바텀시트 표시
  static Future<void> show(BuildContext context, RouteOption route) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteDetailBottomSheet(route: route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '경로 상세 정보',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '약 ${route.durationMinutes}분',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.straighten,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                route.distance,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 경로 타임라인
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: _buildDetailedTimeline(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 상세 타임라인 생성 (출발역 → 교통수단 → 도착역 → 환승...)
  List<Widget> _buildDetailedTimeline() {
    final List<Widget> timeline = [];
    final steps = route.transportOptions ?? [];

    if (steps.isEmpty) {
      // 교통 수단 정보가 없으면 기본 출발지/도착지만 표시
      if (route.departureLocation != null) {
        timeline.add(_buildTimelineItem(
          icon: Icons.trip_origin,
          iconColor: AppColors.primary,
          title: route.departureLocation!,
          isFirst: true,
          isLast: route.arrivalLocation == null,
        ));
      }
      if (route.arrivalLocation != null) {
        timeline.add(_buildTimelineItem(
          icon: Icons.location_on,
          iconColor: Colors.red,
          title: route.arrivalLocation!,
          isFirst: route.departureLocation == null,
          isLast: true,
        ));
      }
      return timeline;
    }

    // 대중교통 step만 필터링 (도보 제외)
    final transitSteps = steps.where((step) => step.type == 'transit').toList();

    // 각 교통 수단 단계를 출발역 → 교통수단 → 도착역 형태로 표시
    for (int i = 0; i < transitSteps.length; i++) {
      final step = transitSteps[i];
      final isFirst = i == 0;
      final isLast = i == transitSteps.length - 1;

      // 출발역 표시
      if (step.departureStop != null) {
        timeline.add(_buildTimelineItem(
          icon: Icons.trip_origin,
          iconColor: isFirst ? AppColors.primary : Colors.grey,
          title: step.departureStop!,
          isFirst: isFirst,
          isLast: false,
        ));
      }

      // 교통 수단 뱃지
      timeline.add(_buildTransportStep(step));

      // 도착역 표시
      if (step.arrivalStop != null) {
        timeline.add(_buildTimelineItem(
          icon: isLast ? Icons.location_on : Icons.swap_horiz,
          iconColor: isLast ? Colors.red : Colors.orange,
          title: step.arrivalStop!,
          trailing: isLast ? null : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 1),
            ),
            child: Text(
              '환승',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          isFirst: false,
          isLast: isLast,
        ));
      }
    }

    return timeline;
  }

  /// 타임라인 아이템
  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 (아이콘 + 선)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // 위쪽 선
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                // 아이콘
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 2),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                // 아래쪽 선
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 16,
                top: isFirst ? 6 : 22, // 위쪽 선이 있으면 아이콘과 정렬 맞추기 위해 22
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 교통 수단 단계 (타임라인 스타일)
  Widget _buildTransportStep(step) {
    Color badgeColor;
    IconData icon;

    // 교통 수단별 색상 및 아이콘
    switch (step.icon?.toLowerCase()) {
      case 'subway':
        badgeColor = const Color(0xFF2196F3);
        icon = Icons.train;
        break;
      case 'bus':
        badgeColor = const Color(0xFF4CAF50);
        icon = Icons.directions_bus;
        break;
      case 'train':
        badgeColor = const Color(0xFFFF9800);
        icon = Icons.train;
        break;
      case 'tram':
        badgeColor = const Color(0xFF9C27B0);
        icon = Icons.tram;
        break;
      case 'walking':
        badgeColor = const Color(0xFF757575);
        icon = Icons.directions_walk;
        break;
      case 'ferry':
        badgeColor = const Color(0xFF00BCD4);
        icon = Icons.directions_boat;
        break;
      default:
        badgeColor = AppColors.primary;
        icon = Icons.directions_transit;
    }

    // 정거장 수 정보 추가
    String durationText = step.duration;
    if (step.numStops != null && step.numStops! > 0) {
      durationText = '$durationText (${step.numStops}개 정거장)';
    }

    return _buildTimelineItem(
      icon: icon,
      iconColor: badgeColor,
      title: step.name,
      trailing: Text(
        durationText,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
