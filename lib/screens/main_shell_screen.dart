import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../routes/routes.dart';
import '../widgets/game_background.dart';
import '../widgets/jelly_nav_bar.dart';
import 'daily_rewards_screen.dart';
import 'events_screen.dart';
import 'shop_screen.dart';
import 'world_map_screen.dart';

/// Main tab shell that keeps navigation fixed while content changes.
class MainShellScreen extends StatefulWidget {
  final String initialRoute;

  const MainShellScreen({super.key, required this.initialRoute});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexForRoute(widget.initialRoute);
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextIndex = _indexForRoute(widget.initialRoute);
    if (nextIndex != _selectedIndex) {
      _selectedIndex = nextIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GameBackground(
      asset: AppAssets.background,
      extraDark: true,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: IndexedStack(
                index: _selectedIndex,
                children: const <Widget>[
                  WorldMapContent(),
                  ShopContent(),
                  EventsContent(),
                  DailyRewardsContent(),
                ],
              ),
            ),
          ),
          JellyNavBar(
            selectedRoute: _routeForIndex(_selectedIndex),
            onRouteSelected: _selectRoute,
          ),
        ],
      ),
    );
  }

  void _selectRoute(String route) {
    if (route == AppRoutes.settingsRoute) {
      context.push(AppRoutes.settingsRoute);
      return;
    }
    final int nextIndex = _indexForRoute(route);
    if (nextIndex == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = nextIndex);
  }

  int _indexForRoute(String route) {
    return switch (route) {
      AppRoutes.shopRoute => 1,
      AppRoutes.eventsRoute => 2,
      AppRoutes.dailyRoute => 3,
      _ => 0,
    };
  }

  String _routeForIndex(int index) {
    return switch (index) {
      1 => AppRoutes.shopRoute,
      2 => AppRoutes.eventsRoute,
      3 => AppRoutes.dailyRoute,
      _ => AppRoutes.mapRoute,
    };
  }
}
