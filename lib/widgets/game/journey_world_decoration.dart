import 'dart:math' as math;

import 'package:flutter/material.dart';

/// طبقة العالم البصرية للخريطة.
///
/// تستخدم أصول Kenney التي تُنزّل إلى assets/game أثناء بناء Android،
/// وتبقى الخريطة نفسها مستقلة عن بيانات المنهج والتقدم.
class JourneyWorldDecoration extends StatelessWidget {
  const JourneyWorldDecoration({super.key});

  static const _grassAsset = 'assets/game/backgrounds/tile_0001.png';
  static const _characterAsset =
      'assets/game/characters/roguelikeChar_transparent.png';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4D8),
                image: DecorationImage(
                  image: AssetImage(_grassAsset),
                  repeat: ImageRepeat.repeat,
                  filterQuality: FilterQuality.none,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.72),
                    BlendMode.modulate,
                  ),
                ),
              ),
            ),
          ),
          const PositionedDirectional(
            top: 18,
            end: 18,
            child: _CompanionSprite(),
          ),
        ],
      ),
    );
  }
}

class _CompanionSprite extends StatefulWidget {
  const _CompanionSprite();

  @override
  State<_CompanionSprite> createState() => _CompanionSpriteState();
}

class _CompanionSpriteState extends State<_CompanionSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value * math.pi * 2;
        final dx = math.sin(phase) * 7;
        final dy = math.sin(phase * 2) * 3;
        final angle = math.sin(phase) * 0.035;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4A017).withValues(alpha: 0.65),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 16 / 918,
            heightFactor: 16 / 203,
            child: Image.asset(
              JourneyWorldDecoration._characterAsset,
              width: 918 * 4,
              height: 203 * 4,
              fit: BoxFit.none,
              filterQuality: FilterQuality.none,
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      ),
    );
  }
}
