import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../models/candy.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/level_provider.dart';
import 'candy_widget.dart';

/// Responsive square board with optimized rebuilds for low-end devices.
class BoardWidget extends StatelessWidget {
  final String? activeBooster;
  final VoidCallback? onBoosterUsed;

  const BoardWidget({super.key, this.activeBooster, this.onBoosterUsed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : constraints.maxWidth;
        final double boardWidth = math.min(
          constraints.maxWidth,
          availableHeight,
        );
        final double boardHeight = math.min(availableHeight, boardWidth * 1.08);
        const double gridPadding = 8;
        final double gridWidth = boardWidth - (gridPadding * 2);
        final double gridHeight = boardHeight - (gridPadding * 2);

        return Container(
          width: boardWidth,
          height: boardHeight,
          decoration: BoxDecoration(
            color: AppColors.board.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppSizes.boardRadius + 4),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(gridPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.boardRadius),
              child: Stack(
                children: <Widget>[
                  // 1. Static Background (Rebuilds only if level dimensions change)
                  Selector<GameProvider, (int, int)>(
                    selector: (_, game) =>
                        (game.level?.gridRows ?? 8, game.level?.gridCols ?? 8),
                    builder: (context, dimensions, child) {
                      return _BoardGridBackground(
                        rows: dimensions.$1,
                        cols: dimensions.$2,
                        cellWidth: gridWidth / dimensions.$2,
                        cellHeight: gridHeight / dimensions.$1,
                      );
                    },
                  ),

                  // 2. Blast Effects (Isolated rebuilds)
                  Selector<GameProvider, Map<String, CandyType>?>(
                    selector: (_, game) => game.state?.matchedCells,
                    builder: (context, matchedCells, child) {
                      if (matchedCells == null || matchedCells.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final game = context.read<GameProvider>();
                      final rows = game.level?.gridRows ?? 8;
                      final cols = game.level?.gridCols ?? 8;
                      return _BlastEffectsLayer(
                        matchedCells: matchedCells,
                        cellWidth: gridWidth / cols,
                        cellHeight: gridHeight / rows,
                      );
                    },
                  ),

                  // 3. Candy Pieces (Isolated rebuilds)
                  Selector<GameProvider, List<List<Candy?>>?>(
                    selector: (_, game) => game.state?.grid,
                    builder: (context, grid, child) {
                      if (grid == null) return const SizedBox.shrink();
                      final game = context.read<GameProvider>();
                      final rows = game.level?.gridRows ?? 8;
                      final cols = game.level?.gridCols ?? 8;
                      return _CandyPiecesLayer(
                        grid: grid,
                        cellWidth: gridWidth / cols,
                        cellHeight: gridHeight / rows,
                        activeBooster: activeBooster,
                        onBoosterUsed: onBoosterUsed,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders the static grid cells once to avoid heavy rebuilds.
class _BoardGridBackground extends StatelessWidget {
  final int rows;
  final int cols;
  final double cellWidth;
  final double cellHeight;

  const _BoardGridBackground({
    required this.rows,
    required this.cols,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    return RepaintBoundary(
      child: Stack(
        children: List<Widget>.generate(rows * cols, (int index) {
          final int row = index ~/ cols;
          final int col = index % cols;
          final bool blocked = game.level!.isBlocked(row: row, col: col);
          return Positioned(
            left: col * cellWidth,
            top: row * cellHeight,
            width: cellWidth,
            height: cellHeight,
            child: Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: blocked
                    ? AppColors.blocked
                    : AppColors.textLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.smallGap),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Renders match animations in an isolated layer.
class _BlastEffectsLayer extends StatelessWidget {
  final Map<String, CandyType> matchedCells;
  final double cellWidth;
  final double cellHeight;

  const _BlastEffectsLayer({
    required this.matchedCells,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> effects = <Widget>[];
    for (final MapEntry<String, CandyType> entry in matchedCells.entries) {
      final List<String> parts = entry.key.split(',');
      if (parts.length != 2) continue;
      final int? row = int.tryParse(parts.first);
      final int? col = int.tryParse(parts.last);
      if (row == null || col == null) continue;

      final double effectSize = math.min(cellWidth, cellHeight);
      effects.add(
        Positioned(
          left: (col * cellWidth) + (cellWidth * 0.5) - (effectSize * 1.05),
          top: (row * cellHeight) + (cellHeight * 0.5) - (effectSize * 1.05),
          width: effectSize * 2.1,
          height: effectSize * 2.1,
          child: _CandyBlast(type: entry.value),
        ),
      );
    }
    return Stack(children: effects);
  }
}

/// Renders and handles interaction for all candy pieces.
class _CandyPiecesLayer extends StatelessWidget {
  final List<List<Candy?>> grid;
  final double cellWidth;
  final double cellHeight;
  final String? activeBooster;
  final VoidCallback? onBoosterUsed;

  const _CandyPiecesLayer({
    required this.grid,
    required this.cellWidth,
    required this.cellHeight,
    this.activeBooster,
    this.onBoosterUsed,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pieces = <Widget>[];

    for (final List<Candy?> row in grid) {
      for (final Candy? candy in row) {
        if (candy == null) continue;

        // Use Selectors for individual candy properties to further optimize?
        // For now, rebuild the whole layer when grid changes is standard Flame-style.
        pieces.add(
          _IndividualCandy(
            candy: candy,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            activeBooster: activeBooster,
            onBoosterUsed: onBoosterUsed,
          ),
        );
      }
    }
    return Stack(children: pieces);
  }
}

class _IndividualCandy extends StatelessWidget {
  final Candy candy;
  final double cellWidth;
  final double cellHeight;
  final String? activeBooster;
  final VoidCallback? onBoosterUsed;

  const _IndividualCandy({
    required this.candy,
    required this.cellWidth,
    required this.cellHeight,
    this.activeBooster,
    this.onBoosterUsed,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    // Freeze animations and input when game ends
    final bool isGameEnded =
        game.state?.phase == GamePhase.won ||
        game.state?.phase == GamePhase.lost;

    final bool isSelected =
        !isGameEnded &&
        game.selectedPoint?.row == candy.row &&
        game.selectedPoint?.col == candy.col;
    final bool isSwapping =
        !isGameEnded && game.swappingCandyIds.contains(candy.id);
    final bool isHint =
        !isGameEnded &&
        (game.hintPoints?.any(
              (p) => p.row == candy.row && p.col == candy.col,
            ) ??
            false);

    return AnimatedPositioned(
      key: ValueKey<String>(candy.id),
      duration: Duration(
        milliseconds: candy.row == -1
            ? 0
            : (isSwapping ? AppSizes.swapMs : AppSizes.fallMinMs),
      ),
      curve: Curves.easeOutCubic,
      left: candy.col * cellWidth,
      top: candy.row * cellHeight,
      width: cellWidth,
      height: cellHeight,
      child: RepaintBoundary(
        child: CandyWidget(
          candy: candy,
          selected: isSelected,
          isSwapping: isSwapping,
          hint: isHint,
          onTap: isGameEnded
              ? null
              : () => _onCellTap(context, game, candy.row, candy.col),
          onPanEnd: isGameEnded
              ? null
              : (details) => _handleSwipe(game, candy.row, candy.col, details),
        ),
      ),
    );
  }

  void _handleSwipe(
    GameProvider game,
    int row,
    int col,
    DragEndDetails details,
  ) {
    final Offset velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      game.swipeFrom(
        row: row,
        col: col,
        rowDelta: 0,
        colDelta: velocity.dx > 0 ? 1 : -1,
      );
    } else {
      game.swipeFrom(
        row: row,
        col: col,
        rowDelta: velocity.dy > 0 ? 1 : -1,
        colDelta: 0,
      );
    }
  }

  void _onCellTap(
    BuildContext context,
    GameProvider game,
    int row,
    int col,
  ) async {
    if (activeBooster != null) {
      final levels = context.read<LevelProvider>();
      if (await levels.consumeBooster(activeBooster!)) {
        if (activeBooster == 'hammer') {
          await game.useHammer(row, col);
        } else if (activeBooster == 'rocket') {
          await game.useRocket(row, col);
        } else if (activeBooster == 'bomb') {
          await game.useBomb(row, col);
        }
        onBoosterUsed?.call();
      }
      return;
    }
    game.selectCell(row: row, col: col);
  }
}

class _CandyBlast extends StatefulWidget {
  final CandyType type;

  const _CandyBlast({required this.type});

  @override
  State<_CandyBlast> createState() => _CandyBlastState();
}

class _CandyBlastState extends State<_CandyBlast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ), // Professional smooth duration
      vsync: this,
    );
    _setupAnimations();
    _ctrl.forward();
  }

  void _setupAnimations() {
    // Smooth scale expansion with easeOutCubic (professional deceleration)
    _scaleAnim = Tween<double>(
      begin: 0.35,
      end: 2.75,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Smooth opacity fade with easeOutQuad (faster falloff for polish)
    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuad),
      ),
    );

    // Smooth rotation with easeInBack for bouncy feel
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 6.28,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInBack));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFor(widget.type);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (BuildContext context, Widget? child) {
          return Opacity(
            opacity: _opacityAnim.value,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Blast burst effect (scales and expands with smooth curve)
                Transform.scale(
                  scale: _scaleAnim.value,
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _CandyBlastPainter(
                      color: color,
                      progress: _ctrl.value,
                    ),
                  ),
                ),
                // Rotating candy icon with proportional scale
                Transform.rotate(
                  angle: _rotateAnim.value,
                  child: Transform.scale(
                    scale: 1.0 - (_rotateAnim.value / 6.28 * 0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        AppAssets.candyFor(widget.type),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _colorFor(CandyType type) {
    return switch (type) {
      CandyType.red => AppColors.redCandy,
      CandyType.blue => AppColors.blueCandy,
      CandyType.green => AppColors.greenCandy,
      CandyType.yellow => AppColors.yellowCandy,
      CandyType.purple => AppColors.purpleCandy,
      CandyType.orange => AppColors.orangeCandy,
    };
  }
}

class _CandyBlastPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _CandyBlastPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    final double radius = size.shortestSide * 0.36;
    final double fade = 1 - progress; // Smooth fade-out

    // Central white flash burst (bright, professional look)
    final Paint flashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75 * fade)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(
      center,
      radius * (0.4 + progress * 0.8), // Smooth scale progression
      flashPaint,
    );

    // Radiant rays expanding outward
    final Paint rayPaint = Paint()
      ..color = color.withValues(alpha: 0.65 * fade)
      ..strokeWidth = math
          .max(2, 4 * fade) // Minimum stroke width for clean look
      ..strokeCap = StrokeCap.round;

    const int rays = 14; // Increased for professional, sophisticated look
    for (int index = 0; index < rays; index++) {
      final double angle = ((index / rays) * math.pi * 2);
      final double rayLength = radius * (1.0 + progress * 1.5);
      final Offset outer = Offset(
        center.dx + (rayLength * math.cos(angle)),
        center.dy + (rayLength * math.sin(angle)),
      );
      canvas.drawLine(center, outer, rayPaint);
    }

    // Outer glow circle for extra polish and depth
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
    canvas.drawCircle(center, radius * (1.2 + progress * 1.8), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CandyBlastPainter oldDelegate) =>
      oldDelegate.progress != progress; // Only repaint if progress changes
}
