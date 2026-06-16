import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Controls whether the app should treat Impeller as safe for this device.
class ImpellerConfig {
  static bool isEnabled = false;

  ImpellerConfig._();

  /// Detects platform and Android device safety before app startup continues.
  static Future<void> init() async {
    if (Platform.isIOS) {
      isEnabled = true;
      return;
    }

    if (!Platform.isAndroid) {
      isEnabled = false;
      return;
    }

    final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    final int sdkInt = info.version.sdkInt;
    final String hardware = info.hardware.toLowerCase();

    if (sdkInt < 29) {
      isEnabled = false;
      debugPrint(
        'Impeller: $isEnabled | Android API: $sdkInt | GPU: $hardware',
      );
      return;
    }

    final bool isPowerVrGpu =
        hardware.contains('powervr') ||
        hardware.contains('sgx') ||
        hardware.contains('rogue');
    if (isPowerVrGpu) {
      isEnabled = false;
      debugPrint(
        'Impeller: $isEnabled | Android API: $sdkInt | GPU: $hardware',
      );
      return;
    }

    if (info.supportedAbis.isEmpty) {
      isEnabled = false;
      debugPrint(
        'Impeller: $isEnabled | Android API: $sdkInt | GPU: $hardware',
      );
      return;
    }

    isEnabled = true;
    debugPrint('Impeller: $isEnabled | Android API: $sdkInt | GPU: $hardware');
  }
}
