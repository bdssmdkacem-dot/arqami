import 'dart:ui';

/// نقطة مرجعية على مسار الرقم، بإحداثيات نسبية (0.0 - 1.0).
class PathPoint {
  final double x;
  final double y;
  const PathPoint(this.x, this.y);

  Offset toOffset(Size size) => Offset(x * size.width, y * size.height);
}

/// مسار رقم واحد مع ترتيب ضربات الكتابة.
class NumberPath {
  final int digit;
  final List<PathPoint> points;
  final List<int> strokeBreaks;

  const NumberPath({
    required this.digit,
    required this.points,
    this.strokeBreaks = const [],
  });

  List<List<PathPoint>> get strokeSegments {
    if (points.isEmpty) return const [];
    final breaks = <int>{0, ...strokeBreaks, points.length}.toList()..sort();
    final segments = <List<PathPoint>>[];
    for (var i = 0; i < breaks.length - 1; i++) {
      if (breaks[i] < breaks[i + 1]) {
        segments.add(points.sublist(breaks[i], breaks[i + 1]));
      }
    }
    return segments;
  }

  /// مسار بصري ناعم؛ نقاط القياس نفسها تبقى حادة ودقيقة للتقييم.
  Path buildGuidePath(Size size) {
    final path = Path();
    final segments = strokeSegments;
    for (final segment in segments) {
      if (segment.isEmpty) continue;
      final first = segment.first.toOffset(size);
      path.moveTo(first.dx, first.dy);
      if (segment.length == 1) continue;
      if (segment.length == 2) {
        final last = segment.last.toOffset(size);
        path.lineTo(last.dx, last.dy);
        continue;
      }

      for (var i = 1; i < segment.length - 1; i++) {
        final current = segment[i].toOffset(size);
        final next = segment[i + 1].toOffset(size);
        final midpoint = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(
          current.dx,
          current.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
      final penultimate = segment[segment.length - 2].toOffset(size);
      final last = segment.last.toOffset(size);
      path.quadraticBezierTo(
        penultimate.dx,
        penultimate.dy,
        last.dx,
        last.dy,
      );
    }
    return path;
  }
}

/// مسارات تعليمية للأرقام 0-9.
/// الأرقام 0-5 تستخدم نقاطاً أكثر كثافة حتى يكون مسار الطفل واضحاً ودقيقاً.
class NumberPathData {
  static final Map<int, NumberPath> _paths = {
    0: const NumberPath(
      digit: 0,
      points: [
        PathPoint(0.50, 0.10), PathPoint(0.38, 0.12), PathPoint(0.28, 0.22),
        PathPoint(0.22, 0.36), PathPoint(0.20, 0.52), PathPoint(0.22, 0.66),
        PathPoint(0.28, 0.78), PathPoint(0.39, 0.87), PathPoint(0.52, 0.90),
        PathPoint(0.64, 0.86), PathPoint(0.74, 0.76), PathPoint(0.80, 0.62),
        PathPoint(0.81, 0.46), PathPoint(0.78, 0.32), PathPoint(0.70, 0.21),
        PathPoint(0.60, 0.14), PathPoint(0.50, 0.10),
      ],
    ),
    1: const NumberPath(
      digit: 1,
      points: [
        PathPoint(0.34, 0.24), PathPoint(0.42, 0.18), PathPoint(0.50, 0.10),
        PathPoint(0.50, 0.28), PathPoint(0.50, 0.46), PathPoint(0.50, 0.64),
        PathPoint(0.50, 0.82), PathPoint(0.50, 0.90),
      ],
    ),
    2: const NumberPath(
      digit: 2,
      points: [
        PathPoint(0.25, 0.25), PathPoint(0.29, 0.18), PathPoint(0.39, 0.12),
        PathPoint(0.51, 0.10), PathPoint(0.63, 0.12), PathPoint(0.71, 0.19),
        PathPoint(0.75, 0.29), PathPoint(0.72, 0.38), PathPoint(0.64, 0.47),
        PathPoint(0.54, 0.55), PathPoint(0.43, 0.63), PathPoint(0.34, 0.72),
        PathPoint(0.27, 0.81), PathPoint(0.25, 0.88), PathPoint(0.39, 0.88),
        PathPoint(0.53, 0.88), PathPoint(0.66, 0.88), PathPoint(0.75, 0.88),
      ],
    ),
    3: const NumberPath(
      digit: 3,
      points: [
        PathPoint(0.27, 0.20), PathPoint(0.37, 0.14), PathPoint(0.49, 0.10),
        PathPoint(0.61, 0.13), PathPoint(0.70, 0.20), PathPoint(0.72, 0.29),
        PathPoint(0.68, 0.38), PathPoint(0.58, 0.46), PathPoint(0.50, 0.49),
        PathPoint(0.59, 0.52), PathPoint(0.68, 0.59), PathPoint(0.72, 0.68),
        PathPoint(0.70, 0.77), PathPoint(0.61, 0.85), PathPoint(0.49, 0.89),
        PathPoint(0.37, 0.86), PathPoint(0.27, 0.80),
      ],
    ),
    4: const NumberPath(
      digit: 4,
      points: [
        PathPoint(0.62, 0.10), PathPoint(0.56, 0.20), PathPoint(0.49, 0.30),
        PathPoint(0.42, 0.40), PathPoint(0.35, 0.50), PathPoint(0.28, 0.56),
        PathPoint(0.40, 0.56), PathPoint(0.52, 0.56), PathPoint(0.64, 0.56),
        PathPoint(0.76, 0.56),
        PathPoint(0.62, 0.10), PathPoint(0.62, 0.26), PathPoint(0.62, 0.44),
        PathPoint(0.62, 0.62), PathPoint(0.62, 0.78), PathPoint(0.62, 0.90),
      ],
      strokeBreaks: [9],
    ),
    5: const NumberPath(
      digit: 5,
      points: [
        PathPoint(0.70, 0.12), PathPoint(0.56, 0.12), PathPoint(0.42, 0.12),
        PathPoint(0.30, 0.12), PathPoint(0.28, 0.22), PathPoint(0.27, 0.34),
        PathPoint(0.26, 0.42), PathPoint(0.38, 0.38), PathPoint(0.50, 0.38),
        PathPoint(0.62, 0.43), PathPoint(0.69, 0.51), PathPoint(0.70, 0.62),
        PathPoint(0.66, 0.73), PathPoint(0.57, 0.82), PathPoint(0.45, 0.86),
        PathPoint(0.34, 0.83), PathPoint(0.27, 0.78),
      ],
    ),
    6: const NumberPath(
      digit: 6,
      points: [
        PathPoint(0.65, 0.12), PathPoint(0.52, 0.16), PathPoint(0.40, 0.26),
        PathPoint(0.32, 0.40), PathPoint(0.28, 0.55), PathPoint(0.29, 0.70),
        PathPoint(0.36, 0.82), PathPoint(0.48, 0.88), PathPoint(0.60, 0.85),
        PathPoint(0.68, 0.76), PathPoint(0.68, 0.63), PathPoint(0.60, 0.54),
        PathPoint(0.48, 0.51), PathPoint(0.36, 0.56),
      ],
    ),
    7: const NumberPath(
      digit: 7,
      points: [
        PathPoint(0.25, 0.12), PathPoint(0.75, 0.12), PathPoint(0.45, 0.90),
      ],
    ),
    8: const NumberPath(
      digit: 8,
      points: [
        PathPoint(0.50, 0.10), PathPoint(0.36, 0.16), PathPoint(0.31, 0.28),
        PathPoint(0.36, 0.39), PathPoint(0.50, 0.48), PathPoint(0.64, 0.39),
        PathPoint(0.69, 0.28), PathPoint(0.64, 0.16), PathPoint(0.50, 0.10),
        PathPoint(0.36, 0.58), PathPoint(0.31, 0.70), PathPoint(0.36, 0.82),
        PathPoint(0.50, 0.90), PathPoint(0.64, 0.82), PathPoint(0.69, 0.70),
        PathPoint(0.64, 0.58), PathPoint(0.50, 0.48),
      ],
    ),
    9: const NumberPath(
      digit: 9,
      points: [
        PathPoint(0.62, 0.45), PathPoint(0.50, 0.50), PathPoint(0.37, 0.46),
        PathPoint(0.30, 0.37), PathPoint(0.30, 0.25), PathPoint(0.37, 0.15),
        PathPoint(0.50, 0.10), PathPoint(0.62, 0.15), PathPoint(0.69, 0.25),
        PathPoint(0.69, 0.43), PathPoint(0.67, 0.58), PathPoint(0.61, 0.72),
        PathPoint(0.52, 0.82), PathPoint(0.32, 0.88),
      ],
    ),
  };

  static NumberPath getPath(int digit) {
    final path = _paths[digit];
    if (path == null) throw ArgumentError('لا يوجد مسار معرّف للرقم $digit');
    return path;
  }

  static bool hasPath(int digit) => _paths.containsKey(digit);
}
