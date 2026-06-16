import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../providers/level_provider.dart';
import '../routes/routes.dart';
import '../widgets/asset_icon.dart';
import '../widgets/game_button.dart';
import '../widgets/top_hud.dart';
import 'main_shell_screen.dart';

/// Daily rewards route wrapper that delegates to the persistent tab shell.
class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(initialRoute: AppRoutes.dailyRoute);
  }
}

/// Daily rewards tab content with seven gift slots.
class DailyRewardsContent extends StatelessWidget {
  const DailyRewardsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    final bool canClaim = levels.canClaimDailyReward;
    return Column(
      children: <Widget>[
        const TopHud(),
        const SizedBox(height: AppSizes.gap),
        const SizedBox(height: AppSizes.gap),
        Expanded(
          child: GridView.builder(
            itemCount: LevelProvider.maxDailyRewardDay,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.gap,
              crossAxisSpacing: AppSizes.gap,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (BuildContext context, int index) {
              final int day = index + 1;
              final bool active = day == levels.dailyRewardDay;
              final int reward = day * LevelProvider.dailyRewardStepCoins;
              return _buildRewardTile(
                context: context,
                day: day,
                reward: reward,
                active: active,
                canClaim: canClaim,
              );
            },
          ),
        ),
        _buildClaimButton(context: context, levels: levels, canClaim: canClaim),
        const SizedBox(height: AppSizes.gap),
      ],
    );
  }

  Widget _buildRewardTile({
    required BuildContext context,
    required int day,
    required int reward,
    required bool active,
    required bool canClaim,
  }) {
    final Color borderColor = active
        ? AppColors.greenBorder
        : AppColors.purpleBorder;
    return Container(
      padding: const EdgeInsets.all(AppSizes.smallGap * 0.5),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: active ? 0.98 : 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: active ? 4 : 3),
        boxShadow: active && canClaim
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.coinYellow.withValues(alpha: 0.72),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AssetIconImage(
            asset: active && canClaim ? AppAssets.openChest : AppAssets.coin,
            size: 44,
          ),
          const SizedBox(height: AppSizes.smallGap * 0.5),
          Text(
            'Day $day',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          Text(
            '+$reward',
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.72),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton({
    required BuildContext context,
    required LevelProvider levels,
    required bool canClaim,
  }) {
    final String label = canClaim
        ? 'CLAIM +${levels.dailyRewardAmount}'
        : 'READY IN ${_formatCooldown(levels.timeUntilDailyReward)}';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.glassButtonRadius),
        boxShadow: canClaim
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.coinYellow.withValues(alpha: 0.75),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: GameButton(
        label: label,
        onPressed: () => _handleClaim(context: context, canClaim: canClaim),
      ),
    );
  }

  Future<void> _handleClaim({
    required BuildContext context,
    required bool canClaim,
  }) async {
    if (!canClaim) {
      return;
    }
    final LevelProvider levels = context.read<LevelProvider>();
    final int claimedAmount = levels.dailyRewardAmount;
    final bool claimed = await levels.claimDailyReward();
    if (!claimed || !context.mounted) {
      return;
    }
    await _showRewardDialog(context: context, amount: claimedAmount);
  }

  Future<void> _showRewardDialog({
    required BuildContext context,
    required int amount,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.coinYellow, width: 4),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.coinYellow.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AssetIconImage(asset: AppAssets.openChest, size: 118),
                const SizedBox(height: AppSizes.gap),
                Text(
                  'Reward Claimed!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.smallGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const AssetIconImage(asset: AppAssets.coin, size: 44),
                    const SizedBox(width: AppSizes.smallGap),
                    Text(
                      '+$amount Coins',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSizes.smallGap),
                    const AssetIconImage(asset: AppAssets.coin, size: 44),
                  ],
                ),
                const SizedBox(height: AppSizes.gap),
                GameButton(
                  label: 'OK',
                  width: 170,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCooldown(Duration duration) {
    if (duration == Duration.zero) {
      return '0H';
    }
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}H ${minutes}M';
    }
    return '${minutes}M';
  }
}
