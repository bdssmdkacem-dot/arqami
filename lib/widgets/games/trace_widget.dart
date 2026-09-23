import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../core/profile/age_activity_presentation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';
import '../../models/number_path.dart';

/// تدريب كتابة الرقم بالإصبع داخل "حديقة الأعداد".
///
/// التتبع يعتمد على مسار هندسي دقيق، بينما العرض يستخدم شريطاً ناعماً
/// ونقاط بداية واضحة حتى يبدو النشاط كلعبة لا كتمرين ورقي تقليدي.
class TraceWidget extends StatefulWidget {
  final int number;
  final VoidCallback onComplete;
  final double? accuracyThreshold;
  final double? toleranceRadius;
  final Color guideColor;
  final Color strokeColor;
  final Color startPointColor;

  const TraceWidget({
    super.key,
    required this.number,
    required this.onComplete,
    this.accuracyThreshold,
    this.toleranceRadius,
    this.guideColor = GameTheme.ocean,
    this.strokeColor = GameTheme.violet,
    this.startPointColor = GameTheme.sunshine,
  });

  @override
  State<TraceWidget> createState() => TraceWidgetState();
}

enum _TraceStatus { idle, inProgress, needsRetry, complete }

class TraceWidgetState extends State<TraceWidget> with SingleTickerProviderStateMixin {
  late SignatureController _controller;
  late NumberPath _numberPath;
  late AnimationController _guideAnimation;
  late AnimationController _celebrationAnimation;
  late AnimationController _checkpointAnimation;
  int _strokeStartIndex = 0;
  final List<List<Offset>> _userStrokes = [];
  _TraceStatus _status = _TraceStatus.idle;
  double _accuracy = 0;
  int _failedAttempts = 0;
  final ValueNotifier<int> _magicInkTick = ValueNotifier<int>(0);
  final ValueNotifier<int> _guidanceTick = ValueNotifier<int>(0);
  double? _guidanceDistance;
  bool _guidanceOnPath = true;
  int _lastCheckpoint = 0;

  int get _checkpoint => (_accuracy * 4).floor().clamp(0, 4);

  AgeActivityPresentation get _presentation => AgeActivityPresentation.current();

  double get _threshold {
    final configured = widget.accuracyThreshold;
    if (configured != null) return configured;
    final base = _presentation.traceAccuracyThreshold;
    return (base - (_failedAttempts * 0.05)).clamp(0.40, base);
  }

  double get _tolerance => widget.toleranceRadius ?? _presentation.traceToleranceRadius;

