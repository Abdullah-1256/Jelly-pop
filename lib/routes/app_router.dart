import 'package:go_router/go_router.dart';

import '../screens/daily_rewards_screen.dart';
import '../screens/events_screen.dart';
import '../screens/game_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/world_map_screen.dart';
import 'routes.dart';

/// GoRouter configuration for every navigable game screen.
abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashRoute,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splashRoute,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcomeRoute,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.mapRoute,
        builder: (_, _) => const WorldMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.gameRoute,
        builder: (_, GoRouterState state) => GameScreen(
          levelId: int.parse(state.pathParameters['levelId'] ?? '1'),
        ),
      ),
      GoRoute(path: AppRoutes.shopRoute, builder: (_, _) => const ShopScreen()),
      GoRoute(
        path: AppRoutes.eventsRoute,
        builder: (_, _) => const EventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsRoute,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailyRoute,
        builder: (_, _) => const DailyRewardsScreen(),
      ),
    ],
  );
}
