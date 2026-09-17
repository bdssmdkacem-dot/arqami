import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../core/profile/age_activity_presentation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';
import '../../models/number_path.dart';

/// تدريب كتابة الرقم بالإصبع داخل "حديقة الأعداد".
///
/// الدقة وترتيب الضربات ما زالا يعتمدان على NumberPath كما كانا، لكن العرض
/// أصبح طريقاً واضحاً للرقم بدلاً من سلسلة نقاط صغيرة تربك الطفل.
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
  int _strokeStartIndex = 0;
  final List<List<Offset>> _userStrokes = [];
  _TraceStatus _status = _TraceStatus.idle;
  double _accuracy = 0;
  int _failedAttempts = 0;

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
      penStrokeWidth: 12,
      penColor: widget.strokeColor,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
      exportBackgroundColor: Colors.transparent,
      onDrawStart: _onDrawStart,
      onDrawEnd: _onStrokeEnd,
    );
    _guideAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
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
    _guideAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDrawStart() {
    if (_status == _TraceStatus.complete) return;
    _strokeStartIndex = _controller.points.length;
    if (mounted) setState(() => _status = _TraceStatus.inProgress);
  }

  void _onStrokeEnd() {
    if (_status == _TraceStatus.complete || _controller.isEmpty) return;
    final points = _controller.points;
    if (_strokeStartIndex >= points.length) return;
    final stroke = points.sublist(_strokeStartIndex).map((p) => p.offset).toList(growable: false);
    if (stroke.isNotEmpty) _userStrokes.add(stroke);
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
    if (_userStrokes.length < expected.length) {
      if (mounted) setState(() => _status = _TraceStatus.inProgress);
      return;
    }

    if (_accuracy >= _threshold) {
      if (!mounted) return;
      setState(() => _status = _TraceStatus.complete);
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
        _GardenHeader(number: widget.number, status: _status, statusText: _statusText, statusColor: _statusColor, onReset: reset),
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
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(child: Signature(controller: _controller, backgroundColor: Colors.transparent)),
                    if (_status == _TraceStatus.complete)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: GameTheme.success.withValues(alpha: .08),
                              border: Border.all(color: GameTheme.success.withValues(alpha: .45), width: 3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(child: Icon(Icons.check_circle_rounded, color: GameTheme.success, size: 68)),
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
  final VoidCallback onReset;

  const _GardenHeader({required this.number, required this.status, required this.statusText, required this.statusColor, required this.onReset});

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
    canvas.drawRRect(Rect.fromCenter(center: Offset(size.width * .82, size.height * .15), width: 54, height: 34), Radius.circular(12), sign);
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

  const _NumberRoadPainter({required this.numberPath, required this.guideColor, required this.startColor, required this.animationValue, required this.completed});

  @override
  void paint(Canvas canvas, Size size) {
    if (numberPath.points.isEmpty) return;
    final guidePath = numberPath.buildGuidePath(size);

    final road = Paint()
      ..color = completed ? GameTheme.success.withValues(alpha: .22) : guideColor.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(guidePath, road);

    final lane = Paint()
      ..color = completed ? GameTheme.success.withValues(alpha: .72) : guideColor.withValues(alpha: .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(guidePath, lane);

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
    PathMetric? activeMetric;
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
        oldDelegate.completed != completed;
  }
}

class _StrokeMatchResult {
  final int matched;
  final int expected;
  const _StrokeMatchResult(this.matched, this.expected);
}