  @override
  void initState() {
    super.initState();
    _numberPath = NumberPathData.getPath(widget.number);
    _controller = SignatureController(
      penStrokeWidth: 17,
      penColor: widget.strokeColor,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
      exportBackgroundColor: Colors.transparent,
      onDrawStart: _onDrawStart,
      onDrawMove: _onDrawMove,
      onDrawEnd: _onStrokeEnd,
    );
    _guideAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _celebrationAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _checkpointAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant TraceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _numberPath = NumberPathData.getPath(widget.number);
      reset();
    }
  }

  @override
  void dispose() {
    _checkpointAnimation.dispose();
    _celebrationAnimation.dispose();
    _guideAnimation.dispose();
    _magicInkTick.dispose();
    _guidanceTick.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDrawStart() {
    if (_status == _TraceStatus.complete) return;
    _strokeStartIndex = _controller.points.length;
    _guidanceDistance = 0;
    _guidanceOnPath = true;
    _guidanceTick.value++;
    if (mounted) setState(() => _status = _TraceStatus.inProgress);
  }

  void _onDrawMove() {
    if (_status == _TraceStatus.complete) return;
    _updateSmartGuidance();
    _magicInkTick.value++;
  }

  void _updateSmartGuidance() {
    final size = context.size;
    final points = _controller.points;
    if (size == null || points.isEmpty) return;

    final segments = _expectedStrokeSegments();
    if (segments.isEmpty) return;
    final segmentIndex = _userStrokes.length.clamp(0, segments.length - 1);
    final expected = segments[segmentIndex];
    if (expected.isEmpty) return;

    final current = points.last.offset;
    var nearest = double.infinity;
    for (final referencePoint in expected) {
      final distance = (current - referencePoint.toOffset(size)).distance;
      if (distance < nearest) nearest = distance;
    }

    final tolerancePx = _tolerance * size.width;
    _guidanceDistance = nearest;
    _guidanceOnPath = nearest <= tolerancePx;
    _guidanceTick.value++;
  }

  void _onStrokeEnd() {
    if (_status == _TraceStatus.complete || _controller.isEmpty) return;
    final points = _controller.points;
    if (_strokeStartIndex >= points.length) return;
    final stroke = points.sublist(_strokeStartIndex).map((p) => p.offset).toList(growable: false);
    if (stroke.isNotEmpty) _userStrokes.add(stroke);
    _magicInkTick.value++;
    _checkAccuracy();
  }

  List<List<PathPoint>> _expectedStrokeSegments() {
    final points = _numberPath.points;
    if (points.isEmpty) return const [];
    final breaks = <int>{0, ..._numberPath.strokeBreaks, points.length}.toList()..sort();
    final segments = <List<PathPoint>>[];
    for (var i = 0; i < breaks.length - 1; i++) {
      if (breaks[i] < breaks[i + 1]) {
        segments.add(points.sublist(breaks[i], breaks[i + 1]));
      }
    }
    return segments;
  }

  void _checkAccuracy() {
    final size = context.size;
    if (size == null || _numberPath.points.isEmpty || _userStrokes.isEmpty) return;

    final expected = _expectedStrokeSegments();
    if (_userStrokes.length > expected.length) {
      _fail(0);
      return;
    }

    var matched = 0;
    var total = 0;
    for (var i = 0; i < _userStrokes.length; i++) {
      final result = _matchStroke(expected[i], _userStrokes[i], size);
      matched += result.matched;
      total += result.expected;
    }

    _accuracy = total == 0 ? 0 : matched / total;
    final checkpoint = _checkpoint;
    if (checkpoint > _lastCheckpoint && checkpoint < 4) {
      _lastCheckpoint = checkpoint;
      _checkpointAnimation.forward(from: 0);
    }
    if (_userStrokes.length < expected.length) {
      if (mounted) setState(() => _status = _TraceStatus.inProgress);
      return;
    }

    if (_accuracy >= _threshold) {
      if (!mounted) return;
      setState(() => _status = _TraceStatus.complete);
      _celebrationAnimation.forward(from: 0);
      widget.onComplete();
    } else {
      _fail(_accuracy);
    }
  }

  _StrokeMatchResult _matchStroke(List<PathPoint> expected, List<Offset> user, Size size) {
    if (expected.isEmpty || user.isEmpty) return const _StrokeMatchResult(0, 0);
    final tolerancePx = _tolerance * size.width;
    var userIndex = 0;
    var matched = 0;
    for (final referencePoint in expected) {
      final target = referencePoint.toOffset(size);
      for (var i = userIndex; i < user.length; i++) {
        if ((user[i] - target).distance <= tolerancePx) {
          matched++;
          userIndex = i + 1;
          break;
        }
      }
    }
    return _StrokeMatchResult(matched, expected.length);
  }

  void _fail(double accuracy) {
    _failedAttempts++;
    if (!mounted) return;
    setState(() {
      _accuracy = accuracy;
      _status = _TraceStatus.needsRetry;
    });
  }

  void reset() {
    _controller.clear();
    _strokeStartIndex = 0;
    _userStrokes.clear();
    _lastCheckpoint = 0;
    _checkpointAnimation.reset();
    _magicInkTick.value++;
    _guidanceDistance = null;
    _guidanceOnPath = true;
    _guidanceTick.value++;
    if (!mounted) return;
    setState(() {
      _accuracy = 0;
      _status = _TraceStatus.idle;
    });
  }

  String get _statusText {
    switch (_status) {
      case _TraceStatus.idle:
        return _presentation.showExtraGuidance
            ? 'ابدأ من البوابة الذهبية واتبع طريق الرقم'
            : 'ابدأ من البوابة الذهبية واتبع الطريق';
      case _TraceStatus.inProgress:
        return _presentation.showExtraGuidance ? 'أكمل الطريق بالترتيب' : 'تابع الطريق';
      case _TraceStatus.needsRetry:
        return _failedAttempts >= 3
            ? 'لا بأس، اقترب من الطريق وحاول مرة أخرى'
            : 'اقترب أكثر من الطريق وحاول مرة أخرى';
      case _TraceStatus.complete:
        return _presentation.useShortFeedback ? 'تمت كتابة الرقم' : 'أحسنت! أكملت طريق الرقم';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case _TraceStatus.needsRetry:
        return AppColors.terracotta;
      case _TraceStatus.complete:
        return GameTheme.success;
      case _TraceStatus.idle:
      case _TraceStatus.inProgress:
        return GameTheme.inkSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GardenHeader(number: widget.number, status: _status, statusText: _statusText, statusColor: _statusColor, checkpoint: _checkpoint, onReset: reset),
        const SizedBox(height: 8),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [GameTheme.sky, GameTheme.paper],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GardenBackgroundPainter(number: widget.number))),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _guideAnimation,
                        builder: (context, _) => CustomPaint(
                          painter: _NumberRoadPainter(
                            numberPath: _numberPath,
                            guideColor: widget.guideColor,
                            startColor: widget.startPointColor,
                            animationValue: _guideAnimation.value,
                            completed: _status == _TraceStatus.complete,
                            celebrationValue: _celebrationAnimation.value,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SmartGuidancePainter(
                          controller: _controller,
                          distance: _guidanceDistance,
                          onPath: _guidanceOnPath,
                          repaint: _guidanceTick,
                          active: _status == _TraceStatus.inProgress,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MagicInkPainter(
                          controller: _controller,
                          completedStrokes: _userStrokes,
                          strokeStartIndex: _strokeStartIndex,
                          repaint: _magicInkTick,
                          active: _status == _TraceStatus.inProgress,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Signature(
                        controller: _controller,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: AnimatedBuilder(
                        animation: _checkpointAnimation,
                        builder: (context, _) => _TraceProgress(
                          checkpoint: _checkpoint,
                          accuracy: _accuracy,
                          active: _status == _TraceStatus.inProgress,
                          pulse: _checkpointAnimation.value,
                        ),
                      ),
                    ),
                    if (_status == _TraceStatus.complete)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _celebrationAnimation,
                            builder: (context, _) => CustomPaint(
                              painter: _CelebrationPainter(value: _celebrationAnimation.value),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        AnimatedOpacity(
          opacity: _accuracy > 0 && _status != _TraceStatus.inProgress ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: Text('الدقة ${(_accuracy * 100).round()}٪', style: const TextStyle(fontSize: 12, color: GameTheme.inkSoft)),
        ),
      ],
    );
  }
}

class _GardenHeader extends StatelessWidget {
  final int number;
  final _TraceStatus status;
  final String statusText;
  final Color statusColor;
  final int checkpoint;
  final VoidCallback onReset;

  const _GardenHeader({required this.number, required this.status, required this.statusText, required this.statusColor, required this.checkpoint, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final active = status == _TraceStatus.inProgress;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 8, 9),
      decoration: BoxDecoration(
        color: GameTheme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: active ? GameTheme.mint : GameTheme.ocean.withValues(alpha: .14), width: active ? 2 : 1),
        boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [GameTheme.sunshine, GameTheme.mango]),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text('$number', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: GameTheme.ink)),
          ),
          const SizedBox(width: 10),
          _CheckpointDots(value: checkpoint),
          const SizedBox(width: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                statusText,
                key: ValueKey(status),
                style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          IconButton(onPressed: onReset, tooltip: 'إعادة المحاولة', icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
    );
  }
}

