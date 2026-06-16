import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../routes/routes.dart';
import 'asset_icon.dart';

/// Custom bottom navigation strip for primary game sections.
class JellyNavBar extends StatelessWidget {
  final String selectedRoute;
  final void Function(String route) onRouteSelected;

  const JellyNavBar({
    super.key,
    required this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.textLight, width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _NavItem(
            label: 'Map',
            asset: AppAssets.navMap,
            route: AppRoutes.mapRoute,
            active: selectedRoute == AppRoutes.mapRoute,
            onTap: onRouteSelected,
          ),
          _NavItem(
            label: 'Shop',
            asset: AppAssets.navShop,
            route: AppRoutes.shopRoute,
            active: selectedRoute == AppRoutes.shopRoute,
            onTap: onRouteSelected,
          ),
          _NavItem(
            label: 'Events',
            asset: AppAssets.navEvents,
            route: AppRoutes.eventsRoute,
            active: selectedRoute == AppRoutes.eventsRoute,
            onTap: onRouteSelected,
          ),
          _NavItem(
            label: 'Daily',
            asset: AppAssets.reward,
            route: AppRoutes.dailyRoute,
            active: selectedRoute == AppRoutes.dailyRoute,
            onTap: onRouteSelected,
          ),
          _NavItem(
            label: 'Settings',
            asset: AppAssets.settings,
            route: AppRoutes.settingsRoute,
            active: selectedRoute == AppRoutes.settingsRoute,
            onTap: onRouteSelected,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String asset;
  final String route;
  final bool active;
  final void Function(String route) onTap;

  const _NavItem({
    required this.label,
    required this.asset,
    required this.route,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (active) {
          return;
        }
        onTap(route);
      },
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: asset, size: active ? 48 : 42),
            Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? AppColors.primary : AppColors.text,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
