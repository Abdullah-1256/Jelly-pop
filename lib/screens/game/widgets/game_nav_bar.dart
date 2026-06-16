import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/level_provider.dart';
import '../../../widgets/asset_icon.dart';

/// Bottom gameplay navigation with consumable booster controls.
class GameNavBar extends StatelessWidget {
  final ValueChanged<String> onBoosterSelected;

  const GameNavBar({super.key, required this.onBoosterSelected});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _BoosterNavItem(
            asset: AppAssets.hammerBooster,
            title: 'Hammer',
            count: levels.hammers,
            onTap: () => _selectOrWarn(
              context: context,
              count: levels.hammers,
              type: 'hammer',
            ),
          ),
          _BoosterNavItem(
            asset: AppAssets.rocketBooster,
            title: 'Rocket',
            count: levels.shuffles,
            onTap: () => _selectOrWarn(
              context: context,
              count: levels.shuffles,
              type: 'rocket',
            ),
          ),
          _BoosterNavItem(
            asset: AppAssets.colorBombBooster,
            title: 'Bomb',
            count: levels.bombs,
            onTap: () => _selectOrWarn(
              context: context,
              count: levels.bombs,
              type: 'bomb',
            ),
          ),
          _BoosterNavItem(
            asset: AppAssets.starterPack,
            title: 'Starter',
            count: levels.starterPacks,
            onTap: () => _useStarterPack(context, levels),
          ),
        ],
      ),
    );
  }

  void _selectOrWarn({
    required BuildContext context,
    required int count,
    required String type,
  }) {
    if (count > 0) {
      onBoosterSelected(type);
      return;
    }
    _showNoStock(context);
  }

  Future<void> _useStarterPack(
    BuildContext context,
    LevelProvider levels,
  ) async {
    if (levels.starterPacks <= 0) {
      _showNoStock(context);
      return;
    }
    final GameProvider gameProvider = context.read<GameProvider>();
    final bool consumed = await levels.consumeBooster('starter');
    if (consumed) {
      await gameProvider.useStarterPack();
    }
  }

  void _showNoStock(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No stock! Buy more in the shop.')),
    );
  }
}

class _BoosterNavItem extends StatelessWidget {
  final String asset;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _BoosterNavItem({
    required this.asset,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Opacity(
                  opacity: count > 0 ? 1.0 : 0.4,
                  child: AssetIconImage(asset: asset, size: 48),
                ),
                if (count > 0)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: count > 0
                    ? AppColors.text
                    : AppColors.text.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
