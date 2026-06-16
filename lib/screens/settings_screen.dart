import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../providers/audio_provider.dart';
import '../providers/level_provider.dart';
import '../widgets/asset_icon.dart';
import '../widgets/game_background.dart';
import '../widgets/game_button.dart';
import '../widgets/jelly_back_button.dart';
import '../widgets/jelly_page_scope.dart';
import '../widgets/resource_pill.dart';

/// Settings screen for audio and local progress.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AudioProvider audio = context.watch<AudioProvider>();
    return JellyPageScope(
      child: Scaffold(
        body: GameBackground(
          asset: AppAssets.background,
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const JellyBackButton(),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: size.width * 0.1),
                      ),
                    ),
                    ResourcePill(
                      asset: AppAssets.heart,
                      value: '${context.watch<LevelProvider>().hearts}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap),
                _SettingRow(
                  asset: audio.musicMuted ? AppAssets.mute : AppAssets.music,
                  label: audio.musicMuted ? 'Music Off' : 'Music On',
                  onTap: audio.toggleMusic,
                ),
                _SettingRow(
                  asset: audio.sfxMuted ? AppAssets.mute : AppAssets.sfx,
                  label: audio.sfxMuted ? 'SFX Off' : 'SFX On',
                  onTap: audio.toggleSfx,
                ),
                _SettingRow(
                  asset: audio.hapticsEnabled
                      ? AppAssets.correct
                      : AppAssets.mute,
                  label: audio.hapticsEnabled
                      ? 'Haptic Touch On'
                      : 'Haptic Touch Off',
                  onTap: audio.toggleHaptics,
                ),
                _SettingRow(
                  asset: AppAssets.about,
                  label: 'About Jelly Pop',
                  onTap: () {},
                ),
                const Spacer(),
                const SizedBox(height: AppSizes.gap),
                GameButton(
                  label: 'RESET SAVE',
                  purple: true,
                  onPressed: () =>
                      context.read<LevelProvider>().resetProgress(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _SettingRow({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.gap),
      padding: const EdgeInsets.all(AppSizes.gap),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.purpleBorder, width: 4),
      ),
      child: Row(
        children: <Widget>[
          AssetIconImage(asset: asset, size: 70),
          const SizedBox(width: AppSizes.gap),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleLarge),
          ),
          GameButton(label: 'TOGGLE', purple: true, onPressed: onTap),
        ],
      ),
    );
  }
}
