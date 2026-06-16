import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Detects the active display refresh rate once during app startup.
class DeviceDisplay {
  static const double _minRefreshRate = 40.0;
  static const double _maxRefreshRate = 120.0;

  static double maxRefreshRate = _minRefreshRate;
  static double targetDt = 1.0 / _minRefreshRate;

  DeviceDisplay._();

  /// Reads and clamps the platform display refresh rate before runApp.
  static Future<void> init() async {
    final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
    final List<FlutterView> views = binding.platformDispatcher.views.toList();
    final double detected = views.isEmpty
        ? _minRefreshRate
        : views.first.display.refreshRate;

    maxRefreshRate = detected.clamp(_minRefreshRate, _maxRefreshRate);
    targetDt = 1.0 / maxRefreshRate;
    debugPrint(
      'Jelly Pop display refresh rate: ${maxRefreshRate.toStringAsFixed(1)}Hz',
    );
  }
}