class _GardenBackgroundPainter extends CustomPainter {
  final int number;
  const _GardenBackgroundPainter({required this.number});

  @override
  void paint(Canvas canvas, Size size) {
    final ground = Paint()..color = GameTheme.mint.withValues(alpha: .12);
    canvas.drawOval(Rect.fromLTWH(-size.width * .12, size.height * .78, size.width * 1.24, size.height * .30), ground);

    final flowerPaint = Paint()..color = GameTheme.berry.withValues(alpha: .55);
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.10 + i * .20);
      final y = size.height * (.88 + (i.isEven ? .025 : -.015));
      canvas.drawCircle(Offset(x, y), 4, flowerPaint);
      canvas.drawCircle(Offset(x + 5, y + 2), 3, flowerPaint);
    }

    final cloudPaint = Paint()..color = GameTheme.cloud.withValues(alpha: .72);
    canvas.drawCircle(Offset(size.width * .16, size.height * .10), 18, cloudPaint);
    canvas.drawCircle(Offset(size.width * .21, size.height * .085), 24, cloudPaint);
    canvas.drawCircle(Offset(size.width * .27, size.height * .105), 17, cloudPaint);

    final sign = Paint()..color = GameTheme.mango.withValues(alpha: .28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * .82, size.height * .15), width: 54, height: 34),
        const Radius.circular(12),
      ),
      sign,
    );
    final tp = TextPainter(
      text: TextSpan(text: '$number', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GameTheme.ink)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(size.width * .82 - tp.width / 2, size.height * .15 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GardenBackgroundPainter oldDelegate) => oldDelegate.number != number;
}

class _NumberRoadPainter extends CustomPainter {
  final NumberPath numberPath;
  final Color guideColor;
  final Color startColor;
  final double animationValue;
  final bool completed;
  final double celebrationValue;

