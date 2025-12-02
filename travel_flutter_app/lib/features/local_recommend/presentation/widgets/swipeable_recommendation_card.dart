import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/place.dart';
import '../../data/models/preference_action.dart';
import '../../data/providers/user_preference_provider.dart';
import 'enhanced_recommendation_card.dart';

/// 스와이프 가능한 추천 카드 위젯
///
/// Dismissible을 사용하여 좌우 스와이프로 관심 표시/거절 기능 제공
class SwipeableRecommendationCard extends ConsumerWidget {
  final Place place;
  final double? score;
  final VoidCallback? onDismissed;

  const SwipeableRecommendationCard({
    super.key,
    required this.place,
    this.score,
    this.onDismissed,
  });

  /// 좌측 스와이프 (거절) 핸들러
  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final repository = ref.read(userPreferenceRepositoryProvider);

    await repository.updatePreferenceFromAction(
      place: place,
      action: PreferenceAction.reject,
    );

    // 상태 동기화
    ref.read(userPreferenceProvider.notifier).syncWithRepository();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${place.name}을(를) 추천에서 제외했습니다'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '실행 취소',
            onPressed: () async {
              // 실행 취소: 거절 목록에서 제거
              await repository.removeRejectedPlace(place.id);
              ref.read(userPreferenceProvider.notifier).syncWithRepository();
            },
          ),
        ),
      );
    }
  }

  /// 우측 스와이프 (관심 표시) 핸들러
  Future<void> _handleLike(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final repository = ref.read(userPreferenceRepositoryProvider);

    await repository.updatePreferenceFromAction(
      place: place,
      action: PreferenceAction.like,
    );

    // 상태 동기화
    ref.read(userPreferenceProvider.notifier).syncWithRepository();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${place.name}을(를) 관심 목록에 추가했습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(place.id),
      background: _buildDismissBackground(
        color: Colors.green,
        icon: Icons.favorite,
        text: '관심 표시',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        color: Colors.red,
        icon: Icons.close,
        text: '관심 없음',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 우측 스와이프: 관심 표시
          await _handleLike(context, ref);
        } else if (direction == DismissDirection.endToStart) {
          // 좌측 스와이프: 거절
          await _handleReject(context, ref);
        }

        // 항상 true 반환하여 카드 제거
        return true;
      },
      onDismissed: (direction) {
        // 카드가 제거된 후 콜백 실행
        onDismissed?.call();
      },
      child: EnhancedRecommendationCard(
        place: place,
        score: score,
      ),
    );
  }

  /// 스와이프 배경 위젯
  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required String text,
    required Alignment alignment,
  }) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeft ? 24 : 0,
        right: isLeft ? 0 : 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
