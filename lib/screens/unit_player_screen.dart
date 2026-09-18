import 'package:flutter/material.dart';

import '../core/ads/ad_service.dart';
import '../core/assessment/assessment_engine.dart';
import '../core/answer/arithmetic_answer_matcher.dart';
import '../core/audio/audio_service.dart';
import '../core/profile/age_activity_presentation.dart';
import '../core/progress/progress_tracker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/game_theme.dart';
import '../core/theme/responsive.dart';
import '../models/curriculum_spec.dart';
import '../models/unit_model.dart';
import '../models/units_data.dart';
import 'certificate_screen.dart';
import '../widgets/games/comparison_widget.dart';
import '../widgets/games/drag_count_widget.dart';
import '../widgets/games/matching_widget.dart';
import '../widgets/games/scene_explore_widget.dart';
import '../widgets/games/trace_widget.dart';
import '../widgets/shared/number_display.dart';
import '../widgets/shared/game_celebration.dart';
import '../widgets/shared/quantity_row.dart';

class UnitPlayerScreen extends StatefulWidget {
  final UnitModel unit;
  const UnitPlayerScreen({super.key, required this.unit});

  @override
  State<UnitPlayerScreen> createState() => _UnitPlayerScreenState();
}

enum _AnswerFeedback { correct, wrong }

class _UnitPlayerScreenState extends State<UnitPlayerScreen> {
  int _activityIndex = 0;
  int _wrongAttemptsInUnit = 0;
  bool _unitCompleted = false;
  int? _lastAnnouncedSceneIndex;
  _AnswerFeedback? _feedback;
  int _feedbackToken = 0;

  CurriculumSpec get _spec => CurriculumSpecs.forUnit(widget.unit);
  List<ActivityConfig> get _activities => CurriculumActivityPlanner.plan(widget.unit);
  AgeActivityPresentation get _age => AgeActivityPresentation.current();

