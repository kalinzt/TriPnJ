import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/plan/presentation/screens/plan_screen.dart';
import '../../features/accommodation/presentation/screens/accommodation_screen.dart';
import '../../features/ai_recommend/presentation/screens/ai_recommend_screen.dart';

/// Go Router 설정 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ============================================
      // Main Screen (하단 네비게이션 바 포함)
      // ============================================
      GoRoute(
        path: '/',
        name: AppRoutes.main,
        builder: (context, state) => const MainScreen(),
      ),

      // ============================================
      // Individual Screens (딥링크 지원)
      // ============================================
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: AppRoutes.explore,
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/plan',
        name: AppRoutes.plan,
        builder: (context, state) => const PlanScreen(),
      ),
      GoRoute(
        path: '/accommodation',
        name: AppRoutes.accommodation,
        builder: (context, state) => const AccommodationScreen(),
      ),
      GoRoute(
        path: '/ai-recommend',
        name: AppRoutes.aiRecommend,
        builder: (context, state) => const AIRecommendScreen(),
      ),

      // ============================================
      // Detail Screens (추후 추가)
      // ============================================
      // TODO: 여행지 상세 화면
      // GoRoute(
      //   path: '/place/:id',
      //   name: AppRoutes.placeDetail,
      //   builder: (context, state) {
      //     final placeId = state.pathParameters['id']!;
      //     return PlaceDetailScreen(placeId: placeId);
      //   },
      // ),

      // TODO: 계획 상세 화면
      // GoRoute(
      //   path: '/plan/:id',
      //   name: AppRoutes.planDetail,
      //   builder: (context, state) {
      //     final planId = state.pathParameters['id']!;
      //     return PlanDetailScreen(planId: planId);
      //   },
      // ),

      // TODO: 숙소 상세 화면
      // GoRoute(
      //   path: '/accommodation/:id',
      //   name: AppRoutes.accommodationDetail,
      //   builder: (context, state) {
      //     final accommodationId = state.pathParameters['id']!;
      //     return AccommodationDetailScreen(accommodationId: accommodationId);
      //   },
      // ),
    ],

    // ============================================
    // Error Handling
    // ============================================
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error,
      uri: state.uri.toString(),
    ),

    // ============================================
    // Redirect (인증 등 추가 가능)
    // ============================================
    // redirect: (context, state) {
    //   // TODO: 인증 체크 및 리다이렉트 로직
    //   // final isAuthenticated = ref.read(authStateProvider);
    //   // if (!isAuthenticated && state.uri.path != '/login') {
    //   //   return '/login';
    //   // }
    //   return null;
    // },
  );
});

/// 앱 라우트 경로 상수
class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String main = 'main';
  static const String home = 'home';
  static const String explore = 'explore';
  static const String plan = 'plan';
  static const String accommodation = 'accommodation';
  static const String aiRecommend = 'ai-recommend';

  // Detail routes (추후 추가)
  static const String placeDetail = 'place-detail';
  static const String planDetail = 'plan-detail';
  static const String accommodationDetail = 'accommodation-detail';

  // Other routes (추후 추가)
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String search = 'search';
  static const String favorites = 'favorites';
  static const String notifications = 'notifications';
}

// ============================================
// Error Screen
// ============================================

/// 에러 화면
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  final String uri;

  const ErrorScreen({
    super.key,
    this.error,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                '페이지를 찾을 수 없습니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '요청하신 페이지가 존재하지 않습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                uri,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('홈으로 돌아가기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
