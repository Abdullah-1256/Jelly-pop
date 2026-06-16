/// Converts matches, specials, and cascades into score values.
class ScoreCalculator {
  /// Returns the score for a normal match group.
  int matchScore({required int candyCount, required double multiplier}) {
    int base = 20;
    if (candyCount == 4) {
      base = 40;
    } else if (candyCount >= 5) {
      base = 60;
    }
    return (base * multiplier).toInt();
  }

  /// Returns the score for special candy removal effects.
  int specialScore({required int candyCount, required double multiplier}) {
    return 100;
  }
}
