import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/trip_plan.dart';
import '../../data/models/route_option_model.dart';
import '../../data/models/transport_step_model.dart';

/// 활동 카드 위젯
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;
  final bool isReorderable;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
    this.isReorderable = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    // 디버그: 경로 정보 확인
    if (activity.type == ActivityType.transportation) {
      Logger.info(
        '교통 활동 카드 렌더링: '
        'type=${activity.type}, '
        'selectedRoute=${activity.selectedRoute != null ? "있음" : "없음"}',
        'ActivityCard',
      );
      if (activity.selectedRoute != null) {
        Logger.info(
          '경로 정보: '
          'departure=${activity.selectedRoute!.departureLocation}, '
          'arrival=${activity.selectedRoute!.arrivalLocation}, '
          'duration=${activity.selectedRoute!.durationMinutes}분',
          'ActivityCard',
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: activity.isCompleted ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: activity.isCompleted
            ? BorderSide(color: AppColors.success.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 완료 체크박스
              if (onToggleComplete != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: activity.isCompleted,
                    onChanged: (_) => onToggleComplete?.call(),
                    activeColor: AppColors.success,
                  ),
                ),

              // 활동 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activity.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    activity.type.iconName,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 활동 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시간
                    if (activity.startTime != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.endTime != null
                                ? '${timeFormat.format(activity.startTime!)} - ${timeFormat.format(activity.endTime!)}'
                                : timeFormat.format(activity.startTime!),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              decoration: activity.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (activity.durationMinutes != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${activity.durationMinutes}분',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (activity.startTime != null) const SizedBox(height: 4),

                    // 제목 또는 장소 이름
                    Text(
                      activity.place?.name ?? activity.title ?? '활동',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: activity.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 활동 유형
                    Text(
                      activity.type.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: activity.type.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 장소 주소
                    if (activity.place != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.place!.address,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // 메모
                    if (activity.memo != null && activity.memo!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.memo!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // 예상 비용
                    if (activity.estimatedCost != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${NumberFormat('#,###').format(activity.estimatedCost)}원',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // 예약 정보
                    if (activity.reservationInfo != null &&
                        activity.reservationInfo!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              size: 12,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                activity.reservationInfo!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 경로 정보 (교통 활동일 때만 표시)
                    if (activity.type == ActivityType.transportation &&
                        activity.selectedRoute != null) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      _buildRouteInfo(activity.selectedRoute!),
                    ],
                  ],
                ),
              ),

              // 액션 버튼
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 지도 열기 버튼
                  if (activity.place != null)
                    IconButton(
                      icon: const Icon(Icons.map),
                      iconSize: 20,
                      color: AppColors.primary,
                      onPressed: () => _openMap(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  // 편집 버튼
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 20,
                      color: AppColors.textSecondary,
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  // 삭제 버튼
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      iconSize: 20,
                      color: AppColors.error,
                      onPressed: () => _confirmDelete(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  // 재정렬 핸들
                  if (isReorderable)
                    const Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 지도에서 장소 열기
  void _openMap(BuildContext context) async {
    if (activity.place == null) return;

    final place = activity.place!;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch map');
      }
    } catch (e, stackTrace) {
      Logger.error('지도 열기 실패', e, stackTrace, 'ActivityCard');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지도를 열 수 없습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('활동 삭제'),
        content: Text(
          '${activity.place?.name ?? activity.title ?? '이 활동'}을(를) 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 경로 정보 위젯
  Widget _buildRouteInfo(RouteOption route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 경로 요약 (출발지 > 도착지)
        if (route.departureLocation != null && route.arrivalLocation != null)
          _buildRouteSummary(route),

        // 경로 단계 (교통 수단별)
        if (route.transportOptions != null && route.transportOptions!.isNotEmpty)
          _buildTransportSteps(route.transportOptions!),

        // 도착 시간 정보
        if (route.estimatedArrivalTime != null || route.delayedArrivalTime != null)
          _buildArrivalTimeInfo(route),

        // 출발 정보
        if (route.departureNote != null) _buildDepartureNote(route.departureNote!),
      ],
    );
  }

  /// 경로 요약 (출발지 > 도착지)
  Widget _buildRouteSummary(RouteOption route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${route.departureLocation} → ${route.arrivalLocation}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 경로 단계들 (교통 수단별)
  Widget _buildTransportSteps(List<TransportStep> steps) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  Text(
                    ' • ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                _buildTransportStepWidget(step),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 개별 TransportStep 위젯
  Widget _buildTransportStepWidget(TransportStep step) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTransportIcon(step.icon),
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${step.name} (${step.duration})',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 도착 시간 정보
  Widget _buildArrivalTimeInfo(RouteOption route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (route.estimatedArrivalTime != null)
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '도착: ${route.estimatedArrivalTime}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          if (route.delayedArrivalTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.warning,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '지연: ${route.delayedArrivalTime}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 출발 정보
  Widget _buildDepartureNote(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              note,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 교통 수단 아이콘 매핑
  IconData _getTransportIcon(String? icon) {
    switch (icon?.toLowerCase()) {
      case 'subway':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'flight':
        return Icons.flight;
      case 'ferry':
        return Icons.directions_boat;
      case 'cable_car':
        return Icons.cable;
      case 'tram':
        return Icons.tram;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.directions_transit;
    }
  }
}

/// ActivityType 확장 - 색상 추가
extension ActivityTypeColor on ActivityType {
  Color get color {
    switch (this) {
      case ActivityType.visit:
        return AppColors.primary;
      case ActivityType.meal:
        return AppColors.warning;
      case ActivityType.accommodation:
        return AppColors.info;
      case ActivityType.transportation:
        return AppColors.textSecondary;
      case ActivityType.shopping:
        return const Color(0xFFE91E63);
      case ActivityType.activity:
        return AppColors.success;
      case ActivityType.rest:
        return const Color(0xFF9C27B0);
      case ActivityType.other:
        return AppColors.textSecondary;
    }
  }
}
