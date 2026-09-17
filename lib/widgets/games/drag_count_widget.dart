import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';

/// مكون "اسحب وعدّ" — الطفل يسحب عناصر (نجوم/تفاح) من الحديقة إلى السلة،
/// والعداد يتحدث حياً، وفي النهاية يختار الرقم المطابق للعدد الذي جمعه.
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
    this.itemColor = AppColors.gold,
    this.onItemDropped,
    this.onWrongDigitSelected,
  }) : assert(targetCount >= 0 && targetCount <= 10, 'targetCount يجب أن يكون بين 0 و 10');

  @override
  State<DragCountWidget> createState() => DragCountWidgetState();
}

class DragCountWidgetState extends State<DragCountWidget> {
  late List<int> _remainingItemKeys;
  int _droppedCount = 0;
  bool _showDigitChoices = false;
  late List<int> _digitChoices;
  int? _wrongSelection;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    _remainingItemKeys = List.generate(widget.targetCount, (i) => i);
    _droppedCount = 0;
    _showDigitChoices = widget.targetCount == 0;
    _wrongSelection = null;
    _digitChoices = _buildDigitChoices(widget.targetCount);
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
    return CustomPaint(
      painter: _GardenPainter(),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$_droppedCount',
              key: ValueKey(_droppedCount),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          if (_remainingItemKeys.isNotEmpty)
            _GardenPatch(items: _remainingItemKeys, icon: widget.itemIcon, color: widget.itemColor),
          if (_remainingItemKeys.isNotEmpty) const SizedBox(height: 18),
          if (_remainingItemKeys.isNotEmpty)
            DragTarget<int>(
              onWillAcceptWithDetails: (details) => _remainingItemKeys.contains(details.data),
              onAcceptWithDetails: (details) => _handleDropped(details.data),
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 150,
                  height: 108,
                  decoration: BoxDecoration(
                    color: isHovering ? GameTheme.paperWarm : GameTheme.paper,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isHovering ? GameTheme.mango : GameTheme.skyDeep,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_basket_rounded, size: 42, color: GameTheme.mango),
                      const SizedBox(height: 4),
                      Text('السلة', style: TextStyle(color: GameTheme.inkSoft, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),
          if (_remainingItemKeys.isNotEmpty) const SizedBox(height: 24),
          if (_showDigitChoices)
            Column(
              children: [
                Text(
                  widget.targetCount == 0 ? 'كم عنصراً؟ لا توجد عناصر.' : 'كم عنصر جمعت؟',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _digitChoices.map((digit) {
                    final isWrong = _wrongSelection == digit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        key: ValueKey('drag-count-choice-$digit'),
                        onTap: () => _handleDigitTap(digit),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isWrong ? GameTheme.danger.withValues(alpha: .12) : GameTheme.paper,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isWrong ? GameTheme.danger : GameTheme.skyDeep,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$digit',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: GameTheme.ink),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
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
    canvas.drawCircle(const Offset(30, 32), 13, paint);
    canvas.drawCircle(const Offset(47, 30), 17, paint);
    canvas.drawCircle(const Offset(67, 34), 12, paint);

    paint.color = GameTheme.mint.withValues(alpha: .25);
    canvas.drawOval(
      Rect.fromLTWH(-20, size.height - 52, size.width + 40, 80),
      paint,
    );

    paint.color = GameTheme.sunshine.withValues(alpha: .7);
    canvas.drawCircle(Offset(size.width - 34, 34), 15, paint);

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
