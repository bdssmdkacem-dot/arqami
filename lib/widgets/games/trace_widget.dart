import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../core/theme/app_colors.dart';
import '../../models/number_path.dart';

/// مكون تتبع الأرقام بالإصبع.
///
/// التحقق هنا لا يعتمد فقط على "هل مرّ الإصبع قريباً من النقاط؟"؛
/// بل يحافظ على ترتيب النقاط وعدد الضربات المطلوبة لكل رقم، حتى لا
/// ينجح الطفل بالرسم العشوائي حول الشكل.
class TraceWidget extends StatefulWidget {
  /// الرقم المطلوب تتبعه (0-9)
  final int number;

  /// يُستدعى عند نجاح التتبع.
  final VoidCallback onComplete;

  /// الحد الأدنى لتغطية نقاط المسار داخل كل ضربة.
  final double accuracyThreshold;

  /// نصف قطر التسامح حول النقاط المرجعية، كنسبة من عرض اللوحة.
  final double toleranceRadius;

  final Color guideColor;
  final Color strokeColor;
  final Color startPointColor;

  const TraceWidget({
    super.key,
    required this.number,
    required this.onComplete,
    this.accuracyThreshold = 0.72,
    this.toleranceRadius = 0.065,
    this.guideColor = const Color(0xFFB8C8C5),
    this.strokeColor = AppColors.teal,
    this.startPointColor = AppColors.gold,
  });

  @override
  State<TraceWidget> createState() => TraceWidgetState();
}

enum _TraceStatus { idle, inProgress, needsRetry, complete }

class TraceWidgetState extends State<TraceWidget> {
  late SignatureController _controller;
  late NumberPath _numberPath;

  /// موضع بداية الضربة الحالية داخل controller.points.
  int _strokeStartIndex = 0;

  /// الضربات التي اكتملت منذ بداية المحاولة الحالية.
  final List<List<Offset>> _userStrokes = [];

