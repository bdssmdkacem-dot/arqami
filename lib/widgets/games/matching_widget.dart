import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';

class MatchPair {
  final String id;
  final Widget leftContent;
  final Widget rightContent;

  const MatchPair({
    required this.id,
    required this.leftContent,
    required this.rightContent,
  });
}

class MatchingWidget extends StatefulWidget {
  final List<MatchPair> pairs;
  final VoidCallback onAllMatched;
  final void Function(String id)? onCorrectMatch;
  final VoidCallback? onWrongAttempt;
  final Color lineColor;
  final Color matchedColor;

  const MatchingWidget({
    super.key,
    required this.pairs,
    required this.onAllMatched,
    this.onCorrectMatch,
    this.onWrongAttempt,
    this.lineColor = GameTheme.ocean,
    this.matchedColor = GameTheme.success,
  });

  @override
  State<MatchingWidget> createState() => MatchingWidgetState();
}

class MatchingWidgetState extends State<MatchingWidget> {
  final GlobalKey _stackKey = GlobalKey();
  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  late List<String> _rightOrder;

  final Set<String> _matchedIds = {};
  String? _activeDragLeftId;
  Offset? _dragPosition;
  String? _flashWrongRightId;

  @override
  void initState() {
    super.initState();
    _setupKeysAndOrder();
  }

  void _setupKeysAndOrder() {
    _leftKeys = List.generate(widget.pairs.length, (_) => GlobalKey());
    _rightKeys = List.generate(widget.pairs.length, (_) => GlobalKey());
    _rightOrder = widget.pairs.map((p) => p.id).toList()..shuffle();
  }

