import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/travel_plan_model.dart';

/// 여행 계획 카드 위젯
class TravelPlanCard extends StatelessWidget {
  final TravelPlan plan;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TravelPlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 테마 시스템 적용
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);

    return Dismissible(
      key: Key(plan.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: _buildDismissBackground(context),
      confirmDismiss: (direction) async {
        final dialogColors = AppColors.of(context);
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('여행 계획 삭제'),
            content: Text('${plan.name} 계획을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: dialogColors.error,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 여행명과 상태 배지
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: textStyles.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(context),
                  ],
                ),
                const SizedBox(height: 12),

                // 목적지
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plan.destination,
                        style: textStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 날짜
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateRange(),
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${plan.duration}일)',
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // 예산 (있는 경우)
                if (plan.budget != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatBudget(plan.budget!),
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상태 배지 빌드
  Widget _buildStatusBadge(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles = AppTextStyles.of(context);
    final status = plan.travelStatus;
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case TravelStatus.planned:
        backgroundColor = colors.primary.withValues(alpha: 0.1);
        textColor = colors.primary;
        label = '계획됨';
        break;
      case TravelStatus.inProgress:
        backgroundColor = colors.success.withValues(alpha: 0.1);
        textColor = colors.success;
        label = '진행 중';
        break;
      case TravelStatus.completed:
        backgroundColor = colors.textHint.withValues(alpha: 0.1);
        textColor = colors.textSecondary;
        label = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: textStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 날짜 범위 포맷
  String _formatDateRange() {
    final formatter = DateFormat('M/d');
    final start = formatter.format(plan.startDate);
    final end = formatter.format(plan.endDate);
    return '$start ~ $end';
  }

  /// 예산 포맷
  String _formatBudget(double budget) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(budget)}원';
  }

  /// Dismissible 배경
  Widget _buildDismissBackground(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
