import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';

/// The original Arqami companion. It is deliberately built from simple
/// shapes so every unit can use the same character without external assets.
class ArqamiCompanion extends StatefulWidget {
  final String mood;
  final double size;

  const ArqamiCompanion({
    super.key,
    this.mood = 'happy',
    this.size = 74,
  });

  @override
  State<ArqamiCompanion> createState() => _ArqamiCompanionState();
}

class _ArqamiCompanionState extends State<ArqamiCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final happy = widget.mood == 'happy' || widget.mood == 'celebrate';
    final celebrate = widget.mood == 'celebrate';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final bob = math.sin(t * math.pi) * (celebrate ? 5 : 3);
        final tilt = math.sin(t * math.pi * 2) * (celebrate ? .035 : .018);

        return Transform.translate(
          offset: Offset(0, -bob),
          child: Transform.rotate(angle: tilt, child: child),
        );
      },
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _CompanionPainter(
          happy: happy,
          celebrate: celebrate,
        ),
      ),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  final bool happy;
  final bool celebrate;

  const _CompanionPainter({
    required this.happy,
    required this.celebrate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);
    final body = Paint()..color = GameTheme.ocean;
    final belly = Paint()..color = GameTheme.cloud;
    final eye = Paint()..color = GameTheme.ink;
    final smile = Paint()
      ..color = GameTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, s * .035)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(center.dx, s * .55), s * .34, body);
    canvas.drawCircle(Offset(center.dx, s * .60), s * .22, belly);

    final eyeY = s * .43;
    canvas.drawCircle(Offset(s * .40, eyeY), s * .045, eye);
    canvas.drawCircle(Offset(s * .60, eyeY), s * .045, eye);

    final mouth = Path()..moveTo(s * .43, s * .53);
    if (happy) {
      mouth.quadraticBezierTo(s * .50, s * .62, s * .57, s * .53);
    } else {
      mouth.quadraticBezierTo(s * .50, s * .48, s * .57, s * .53);
    }
    canvas.drawPath(mouth, smile);

    final cheek = Paint()..color = GameTheme.berry.withValues(alpha: .55);
    canvas.drawCircle(Offset(s * .32, s * .52), s * .035, cheek);
    canvas.drawCircle(Offset(s * .68, s * .52), s * .035, cheek);

    if (celebrate) {
      final star = Paint()..color = GameTheme.sunshine;
      _drawStar(canvas, Offset(s * .18, s * .18), s * .08, star);
      _drawStar(canvas, Offset(s * .82, s * .20), s * .07, star);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * .45;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CompanionPainter oldDelegate) =>
      oldDelegate.happy != happy || oldDelegate.celebrate != celebrate;
}

/// Lightweight particle burst used by completion screens and world unlocks.
/// It uses deterministic positions, so tests and screenshots remain stable.
class GameParticleBurst extends StatefulWidget {
  final bool active;
  final int seed;
  final int count;

  const GameParticleBurst({
    super.key,
    required this.active,
    this.seed = 7,
    this.count = 30,
  });

  @override
  State<GameParticleBurst> createState() => _GameParticleBurstState();
}

class _GameParticleBurstState extends State<GameParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant GameParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ParticlePainter(
            progress: _controller,
            seed: widget.seed,
            count: widget.count,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final Animation<double> progress;
  final int seed;
  final int count;

  _ParticlePainter({
    required this.progress,
    required this.seed,
    required this.count,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final random = math.Random(seed);
    final palette = <Color>[
      GameTheme.sunshine,
      GameTheme.mango,
      GameTheme.coral,
      GameTheme.mint,
      GameTheme.ocean,
      GameTheme.violet,
      GameTheme.berry,
    ];

    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 35 + random.nextDouble() * math.min(size.width, size.height) * .42;
      final startX = size.width / 2;
      final startY = size.height * .42;
      final x = startX + math.cos(angle) * distance * progress.value;
      final y = startY +
          math.sin(angle) * distance * progress.value +
          120 * progress.value * progress.value;
      final radius = 2.5 + random.nextDouble() * 4;
      final opacity = (1 - progress.value).clamp(0.0, 1.0);
      final paint = Paint()..color = palette[i % palette.length].withValues(alpha: opacity);

      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: radius * 1.8,
          height: radius * 1.8,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.count != count;
}
