/// Persisted profile containing level stars, scores, resources, and unlock state.
class PlayerProgress {
  final Map<int, int> levelStars;
  final Map<int, int> levelBestScore;
  final int highestUnlockedLevel;
  final int hearts;
  final int coins;
  final int gems;
  final int totalScore;
  final int hammers;
  final int shuffles;
  final int bombs;
  final int starterPacks;
  final int dailyRewardDay;
  final DateTime? heartsDepletedAt;
  final DateTime? lastDailyRewardClaimedAt;

  const PlayerProgress({
    this.levelStars = const <int, int>{},
    this.levelBestScore = const <int, int>{},
    this.highestUnlockedLevel = 1,
    this.hearts = 5,
    this.coins = 1000,
    this.gems = 0,
    this.totalScore = 0,
    this.hammers = 3,
    this.shuffles = 3,
    this.bombs = 1,
    this.starterPacks = 1,
    this.dailyRewardDay = 1,
    this.heartsDepletedAt,
    this.lastDailyRewardClaimedAt,
  });

  /// Builds progress from SharedPreferences JSON.
  factory PlayerProgress.fromJson(Map<String, Object?> json) {
    final Map<String, Object?> stars =
        (json['level_stars'] as Map<String, Object?>?) ?? <String, Object?>{};
    final Map<String, Object?> scores =
        (json['level_best_score'] as Map<String, Object?>?) ??
        <String, Object?>{};
    final String? depletedAt = json['hearts_depleted_at'] as String?;
    final String? dailyClaimedAt =
        json['last_daily_reward_claimed_at'] as String?;
    return PlayerProgress(
      levelStars: stars.map((String key, Object? value) {
        return MapEntry<int, int>(int.parse(key), value as int);
      }),
      levelBestScore: scores.map((String key, Object? value) {
        return MapEntry<int, int>(int.parse(key), value as int);
      }),
      highestUnlockedLevel: json['highest_unlocked_level'] as int? ?? 1,
      hearts: json['hearts'] as int? ?? 5,
      coins: json['coins'] as int? ?? 1000,
      gems: json['gems'] as int? ?? 0,
      totalScore: json['total_score'] as int? ?? 0,
      hammers: json['hammers'] as int? ?? 3,
      shuffles: json['shuffles'] as int? ?? 3,
      bombs: json['bombs'] as int? ?? 1,
      starterPacks: json['starter_packs'] as int? ?? 1,
      dailyRewardDay: json['daily_reward_day'] as int? ?? 1,
      heartsDepletedAt: depletedAt == null
          ? null
          : DateTime.tryParse(depletedAt),
      lastDailyRewardClaimedAt: dailyClaimedAt == null
          ? null
          : DateTime.tryParse(dailyClaimedAt),
    );
  }

  /// Converts this progress model to serializable JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'level_stars': levelStars.map((int key, int value) {
        return MapEntry<String, int>(key.toString(), value);
      }),
      'level_best_score': levelBestScore.map((int key, int value) {
        return MapEntry<String, int>(key.toString(), value);
      }),
      'highest_unlocked_level': highestUnlockedLevel,
      'hearts': hearts,
      'coins': coins,
      'gems': gems,
      'total_score': totalScore,
      'hammers': hammers,
      'shuffles': shuffles,
      'bombs': bombs,
      'starter_packs': starterPacks,
      'daily_reward_day': dailyRewardDay,
      'hearts_depleted_at': heartsDepletedAt?.toIso8601String(),
      'last_daily_reward_claimed_at': lastDailyRewardClaimedAt
          ?.toIso8601String(),
    };
  }

  /// Creates a copy with changed fields.
  PlayerProgress copyWith({
    Map<int, int>? levelStars,
    Map<int, int>? levelBestScore,
    int? highestUnlockedLevel,
    int? hearts,
    int? coins,
    int? gems,
    int? totalScore,
    int? hammers,
    int? shuffles,
    int? bombs,
    int? starterPacks,
    int? dailyRewardDay,
    DateTime? heartsDepletedAt,
    DateTime? lastDailyRewardClaimedAt,
    bool clearHeartsDepletedAt = false,
  }) {
    return PlayerProgress(
      levelStars: levelStars ?? this.levelStars,
      levelBestScore: levelBestScore ?? this.levelBestScore,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      hearts: hearts ?? this.hearts,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      totalScore: totalScore ?? this.totalScore,
      hammers: hammers ?? this.hammers,
      shuffles: shuffles ?? this.shuffles,
      bombs: bombs ?? this.bombs,
      starterPacks: starterPacks ?? this.starterPacks,
      dailyRewardDay: dailyRewardDay ?? this.dailyRewardDay,
      heartsDepletedAt: clearHeartsDepletedAt
          ? null
          : heartsDepletedAt ?? this.heartsDepletedAt,
      lastDailyRewardClaimedAt:
          lastDailyRewardClaimedAt ?? this.lastDailyRewardClaimedAt,
    );
  }
}
