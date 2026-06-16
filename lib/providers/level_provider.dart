import 'package:flutter/foundation.dart';

import '../core/utils/save_manager.dart';
import '../data/levels_data.dart';
import '../models/level.dart';
import '../models/player_progress.dart';

/// Provides level metadata, lives, currency, and persisted player progress.
class LevelProvider extends ChangeNotifier {
  static const int maxHearts = 5;
  static const int rewardedAdHearts = 1;
  static const int maxDailyRewardDay = 7;
  static const int dailyRewardStepCoins = 100;
  static const int baseWinCoins = 50;
  static const int coinsPerStar = 25;
  static const Duration heartRefillDuration = Duration(hours: 24);
  static const Duration dailyRewardCooldown = Duration(hours: 24);

  final SaveManager _saveManager;
  PlayerProgress _progress = const PlayerProgress();

  LevelProvider(this._saveManager);

  /// Returns all game levels.
  List<Level> get levels => LevelsData.levels;

  /// Returns the loaded player progress.
  PlayerProgress get progress => _progress;

  /// Returns available hearts after applying any due refill.
  int get hearts => _progress.hearts;

  /// Returns the current saved coin total.
  int get coins => _progress.coins;

  /// Returns the current saved gem total.
  int get gems => _progress.gems;

  /// Returns the daily reward day waiting to be claimed.
  int get dailyRewardDay => _progress.dailyRewardDay;

  /// Returns the coin amount for the current daily reward day.
  int get dailyRewardAmount => dailyRewardDay * dailyRewardStepCoins;

  /// Returns whether the daily reward can be claimed now.
  bool get canClaimDailyReward => timeUntilDailyReward == Duration.zero;

