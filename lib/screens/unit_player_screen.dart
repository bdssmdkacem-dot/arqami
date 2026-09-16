import 'package:flutter/material.dart';

import '../core/ads/ad_service.dart';
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

/// شاشة عامة تشغّل أي وحدة من الـ13، بالاعتماد على بيانات
/// [UnitModel.activities]. تتنقل تلقائياً بين الأنشطة وتسجّل التقدم.
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

  ActivityConfig get _currentActivity =>
      widget.unit.activities[_activityIndex];

  void _onWrongAttempt() {
    _wrongAttemptsInUnit++;
    AudioService.instance.playTryAgain();
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
    final stars = _wrongAttemptsInUnit == 0
        ? 3
        : (_wrongAttemptsInUnit <= 2 ? 2 : 1);

    await ProgressTracker.instance.markUnitComplete(
      widget.unit.id,
      stars: stars,
    );
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
      appBar: AppBar(
        title: Text(widget.unit.titleAr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Responsive.constrainedCenter(
            child: !widget.unit.isImplemented
                ? _buildPendingView()
                : (_unitCompleted
                    ? _buildCompletionView()
                    : _buildActivity(_currentActivity)),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingView() {
    final pending = widget.unit.activities
        .whereType<PendingActivityConfig>()
        .first;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction_rounded,
              size: 56, color: AppColors.gold),
          const SizedBox(height: 16),
          const Text(
            'هاد الوحدة قيد الإنشاء',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            pending.reasonAr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('رجوع'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    final progress = ProgressTracker.instance.getUnitProgress(widget.unit.id);
    final isFinalUnit = widget.unit.order == UnitsData.units.length;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_rounded,
                  size: 64, color: AppColors.gold),
              const SizedBox(height: 12),
              const Text(
                'أحسنت!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'أكملت هذه الوحدة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final filled = i < progress.stars;
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.gold,
                    size: 40,
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (isFinalUnit) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CertificateScreen(),
                        ),
                      );
                    },
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
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('رجوع لخريطة الوحدات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivity(ActivityConfig config) {
    final totalActivities = widget.unit.activities.length;
    final currentNumber = _activityIndex + 1;
    final progressValue = currentNumber / totalActivities;

    Widget activity;

    if (config is TraceActivityConfig) {
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
          .map(
            (spec) => MatchPair(
              id: spec.id,
              leftContent: _buildMatchContent(spec.leftType, spec.leftValue),
              rightContent:
                  _buildMatchContent(spec.rightType, spec.rightValue),
            ),
          )
          .toList();

      activity = MatchingWidget(
        key: ValueKey('matching_$_activityIndex'),
        pairs: pairs,
        onCorrectMatch: (_) => AudioService.instance.playCorrect(),
        onWrongAttempt: _onWrongAttempt,
        onAllMatched: () {
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else if (config is ComparisonActivityConfig) {
      activity = ComparisonWidget(
        key: ValueKey('comparison_$_activityIndex'),
        leftCount: config.leftCount,
        rightCount: config.rightCount,
        question: config.question == ComparisonQuestionType.more
            ? ComparisonQuestion.more
            : ComparisonQuestion.fewer,
        onWrongAttempt: _onWrongAttempt,
        onComplete: () {
          AudioService.instance.playCorrect();
          Future.delayed(const Duration(milliseconds: 700), _onActivityComplete);
        },
      );
    } else if (config is SceneExploreActivityConfig) {
      if (_lastAnnouncedSceneIndex != _activityIndex) {
        _lastAnnouncedSceneIndex = _activityIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AudioService.instance.playNumber(config.targetDigit);
        });
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
        _ActivityProgress(
          current: currentNumber,
          total: totalActivities,
          value: progressValue,
        ),
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

class _ActivityProgress extends StatelessWidget {
  final int current;
  final int total;
  final double value;

  const _ActivityProgress({
    required this.current,
    required this.total,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'خطوة التعلّم',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$current من $total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
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
