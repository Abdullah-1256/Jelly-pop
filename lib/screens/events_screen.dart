import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../widgets/asset_icon.dart';
import '../routes/routes.dart';
import '../widgets/top_hud.dart';
import 'main_shell_screen.dart';

/// Events route wrapper that delegates to the persistent tab shell.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(initialRoute: AppRoutes.eventsRoute);
  }
}

/// Limited-time events tab content.
class EventsContent extends StatelessWidget {
  const EventsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const TopHud(),
        const SizedBox(height: AppSizes.gap),
        const SizedBox(height: AppSizes.gap),
        Expanded(
          child: ListView(
            children: const <Widget>[
              _EventCard(
                title: 'Reward Rush',
                subtitle: 'Open reward boxes and collect bonus coins.',
                asset: AppAssets.reward,
              ),
              _EventCard(
                title: 'Star Sprint',
                subtitle: 'Beat three levels today to fill the star meter.',
                asset: AppAssets.starFilled,
              ),
              _EventCard(
                title: 'Team Jelly',
                subtitle: 'Team rewards are coming soon.',
                asset: AppAssets.team,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;

  const _EventCard({
    required this.title,
    required this.subtitle,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.smallGap),
      padding: const EdgeInsets.all(AppSizes.gap),
      constraints: const BoxConstraints(minHeight: 86),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.greenBorder, width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          AssetIconImage(asset: asset, size: 56),
          const SizedBox(width: AppSizes.gap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSizes.smallGap * 0.5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.74),
                    fontSize: 13,
                    height: 1.15,
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
