import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'device_display.dart';

/// Calibrates burst particle quality from the startup refresh-rate reading.
class ParticleSettings {
  static int burstCount = 6;
  static int sparkleCount = 8;
  static double particleLifespan = 0.40;
  static double sparkleLifespan = 0.30;
  static bool enableShockwave = false;

  ParticleSettings._();

  /// Sets particle quality once so low-end devices stay within budget.
  static Future<void> calibrateForDevice() async {
    if (await _isLowEndDevice()) {
      burstCount = 6;
      sparkleCount = 8;
      particleLifespan = 0.36;
      sparkleLifespan = 0.26;
      enableShockwave = false;
      return;
    }

    final double refreshRate = DeviceDisplay.maxRefreshRate;
    if (refreshRate >= 90.0) {
      burstCount = 14;
      sparkleCount = 18;
      particleLifespan = 0.60;
      sparkleLifespan = 0.44;
      enableShockwave = true;
      return;
    }
    if (refreshRate >= 60.0) {
      burstCount = 10;
      sparkleCount = 12;
      particleLifespan = 0.50;
      sparkleLifespan = 0.36;
      enableShockwave = true;
      return;
    }
    burstCount = 6;
    sparkleCount = 8;
    particleLifespan = 0.40;
    sparkleLifespan = 0.30;
    enableShockwave = false;
  }

  static Future<bool> _isLowEndDevice() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return DeviceDisplay.maxRefreshRate < 55.0;
    }

    try {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt < 26;
    } catch (_) {
      return DeviceDisplay.maxRefreshRate < 55.0;
    }
  }
}
