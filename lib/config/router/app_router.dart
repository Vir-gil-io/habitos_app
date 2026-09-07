import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app/config/constants/app_constants.dart';
import 'package:habitos_app/config/router/go_router_refresh_stream.dart';
import 'package:habitos_app/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.splashRoute,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isAuthRoute = state.matchedLocation == AppConstants.authRoute;
    final isSplash = state.matchedLocation == AppConstants.splashRoute;

    if (isSplash) return null; // el splash decide su propia navegación

    if (!isLoggedIn && !isAuthRoute) return AppConstants.authRoute;
    if (isLoggedIn && isAuthRoute) return AppConstants.homeRoute;
    return null;
  },
  routes: [
    GoRoute(
      path: AppConstants.splashRoute,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppConstants.authRoute,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'statistics',
          builder: (context, state) => const ActivityStatisticsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppConstants.habitsRoute,
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: AppConstants.calendarRoute,
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: AppConstants.profileRoute,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);