import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/save_manager.dart';
import 'utils/device_display.dart';
import 'utils/impeller_config.dart';
import 'utils/particle_settings.dart';

/// Boots Jelly Pop with saved progress, audio, and the routed app UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent buffer queue exhaustion on older devices with Impeller.
  // Limits rendering to device refresh rate + safety margin.
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await ImpellerConfig.init();
  await DeviceDisplay.init();
  await ParticleSettings.calibrateForDevice();

  final SaveManager saveManager = await SaveManager.create();
  final AudioManager audioManager = AudioManager();
  await audioManager.preloadAll();

  runApp(CandyCrushApp(saveManager: saveManager, audioManager: audioManager));
}
