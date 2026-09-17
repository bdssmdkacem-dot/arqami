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

class _CompanionSprite extends StatelessWidget {
  const _CompanionSprite();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
