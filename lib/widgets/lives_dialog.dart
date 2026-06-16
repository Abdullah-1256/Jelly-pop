import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../providers/level_provider.dart';
import 'asset_icon.dart';
import 'game_button.dart';

/// Shows the no-lives state, refill timer, and rewarded-ad option.
class NoHeartsDialog extends StatelessWidget {
  const NoHeartsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    final Duration remaining = levels.timeUntilHeartRefill;
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
            const AssetIconImage(asset: AppAssets.heart, size: 92),
            Text(
              'No Hearts',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSizes.smallGap),
            Text(
              remaining == Duration.zero
                  ? 'Your hearts are ready. Try again.'
                  : 'Full refill in ${_formatDuration(remaining)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.gap),
            GameButton(
              label: 'WATCH AD +1',
              purple: true,
              onPressed: () => _openRewardedAd(context),
            ),
            const SizedBox(height: AppSizes.smallGap),
            GameButton(
              label: 'CLOSE',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _openRewardedAd(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      DialogRoute<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (_) => const RewardedAdDialog(),
      ),
    );
  }
}

/// Simulates rewarded ad playback and grants a reward on completion.
class RewardedAdDialog extends StatefulWidget {
  final VoidCallback? onComplete;

  const RewardedAdDialog({super.key, this.onComplete});

  @override
  State<RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<RewardedAdDialog> {
  static const int _totalSeconds = 5;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (!mounted) return;
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          // Default fallback to hearts if no callback provided
          await context.read<LevelProvider>().addRewardedAdHearts();
        }
        if (mounted) {
          setState(() {
            _secondsLeft = 0;
            _completed = true;
          });
        }
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_totalSeconds - _secondsLeft) / _totalSeconds;
    return PopScope(
      canPop: _completed,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.greenBorder, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AssetIconImage(
                asset: _completed ? AppAssets.correct : AppAssets.timer,
                size: 96,
              ),
              Text(
                _completed ? 'Reward Added' : 'Ad Playing',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.smallGap),
              Text(
                _completed
                    ? '+1 heart added to your app.'
                    : 'Please wait $_secondsLeft seconds.',
              ),
              const SizedBox(height: AppSizes.gap),
              LinearProgressIndicator(value: progress.clamp(0, 1)),
              const SizedBox(height: AppSizes.gap),
              if (_completed)
                GameButton(
                  label: 'DONE',
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
