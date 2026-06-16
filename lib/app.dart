import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/save_manager.dart';
import 'providers/audio_provider.dart';
import 'providers/game_provider.dart';
import 'providers/level_provider.dart';
import 'routes/app_router.dart';

/// Root app shell that wires providers, theme, and GoRouter.
class CandyCrushApp extends StatelessWidget {
  final SaveManager saveManager;
  final AudioManager audioManager;

  const CandyCrushApp({
    super.key,
    required this.saveManager,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioProvider>(
          create: (_) => AudioProvider(audioManager),
        ),
        ChangeNotifierProvider<LevelProvider>(
          create: (_) => LevelProvider(saveManager)..loadProgress(),
        ),
        ChangeNotifierProxyProvider<LevelProvider, GameProvider>(
          create: (_) => GameProvider(audioManager),
          update: (_, LevelProvider levels, GameProvider? game) =>
              (game ?? GameProvider(audioManager))..attachLevels(levels),
        ),
      ],
      child: MaterialApp.router(
        title: 'Jelly Pop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