  /// Returns remaining time until the next daily reward claim.
  Duration get timeUntilDailyReward {
    final DateTime? lastClaim = _progress.lastDailyRewardClaimedAt;
    if (lastClaim == null) {
      return Duration.zero;
    }
    final Duration elapsed = DateTime.now().difference(lastClaim);
    final Duration remaining = dailyRewardCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns the coin reward for a completed level.
  static int coinRewardForStars(int stars) {
    return baseWinCoins + (stars * coinsPerStar);
  }

  /// Returns the gem reward for a completed level.
  static int gemRewardForStars(int stars) {
    return stars.clamp(0, 3).toInt();
  }

  /// Returns whether the player can start a level.
  bool get canPlayLevel => hearts > 0;

  /// Returns current booster inventory.
  int get hammers => _progress.hammers;
  int get shuffles => _progress.shuffles;
  int get bombs => _progress.bombs;
  int get starterPacks => _progress.starterPacks;

  /// Purchases a booster using coins.
  Future<bool> purchaseBooster(String type, int price) async {
    if (_progress.coins < price) {
      return false;
    }

    _progress = _progress.copyWith(
      coins: _progress.coins - price,
      hammers: type == 'hammer' ? _progress.hammers + 1 : _progress.hammers,
      shuffles: type == 'rocket' ? _progress.shuffles + 1 : _progress.shuffles,
      bombs: type == 'bomb' ? _progress.bombs + 1 : _progress.bombs,
      starterPacks: type == 'starter'
          ? _progress.starterPacks + 1
          : _progress.starterPacks,
    );
    await _save();
    return true;
  }

  /// Purchases a booster using gems.
  Future<bool> purchaseBoosterWithGems(String type, int gemPrice) async {
    if (_progress.gems < gemPrice) {
      return false;
    }

    _progress = _progress.copyWith(
      gems: _progress.gems - gemPrice,
      hammers: type == 'hammer' ? _progress.hammers + 1 : _progress.hammers,
      shuffles: type == 'rocket' ? _progress.shuffles + 1 : _progress.shuffles,
      bombs: type == 'bomb' ? _progress.bombs + 1 : _progress.bombs,
      starterPacks: type == 'starter'
          ? _progress.starterPacks + 1
          : _progress.starterPacks,
    );
    await _save();
    return true;
  }

  /// Consumes a booster from inventory.
  Future<bool> consumeBooster(String type) async {
    int current = 0;
    if (type == 'hammer') {
      current = _progress.hammers;
    } else if (type == 'rocket') {
      current = _progress.shuffles;
    } else if (type == 'bomb') {
      current = _progress.bombs;
    } else if (type == 'starter') {
      current = _progress.starterPacks;
    }

    if (current <= 0) {
      return false;
    }

    _progress = _progress.copyWith(
      hammers: type == 'hammer' ? _progress.hammers - 1 : _progress.hammers,
      shuffles: type == 'rocket' ? _progress.shuffles - 1 : _progress.shuffles,
      bombs: type == 'bomb' ? _progress.bombs - 1 : _progress.bombs,
      starterPacks: type == 'starter'
          ? _progress.starterPacks - 1
          : _progress.starterPacks,
    );
    await _save();
    return true;
  }

  /// Returns remaining time until hearts refill, or zero when available.
  Duration get timeUntilHeartRefill {
    if (_progress.hearts > 0 || _progress.heartsDepletedAt == null) {
      return Duration.zero;
    }
    final Duration elapsed = DateTime.now().difference(
      _progress.heartsDepletedAt!,
    );
    final Duration remaining = heartRefillDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Loads progress from local storage and applies any due heart refill.
  void loadProgress() {
    _progress = _saveManager.loadProgress();
    _applyHeartRefillIfDue(save: false);
    notifyListeners();
  }

  /// Finds a level by its stable id.
  Level levelById(int id) {
    return levels.firstWhere((Level level) => level.id == id);
  }

  /// Returns whether a level is unlocked for play.
  bool isUnlocked(int levelId) {
    return levelId <= _progress.highestUnlockedLevel;
  }

  /// Persists a completed level score, coins, and unlocks the next level.
  Future<void> completeLevel({
    required int levelId,
    required int score,
    required int stars,
  }) async {
    final Map<int, int> nextStars = <int, int>{..._progress.levelStars};
    final Map<int, int> nextScores = <int, int>{..._progress.levelBestScore};
    final int previousStars = nextStars[levelId] ?? 0;
    final int previousScore = nextScores[levelId] ?? 0;
    nextStars[levelId] = stars > previousStars ? stars : previousStars;
    nextScores[levelId] = score > previousScore ? score : previousScore;
    final int unlocked = levelId >= levels.length ? levelId : levelId + 1;
    final int coinReward =
        coinRewardForStars(stars) + score; // Score converted to coins
    final int gemReward = gemRewardForStars(stars);
    _progress = _progress.copyWith(
      levelStars: nextStars,
      levelBestScore: nextScores,
      coins: _progress.coins + coinReward,
      gems: _progress.gems + gemReward,
      totalScore: _progress.totalScore + score,
      highestUnlockedLevel: unlocked > _progress.highestUnlockedLevel
          ? unlocked
          : _progress.highestUnlockedLevel,
    );
    await _save();
  }

  /// Records a failed attempt and consumes one heart once per failed level.
  Future<void> recordLevelFailure() async {
    _applyHeartRefillIfDue(save: false);
    if (_progress.hearts <= 0) {
      notifyListeners();
      return;
    }
    final int nextHearts = _progress.hearts - 1;
    _progress = _progress.copyWith(
      hearts: nextHearts,
      heartsDepletedAt: nextHearts == 0 ? DateTime.now() : null,
      clearHeartsDepletedAt: nextHearts > 0,
    );
    await _save();
  }

  /// Adds one heart after a rewarded ad completes.
  Future<void> addRewardedAdHearts() async {
    final int nextHearts = (_progress.hearts + rewardedAdHearts)
        .clamp(0, maxHearts)
        .toInt();
    _progress = _progress.copyWith(
      hearts: nextHearts,
      clearHeartsDepletedAt: nextHearts > 0,
    );
    await _save();
  }

  /// Refills hearts when the 24-hour timer has elapsed.
  Future<void> refreshHeartsIfDue() async {
    final bool changed = _applyHeartRefillIfDue(save: false);
    if (changed) {
      await _save();
    } else {
      notifyListeners();
    }
  }

  /// Adds the available daily reward to saved coins when the cooldown is done.
  Future<bool> claimDailyReward() async {
    if (!canClaimDailyReward) {
      notifyListeners();
      return false;
    }
    final int claimedAmount = dailyRewardAmount;
    final int nextDay = dailyRewardDay >= maxDailyRewardDay
        ? 1
        : dailyRewardDay + 1;
    _progress = _progress.copyWith(
      coins: _progress.coins + claimedAmount,
      dailyRewardDay: nextDay,
      lastDailyRewardClaimedAt: DateTime.now(),
    );
    await _save();
    return true;
  }

  /// Clears all saved progress.
  Future<void> resetProgress() async {
    await _saveManager.resetProgress();
    _progress = const PlayerProgress();
    notifyListeners();
  }

  bool _applyHeartRefillIfDue({required bool save}) {
    if (_progress.hearts > 0 || _progress.heartsDepletedAt == null) {
      return false;
    }
    if (DateTime.now().difference(_progress.heartsDepletedAt!) <
        heartRefillDuration) {
      return false;
    }
    _progress = _progress.copyWith(
      hearts: maxHearts,
      clearHeartsDepletedAt: true,
    );
    if (save) {
      _save();
    }
    return true;
  }

  Future<void> _save() async {
    await _saveManager.saveProgress(_progress);
    notifyListeners();
  }
}
