import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';

/// مكون "اسحب وعدّ" داخل حديقة الأعداد.
/// يحافظ على منطق العد والتقييم نفسه، مع تحويل مساحة النشاط إلى مشهد لعب
/// مناسب لعالم الأعداد 0–10.
class DragCountWidget extends StatefulWidget {
  final int targetCount;
  final IconData itemIcon;
  final Color itemColor;
  final VoidCallback onComplete;
  final void Function(int currentCount)? onItemDropped;
  final VoidCallback? onWrongDigitSelected;

  const DragCountWidget({
    super.key,
    required this.targetCount,
    required this.onComplete,
    this.itemIcon = Icons.star_rounded,
    this.itemColor = GameTheme.sunshine,
    this.onItemDropped,
    this.onWrongDigitSelected,
  }) : assert(
          targetCount >= 0 && targetCount <= 10,
          'targetCount يجب أن يكون بين 0 و 10',
        );

  @override
  State<DragCountWidget> createState() => DragCountWidgetState();
}

class DragCountWidgetState extends State<DragCountWidget>
    with SingleTickerProviderStateMixin {
  late List<int> _remainingItemKeys;
  int _droppedCount = 0;
  bool _showDigitChoices = false;
  late List<int> _digitChoices;
  int? _wrongSelection;
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: GameTheme.popMotion,
  );

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setup() {
    _remainingItemKeys = List.generate(widget.targetCount, (i) => i);
    _droppedCount = 0;
    _showDigitChoices = widget.targetCount == 0;
    _wrongSelection = null;
    _digitChoices = _buildDigitChoices(widget.targetCount);
    _pulseController.reset();
  }

  List<int> _buildDigitChoices(int target) {
    final choices = <int>{target};
    final candidates = <int>[
      if (target - 1 >= 0) target - 1,
      if (target + 1 <= 10) target + 1,
      if (target - 2 >= 0) target - 2,
      if (target + 2 <= 10) target + 2,
    ]..shuffle();

    for (final c in candidates) {
      if (choices.length >= 3) break;
      choices.add(c);
    }
    return choices.toList()..shuffle();
  }

  @override
  void didUpdateWidget(covariant DragCountWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetCount != widget.targetCount) {
      setState(_setup);
    }
  }

  void reset() => setState(_setup);

  void _handleDropped(int itemKey) {
    if (!_remainingItemKeys.contains(itemKey)) return;
    setState(() {
      _remainingItemKeys.remove(itemKey);
      _droppedCount++;
    });
    widget.onItemDropped?.call(_droppedCount);
    _pulseController.forward(from: 0);

    if (_droppedCount == widget.targetCount) {
      setState(() => _showDigitChoices = true);
    }
  }

  void _handleDigitTap(int digit) {
    if (digit == widget.targetCount) {
      widget.onComplete();
    } else {
      widget.onWrongDigitSelected?.call();
      setState(() => _wrongSelection = digit);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _wrongSelection = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetCount == 0
        ? 1.0
        : (_droppedCount / widget.targetCount).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameTheme.sky, GameTheme.paper],
        ),
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        border: Border.all(color: GameTheme.skyDeep, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GardenPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: GameTheme.cloud,
                        shape: BoxShape.circle,
                        border: Border.all(color: GameTheme.sunshine, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: GameTheme.popMotion,
                        child: Text(
                          '$_droppedCount',
                          key: ValueKey(_droppedCount),
                          style: const TextStyle(
                            color: GameTheme.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حديقة الأعداد',
                            style: TextStyle(
                              color: GameTheme.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _showDigitChoices
                                ? 'اختر العدد الذي يمثل ما جمعت.'
                                : 'اسحب العناصر إلى السلة وعدّها.',
                            style: const TextStyle(
                              color: GameTheme.inkSoft,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: progress,
                    backgroundColor: GameTheme.cloud.withValues(alpha: .8),
                    valueColor: const AlwaysStoppedAnimation(GameTheme.mint),
                  ),
                ),
                const SizedBox(height: 22),
                if (_remainingItemKeys.isNotEmpty)
                  _GardenPatch(
                    items: _remainingItemKeys,
                    icon: widget.itemIcon,
                    color: widget.itemColor,
                  ),
                if (_remainingItemKeys.isNotEmpty) const SizedBox(height: 18),
                if (_remainingItemKeys.isNotEmpty)
                  DragTarget<int>(
                    onWillAcceptWithDetails: (_) => true,
                    onAcceptWithDetails: (details) => _handleDropped(details.data),
                    builder: (context, candidateData, rejectedData) {
                      final hovering = candidateData.isNotEmpty;
                      return AnimatedScale(
                        scale: hovering ? 1.04 : 1.0,
                        duration: GameTheme.tapMotion,
                        child: AnimatedContainer(
                          duration: GameTheme.tapMotion,
                          width: 164,
                          height: 104,
                          decoration: BoxDecoration(
                            color: hovering
                                ? GameTheme.paperWarm
                                : GameTheme.cloud.withValues(alpha: .94),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: hovering ? GameTheme.mango : GameTheme.mint,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_basket_rounded,
                                size: 42,
                                color: GameTheme.mint,
                              ),
                              SizedBox(height: 3),
                              Text(
                                'ضع هنا',
                                style: TextStyle(
                                  color: GameTheme.inkSoft,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (_showDigitChoices) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.targetCount == 0
                        ? 'كم عنصراً؟ لا توجد عناصر.'
                        : 'كم عنصر جمعت؟',
                    style: const TextStyle(
                      color: GameTheme.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _digitChoices.map((digit) {
                      final isWrong = _wrongSelection == digit;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          key: ValueKey('drag-count-choice-$digit'),
                          onTap: () => _handleDigitTap(digit),
                          child: AnimatedContainer(
                            duration: GameTheme.tapMotion,
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isWrong ? GameTheme.danger : GameTheme.cloud,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isWrong ? GameTheme.danger : GameTheme.ocean,
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x16000000),
                                  blurRadius: 7,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$digit',
                              style: const TextStyle(
                                color: GameTheme.ink,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenPatch extends StatelessWidget {
  final List<int> items;
  final IconData icon;
  final Color color;

  const _GardenPatch({required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameTheme.mint.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GameTheme.mint.withValues(alpha: .35)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: items.map((itemKey) {
          return Draggable<int>(
            data: itemKey,
            feedback: _DragItem(icon: icon, color: color, size: 58),
            childWhenDragging: Opacity(
              opacity: .25,
              child: _DragItem(icon: icon, color: color, size: 48),
            ),
            child: _DragItem(icon: icon, color: color, size: 48),
          );
        }).toList(),
      ),
    );
  }
}

class _DragItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _DragItem({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _GardenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = GameTheme.cloud.withValues(alpha: .8);
    canvas.drawCircle(30, 32, 13, paint);
    canvas.drawCircle(47, 30, 17, paint);
    canvas.drawCircle(67, 34, 12, paint);

    paint.color = GameTheme.mint.withValues(alpha: .25);
    canvas.drawOval(
      Rect.fromLTWH(-20, size.height - 52, size.width + 40, 80),
      paint,
    );

    paint.color = GameTheme.sunshine.withValues(alpha: .7);
    canvas.drawCircle(size.width - 34, 34, 15, paint);

    final flowerPaint = Paint()..color = GameTheme.coral.withValues(alpha: .55);
    for (var i = 0; i < 4; i++) {
      final x = 24.0 + i * ((size.width - 48) / 3);
      final y = size.height - 25.0 - (i.isEven ? 4 : 0);
      canvas.drawCircle(Offset(x, y), 4, flowerPaint);
      canvas.drawCircle(Offset(x + 6, y), 4, flowerPaint);
      canvas.drawCircle(Offset(x + 3, y - 5), 4, flowerPaint);
      canvas.drawCircle(Offset(x + 3, y), 2.5, Paint()..color = GameTheme.sunshine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
