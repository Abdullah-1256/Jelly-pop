import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../game/flame/candy_crush_flame_game.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/level_provider.dart';
import '../routes/routes.dart';
import '../widgets/board_widget.dart';
import '../widgets/game_background.dart';
import '../widgets/jelly_page_scope.dart';
import 'game/widgets/game_hud.dart';
import 'game/widgets/game_nav_bar.dart';
import 'game/widgets/game_result_overlays.dart';

/// Match-3 play screen for a concrete level route.
class GameScreen extends StatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  bool _started = false;
  bool _resultShown = false;
  late final CandyCrushFlameGame _flameGame;
  String? _activeBooster;
  GamePhase? _lastPhase;  // Track previous phase to detect changes

  @override
  void initState() {
    super.initState();
    _flameGame = CandyCrushFlameGame();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to game state changes for win/lose conditions
    context.read<GameProvider>().addListener(_onGameUpdate);
  }

  @override
  void dispose() {
    context.read<GameProvider>().removeListener(_onGameUpdate);
    WidgetsBinding.instance.removeObserver(this);
    _flameGame.pauseEngine();
    _flameGame.detach();
    super.dispose();
  }

  void _onGameUpdate() {
    if (!mounted) return;
    _handlePhaseChange(context.read<GameProvider>());
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _resultShown = false;
      _lastPhase = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<GameProvider>().startLevelById(widget.levelId);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startLevelById(widget.levelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final Size size = MediaQuery.of(context).size;
    
    return JellyPageScope(
      fallbackRoute: AppRoutes.mapRoute,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GameBackground(
              asset: AppAssets.background,
              child: const SizedBox.expand(),
            ),
            _PersistentGameWidget(game: _flameGame),
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.035,
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 8),
                          GameLevelInfoHud(game: game),
                          const SizedBox(height: 8),
                          GameObjectives(game: game),
                          Expanded(child: _buildBoardStack(game, size)),
                        ],
                      ),
                    ),
                  ),
                  GameNavBar(onBoosterSelected: _selectBooster),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardStack(GameProvider game, Size size) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: OverflowBox(
            maxWidth: size.width - 8,
            child: BoardWidget(
              activeBooster: _activeBooster,
              onBoosterUsed: _clearBooster,
            ),
          ),
        ),
        if (game.comboText.isNotEmpty) ComboText(text: game.comboText),
        if (_activeBooster != null)
          Positioned(top: 8, child: BoosterAimBanner(onCancel: _clearBooster)),
      ],
    );
  }

  void _selectBooster(String booster) {
    setState(() => _activeBooster = booster);
  }

  void _clearBooster() {
    setState(() => _activeBooster = null);
  }

  void _handlePhaseChange(GameProvider game) {
    final GamePhase? currentPhase = game.state?.phase;
    
    // Only proceed if phase changed and is a terminal state
    if (currentPhase == _lastPhase) return;
    if (currentPhase != GamePhase.won && currentPhase != GamePhase.lost) {
      _lastPhase = currentPhase;
      _resultShown = false;
      return;
    }
    if (_resultShown) {
      _lastPhase = currentPhase;
      return;
    }

    _resultShown = true;
    _lastPhase = currentPhase;
    
    // Schedule in next frame for safe dialog display
    Future<void>.delayed(const Duration(milliseconds: 100), () async {
      if (!mounted) return;
      
      if (currentPhase == GamePhase.won) {
        try {
          await game.saveWinProgress();
        } catch (e) {
          debugPrint('GameScreen: Failed to save win progress: $e');
        }
        if (!mounted) return;
        
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => LevelWinOverlay(
            levelId: widget.levelId,
            score: game.state?.score ?? 0,
            stars: game.stars,
          ),
        );
        return;
      }

      final LevelProvider levels = context.read<LevelProvider>();
      try {
        await levels.recordLevelFailure();
      } catch (e) {
        debugPrint('GameScreen: Failed to record level failure: $e');
      }
      if (!mounted) return;
      
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelFailedOverlay(
          levelId: widget.levelId,
          heartsLeft: levels.hearts,
          refillRemaining: levels.timeUntilHeartRefill,
          score: game.state?.score ?? 0,
        ),
      );
    });
  }
}

class _PersistentGameWidget extends StatelessWidget {
  final CandyCrushFlameGame game;

  const _PersistentGameWidget({required this.game});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: GameWidget<CandyCrushFlameGame>(game: game));
  }
}
