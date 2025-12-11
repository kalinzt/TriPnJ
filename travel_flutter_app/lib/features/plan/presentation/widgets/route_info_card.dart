import 'package:flutter/material.dart';
import '../../data/models/route_option_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'route_detail_bottom_sheet.dart';

/// 경로 정보를 UI 카드로 표시하는 위젯 (구글 스타일)
class RouteInfoCard extends StatelessWidget {
  final RouteOption route;
  final VoidCallback? onSelect;

  const RouteInfoCard({
    super.key,
    required this.route,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 소요 시간 및 거리 (헤더)
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.straighten,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route.distance,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 상세보기 버튼
                  InkWell(
                    onTap: () {
                      RouteDetailBottomSheet.show(context, route);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        '상세보기',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 선택 버튼
                  if (onSelect != null)
                    InkWell(
                      onTap: onSelect,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '선택',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // 출발지 → 도착지
              if (route.departureLocation != null && route.arrivalLocation != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trip_origin, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      route.departureLocation!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        route.arrivalLocation!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // 교통 수단 정보 (노선 번호)
              if (route.transportOptions != null && route.transportOptions!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildTransportSteps(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 교통 수단 단계별 표시 (구글 스타일)
  Widget _buildTransportSteps() {
    // 대중교통 step만 필터링 (도보 제외)
    final transitSteps = route.transportOptions!.where((step) => step.type == 'transit').toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: transitSteps.map((step) {
        return _buildTransportBadge(step);
      }).toList(),
    );
  }

  /// 교통 수단 뱃지 (노선 번호만 표시, 소요시간 제거)
  Widget _buildTransportBadge(step) {
    Color badgeColor;
    IconData icon;

    // 교통 수단별 색상 및 아이콘
    switch (step.icon?.toLowerCase()) {
      case 'subway':
        badgeColor = const Color(0xFF2196F3); // 파란색
        icon = Icons.train;
        break;
      case 'bus':
        badgeColor = const Color(0xFF4CAF50); // 녹색
        icon = Icons.directions_bus;
        break;
      case 'train':
        badgeColor = const Color(0xFFFF9800); // 주황색
        icon = Icons.train;
        break;
      case 'tram':
        badgeColor = const Color(0xFF9C27B0); // 보라색
        icon = Icons.tram;
        break;
      case 'walking':
        badgeColor = const Color(0xFF757575); // 회색
        icon = Icons.directions_walk;
        break;
      case 'ferry':
        badgeColor = const Color(0xFF00BCD4); // 청록색
        icon = Icons.directions_boat;
        break;
      default:
        badgeColor = AppColors.primary;
        icon = Icons.directions_transit;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: badgeColor),
          const SizedBox(width: 8),
          Text(
            step.name, // 노선 번호/이름 (예: "9호선", "740")
            style: AppTextStyles.bodyMedium.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
