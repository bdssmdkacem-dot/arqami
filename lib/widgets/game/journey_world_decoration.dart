import 'package:flutter/material.dart';

/// طبقة العالم البصرية للخريطة.
///
/// تستخدم أصل Kenney الذي يُنزّل إلى assets/game أثناء بناء Android.
/// حركة الشخصية وتحديد موقعها مسؤولية خريطة الرحلة نفسها حتى يرتبطان
/// مباشرة بتقدم الطفل الحقيقي.
class JourneyWorldDecoration extends StatelessWidget {
  const JourneyWorldDecoration({super.key});

  static const _grassAsset = 'assets/game/backgrounds/tile_0001.png';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4D8),
          image: DecorationImage(
            image: const AssetImage(_grassAsset),
            repeat: ImageRepeat.repeat,
            filterQuality: FilterQuality.none,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.72),
              BlendMode.modulate,
            ),
          ),
        ),
      ),
    );
  }
}
