import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_screen.dart';
import '../../features/assets/presentation/asset_detail_screen.dart';
import '../../features/assets/presentation/asset_form_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/documents/presentation/documents_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/family/presentation/family_screen.dart';
import '../../features/homes/presentation/home_screen.dart';
import '../../features/maintenance/presentation/maintenance_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/providers/presentation/providers_screen.dart';
import '../../features/reminders/presentation/schedule_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/settings/presentation/feature_management_screen.dart';
import '../../features/settings/presentation/global_search_screen.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../../features/subscriptions/presentation/paywall_screen.dart';
import '../../features/warranties/presentation/warranties_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (auth.isLoading) return path == '/splash' ? null : '/splash';
      if (!auth.isAuthenticated) return path == '/auth' ? null : '/auth';
      if (!auth.hasCompletedOnboarding) return path == '/onboarding' ? null : '/onboarding';
      if (path == '/splash' || path == '/auth' || path == '/onboarding') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/house', builder: (context, state) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/activity', builder: (context, state) => const ActivityScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (context, state) => const MoreScreen())]),
        ],
      ),
      GoRoute(path: '/asset/new', builder: (context, state) => const AssetFormScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/search', builder: (context, state) => const GlobalSearchScreen()),
      GoRoute(
        path: '/upgrade',
        builder: (context, state) => PaywallScreen(reason: state.uri.queryParameters['reason']),
      ),
      GoRoute(path: '/manage/maintenance', builder: (context, state) => const MaintenanceScreen()),
      GoRoute(path: '/manage/services', builder: (context, state) => const ServicesScreen()),
      GoRoute(path: '/manage/providers', builder: (context, state) => const ProvidersScreen()),
      GoRoute(path: '/manage/warranties', builder: (context, state) => const WarrantiesScreen()),
      GoRoute(path: '/manage/documents', builder: (context, state) => const DocumentsScreen()),
      GoRoute(path: '/manage/expenses', builder: (context, state) => const ExpensesScreen()),
      GoRoute(path: '/manage/family', builder: (context, state) => const FamilyScreen()),
      GoRoute(
        path: '/manage/:feature',
        builder: (context, state) => FeatureManagementScreen(feature: state.pathParameters['feature']!),
      ),
      GoRoute(
        path: '/asset/:id',
        builder: (context, state) => AssetDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});