  @override
  void didUpdateWidget(covariant MatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pairs.length != widget.pairs.length ||
        !_samePairIds(oldWidget.pairs, widget.pairs)) {
      reset(reshuffleAndRebuildKeys: true);
    }
  }

  bool _samePairIds(List<MatchPair> a, List<MatchPair> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void reset({bool reshuffleAndRebuildKeys = false}) {
    setState(() {
      _matchedIds.clear();
      _activeDragLeftId = null;
      _dragPosition = null;
      _flashWrongRightId = null;
      if (reshuffleAndRebuildKeys) _setupKeysAndOrder();
    });
  }

  Offset? _centerOfKey(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null || !renderBox.attached) {
      return null;
    }
    final globalCenter =
        renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    return stackBox.globalToLocal(globalCenter);
  }

  Offset _toLocal(Offset global) {
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return global;
    return stackBox.globalToLocal(global);
  }

  void _onPanStart(String leftId, DragStartDetails details) {
    if (_matchedIds.contains(leftId)) return;
    setState(() {
      _activeDragLeftId = leftId;
      _dragPosition = _toLocal(details.globalPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeDragLeftId == null) return;
    setState(() => _dragPosition = _toLocal(details.globalPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    final leftId = _activeDragLeftId;
    final dropPosition = _dragPosition;

    setState(() {
      _activeDragLeftId = null;
      _dragPosition = null;
    });

    if (leftId == null || dropPosition == null) return;

    const hitThreshold = 55.0;
    String? hitId;
    double bestDistance = double.infinity;

    for (int i = 0; i < _rightOrder.length; i++) {
      final rightId = _rightOrder[i];
      if (_matchedIds.contains(rightId)) continue;
      final center = _centerOfKey(_rightKeys[i]);
      if (center == null) continue;
      final distance = (center - dropPosition).distance;
      if (distance < hitThreshold && distance < bestDistance) {
        bestDistance = distance;
        hitId = rightId;
      }
    }

    if (hitId == null) return;

    if (hitId == leftId) {
      setState(() => _matchedIds.add(leftId));
      widget.onCorrectMatch?.call(leftId);
      if (_matchedIds.length == widget.pairs.length) {
        widget.onAllMatched();
      }
    } else {
      widget.onWrongAttempt?.call();
      setState(() => _flashWrongRightId = hitId);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _flashWrongRightId = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameTheme.sky, GameTheme.paperWarm],
        ),
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        key: _stackKey,
        children: [
          const Positioned(
            top: 12,
            left: 18,
            child: _GardenCloud(size: 34),
          ),
          const Positioned(
            top: 28,
            right: 24,
            child: _GardenCloud(size: 24),
          ),
          const Positioned(
            bottom: 8,
            left: 12,
            child: _GardenFlower(color: GameTheme.berry),
          ),
          const Positioned(
            bottom: 12,
            right: 12,
            child: _GardenFlower(color: GameTheme.sunshine),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColumn(isLeft: true),
                const _MatchBridge(),
                _buildColumn(isLeft: false),
              ],
            ),
          ),
          if (_activeDragLeftId != null && _dragPosition != null)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _DragLinePainter(
                  start: _centerOfKey(
                        _leftKeys[widget.pairs.indexWhere(
                            (p) => p.id == _activeDragLeftId)],
                      ) ??
                      _dragPosition!,
                  end: _dragPosition!,
                  color: widget.lineColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColumn({required bool isLeft}) {
    final count = isLeft ? widget.pairs.length : _rightOrder.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final pair = isLeft
            ? widget.pairs[i]
            : widget.pairs.firstWhere((p) => p.id == _rightOrder[i]);
        final id = pair.id;
        final isMatched = _matchedIds.contains(id);
        final isFlashingWrong = !isLeft && _flashWrongRightId == id;
        final key = isLeft ? _leftKeys[i] : _rightKeys[i];

        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: GestureDetector(
            onPanStart: isLeft && !isMatched
                ? (details) => _onPanStart(id, details)
                : null,
            onPanUpdate: isLeft && !isMatched ? _onPanUpdate : null,
            onPanEnd: isLeft && !isMatched ? _onPanEnd : null,
            child: AnimatedScale(
              scale: isMatched ? 0.94 : 1,
              duration: GameTheme.popMotion,
              child: AnimatedOpacity(
                opacity: isMatched ? 0.42 : 1,
                duration: GameTheme.popMotion,
                child: _ItemCard(
                  borderColor: isFlashingWrong
                      ? GameTheme.danger
                      : (isMatched ? widget.matchedColor : GameTheme.cloud),
                  accentColor: isMatched
                      ? widget.matchedColor
                      : (isLeft ? GameTheme.ocean : GameTheme.mint),
                  isLeft: isLeft,
                  rightChild: pair.rightContent,
                  child: pair.leftContent,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Widget child;
  final Widget rightChild;
  final bool isLeft;
  final Color borderColor;
  final Color accentColor;

  const _ItemCard({
    required this.child,
    required this.rightChild,
    required this.isLeft,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GameTheme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            left: 8,
            child: Icon(
              isLeft ? Icons.touch_app_rounded : Icons.flag_rounded,
              size: 16,
              color: accentColor.withValues(alpha: 0.75),
            ),
          ),
          Center(child: isLeft ? child : rightChild),
        ],
      ),
    );
  }
}

class _MatchBridge extends StatelessWidget {
  const _MatchBridge();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: GameTheme.sunshine,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.swap_horiz_rounded,
            size: 20,
            color: GameTheme.ink,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'طابِق',
          style: TextStyle(
            color: GameTheme.inkSoft,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _GardenCloud extends StatelessWidget {
  final double size;

  const _GardenCloud({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.6,
      height: size * 0.72,
      decoration: BoxDecoration(
        color: GameTheme.cloud.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _GardenFlower extends StatelessWidget {
  final Color color;

  const _GardenFlower({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_florist_rounded, color: color, size: 24);
  }
}

class _DragLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _DragLinePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    canvas.drawCircle(start, 7, paint);
  }

  @override
  bool shouldRepaint(covariant _DragLinePainter oldDelegate) => true;
}
