import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../core/profile/age_activity_presentation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/number_path.dart';

/// تدريب كتابة الرقم بالإصبع.
///
/// صُمم ليعلّم الطفل ترتيب الحركة، لكن لا يجعل دقة الرسم حاجزاً يمنعه
/// من إكمال الوحدة. التسامح يتكيف مع العمر، ويزداد قليلاً بعد المحاولات.
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
    // بعد ثلاث محاولات فاشلة نخفف معيار الدقة قليلاً، مع بقاء ترتيب
    // الضربات مطلوباً. الهدف هو التدريب لا حبس الطفل في نفس الشاشة.
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
            ? 'ابدأ من النقطة الذهبية واتبع الخط المنقّط'
            : 'ابدأ من النقطة الذهبية واتبع المسار';
      case _TraceStatus.inProgress:
        return _presentation.showExtraGuidance ? 'تابع النقاط بالترتيب' : 'تابع بالترتيب';
      case _TraceStatus.needsRetry:
        return _failedAttempts >= 3
            ? 'لا بأس، اقترب من الخط وحاول مرة أخرى'
            : 'اقترب أكثر من المسار وحاول مرة أخرى';
      case _TraceStatus.complete:
        return _presentation.useShortFeedback ? 'تمت كتابة الرقم' : 'أحسنت! كتبت الرقم بشكل رائع';
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
                      style: TextStyle(color: _statusColor, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: reset, tooltip: 'إعادة المحاولة', icon: const Icon(Icons.refresh_rounded)),
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
                    Positioned.fill(child: Signature(controller: _controller, backgroundColor: Colors.transparent)),
                    if (_status == _TraceStatus.complete)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.correct.withValues(alpha: 0.08),
                              border: Border.all(color: AppColors.correct.withValues(alpha: 0.45), width: 3),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 68)),
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
          child: Text('الدقة ${(_accuracy * 100).round()}٪', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  const _GuidePathPainter({required this.numberPath, required this.dotColor, required this.startColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (numberPath.points.isEmpty) return;
    final guidePaint = Paint()
      ..color = dotColor.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(numberPath.buildGuidePath(size), guidePaint);

    final dotPaint = Paint()..color = dotColor;
    for (final point in numberPath.points) {
      canvas.drawCircle(point.toOffset(size), 4.5, dotPaint);
    }

    final start = numberPath.points.first.toOffset(size);
    canvas.drawCircle(start, 17, Paint()..color = startColor.withValues(alpha: 0.22));
    canvas.drawCircle(start, 10, Paint()..color = startColor);

    for (final breakIndex in numberPath.strokeBreaks) {
      if (breakIndex < numberPath.points.length) {
        canvas.drawCircle(
          numberPath.points[breakIndex].toOffset(size),
          9,
          Paint()..color = startColor.withValues(alpha: 0.18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePathPainter oldDelegate) {
    return oldDelegate.numberPath.digit != numberPath.digit || oldDelegate.dotColor != dotColor || oldDelegate.startColor != startColor;
  }
}
