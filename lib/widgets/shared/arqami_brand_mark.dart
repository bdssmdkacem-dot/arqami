import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';

/// العلامة البصرية لأرقامي:
/// أرقام عربية + نقطة لعب + مسار، بدلاً من رمز عام أو شخصية جاهزة.
class ArqamiBrandMark extends StatelessWidget {
  final double size;
  final bool compact;

  const ArqamiBrandMark({
    super.key,
    this.size = 52,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArqamiBrandPainter(compact: compact),
      ),
    );
  }
}

class _ArqamiBrandPainter extends CustomPainter {
  final bool compact;

  const _ArqamiBrandPainter({required this.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()..color = GameTheme.ocean,
    );
    canvas.drawCircle(
      center,
      r * .78,
      Paint()..color = GameTheme.paper,
    );

    final path = Path()
      ..moveTo(size.width * .22, size.height * .68)
      ..quadraticBezierTo(
        size.width * .44,
        size.height * .25,
        size.width * .74,
        size.height * .38,
      )
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .43,
        size.width * .78,
        size.height * .70,
      );

    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = GameTheme.mint;
    canvas.drawPath(path, route);

    final dot = Offset(size.width * .23, size.height * .69);
    canvas.drawCircle(dot, size.width * .085, Paint()..color = GameTheme.sunshine);
    canvas.drawCircle(
      dot,
      size.width * .035,
      Paint()..color = GameTheme.paper,
    );

    if (!compact) {
      final text = TextPainter(
        text: TextSpan(
          text: '١٢٣',
          style: TextStyle(
            color: GameTheme.ink,
            fontSize: size.width * .25,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();

      text.paint(
        canvas,
        Offset(
          size.width * .50 - text.width / 2,
          size.height * .47 - text.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArqamiBrandPainter oldDelegate) =>
      oldDelegate.compact != compact;
}
