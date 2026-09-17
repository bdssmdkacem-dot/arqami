import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';

/// عالم رحلة أرقامي: خلفية مرحة وحية، مرسومة محلياً حتى تبقى خفيفة.
/// الحركة زخرفية فقط ولا تتدخل في المسار أو منطق فتح الوحدات.
class JourneyWorldDecoration extends StatefulWidget {
  const JourneyWorldDecoration({super.key});

  @override
  State<JourneyWorldDecoration> createState() => _JourneyWorldDecorationState();
}

class _JourneyWorldDecorationState extends State<JourneyWorldDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _JourneyWorldPainter(_controller.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _JourneyWorldPainter extends CustomPainter {
  final double progress;

  const _JourneyWorldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = GameTheme.sky);

    final zones = <Color>[
      GameTheme.ocean,
      GameTheme.mint,
      GameTheme.sunshine,
      GameTheme.mango,
      GameTheme.coral,
      GameTheme.violet,
      GameTheme.berry,
    ];
    final zoneHeight = math.max(180.0, height / 7);
    for (var i = 0; i < zones.length; i++) {
      final top = i * zoneHeight;
      canvas.drawRect(
        Rect.fromLTWH(0, top, width, zoneHeight + 2),
        Paint()..color = zones[i].withValues(alpha: i.isEven ? .075 : .055),
      );
    }

    final sunCenter = Offset(width * .84, 58);
    canvas.drawCircle(
      sunCenter,
      38,
      Paint()..color = GameTheme.sunshine.withValues(alpha: .16),
    );
    canvas.drawCircle(
      sunCenter,
      24,
      Paint()..color = GameTheme.sunshine.withValues(alpha: .85),
    );

    _drawCloud(canvas, Offset(width * .18 + progress * 18, 62), 1.0);
    _drawCloud(canvas, Offset(width * .62 - progress * 24, 125), .72);
    _drawCloud(canvas, Offset(width * .28 + progress * 12, height * .43), .56);

    _drawHill(canvas, Offset(width * .10, height * .23), width * .38, 70, GameTheme.mint);
    _drawHill(canvas, Offset(width * .92, height * .32), width * .44, 82, GameTheme.ocean);
    _drawHill(canvas, Offset(width * .08, height * .60), width * .34, 58, GameTheme.sunshine);
    _drawHill(canvas, Offset(width * .92, height * .80), width * .40, 72, GameTheme.violet);

    _drawIsland(canvas, Offset(width * .79, height * .55), width * .18, GameTheme.mint);
    _drawIsland(canvas, Offset(width * .18, height * .78), width * .15, GameTheme.sunshine);

    _drawTree(canvas, Offset(width * .09, height * .18), .72, GameTheme.mint);
    _drawTree(canvas, Offset(width * .92, height * .20), .58, GameTheme.mint);
    _drawTree(canvas, Offset(width * .07, height * .47), .55, GameTheme.mango);
    _drawTree(canvas, Offset(width * .94, height * .54), .66, GameTheme.mint);
    _drawTree(canvas, Offset(width * .13, height * .90), .60, GameTheme.violet);
    _drawTree(canvas, Offset(width * .86, height * .92), .52, GameTheme.coral);

    _drawFlowers(canvas, width, height);
    _drawSparkles(canvas, width, height);
  }

  void _drawCloud(Canvas canvas, Offset center, double scale) {
    final paint = Paint()..color = GameTheme.cloud.withValues(alpha: .72);
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

  void _drawHill(Canvas canvas, Offset center, double width, double height, Color color) {
    final path = Path()
      ..moveTo(center.dx - width / 2, center.dy + height / 2)
      ..quadraticBezierTo(center.dx, center.dy - height / 2, center.dx + width / 2, center.dy + height / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: .12));
  }

  void _drawIsland(Canvas canvas, Offset center, double width, Color color) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: width * .46),
      Paint()..color = color.withValues(alpha: .15),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, -2), width: width * .72, height: width * .24),
      Paint()..color = Colors.white.withValues(alpha: .32),
    );
  }

  void _drawTree(Canvas canvas, Offset base, double scale, Color color) {
    final trunk = Paint()..color = GameTheme.mango.withValues(alpha: .50);
    final crown = Paint()..color = color.withValues(alpha: .25);
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

  void _drawFlowers(Canvas canvas, double width, double height) {
    final stem = Paint()
      ..strokeWidth = 1.3
      ..color = GameTheme.mint.withValues(alpha: .32);
    final petals = Paint()..color = GameTheme.coral.withValues(alpha: .62);
    for (var i = 0; i < 22; i++) {
      final x = ((i * 47 + 17) % 91) / 100 * width + 8;
      final y = ((i * 71 + 23) % 87) / 100 * height + 6;
      canvas.drawLine(Offset(x, y), Offset(x, y + 8), stem);
      canvas.drawCircle(Offset(x, y - 1), 2.5, petals);
    }
  }

  void _drawSparkles(Canvas canvas, double width, double height) {
    for (var i = 0; i < 18; i++) {
      final x = ((i * 83 + 19) % 97) / 100 * width;
      final baseY = ((i * 137 + 31) % 91) / 100 * height;
      final wave = progress * math.pi * 2 + i;
      final y = baseY + math.sin(wave) * 4;
      final alpha = .12 + ((math.sin(wave) + 1) / 2) * .16;
      final paint = Paint()..color = GameTheme.sunshine.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 2.0 + (i % 3) * .6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyWorldPainter oldDelegate) => oldDelegate.progress != progress;
}
