/// Keeps Flame frame deltas inside a stable simulation range.
class SafeDeltaTime {
  static const double maxDelta = 1 / 30;

  SafeDeltaTime._();

  /// Clamps frame delta spikes so slow frames do not teleport game objects.
  static double clamp(double dt) {
    return dt.clamp(0.0, maxDelta).toDouble();
  }
}
