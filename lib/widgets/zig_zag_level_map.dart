import 'package:flutter/material.dart';

import '../models/level.dart';
import 'level_orb.dart';
import 'zig_zag_level_path_painter.dart';

/// Scrollable Candy-Crush-style zig-zag level map.
class ZigZagLevelMap extends StatefulWidget {
  final List<Level> levels;
  final int highestUnlockedLevel;
  final Map<int, int> starsByLevel;
  final bool Function(int levelId) isUnlocked;
  final void Function(int levelId) onLevelTap;

  const ZigZagLevelMap({
    super.key,
    required this.levels,
    required this.highestUnlockedLevel,
    required this.starsByLevel,
    required this.isUnlocked,
    required this.onLevelTap,
  });

  @override
  State<ZigZagLevelMap> createState() => _ZigZagLevelMapState();
}

class _ZigZagLevelMapState extends State<ZigZagLevelMap> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncScrollOffset);
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double nodeSize = constraints.maxWidth < 380 ? 58 : 66;
        final double rowHeight = nodeSize + 32;
        final double mapHeight = widget.levels.length * rowHeight + nodeSize;
        final List<Offset> points = _buildPoints(
          width: constraints.maxWidth,
          rowHeight: rowHeight,
          nodeSize: nodeSize,
        );
        return SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            width: constraints.maxWidth,
            height: mapHeight,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollOffset,
                    builder:
                        (
                          BuildContext context,
                          double scrollOffset,
                          Widget? child,
                        ) {
                          return CustomPaint(
                            painter: ZigZagLevelPathPainter(
                              points: points,
                              motionOffset: scrollOffset,
                            ),
                          );
                        },
                  ),
                ),
                for (int index = 0; index < widget.levels.length; index++)
                  _buildLevelNode(
                    levelId: widget.levels[index].id,
                    point: points[index],
                    nodeSize: nodeSize,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Offset> _buildPoints({
    required double width,
    required double rowHeight,
    required double nodeSize,
  }) {
    const List<double> xPattern = <double>[0.22, 0.48, 0.76, 0.62, 0.34];
    return List<Offset>.generate(widget.levels.length, (int index) {
      final double x = width * xPattern[index % xPattern.length];
      final double y = nodeSize + (index * rowHeight);
      return Offset(x, y);
    });
  }

  Widget _buildLevelNode({
    required int levelId,
    required Offset point,
    required double nodeSize,
  }) {
    return Positioned(
      left: point.dx - (nodeSize * 0.5),
      top: point.dy - (nodeSize * 0.5),
      child: LevelOrb(
        levelId: levelId,
        unlocked: widget.isUnlocked(levelId),
        active: levelId == widget.highestUnlockedLevel,
        stars: widget.starsByLevel[levelId] ?? 0,
        size: nodeSize,
        scrollOffset: _scrollOffset,
        onTap: () => widget.onLevelTap(levelId),
      ),
    );
  }

  void _syncScrollOffset() {
    _scrollOffset.value = _scrollController.offset;
  }
}
