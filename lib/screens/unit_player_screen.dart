import 'package:flutter/material.dart';

import '../core/ads/ad_service.dart';
import '../core/assessment/assessment_engine.dart';
import '../core/answer/arithmetic_answer_matcher.dart';
import '../core/audio/audio_service.dart';
import '../core/profile/learner_profile.dart';
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
  AgeBand get _ageBand => LearnerProfile.band;

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

  EdgeInsets get _playerPadding => switch (_ageBand) {
        AgeBand.early => const EdgeInsets.fromLTRB(16, 10, 16, 16),
        AgeBand.primary => const EdgeInsets.fromLTRB(20, 12, 20, 20),
        AgeBand.middle => const EdgeInsets.fromLTRB(24, 12, 24, 20),
        AgeBand.teen => const EdgeInsets.fromLTRB(28, 14, 28, 22),
      };

  double get _titleSize => switch (_ageBand) {
        AgeBand.early => 25,
        AgeBand.primary => 23,
        AgeBand.middle => 21,
        AgeBand.teen => 20,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.unit.titleAr, style: TextStyle(fontSize: _titleSize)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: _playerPadding,
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
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.55, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: const Icon(Icons.celebration_rounded, size: 64, color: AppColors.gold),
      ),
      const SizedBox(height: 12),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) => Opacity(opacity: value, child: child),
        child: Text('أحسنت!', style: TextStyle(fontSize: _ageBand == AgeBand.early ? 30 : 26, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 6),
      const Text('أكملت هذه الوحدة بنجاح', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 18),
      _AnimatedStars(stars: progress.stars),
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
          padding: EdgeInsets.all(_ageBand == AgeBand.early ? 24 : 20),
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

class _AnimatedStars extends StatelessWidget {
  final int stars;
  const _AnimatedStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = index < stars;
            return Transform.scale(
              scale: .75 + (value * .25),
              child: Icon(
                active ? Icons.star_rounded : Icons.star_border_rounded,
                size: 42,
                color: active ? AppColors.gold : AppColors.locked,
              ),
            );
          }),
        );
      },
    );
  }
}
