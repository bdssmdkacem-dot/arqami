import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../models/number_path.dart';

/// مكون تتبع الأرقام بالإصبع.
class TraceWidget extends StatefulWidget {
  /// الرقم المطلوب تتبعه (0-9)
  final int number;

  /// يُستدعى عند الوصول لنسبة الدقة المطلوبة.
  final VoidCallback onComplete;

  /// نسبة الدقة المطلوبة لاعتبار التتبع ناجحاً.
  final double accuracyThreshold;

  /// نصف قطر التسامح حول النقاط المرجعية.
  final double toleranceRadius;

  final Color guideColor;
  final Color strokeColor;
  final Color startPointColor;

  const TraceWidget({
    super.key,
    required this.number,
    required this.onComplete,
    this.accuracyThreshold = 0.7,
    this.toleranceRadius = 0.08,
    this.guideColor = const Color(0xFFCCCCCC),
    this.strokeColor = const Color(0xFF2E7D32),
    this.startPointColor = const Color(0xFF4CAF50),
  });

  @override
  State<TraceWidget> createState() => TraceWidgetState();
}

class TraceWidgetState extends State<TraceWidget> {
  late SignatureController _controller;
  late NumberPath _numberPath;

  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _numberPath = NumberPathData.getPath(widget.number);

    _controller = SignatureController(
      penStrokeWidth: 12,
      penColor: widget.strokeColor,
      exportBackgroundColor: Colors.transparent,
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

  void _onStrokeEnd() {
    if (_completed || _controller.isEmpty) {
      return;
    }

    _checkAccuracy();
  }

  void _checkAccuracy() {
    final size = context.size;

    if (size == null || _numberPath.points.isEmpty) {
      return;
    }

    final userOffsets =
        _controller.points.map((p) => p.offset).toList(growable: false);

    if (userOffsets.isEmpty) {
      return;
    }

    final toleranceRadiusPx = widget.toleranceRadius * size.width;

    int matchedCount = 0;

    for (final refPoint in _numberPath.points) {
      final refOffset = refPoint.toOffset(size);

      final hasNearbyUserPoint = userOffsets.any(
        (userOffset) =>
            (userOffset - refOffset).distance <= toleranceRadiusPx,
      );

      if (hasNearbyUserPoint) {
        matchedCount++;
      }
    }

    final accuracy = matchedCount / _numberPath.points.length;

    if (accuracy >= widget.accuracyThreshold) {
      _completed = true;
      widget.onComplete();
    }
  }

  /// يمسح اللوحة ويعيد المحاولة.
  void reset() {
    _controller.clear();

    setState(() {
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: const Color(0xFFFAFAFA),
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
            ],
          ),
        ),
      ),
    );
  }
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
    if (numberPath.points.isEmpty) {
      return;
    }

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final point in numberPath.points) {
      canvas.drawCircle(point.toOffset(size), 5, dotPaint);
    }

    final startOffset = numberPath.points.first.toOffset(size);

    final startFillPaint = Paint()
      ..color = startColor;

    final startRingPaint = Paint()
      ..color = startColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startOffset, 14, startRingPaint);
    canvas.drawCircle(startOffset, 8, startFillPaint);
  }

  @override
  bool shouldRepaint(covariant _GuidePathPainter oldDelegate) {
    return oldDelegate.numberPath.digit != numberPath.digit;
  }
}
