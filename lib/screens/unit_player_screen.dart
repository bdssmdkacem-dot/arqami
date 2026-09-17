import 'package:flutter/material.dart';

import '../core/ads/ad_service.dart';
import '../core/assessment/assessment_engine.dart';
import '../core/audio/audio_service.dart';
import '../core/progress/progress_tracker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
import '../models/unit_model.dart';
import '../models/units_data.dart';
import 'certificate_screen.dart';
import '../widgets/games/comparison_widget.dart';
import '../widgets/games/drag_count_widget.dart';
import '../widgets/games/matching_widget.dart';
import '../widgets/games/scene_explore_widget.dart';
import '../widgets/games/trace_widget.dart';
import '../widgets/shared/number_display.dart';
import '../widgets/shared/quantity_row.dart';

class UnitPlayerScreen extends StatefulWidget {
  final UnitModel unit;
  const UnitPlayerScreen({super.key, required this.unit});

  @override
  State<UnitPlayerScreen> createState() => _UnitPlayerScreenState();
}

class _UnitPlayerScreenState extends State<UnitPlayerScreen> {
  int _activityIndex = 0;
  int _wrongAttemptsInUnit = 0;
  bool _unitCompleted = false;
  int? _lastAnnouncedSceneIndex;

  ActivityConfig get _currentActivity => widget.unit.activities[_activityIndex];

  void _onWrongAttempt() {
    _wrongAttemptsInUnit++;
    AudioService.instance.playTryAgain();
  }

  Future<void> _onAssessmentFailed(AssessmentResult result) async {
    await ProgressTracker.instance.recordAttempt(widget.unit.id);
  }

  void _onActivityComplete() {
    if (!mounted) return;
    if (_activityIndex < widget.unit.activities.length - 1) {
      setState(() => _activityIndex++);
    } else {
      _completeUnit();
    }
  }

