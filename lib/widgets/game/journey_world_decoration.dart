import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// الخلفية البصرية لعالم رحلة أرقامي.
///
/// مرسومة محلياً عبر Canvas حتى لا تعتمد الخريطة على صورة صغيرة مكررة.
/// العناصر خفيفة ومقصودة لتبقى عقد الوحدات هي نقطة التركيز.
class JourneyWorldDecoration extends StatelessWidget {
  const JourneyWorldDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _JourneyWorldPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _JourneyWorldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = AppColors.backgroundAlt;
    canvas.drawRect(Offset.zero & size, base);

    final width = size.width;
    final height = size.height;

    // شرائط لونية هادئة تعطي إحساساً بعوالم متدرجة دون إخفاء المسار.
    final zones = <Color>[
      const Color(0xFFEAF6D9),
      const Color(0xFFFFF0C9),
      const Color(0xFFE1F1EA),
      const Color(0xFFF8E7D8),
    ];
    final zoneHeight = math.max(150.0, height / zones.length);
    for (var i = 0; i < zones.length; i++) {
      final top = i * zoneHeight;
      canvas.drawRect(
        Rect.fromLTWH(0, top, width, zoneHeight + 2),
        Paint()..color = zones[i].withValues(alpha: .72),
      );
    }

    _drawCloud(canvas, Offset(width * .16, 55), 1.0);
    _drawCloud(canvas, Offset(width * .82, 110), .78);
    _drawCloud(canvas, Offset(width * .52, height * .42), .62);
    _drawCloud(canvas, Offset(width * .18, height * .70), .70);

    _drawHill(canvas, Offset(width * .05, height * .24), width * .32, 52);
    _drawHill(canvas, Offset(width * .94, height * .34), width * .38, 66);
    _drawHill(canvas, Offset(width * .12, height * .62), width * .28, 48);
    _drawHill(canvas, Offset(width * .88, height * .82), width * .34, 58);

    _drawTree(canvas, Offset(width * .10, height * .18), .72);
    _drawTree(canvas, Offset(width * .90, height * .20), .58);
    _drawTree(canvas, Offset(width * .08, height * .48), .55);
    _drawTree(canvas, Offset(width * .92, height * .55), .68);
    _drawTree(canvas, Offset(width * .16, height * .88), .62);
    _drawTree(canvas, Offset(width * .84, height * .93), .55);

    _drawPond(canvas, Offset(width * .76, height * .63), width * .18);
    _drawFlowers(canvas, width, height);

    // نقاط صغيرة تشبه الحصى/النجوم الأرضية وتمنح العمق من دون تشويش.
    final pebble = Paint()..color = AppColors.terracotta.withValues(alpha: .12);
    for (var i = 0; i < 28; i++) {
      final x = ((i * 83) % 101) / 100 * width;
      final y = ((i * 137 + 41) % 97) / 100 * height;
      canvas.drawCircle(Offset(x, y), 2.2 + (i % 3), pebble);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double scale) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .58);
    canvas.drawCircle(center.translate(-18 * scale, 2), 15 * scale, paint);
    canvas.drawCircle(center.translate(0, -5 * scale), 21 * scale, paint);
    canvas.drawCircle(center.translate(20 * scale, 3), 16 * scale, paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(2 * scale, 9 * scale),
        width: 65 * scale,
        height: 24 * scale,
      ),
      paint,
    );
  }

  void _drawHill(Canvas canvas, Offset center, double width, double height) {
    final path = Path()
      ..moveTo(center.dx - width / 2, center.dy + height / 2)
      ..quadraticBezierTo(
        center.dx,
        center.dy - height / 2,
        center.dx + width / 2,
        center.dy + height / 2,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.teal.withValues(alpha: .075),
    );
  }

  void _drawTree(Canvas canvas, Offset base, double scale) {
    final trunk = Paint()..color = AppColors.terracotta.withValues(alpha: .42);
    final crown = Paint()..color = AppColors.teal.withValues(alpha: .22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 4 * scale, base.dy, 8 * scale, 22 * scale),
        Radius.circular(3 * scale),
      ),
      trunk,
    );
    canvas.drawCircle(base.translate(0, -7 * scale), 17 * scale, crown);
    canvas.drawCircle(base.translate(-12 * scale, 0), 12 * scale, crown);
    canvas.drawCircle(base.translate(12 * scale, 0), 12 * scale, crown);
  }

  void _drawPond(Canvas canvas, Offset center, double width) {
    final pond = Paint()..color = AppColors.teal.withValues(alpha: .13);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: width * .52),
      pond,
    );
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.teal.withValues(alpha: .20);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(0, (i - 1) * 7.0),
          width: width * (.38 + i * .12),
          height: width * .10,
        ),
        ripple,
      );
    }
  }

  void _drawFlowers(Canvas canvas, double width, double height) {
    final stem = Paint()
      ..strokeWidth = 1.3
      ..color = AppColors.teal.withValues(alpha: .25);
    final petals = Paint()..color = AppColors.gold.withValues(alpha: .55);
    for (var i = 0; i < 18; i++) {
      final x = ((i * 47 + 17) % 91) / 100 * width + 8;
      final y = ((i * 71 + 23) % 87) / 100 * height + 6;
      canvas.drawLine(Offset(x, y), Offset(x, y + 8), stem);
      canvas.drawCircle(Offset(x, y - 1), 2.5, petals);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