  void _showFeedback(_AnswerFeedback feedback) {
    if (!mounted) return;
    final token = ++_feedbackToken;
    setState(() => _feedback = feedback);
    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted || token != _feedbackToken) return;
      setState(() => _feedback = null);
    });
  }

  void _onWrongAttempt() {
    _wrongAttemptsInUnit++;
    _showFeedback(_AnswerFeedback.wrong);
    AudioService.instance.playTryAgain();
  }

  Future<void> _onAssessmentFailed(AssessmentResult result) async {
    await ProgressTracker.instance.recordAttempt(widget.unit.id);
  }

  void _onActivityComplete() {
    if (!mounted) return;
    _showFeedback(_AnswerFeedback.correct);
    if (_activityIndex < _activities.length - 1) {
      Future.delayed(const Duration(milliseconds: 360), () {
        if (!mounted) return;
        setState(() => _activityIndex++);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 360), _completeUnit);
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

  String get _stageLabel {
    if (widget.unit.order <= 13) return 'عالم الأعداد';
    if (widget.unit.order <= 20) return 'عالم العشرات';
    if (widget.unit.order <= 34) return 'عالم المئات والآلاف';
    if (widget.unit.order <= 40) return 'عالم الجمع والطرح';
    if (widget.unit.order <= 46) return 'عالم العمليات';
    if (widget.unit.order <= 50) return 'عالم الكسور والعشريات';
    return 'عالم النسب والجبر';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.sky,
      appBar: AppBar(
        title: Text(widget.unit.titleAr),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'خروج',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: GameTheme.screenPadding,
          child: Responsive.constrainedCenter(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _unitCompleted ? _buildCompletionView() : _buildPlayerView(),
                ),
                if (_feedback != null)
                  Positioned.fill(
                    child: IgnorePointer(child: _AnswerFeedbackOverlay(type: _feedback!)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerView() {
    final total = _activities.length;
    final current = _activityIndex + 1;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      children: [
        _PlayerHud(
          stageLabel: _stageLabel,
          unitNumber: widget.unit.order,
          activityNumber: current,
          activityTotal: total,
          progress: progress,
          ageBandLabel: _age.band.labelAr,
          learningGoal: _spec.learningGoalAr,
          estimatedMinutes: _spec.estimatedMinutes,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: GameTheme.popMotion,
            switchInCurve: GameTheme.playfulCurve,
            switchOutCurve: GameTheme.softCurve,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: GameTheme.softCurve));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_activityIndex),
              child: _buildActivity(_activities[_activityIndex]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView() {
    final progress = ProgressTracker.instance.getUnitProgress(widget.unit.id);
    final isFinalUnit = widget.unit.order == UnitsData.units.length;

    return Stack(
      fit: StackFit.expand,
      children: [
        const GameParticleBurst(active: true, seed: 52, count: 42),
        Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ArqamiCompanion(mood: 'celebrate', size: 86),
                    const SizedBox(height: 4),
                    const Text(
                      'أحسنت! 🎉',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'أنهيت ${widget.unit.titleAr}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هدف التعلم: ${_spec.learningGoalAr}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AnimatedStars(stars: progress.stars),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        progress.stars == 3
                            ? 'ممتاز! أنهيت الوحدة بدون أخطاء.'
                            : progress.stars == 2
                                ? 'رائع! نجمتان — يمكنك إعادة اللعب لتحصل على 3.'
                                : 'تمت الوحدة. أعد المحاولة لتحسن نتيجتك.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.tealSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'التحدي النهائي: ${_spec.finalChallengeAr}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (isFinalUnit) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CertificateScreen()),
                          ),
                          icon: const Icon(Icons.workspace_premium_rounded),
                          label: const Text('احصل على شهادتك'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.map_rounded),
                        label: const Text('العودة إلى الخريطة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivity(ActivityConfig config) {
    Widget activity;

    if (config is LessonActivityConfig) {
      activity = _LessonView(config: config, spec: _spec, onContinue: _onActivityComplete, age: _age);
    } else if (config is MultipleChoiceActivityConfig) {
      activity = _ChoiceQuizView(
        title: widget.unit.titleAr,
        questions: config.questions,
        onWrong: _onWrongAttempt,
        onComplete: _onActivityComplete,
        age: _age,
      );
    } else if (config is AssessmentActivityConfig) {
      activity = _ChoiceQuizView(
        key: ValueKey('assessment_${widget.unit.id}_$_activityIndex'),
        title: config.titleAr,
        questions: config.questions,
        onWrong: _onWrongAttempt,
        onComplete: _onActivityComplete,
        isAssessment: true,
        onAssessmentFailed: _onAssessmentFailed,
        age: _age,
      );
    } else if (config is ReviewActivityConfig) {
      activity = _ChoiceQuizView(
        title: config.titleAr,
        questions: config.questions,
        onWrong: _onWrongAttempt,
        onComplete: _onActivityComplete,
        age: _age,
      );
    } else if (config is ArithmeticActivityConfig) {
      activity = _ArithmeticView(config: config, onWrong: _onWrongAttempt, onComplete: _onActivityComplete, age: _age);
    } else if (config is WordProblemActivityConfig) {
      activity = _ArithmeticView(
        config: ArithmeticActivityConfig(operation: 'مسألة', questions: config.questions),
        onWrong: _onWrongAttempt,
        onComplete: _onActivityComplete,
        age: _age,
      );
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
        question: switch (config.question) {
          ComparisonQuestionType.more => ComparisonQuestion.more,
          ComparisonQuestionType.fewer => ComparisonQuestion.fewer,
          ComparisonQuestionType.equal => ComparisonQuestion.equal,
        },
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

    return activity;
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

class _AnswerFeedbackOverlay extends StatelessWidget {
  final _AnswerFeedback type;

  const _AnswerFeedbackOverlay({required this.type});

  @override
  Widget build(BuildContext context) {
    final correct = type == _AnswerFeedback.correct;
    final color = correct ? AppColors.correct : AppColors.incorrect;
    final soft = correct ? AppColors.correctSoft : AppColors.incorrectSoft;
    final icon = correct ? Icons.check_rounded : Icons.close_rounded;
    final label = correct ? 'أحسنت!' : 'حاول مرة أخرى';

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.65, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 230),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: soft.withValues(alpha: .97),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withValues(alpha: .35), width: 2),
            boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 7), color: Color(0x25000000))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerHud extends StatelessWidget {
  final String stageLabel;
  final int unitNumber;
  final int activityNumber;
  final int activityTotal;
  final double progress;
  final String ageBandLabel;
  final String learningGoal;
  final int estimatedMinutes;

  const _PlayerHud({
    required this.stageLabel,
    required this.unitNumber,
    required this.activityNumber,
    required this.activityTotal,
    required this.progress,
    required this.ageBandLabel,
    required this.learningGoal,
    required this.estimatedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.teal.withValues(alpha: .12)),
        boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x16000000))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ArqamiCompanion(size: 44),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stageLabel, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text('المستوى $unitNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.face_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 5),
                    Text(ageBandLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(learningGoal, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
              const SizedBox(width: 8),
              Text('$estimatedMinutes د', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 9,
                      backgroundColor: AppColors.teal.withValues(alpha: .10),
                      valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$activityNumber/$activityTotal',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedStars extends StatelessWidget {
  final int stars;
  const _AnimatedStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final start = index / 3;
            final local = ((value - start) / (1 - start)).clamp(0.0, 1.0);
            final earned = index < stars;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: earned ? 0.65 + local * 0.35 : 1,
                child: Opacity(
                  opacity: earned ? local : 0.35,
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.gold,
                    size: 42,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _LessonView extends StatelessWidget {
  final LessonActivityConfig config;
  final CurriculumSpec spec;
  final VoidCallback onContinue;
  final AgeActivityPresentation age;

  const _LessonView({required this.config, required this.spec, required this.onContinue, required this.age});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.teal.withValues(alpha: .12)),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.tealSoft),
                child: const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.teal),
              ),
            ),
            const SizedBox(height: 14),
            Text(config.titleAr, textAlign: TextAlign.center, style: TextStyle(fontSize: age.questionTextSize + 2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(16)), child: Text('هدف التعلم: ${spec.learningGoalAr}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            Text(config.explanationAr, textAlign: TextAlign.center, style: TextStyle(fontSize: age.questionTextSize - 1, height: 1.65, color: AppColors.textSecondary)),
            if (config.examplesAr.isNotEmpty) ...[
              const SizedBox(height: 20),
              ...config.examplesAr.map(
                (example) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(color: AppColors.tealSoft, borderRadius: BorderRadius.circular(18)),
                    child: Text(example, textAlign: TextAlign.center, style: TextStyle(fontSize: age.choiceTextSize, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: age.choiceHeight,
              child: ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(age.showExtraGuidance ? 'شاهد المثال ثم ابدأ 🚀' : 'ابدأ التمرين', style: TextStyle(fontSize: age.choiceTextSize - 1, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
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
  final AgeActivityPresentation age;

  const _ChoiceQuizView({
    super.key,
    required this.title,
    required this.questions,
    required this.onWrong,
    required this.onComplete,
    required this.age,
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
  int? selectedIndex;
  final List<int> _selectedAnswers = [];
  static const AssessmentEngine _assessmentEngine = AssessmentEngine();

  ChoiceQuestion get question => widget.questions[index];

  void choose(int selected) {
    if (answered || widget.questions.isEmpty) return;
    selectedIndex = selected;

    if (widget.isAssessment) {
      _chooseAssessment(selected);
      return;
    }

    if (selected == question.correctIndex) {
      setState(() {
        answered = true;
        message = 'أحسنت! إجابة صحيحة ✨';
      });
      AudioService.instance.playCorrect();
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        if (index == widget.questions.length - 1) {
          widget.onComplete();
        } else {
          setState(() {
            index++;
            answered = false;
            message = null;
            selectedIndex = null;
          });
        }
      });
    } else {
      widget.onWrong();
      setState(() => message = question.hintAr ?? (widget.age.showExtraGuidance ? 'جرّب مرة أخرى. انظر إلى السؤال خطوة خطوة 👀' : 'حاول مرة أخرى'));
    }
  }

  void _chooseAssessment(int selected) {
    final isCorrect = selected == question.correctIndex;
    _selectedAnswers.add(selected);
    if (!isCorrect) widget.onWrong();

    setState(() {
      answered = true;
      message = isCorrect ? 'إجابة صحيحة' : 'تم تسجيل الإجابة';
    });
    if (isCorrect) AudioService.instance.playCorrect();

    Future.delayed(const Duration(milliseconds: 650), () async {
      if (!mounted) return;
      if (index == widget.questions.length - 1) {
        final result = _assessmentEngine.evaluate(questions: widget.questions, selectedAnswers: _selectedAnswers);
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
          selectedIndex = null;
          message = 'نتيجتك $percentage٪ — تحتاج إلى 70٪ على الأقل. حاول مرة أخرى.';
        });
        return;
      }
      setState(() {
        index++;
        answered = false;
        message = null;
        selectedIndex = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(22), child: Center(child: Text('لا توجد أسئلة في هذا النشاط.'))));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.teal.withValues(alpha: .12)),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_rounded, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              if (widget.isAssessment) Text('${index + 1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          Text(question.questionAr, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.age.questionTextSize, fontWeight: FontWeight.w900, height: 1.45)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                final selected = selectedIndex == i;
                final correct = answered && i == question.correctIndex;
                final wrongSelected = answered && selected && !correct;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: correct ? AppColors.correct : wrongSelected ? AppColors.incorrect : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: SizedBox(
                      height: widget.age.choiceHeight,
                      child: ElevatedButton(
                        onPressed: answered ? null : () => choose(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: correct ? AppColors.correctSoft : wrongSelected ? AppColors.incorrectSoft : null,
                          foregroundColor: correct ? AppColors.correct : wrongSelected ? AppColors.incorrect : null,
                          elevation: selected ? 3 : 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(question.options[i], textAlign: TextAlign.center, style: TextStyle(fontSize: widget.age.choiceTextSize, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (message != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Container(
                key: ValueKey(message),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: answered ? AppColors.correctSoft : AppColors.terracottaSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(message!, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.age.useShortFeedback ? 14 : 16, fontWeight: FontWeight.w800, color: answered ? AppColors.correct : AppColors.terracotta)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArithmeticView extends StatefulWidget {
  final ArithmeticActivityConfig config;
  final VoidCallback onWrong;
  final VoidCallback onComplete;
  final AgeActivityPresentation age;

  const _ArithmeticView({required this.config, required this.onWrong, required this.onComplete, required this.age});

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

  void _keepWesternDigits(String input) {
    final normalized = ArithmeticAnswerMatcher.normalize(input);
    if (normalized == input) return;
    controller.value = controller.value.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  void submit() {
    if (locked) return;
    final question = widget.config.questions[index];
    if (ArithmeticAnswerMatcher.matches(question, controller.text)) {
      setState(() {
        locked = true;
        message = 'أحسنت! إجابة صحيحة ✨';
      });
      AudioService.instance.playCorrect();
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
      setState(() => message = question.hintAr ?? (widget.age.showExtraGuidance ? 'راجع العملية خطوة خطوة وحاول من جديد 👀' : 'حاول مرة أخرى'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.questions.isEmpty) return const Card(child: Center(child: Text('لا توجد أسئلة في هذا النشاط.')));
    final question = widget.config.questions[index];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gold.withValues(alpha: .22)),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.calculate_rounded, size: 48, color: AppColors.gold),
          const SizedBox(height: 10),
          Text(question.questionAr, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.age.questionTextSize + 2, fontWeight: FontWeight.w900, height: 1.4)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            enabled: !locked,
            keyboardType: question.correctAnswerText != null ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
            onChanged: _keepWesternDigits,
            textAlign: TextAlign.center,
            textDirection: question.correctAnswerText != null ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(fontSize: widget.age.choiceTextSize + 5, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              labelText: 'اكتب الإجابة',
              helperText: widget.age.showExtraGuidance && question.correctAnswerText != null ? 'اكتب العدد ثم «والباقي» ثم الباقي' : null,
              prefixIcon: const Icon(Icons.edit_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: widget.age.choiceHeight,
            child: ElevatedButton.icon(
              onPressed: locked ? null : submit,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('تحقق', style: TextStyle(fontSize: widget.age.choiceTextSize, fontWeight: FontWeight.w900)),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: message!.startsWith('أحسنت') ? AppColors.correctSoft : AppColors.terracottaSoft, borderRadius: BorderRadius.circular(15)),
              child: Text(message!, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: message!.startsWith('أحسنت') ? AppColors.correct : AppColors.terracotta)),
            ),
          ],
        ],
      ),
    );
  }
}