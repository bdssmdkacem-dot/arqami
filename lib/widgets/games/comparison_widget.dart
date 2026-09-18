import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart;

/// نوع السؤال: أيهما أكثر، أيهما أقل، أو هل هما متساويان.
enum ComparisonQuestion {
  more,
  fewer,
  equal,
}

/// مكون المقارنة البصرية — يعرض كومتين من عناصر مختلفة أو متساوية العدد.
/// لا يعتمد على الرموز الرياضية، بل على المقارنة البصرية المباشرة.
class ComparisonWidget extends StatefulWidget {
  final int leftCount;
  final int rightCount;
  final ComparisonQuestion question;
  final VoidCallback onComplete;
  final VoidCallback? onWrongAttempt;
  final IconData itemIcon;

  const ComparisonWidget({
    super.key,
    required this.leftCount,
    required this.rightCount,
    required this.onComplete,
    this.question = ComparisonQuestion.more,
    this.onWrongAttempt,
    this.itemIcon = Icons.circle,
  }) : assert(leftCount >= 0 && rightCount >= 0);

  @override
  State<ComparisonWidget> createState() => ComparisonWidgetState();
}

class ComparisonWidgetState extends State<ComparisonWidget> {
  bool _completed = false;
  bool _wrongLeft = false;
  bool _wrongRight = false;

  /// Equality is determined by the actual quantities. This also protects
  /// against a malformed curriculum config that accidentally labels an
  /// equal pair as "more" or "fewer".
  ComparisonQuestion get _effectiveQuestion {
    if (widget.leftCount == widget.rightCount) {
      return ComparisonQuestion.equal;
    }
    return widget.question;
  }

  bool get _leftIsCorrect {
    switch (_effectiveQuestion) {
      case ComparisonQuestion.more:
        return widget.leftCount > widget.rightCount;
      case ComparisonQuestion.fewer:
        return widget.leftCount < widget.rightCount;
      case ComparisonQuestion.equal:
        return widget.leftCount == widget.rightCount;
    }
  }

  String get _questionLabel {
    switch (_effectiveQuestion) {
      case ComparisonQuestion.more:
        return 'أيّ كومة فيها أكثر؟';
      case ComparisonQuestion.fewer:
        return 'أيّ كومة فيها أقل؟';
      case ComparisonQuestion.equal:
        return 'هل الكومتان متساويتان؟';
    }
  }

  void _handleTap(bool tappedLeft) {
    if (_completed) {
      return;
    }

    // في سؤال التساوي لا توجد إجابة "يسار/يمين"؛ الضغط على أي كومة
    // يعني اختيار أن الكومتين متساويتان.
    final tappedIsCorrect = _effectiveQuestion == ComparisonQuestion.equal
        ? widget.leftCount == widget.rightCount
        : (tappedLeft ? _leftIsCorrect : !_leftIsCorrect);

    if (tappedIsCorrect) {
      setState(() {
        _completed = true;
      });

      widget.onComplete();
      return;
    }

    widget.onWrongAttempt?.call();

    setState(() {
      _wrongLeft = tappedLeft;
      _wrongRight = !tappedLeft;
    });

    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _wrongLeft = false;
          _wrongRight = false;
        });
      },
    );
  }

  void reset() {
    if (!mounted) {
      return;
    }

    setState(() {
      _completed = false;
      _wrongLeft = false;
      _wrongRight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final equalQuestion = _effectiveQuestion == ComparisonQuestion.equal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _questionLabel,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _GroupCard(
              count: widget.leftCount,
              icon: widget.itemIcon,
              color: AppColors.teal,
              isWrong: _wrongLeft,
              isCorrectAndCompleted: _completed && _leftIsCorrect,
              onTap: () => _handleTap(true),
              semanticLabel: equalQuestion
                  ? 'مجموعة فيها ${widget.leftCount} عناصر، اختر للتأكيد على التساوي'
                  : 'مجموعة فيها ${widget.leftCount} عناصر، اليسار',
            ),
            _GroupCard(
              count: widget.rightCount,
              icon: widget.itemIcon,
              color: AppColors.terracotta,
              isWrong: _wrongRight,
              isCorrectAndCompleted: _completed &&
                  (equalQuestion ? _leftIsCorrect : !_leftIsCorrect),
              onTap: () => _handleTap(false),
              semanticLabel: equalQuestion
                  ? 'مجموعة فيها ${widget.rightCount} عناصر، اختر للتأكيد على التساوي'
                  : 'مجموعة فيها ${widget.rightCount} عناصر، اليمين',
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final int count;
  final IconData icon;
  final Color color;
  final bool isWrong;
  final bool isCorrectAndCompleted;
  final VoidCallback onTap;
  final String semanticLabel;

  const _GroupCard({
    required this.count,
    required this.icon,
    required this.color,
    required this.isWrong,
    required this.isCorrectAndCompleted,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;

    if (isWrong) {
      borderColor = const Color(0xFFE57373);
    } else if (isCorrectAndCompleted) {
      borderColor = const Color(0xFF4CAF50);
    } else {
      borderColor = Colors.white;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(
              count,
              (_) => Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