  Future<void> _completeUnit() async {
    final stars = _wrongAttemptsInUnit == 0 ? 3 : (_wrongAttemptsInUnit <= 2 ? 2 : 1);
    await ProgressTracker.instance.markUnitComplete(widget.unit.id, stars: stars);
    AudioService.instance.playUnitComplete();
    if (mounted) setState(() => _unitCompleted = true);
    if (widget.unit.order % 3 == 0) {
      await AdService.instance.maybeShowInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.unit.titleAr), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Responsive.constrainedCenter(
            child: _unitCompleted ? _buildCompletionView() : _buildActivity(_currentActivity),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionView() {
    final progress = ProgressTracker.instance.getUnitProgress(widget.unit.id);
    final isFinalUnit = widget.unit.order == UnitsData.units.length;
    final children = <Widget>[
      const Icon(Icons.celebration_rounded, size: 64, color: AppColors.gold),
      const SizedBox(height: 12),
      const Text('أحسنت!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('أكملت هذه الوحدة بنجاح', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 18),
      Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Icon(i < progress.stars ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.gold, size: 40))),
      const SizedBox(height: 24),
    ];
    if (isFinalUnit) {
      children.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CertificateScreen())),
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('احصل على شهادتك'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textPrimary),
          ),
        ),
      );
      children.add(const SizedBox(height: 10));
    }
    children.add(
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('رجوع لخريطة الوحدات')),
      ),
    );

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }

  Widget _buildActivity(ActivityConfig config) {
    final totalActivities = widget.unit.activities.length;
    final currentNumber = _activityIndex + 1;
    final progressValue = currentNumber / totalActivities;
    Widget activity;

    if (config is LessonActivityConfig) {
      activity = _LessonView(config: config, onContinue: _onActivityComplete);
    } else if (config is MultipleChoiceActivityConfig) {
      activity = _ChoiceQuizView(title: widget.unit.titleAr, questions: config.questions, onWrong: _onWrongAttempt, onComplete: _onActivityComplete);
    } else if (config is AssessmentActivityConfig) {
      activity = _ChoiceQuizView(
        key: ValueKey('assessment_${widget.unit.id}_$_activityIndex'),
        title: config.titleAr,
        questions: config.questions,
        onWrong: _onWrongAttempt,
        onComplete: _onActivityComplete,
        isAssessment: true,
        onAssessmentFailed: _onAssessmentFailed,
      );
    } else if (config is ReviewActivityConfig) {
      activity = _ChoiceQuizView(title: config.titleAr, questions: config.questions, onWrong: _onWrongAttempt, onComplete: _onActivityComplete);
    } else if (config is ArithmeticActivityConfig) {
      activity = _ArithmeticView(config: config, onWrong: _onWrongAttempt, onComplete: _onActivityComplete);
    } else if (config is WordProblemActivityConfig) {
      activity = _ArithmeticView(config: ArithmeticActivityConfig(operation: 'مسألة', questions: config.questions), onWrong: _onWrongAttempt, onComplete: _onActivityComplete);
    } else if (config is TraceActivityConfig) {
      activity = TraceWidget(
        key: ValueKey('trace_${config.digit}_$_activityIndex'),
        number: config.digit,
        onComplete: () {
          AudioService.instance.playCorrect();
          AudioService.instance.playNumber(config.digit);
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else if (config is MatchingActivityConfig) {
      final pairs = config.pairs
          .map((spec) => MatchPair(
                id: spec.id,
                leftContent: _buildMatchContent(spec.leftType, spec.leftValue),
                rightContent: _buildMatchContent(spec.rightType, spec.rightValue),
              ))
          .toList();
      activity = MatchingWidget(
        key: ValueKey('matching_$_activityIndex'),
        pairs: pairs,
        onCorrectMatch: (_) => AudioService.instance.playCorrect(),
        onWrongAttempt: _onWrongAttempt,
        onAllMatched: () => Future.delayed(const Duration(milliseconds: 700), _onActivityComplete),
      );
    } else if (config is ComparisonActivityConfig) {
      activity = ComparisonWidget(
        key: ValueKey('comparison_$_activityIndex'),
        leftCount: config.leftCount,
        rightCount: config.rightCount,
        question: config.question == ComparisonQuestionType.more ? ComparisonQuestion.more : ComparisonQuestion.fewer,
        onWrongAttempt: _onWrongAttempt,
        onComplete: () {
          AudioService.instance.playCorrect();
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else if (config is SceneExploreActivityConfig) {
      if (_lastAnnouncedSceneIndex != _activityIndex) {
        _lastAnnouncedSceneIndex = _activityIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) => AudioService.instance.playNumber(config.targetDigit));
      }
      activity = SceneExploreWidget(
        key: ValueKey('scene_$_activityIndex'),
        sceneType: config.sceneType,
        targetDigit: config.targetDigit,
        onWrongAttempt: _onWrongAttempt,
        onComplete: () {
          AudioService.instance.playCorrect();
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else if (config is DragCountActivityConfig) {
      activity = DragCountWidget(
        key: ValueKey('dragcount_$_activityIndex'),
        targetCount: config.targetCount,
        onItemDropped: (count) => AudioService.instance.playNumber(count),
        onWrongDigitSelected: _onWrongAttempt,
        onComplete: () {
          AudioService.instance.playCorrect();
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _ActivityProgress(current: currentNumber, total: totalActivities, value: progressValue),
        const SizedBox(height: 14),
        Expanded(child: activity),
      ],
    );
  }

  Widget _buildMatchContent(MatchContentType type, int value) {
    switch (type) {
      case MatchContentType.number:
        return NumberDisplay(value: value);
      case MatchContentType.quantity:
        return QuantityRow(count: value);
    }
  }
}

class _LessonView extends StatelessWidget {
  final LessonActivityConfig config;
  final VoidCallback onContinue;
  const _LessonView({required this.config, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const Icon(Icons.menu_book_rounded, size: 58, color: AppColors.teal),
      const SizedBox(height: 16),
      Text(config.titleAr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      Text(config.explanationAr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.6)),
    ];
    if (config.examplesAr.isNotEmpty) {
      children.add(const SizedBox(height: 20));
      for (final example in config.examplesAr) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(example, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            ),
          ),
        );
      }
    }
    children.add(const SizedBox(height: 22));
    children.add(
      SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('فهمت، نبدأ التمرين'),
        ),
      ),
    );

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

class _ChoiceQuizView extends StatefulWidget {
  final String title;
  final List<ChoiceQuestion> questions;
  final VoidCallback onWrong;
  final VoidCallback onComplete;
  final bool isAssessment;
  final Future<void> Function(AssessmentResult result)? onAssessmentFailed;

  const _ChoiceQuizView({
    super.key,
    required this.title,
    required this.questions,
    required this.onWrong,
    required this.onComplete,
    this.isAssessment = false,
    this.onAssessmentFailed,
  });

  @override
  State<_ChoiceQuizView> createState() => _ChoiceQuizViewState();
}

class _ChoiceQuizViewState extends State<_ChoiceQuizView> {
  int index = 0;
  bool answered = false;
  String? message;
  final List<int> _selectedAnswers = [];
  static const AssessmentEngine _assessmentEngine = AssessmentEngine();

  ChoiceQuestion get question => widget.questions[index];

  void choose(int selected) {
    if (answered || widget.questions.isEmpty) return;

    if (widget.isAssessment) {
      _chooseAssessment(selected);
      return;
    }

    if (selected == question.correctIndex) {
      setState(() {
        answered = true;
        message = 'أحسنت! إجابة صحيحة';
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        if (index == widget.questions.length - 1) {
          widget.onComplete();
        } else {
          setState(() {
            index++;
            answered = false;
            message = null;
          });
        }
      });
    } else {
      widget.onWrong();
      setState(() => message = question.hintAr ?? 'حاول مرة أخرى وفكّر بهدوء');
    }
  }

  void _chooseAssessment(int selected) {
    final isCorrect = selected == question.correctIndex;
    _selectedAnswers.add(selected);

    if (!isCorrect) {
      widget.onWrong();
    }

    setState(() {
      answered = true;
      message = isCorrect ? 'أحسنت! إجابة صحيحة' : 'تم تسجيل الإجابة';
    });

    Future.delayed(const Duration(milliseconds: 650), () async {
      if (!mounted) return;

      if (index == widget.questions.length - 1) {
        final result = _assessmentEngine.evaluate(
          questions: widget.questions,
          selectedAnswers: _selectedAnswers,
        );

        if (result.passed) {
          widget.onComplete();
          return;
        }

        await widget.onAssessmentFailed?.call(result);
        if (!mounted) return;
        final percentage = (result.score * 100).round();
        setState(() {
          index = 0;
          _selectedAnswers.clear();
          answered = false;
          message = 'نتيجتك $percentage٪ — تحتاج إلى 70٪ على الأقل. حاول مرة أخرى.';
        });
        return;
      }

      setState(() {
        index++;
        answered = false;
        message = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Center(child: Text('لا توجد أسئلة في هذا النشاط.')),
        ),
      );
    }

    final children = <Widget>[
      Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 24),
      if (widget.isAssessment)
        Text(
          'السؤال ${index + 1} من ${widget.questions.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
      if (widget.isAssessment) const SizedBox(height: 10),
      Text(question.questionAr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.5)),
      const SizedBox(height: 22),
    ];
    for (var i = 0; i < question.options.length; i++) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => choose(i),
              child: Text(question.options[i], style: const TextStyle(fontSize: 19)),
            ),
          ),
        ),
      );
    }
    if (message != null) {
      children.add(const SizedBox(height: 8));
      children.add(
        Text(
          message!,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: answered ? AppColors.teal : AppColors.terracotta),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

class _ArithmeticView extends StatefulWidget {
  final ArithmeticActivityConfig config;
  final VoidCallback onWrong;
  final VoidCallback onComplete;
  const _ArithmeticView({required this.config, required this.onWrong, required this.onComplete});

  @override
  State<_ArithmeticView> createState() => _ArithmeticViewState();
}

class _ArithmeticViewState extends State<_ArithmeticView> {
  final TextEditingController controller = TextEditingController();
  int index = 0;
  String? message;
  bool locked = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const eastern = '۰۱۲۳۴۵۶۷۸۹';
    var value = input.trim();
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(arabic[i], '$i').replaceAll(eastern[i], '$i');
    }
    return value.replaceAll('٫', '.').replaceAll(',', '.').replaceAll('،', '.');
  }

  void _keepWesternDigits(String input) {
    final normalized = _normalizeDigits(input);
    if (normalized == input) return;
    controller.value = controller.value.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  num? _parseNumber(String input) {
    final normalized = _normalizeDigits(input);
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  bool _matches(ArithmeticQuestion question, String rawInput) {
    if (question.correctAnswerText != null) {
      return _normalizeDigits(rawInput) == _normalizeDigits(question.correctAnswerText!);
    }
    final value = _parseNumber(rawInput);
    final expected = question.correctAnswer;
    if (value == null || expected == null) return false;
    return (value - expected).abs() < 0.000001;
  }

  void submit() {
    if (locked) return;
    final question = widget.config.questions[index];
    if (_matches(question, controller.text)) {
      setState(() {
        locked = true;
        message = 'أحسنت! إجابة صحيحة';
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        if (index == widget.config.questions.length - 1) {
          widget.onComplete();
        } else {
          setState(() {
            index++;
            locked = false;
            message = null;
            controller.clear();
          });
        }
      });
    } else {
      widget.onWrong();
      setState(() => message = question.hintAr ?? 'راجع العملية وحاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.config.questions[index];
    final children = <Widget>[
      Text(question.questionAr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
      const SizedBox(height: 24),
      TextField(
        controller: controller,
        enabled: !locked,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: _keepWesternDigits,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(labelText: 'اكتب الإجابة', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      SizedBox(height: 54, child: ElevatedButton(onPressed: submit, child: const Text('تحقق', style: TextStyle(fontSize: 18)))),
    ];
    if (message != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        Text(
          message!,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: message!.startsWith('أحسنت') ? AppColors.teal : AppColors.terracotta),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

class _ActivityProgress extends StatelessWidget {
  final int current;
  final int total;
  final double value;
  const _ActivityProgress({required this.current, required this.total, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('خطوة التعلّم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            Text('$current من $total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.teal.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
        ),
      ],
    );
  }
}
