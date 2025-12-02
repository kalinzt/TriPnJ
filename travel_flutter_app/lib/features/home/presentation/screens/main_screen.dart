import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../plan/presentation/screens/plan_screen.dart';
import '../../../accommodation/presentation/screens/accommodation_screen.dart';
import '../../../local_recommend/presentation/screens/local_recommend_screen.dart';

/// 메인 스크린 - 하단 네비게이션 바를 포함한 메인 컨테이너
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // 각 탭에 표시할 화면들
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    PlanScreen(),
    AccommodationScreen(),
    LocalRecommendScreen(),
  ];

  // 네비게이션 바 아이템 정의
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
    ),
    NavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: '탐색',
    ),
    NavigationItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note,
      label: '계획',
    ),
    NavigationItem(
      icon: Icons.hotel_outlined,
      activeIcon: Icons.hotel,
      label: '숙박',
    ),
    NavigationItem(
      icon: Icons.recommend_outlined,
      activeIcon: Icons.recommend,
      label: '맞춤 추천',
    ),
  ];

  void _onTapNavigation(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTapNavigation,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems[_currentIndex] == item;
            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 26,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 네비게이션 아이템 모델
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
