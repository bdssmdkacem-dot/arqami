import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// مكون "اسحب وعدّ" — الطفل يسحب عناصر (نجوم/تفاح) من الكومة لسلة،
/// والعداد يتحدث حياً، وفي النهاية يختار الرقم المطابق للعدد الذي جمعه.
class DragCountWidget extends StatefulWidget {
  /// عدد العناصر الذي يجب على الطفل سحبه ثم التعرف على رقمه.
  /// الصفر مدعوم أيضاً: لا توجد عناصر للسحب، ويظهر اختيار الرقم مباشرة.
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
  }) : assert(
          targetCount >= 0 && targetCount <= 10,
          'targetCount يجب أن يكون بين 0 و 10',
        );

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
    return Column(
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _remainingItemKeys.map((itemKey) {
              return Draggable<int>(
                data: itemKey,
                feedback: _DragItem(icon: widget.itemIcon, color: widget.itemColor, size: 56),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _DragItem(icon: widget.itemIcon, color: widget.itemColor, size: 48),
                ),
                child: _DragItem(icon: widget.itemIcon, color: widget.itemColor, size: 48),
              );
            }).toList(),
          ),
        if (_remainingItemKeys.isNotEmpty) const SizedBox(height: 24),
        if (_remainingItemKeys.isNotEmpty)
          DragTarget<int>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) => _handleDropped(details.data),
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 140,
                height: 100,
                decoration: BoxDecoration(
                  color: isHovering ? const Color(0xFFFFF3CD) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHovering ? const Color(0xFFFFA000) : const Color(0xFFBDBDBD),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.shopping_basket_outlined, size: 40, color: Color(0xFF8D6E63)),
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
                      onTap: () => _handleDigitTap(digit),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isWrong ? const Color(0xFFFFCDD2) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWrong ? const Color(0xFFE57373) : const Color(0xFFBDBDBD),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text('$digit', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
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
    return Icon(icon, color: color, size: size);
  }
}
