import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../utils/safe_delta_time.dart';

/// Lightweight Flame scene used behind Flutter game UI.
/// Implements buffer-safe frame synchronization for older devices with Impeller.
class CandyCrushFlameGame extends FlameGame {
  static const double _fixedDt = 1.0 / 60.0;
  double _accumulator = 0.0;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  void update(double dt) {
    final double safeDt = SafeDeltaTime.clamp(dt);

    _accumulator += safeDt;
    while (_accumulator >= _fixedDt) {
      super.update(_fixedDt);
      _accumulator -= _fixedDt;
    }
  }
}
