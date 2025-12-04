import 'package:flutter/material.dart';
import '../../data/models/route_option_model.dart';
import '../../../../core/constants/app_colors.dart';

/// 경로 정보를 UI 카드로 표시하는 위젯 (Google Maps 없이 경량화)
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 교통편 정보와 선택 버튼
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.vehicleInfo ?? '정보 없음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${route.durationMinutes}분',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.straighten,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            route.distance,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onSelect != null)
                  ElevatedButton(
                    onPressed: onSelect,
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

            // 경로 상세 정보
            if (route.details != null && route.details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildRouteDetails(route.details!),
            ],
          ],
        ),
      ),
    );
  }

  /// 경로 상세 정보를 파싱하여 표시
  Widget _buildRouteDetails(String details) {
    // details는 " | "로 구분된 문자열
    final steps = details.split(' | ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.route,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              '경로 상세',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return _buildStepItem(
            step: step,
            isLast: isLast,
            index: index,
          );
        }),
      ],
    );
  }

  /// 개별 경로 단계 아이템
  Widget _buildStepItem({
    required String step,
    required bool isLast,
    required int index,
  }) {
    // 단계 유형 감지
    IconData icon;
    Color iconColor;

    if (step.contains('도보')) {
      icon = Icons.directions_walk;
      iconColor = Colors.orange;
    } else if (step.contains('버스') || step.contains('Bus')) {
      icon = Icons.directions_bus;
      iconColor = Colors.blue;
    } else if (step.contains('지하철') || step.contains('Subway')) {
      icon = Icons.subway;
      iconColor = Colors.red;
    } else if (step.contains('기차') || step.contains('Train')) {
      icon = Icons.train;
      iconColor = Colors.green;
    } else if (step.contains('출발') || step.contains('도착')) {
      icon = Icons.schedule;
      iconColor = Colors.purple;
    } else {
      icon = Icons.arrow_forward;
      iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 인디케이터
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 12),
          // 단계 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