  _TraceStatus _status = _TraceStatus.idle;
  double _accuracy = 0;

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
    _controller.dispose();
    super.dispose();
  }

  void _onDrawStart() {
    if (_status == _TraceStatus.complete) return;
    _strokeStartIndex = _controller.points.length;
    if (!mounted) return;
    setState(() => _status = _TraceStatus.inProgress);
  }

  void _onStrokeEnd() {
    if (_status == _TraceStatus.complete || _controller.isEmpty) {
      return;
    }

    final points = _controller.points;
    if (_strokeStartIndex >= points.length) return;

    final stroke = points
        .sublist(_strokeStartIndex)
        .map((point) => point.offset)
        .toList(growable: false);

    if (stroke.isNotEmpty) {
      _userStrokes.add(stroke);
    }

    _checkAccuracy();
  }

  List<List<PathPoint>> _expectedStrokeSegments() {
    final points = _numberPath.points;
    if (points.isEmpty) return const [];

    final breaks = <int>{0, ..._numberPath.strokeBreaks, points.length}.toList()
      ..sort();

    final segments = <List<PathPoint>>[];
    for (var i = 0; i < breaks.length - 1; i++) {
      final start = breaks[i];
      final end = breaks[i + 1];
      if (start < end) {
        segments.add(points.sublist(start, end));
      }
    }
    return segments;
  }

  void _checkAccuracy() {
    final size = context.size;
    if (size == null || _numberPath.points.isEmpty) return;

    final expectedStrokes = _expectedStrokeSegments();
    final userStrokes = List<List<Offset>>.unmodifiable(_userStrokes);

    if (userStrokes.isEmpty) return;

    // عدد الضربات جزء من تعليم طريقة كتابة الرقم. نسمح بالاستمرار عندما
    // لم تكتمل كل الضربات بعد، لكن أي ضربة إضافية تعني أن المحاولة تحتاج
    // إلى إعادة الرسم.
    if (userStrokes.length > expectedStrokes.length) {
      _setRetry(0.0);
      return;
    }

    var totalMatched = 0;
    var totalExpected = 0;

    for (var strokeIndex = 0; strokeIndex < userStrokes.length; strokeIndex++) {
      final expected = expectedStrokes[strokeIndex];
      final user = userStrokes[strokeIndex];
      final result = _matchStroke(expected, user, size);

      totalMatched += result.matched;
      totalExpected += result.expected;
    }

    final double accuracy =
        totalExpected == 0 ? 0.0 : totalMatched / totalExpected;
    _accuracy = accuracy;

    // إذا لم نصل بعد إلى آخر ضربة، لا نحكم على المحاولة بالفشل.
    if (userStrokes.length < expectedStrokes.length) {
      if (mounted) setState(() => _status = _TraceStatus.inProgress);
      return;
    }

    if (accuracy >= widget.accuracyThreshold) {
      if (!mounted) return;
      setState(() {
        _accuracy = accuracy;
        _status = _TraceStatus.complete;
      });
      widget.onComplete();
    } else {
      _setRetry(accuracy);
    }
  }

  _StrokeMatchResult _matchStroke(
    List<PathPoint> expected,
    List<Offset> user,
    Size size,
  ) {
    if (expected.isEmpty || user.isEmpty) {
      return const _StrokeMatchResult(0, 0);
    }

    final tolerancePx = widget.toleranceRadius * size.width;
    var userIndex = 0;
    var matched = 0;

    // المطابقة تسير من البداية للنهاية. هذا يمنع النجاح بمجرد تغطية
    // النقاط نفسها لكن بترتيب عشوائي.
    for (final referencePoint in expected) {
      final target = referencePoint.toOffset(size);
      var found = false;

      for (var i = userIndex; i < user.length; i++) {
        if ((user[i] - target).distance <= tolerancePx) {
          matched++;
          userIndex = i + 1;
          found = true;
          break;
        }
      }

      if (!found) {
        break;
      }
    }

    return _StrokeMatchResult(matched, expected.length);
  }

  void _setRetry(double accuracy) {
    if (!mounted) return;
    setState(() {
      _accuracy = accuracy;
      _status = _TraceStatus.needsRetry;
    });
  }

  /// يمسح اللوحة ويعيد المحاولة.
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
        return 'ابدأ من النقطة الذهبية واتبع المسار';
      case _TraceStatus.inProgress:
        return 'ممتاز، تابع بهدوء';
      case _TraceStatus.needsRetry:
        return 'اقترب أكثر من المسار وحاول مرة أخرى';
      case _TraceStatus.complete:
        return 'أحسنت! كتبت الرقم بشكل رائع';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case _TraceStatus.needsRetry:
        return AppColors.terracotta;
      case _TraceStatus.complete:
        return AppColors.correct;
      case _TraceStatus.idle:
      case _TraceStatus.inProgress:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Align(
                    key: ValueKey(_status),
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _statusText,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'إعادة المحاولة',
                onPressed: reset,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.cardBackground),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GuidePathPainter(
                          numberPath: _numberPath,
                          dotColor: widget.guideColor,
                          startColor: widget.startPointColor,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Signature(
                        controller: _controller,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    if (_status == _TraceStatus.complete)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.correct.withValues(alpha: 0.08),
                              border: Border.all(
                                color: AppColors.correct.withValues(alpha: 0.45),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.correct,
                                size: 68,
                              ),
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
        const SizedBox(height: 8),
        AnimatedOpacity(
          opacity: _accuracy > 0 && _status != _TraceStatus.inProgress ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: Text(
            'الدقة ${(_accuracy * 100).round()}٪',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StrokeMatchResult {
  final int matched;
  final int expected;

  const _StrokeMatchResult(this.matched, this.expected);
}

class _GuidePathPainter extends CustomPainter {
  final NumberPath numberPath;
  final Color dotColor;
  final Color startColor;

  const _GuidePathPainter({
    required this.numberPath,
    required this.dotColor,
    required this.startColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (numberPath.points.isEmpty) return;

    final guidePaint = Paint()
      ..color = dotColor.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final guidePath = numberPath.buildGuidePath(size);
    canvas.drawPath(guidePath, guidePaint);

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final point in numberPath.points) {
      canvas.drawCircle(point.toOffset(size), 4.5, dotPaint);
    }

    final startOffset = numberPath.points.first.toOffset(size);

    final startRingPaint = Paint()
      ..color = startColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startOffset, 17, startRingPaint);
    canvas.drawCircle(startOffset, 10, Paint()..color = startColor);

    if (numberPath.strokeBreaks.isNotEmpty) {
      for (final breakIndex in numberPath.strokeBreaks) {
        if (breakIndex < numberPath.points.length) {
          final offset = numberPath.points[breakIndex].toOffset(size);
          canvas.drawCircle(
            offset,
            9,
            Paint()..color = startColor.withValues(alpha: 0.18),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePathPainter oldDelegate) {
    return oldDelegate.numberPath.digit != numberPath.digit ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.startColor != startColor;
  }
}