  const _NumberRoadPainter({required this.numberPath, required this.guideColor, required this.startColor, required this.animationValue, required this.completed, required this.celebrationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (numberPath.points.isEmpty) return;
    final guidePath = numberPath.buildGuidePath(size);

    final glow = Paint()
      ..color = completed ? GameTheme.success.withValues(alpha: .12) : guideColor.withValues(alpha: .10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(guidePath, glow);

    final ribbon = Paint()
      ..color = completed ? GameTheme.success.withValues(alpha: .68) : guideColor.withValues(alpha: .62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(guidePath, ribbon);

    final centerline = Paint()
      ..color = Colors.white.withValues(alpha: completed ? .55 : .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(guidePath, centerline);

    final start = numberPath.points.first.toOffset(size);
    canvas.drawCircle(start, 22, Paint()..color = startColor.withValues(alpha: .16));
    canvas.drawCircle(start, 13, Paint()..color = startColor);
    canvas.drawCircle(start, 5, Paint()..color = Colors.white);

    for (final breakIndex in numberPath.strokeBreaks) {
      if (breakIndex < numberPath.points.length) {
        final point = numberPath.points[breakIndex].toOffset(size);
        canvas.drawCircle(point, 13, Paint()..color = startColor.withValues(alpha: .28));
        canvas.drawCircle(point, 6, Paint()..color = startColor);
      }
    }

    if (!completed) _paintMovingArrow(canvas, size, guidePath);
  }

  void _paintMovingArrow(Canvas canvas, Size size, Path path) {
    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) return;
    final total = metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    if (total <= 0) return;
    var distance = total * animationValue;
    ui.PathMetric? activeMetric;
    for (final metric in metrics) {
      if (distance <= metric.length) {
        activeMetric = metric;
        break;
      }
      distance -= metric.length;
    }
    activeMetric ??= metrics.last;
    final tangent = activeMetric.getTangentForOffset(distance.clamp(0, activeMetric.length));
    if (tangent == null) return;

    canvas.save();
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(tangent.angle);
    final arrow = Paint()..color = GameTheme.mango;
    final pathArrow = Path()
      ..moveTo(12, 0)
      ..lineTo(-8, -7)
      ..lineTo(-4, 0)
      ..lineTo(-8, 7)
      ..close();
    canvas.drawShadow(pathArrow, const Color(0x33000000), 4, false);
    canvas.drawPath(pathArrow, arrow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NumberRoadPainter oldDelegate) {
    return oldDelegate.numberPath.digit != numberPath.digit ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.completed != completed ||
        oldDelegate.celebrationValue != celebrationValue;
  }
}

class _SmartGuidancePainter extends CustomPainter {
  final SignatureController controller;
  final double? distance;
  final bool onPath;
  final Listenable repaint;
  final bool active;

  _SmartGuidancePainter({
    required this.controller,
    required this.distance,
    required this.onPath,
    required this.repaint,
    required this.active,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (!active || distance == null || controller.points.isEmpty) return;

    final current = controller.points.last.offset;
    final close = onPath;
    final haloColor = close ? GameTheme.mint : GameTheme.mango;

    canvas.drawCircle(
      current,
      close ? 19 : 23,
      Paint()..color = haloColor.withValues(alpha: close ? .14 : .18),
    );
    canvas.drawCircle(
      current,
      close ? 8 : 10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = haloColor.withValues(alpha: .72),
    );
    canvas.drawCircle(
      current,
      3.5,
      Paint()..color = haloColor,
    );

    if (!close) {
      final pulse = 1 + ((DateTime.now().millisecondsSinceEpoch % 600) / 600);
      canvas.drawCircle(
        current,
        13 * pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = GameTheme.mango.withValues(alpha: .12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SmartGuidancePainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.distance != distance ||
      oldDelegate.onPath != onPath ||
      oldDelegate.active != active;
}

class _MagicInkPainter extends CustomPainter {
  final SignatureController controller;
  final List<List<Offset>> completedStrokes;
  final int strokeStartIndex;
  final Listenable repaint;
  final bool active;

  _MagicInkPainter({
    required this.controller,
    required this.completedStrokes,
    required this.strokeStartIndex,
    required this.repaint,
    required this.active,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 27
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = GameTheme.mint.withValues(alpha: .13);

    final trail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = GameTheme.mint.withValues(alpha: .24);

    for (final stroke in completedStrokes) {
      _drawStroke(canvas, stroke, glow, trail);
    }

    if (!active || controller.points.isEmpty) return;

    final points = controller.points;
    if (strokeStartIndex >= points.length) return;
    final live = points
        .sublist(strokeStartIndex)
        .map((point) => point.offset)
        .toList(growable: false);

    if (live.isEmpty) return;

    _drawStroke(canvas, live, glow, trail);

    final last = live.last;
    final pulse = 0.82 + (0.18 * ((DateTime.now().millisecondsSinceEpoch % 700) / 700));
    canvas.drawCircle(
      last,
      14 * pulse,
      Paint()..color = GameTheme.sunshine.withValues(alpha: .20),
    );
    canvas.drawCircle(
      last,
      5,
      Paint()..color = GameTheme.sunshine,
    );
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> points,
    Paint glow,
    Paint trail,
  ) {
    if (points.isEmpty) return;

    if (points.length == 1) {
      canvas.drawCircle(points.first, glow.strokeWidth / 2, glow);
      canvas.drawCircle(points.first, trail.strokeWidth / 2, trail);
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, glow);
    canvas.drawPath(path, trail);
  }

  @override
  bool shouldRepaint(covariant _MagicInkPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.completedStrokes != completedStrokes ||
        oldDelegate.strokeStartIndex != strokeStartIndex ||
        oldDelegate.active != active;
  }
}

class _StrokeMatchResult {
  final int matched;
  final int expected;
  const _StrokeMatchResult(this.matched, this.expected);
}


class _CelebrationPainter extends CustomPainter {
  final double value;

  const _CelebrationPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutBack.transform(value.clamp(0.0, 1.0));
    final center = Offset(size.width / 2, size.height / 2);

    final overlay = Paint()..color = GameTheme.success.withValues(alpha: .06 * (1 - value));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(30),
      ),
      overlay,
    );

    final checkScale = .55 + (.45 * t);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(checkScale);
    final checkPaint = Paint()..color = GameTheme.success;
    canvas.drawCircle(Offset.zero, 34, checkPaint);
    final tick = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final tickPath = Path()
      ..moveTo(-15, 1)
      ..lineTo(-4, 12)
      ..lineTo(17, -13);
    canvas.drawPath(tickPath, tick);
    canvas.restore();

    final particlePaint = Paint()..style = PaintingStyle.fill;
    const particles = <Offset>[
      Offset(-92, -72),
      Offset(-42, -105),
      Offset(35, -100),
      Offset(92, -62),
      Offset(-112, 8),
      Offset(112, 12),
      Offset(-78, 76),
      Offset(-20, 105),
      Offset(48, 92),
      Offset(96, 62),
    ];
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final progress = ((value * 1.35) - (i * .035)).clamp(0.0, 1.0);
      final alpha = (1 - progress).clamp(0.0, 1.0);
      particlePaint.color = (i.isEven ? GameTheme.sunshine : GameTheme.berry)
          .withValues(alpha: alpha);
      final drift = Offset(p.dx * progress, p.dy * progress);
      final radius = 4.5 * (1 - .35 * progress);
      canvas.drawCircle(center + drift, radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.value != value;
}


class _CheckpointDots extends StatelessWidget {
  final int value;
  const _CheckpointDots({required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(4, (index) {
      final filled = index < value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut,
        width: filled ? 9 : 7, height: filled ? 9 : 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? GameTheme.success : GameTheme.ocean.withValues(alpha: .18)),
      );
    }));
  }
}

class _TraceProgress extends StatelessWidget {
  final int checkpoint;
  final double accuracy;
  final bool active;
  final double pulse;
  const _TraceProgress({required this.checkpoint, required this.accuracy, required this.active, this.pulse = 0});
  @override
  Widget build(BuildContext context) {
    if (!active && checkpoint == 0) return const SizedBox.shrink();
    final scale = 1 + (Curves.easeOutBack.transform(pulse.clamp(0.0, 1.0)) * .045);
    return Transform.scale(
      scale: scale,
      child: Container(
        height: 34, padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: GameTheme.paper.withValues(alpha: .92), borderRadius: BorderRadius.circular(17), border: Border.all(color: active ? GameTheme.mint.withValues(alpha: .65) : GameTheme.success.withValues(alpha: .35))),
      child: Row(children: [
        const Icon(Icons.auto_awesome_rounded, size: 17, color: GameTheme.sunshine),
        const SizedBox(width: 7),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: accuracy.clamp(0.0, 1.0), minHeight: 7, backgroundColor: GameTheme.ocean.withValues(alpha: .12), valueColor: AlwaysStoppedAnimation<Color>(active ? GameTheme.mint : GameTheme.success)))),
        const SizedBox(width: 8),
        Text('${checkpoint * 25}٪', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: GameTheme.ink)),
      ]),
      ),
    );
  }
}
