import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../widgets/asset_icon.dart';
import '../widgets/game_button.dart';
import '../providers/level_provider.dart';
import '../routes/routes.dart';
import '../widgets/top_hud.dart';
import 'main_shell_screen.dart';

/// Shop route wrapper that delegates to the persistent tab shell.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(initialRoute: AppRoutes.shopRoute);
  }
}

/// Shop tab content for boosters and currency packs.
class ShopContent extends StatelessWidget {
  const ShopContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    return Column(
      children: <Widget>[
        const TopHud(),
        const SizedBox(height: AppSizes.gap),
        const SizedBox(height: AppSizes.gap),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _ShopCard(
                asset: AppAssets.hammerBooster,
                title: 'Jelly Hammer',
                subtitle: 'Smash a row and a column with one hit.',
                price: 5,
                onBuy: () => _handleGemPurchase(context, levels, 'hammer', 5),
              ),
              _ShopCard(
                asset: AppAssets.rocketBooster,
                title: 'Rocket Jelly',
                subtitle: 'Blast through 3 rows at once.',
                price: 10,
                onBuy: () => _handleGemPurchase(context, levels, 'rocket', 10),
              ),
              _ShopCard(
                asset: AppAssets.colorBombBooster,
                title: 'Color Bomb',
                subtitle: 'Detonate a massive area of candies.',
                price: 15,
                onBuy: () => _handleGemPurchase(context, levels, 'bomb', 15),
              ),
              _ShopCard(
                asset: AppAssets.starterPack,
                title: 'Starter Pack',
                subtitle: 'Clear the entire board in one go!',
                price: 25,
                onBuy: () => _handleGemPurchase(context, levels, 'starter', 25),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleGemPurchase(
    BuildContext context,
    LevelProvider levels,
    String type,
    int gemPrice,
  ) async {
    final bool success = await levels.purchaseBoosterWithGems(type, gemPrice);
    if (!context.mounted) return;
    _showPurchaseResult(context, success, type);
  }

  void _showPurchaseResult(BuildContext context, bool success, String type) {
    if (success) {
      final String boosterAsset = switch (type) {
        'hammer' => AppAssets.hammerBooster,
        'shuffle' || 'rocket' => AppAssets.rocketBooster,
        'bomb' => AppAssets.colorBombBooster,
        _ => AppAssets.starterPack,
      };

      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.success, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetIconImage(asset: boosterAsset, size: 100),
                const SizedBox(height: AppSizes.gap),
                Text(
                  'Purchase Successful!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSizes.smallGap),
                Text(
                  'You now have more ${type == 'shuffle' ? 'Rocket' : type}s!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.gap),
                GameButton(
                  label: 'SWEET!',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.danger, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AssetIconImage(asset: AppAssets.gem, size: 80),
                const SizedBox(height: AppSizes.gap),
                Text(
                  'Not Enough Gems!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSizes.smallGap),
                const Text(
                  'Earn more gems by completing levels with high scores!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: AppSizes.gap),
                GameButton(
                  label: 'OK',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  purple: true,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _ShopCard extends StatelessWidget {
  final String asset;
  final String title;
  final String subtitle;
  final int price;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onBuy,
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
          const SizedBox(width: 8),
          GameButton(
            label: '$price',
            icon: AppAssets.gem,
            purple: true,
            onPressed: onBuy,
            minWidth: 84,
            minHeight: 40,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _MiniPrice extends StatelessWidget {
  final String asset;
  final String value;

  const _MiniPrice({required this.asset, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AssetIconImage(asset: asset, size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

/// Popup explaining a booster purchase.
class BoosterInfoDialog extends StatelessWidget {
  final String title;
  final String asset;

  const BoosterInfoDialog({
    super.key,
    required this.title,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.purpleBorder, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: asset, size: 120),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const Text('This item is ready for a future power-up update.'),
            const SizedBox(height: AppSizes.gap),
            GameButton(
              label: 'OK',
              purple: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
