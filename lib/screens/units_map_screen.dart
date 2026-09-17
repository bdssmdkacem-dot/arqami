import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio/audio_service.dart';
import '../core/progress/progress_tracker.dart';
import '../core/progress/unit_progress.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
import '../models/stage_reward.dart';
import '../models/unit_model.dart';
import '../models/units_data.dart';
import '../widgets/game/journey_world_decoration.dart';
import '../widgets/shared/banner_ad_widget.dart';
import 'certificate_screen.dart';
import 'unit_player_screen.dart';

class UnitsMapScreen extends StatefulWidget {
  const UnitsMapScreen({super.key});

  @override
  State<UnitsMapScreen> createState() => _UnitsMapScreenState();
}

class _UnitsMapScreenState extends State<UnitsMapScreen> {
  final List<UnitModel> _units = UnitsData.units;
  String? _newlyUnlockedUnitId;
  int? _rewardCelebrationStage;

  Future<void> _openUnit(UnitModel unit) async {
    final before = ProgressTracker.instance.getCompletedUnitIds().toSet();

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitPlayerScreen(unit: unit)),
    );

    if (!mounted) return;

    final after = ProgressTracker.instance.getCompletedUnitIds().toSet();
    final newlyCompleted = after.difference(before);
    UnitModel? newlyUnlocked;

    for (final id in newlyCompleted) {
      final index = _units.indexWhere((u) => u.id == id);
      if (index >= 0 && index + 1 < _units.length) {
        newlyUnlocked = _units[index + 1];
        break;
      }
    }

    final id = newlyUnlocked?.id;
    setState(() => _newlyUnlockedUnitId = id);

    if (newlyUnlocked != null) {
      await AudioService.instance.playUnlock();
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 2200), () {
        if (mounted && _newlyUnlockedUnitId == id) {
          setState(() => _newlyUnlockedUnitId = null);
        }
      });
    }
  }

  Future<void> _claimReward(StageRewardDefinition reward) async {
    final claimed = await ProgressTracker.instance.claimStageReward(reward.stage);
    if (!mounted) return;

    if (!claimed) {
      setState(() {});
      return;
    }

    setState(() => _rewardCelebrationStage = reward.stage);
    await AudioService.instance.playUnlock();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => _RewardCelebration(reward: reward),
    );

    if (mounted) {
      setState(() => _rewardCelebrationStage = null);
    }
  }

  void _showReward(StageRewardDefinition reward) {
    final status = ProgressTracker.instance.getStageRewardStatus(reward.stage);

    if (status == StageRewardStatus.available) {
      _claimReward(reward);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(reward.titleAr),
        content: Text(
          status == StageRewardStatus.claimed
              ? 'تم جمع هذه المكافأة وربطها بإنجاز المرحلة.'
              : 'أكمل جميع وحدات المرحلة ${reward.stage} أولاً لتفتح المكافأة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        ProgressTracker.instance.getCompletedUnitIds().length;
    final progress = ProgressTracker.instance.getOverallProgress(_units.length);
    final nextUnit = ProgressTracker.instance.getNextUnit();
    final allCompleted = completedCount == _units.length;
    final mapItems = _buildMapItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أرقامي'),
        centerTitle: true,
        actions: [
          if (allCompleted)
            IconButton(
              tooltip: 'شهادتك',
              icon: Image.asset(
                'assets/game/rewards/trophy.png',
                width: 25,
                height: 25,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CertificateScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Responsive.constrainedCenter(
              child: _JourneyHeader(
                progress: progress,
                completedCount: completedCount,
                totalCount: _units.length,
                nextUnit: nextUnit,
                onContinue:
                    nextUnit == null ? null : () => _openUnit(nextUnit),
                claimedRewards:
                    ProgressTracker.instance.getClaimedStageRewards().length,
                totalRewards: StageRewards.all.length,
              ),
            ),
            Expanded(
              child: Responsive.constrainedCenter(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const JourneyWorldDecoration(),
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                      itemCount: mapItems.length,
                      itemBuilder: (context, index) {
                        final item = mapItems[index];
                        if (item is StageRewardDefinition) {
                          final status = ProgressTracker.instance
                              .getStageRewardStatus(item.stage);
                          return _StageRewardNode(
                            reward: item,
                            status: status,
                            celebration:
                                _rewardCelebrationStage == item.stage,
                            onTap: () => _showReward(item),
                          );
                        }

                        final unit = item as UnitModel;
                        final unitIndex = _units.indexOf(unit);
                        final unlocked =
                            ProgressTracker.instance.isUnitUnlocked(unit.id);
                        final unitProgress =
                            ProgressTracker.instance.getUnitProgress(unit.id);
                        final previousCompleted = unitIndex == 0 ||
                            ProgressTracker.instance
                                .getUnitProgress(_units[unitIndex - 1].id)
                                .completed;

                        return _MapLevel(
                          key: ValueKey('map_level_${unit.id}'),
                          unit: unit,
                          progress: unitProgress,
                          unlocked: unlocked,
                          previousCompleted: previousCompleted,
                          highlight: unit.id == _newlyUnlockedUnitId,
                          onTap: unlocked ? () => _openUnit(unit) : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  List<Object> _buildMapItems() {
    final items = <Object>[];
    for (final unit in _units) {
      items.add(unit);
      if (_isStageEnd(unit.order)) {
        items.add(StageRewards.forStage(_stageNumberForOrder(unit.order)));
      }
    }
    return items;
  }
}

class _JourneyHeader extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final UnitModel? nextUnit;
  final VoidCallback? onContinue;
  final int claimedRewards;
  final int totalRewards;

  const _JourneyHeader({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.nextUnit,
    required this.onContinue,
    required this.claimedRewards,
    required this.totalRewards,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/game/rewards/trophy.png',
                  width: 44,
                  height: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رحلة الأرقام',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text('$completedCount من $totalCount وحدات مكتملة'),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: AppColors.teal.withValues(alpha: .10),
                valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 18,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 5),
                Text('مكافآت المراحل: $claimedRewards / $totalRewards'),
              ],
            ),
            if (nextUnit != null) ...[
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('تابع: ${nextUnit!.titleAr}'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'أكملت رحلة أرقامي كاملة 🎉',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapLevel extends StatelessWidget {
  final UnitModel unit;
  final UnitProgress progress;
  final bool unlocked;
  final bool previousCompleted;
  final bool highlight;
  final VoidCallback? onTap;

  const _MapLevel({
    super.key,
    required this.unit,
    required this.progress,
    required this.unlocked,
    required this.previousCompleted,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRight = unit.order.isEven;
    final locked = !unlocked;
    final current = unlocked && !progress.completed;
    final nodeColor = locked
        ? AppColors.locked
        : progress.completed
            ? AppColors.completed
            : AppColors.teal;

    return SizedBox(
      height: 126,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(
                fromRight: unit.order > 1 && !isRight,
                toRight: isRight,
                active: previousCompleted || progress.completed,
              ),
            ),
          ),
          Align(
            alignment: Alignment(isRight ? .78 : -.78, 0),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: highlight ? .86 : 1, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: SizedBox(
                  width: math.min(MediaQuery.sizeOf(context).width * .72, 310),
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(9, 8, 14, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: highlight || current
                            ? AppColors.gold
                            : nodeColor.withValues(alpha: .28),
                        width: highlight ? 3 : current ? 2.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: highlight ? 22 : current ? 12 : 6,
                          spreadRadius: highlight ? 3 : 0,
                          offset: const Offset(0, 3),
                          color: highlight
                              ? AppColors.gold.withValues(alpha: .34)
                              : Colors.black.withValues(
                                  alpha: current ? .12 : .06,
                                ),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Opacity(
                              opacity: locked ? .32 : .90,
                              child: Image.asset(
                                'assets/game/ui/kenney_button.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _CircularNode(
                              color: nodeColor,
                              completed: progress.completed,
                              locked: locked,
                              current: current,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'المستوى ${unit.order}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: nodeColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    unit.titleAr,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: locked
                                              ? AppColors.locked
                                              : null,
                                        ),
                                  ),
                                  if (progress.completed) ...[
                                    const SizedBox(height: 2),
                                    _StarsRow(stars: progress.stars),
                                  ] else if (current) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'ابدأ الآن',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (current || highlight)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment(isRight ? .42 : -.42, -.62),
                  child: _CompanionMarker(
                    key: ValueKey('companion_${unit.id}'),
                    arriving: highlight,
                  ),
                ),
              ),
            ),
          if (highlight)
            const Positioned.fill(
              child: IgnorePointer(child: _UnlockBurst()),
            ),
          if (_isStageStart(unit.order))
            Positioned(
              top: 4,
              left: isRight ? null : 10,
              right: isRight ? 10 : null,
              child: _StageChip(label: _stageFor(unit.order)),
            ),
        ],
      ),
    );
  }
}

class _StageRewardNode extends StatelessWidget {
  final StageRewardDefinition reward;
  final StageRewardStatus status;
  final bool celebration;
  final VoidCallback onTap;

  const _StageRewardNode({
    required this.reward,
    required this.status,
    required this.celebration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = status == StageRewardStatus.available;
    final claimed = status == StageRewardStatus.claimed;
    final color = claimed
        ? AppColors.completed
        : available
            ? AppColors.gold
            : AppColors.locked;

    return SizedBox(
      height: 112,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: celebration ? .75 : available ? .92 : 1, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: math.min(MediaQuery.sizeOf(context).width * .78, 330),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: color.withValues(alpha: claimed || available ? 1 : .35),
                  width: claimed || available ? 2.5 : 1.5,
                ),
                boxShadow: [
                  if (available)
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: .30),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 62,
                    height: 62,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: .9),
                    ),
                    child: Image.asset(
                      claimed
                          ? 'assets/game/rewards/checkmark.png'
                          : available
                              ? 'assets/game/rewards/trophy.png'
                              : 'assets/game/rewards/lock.png',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مكافأة المرحلة ${reward.stage}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: available ? AppColors.gold : null,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reward.titleAr,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          claimed
                              ? 'تم الجمع · الإنجاز مفتوح'
                              : available
                                  ? 'اضغط للجمع ✨'
                                  : 'أكمل المرحلة لفتحها',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardCelebration extends StatelessWidget {
  final StageRewardDefinition reward;

  const _RewardCelebration({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .3, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Image.asset(
                'assets/game/rewards/trophy.png',
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أحسنت! 🎉',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              reward.titleAr,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'جمعت المكافأة وفتحت إنجاز هذه المرحلة.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.all(3),
                  child: Image.asset(
                    'assets/game/rewards/star.png',
                    width: 30,
                    height: 30,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('متابعة الرحلة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionMarker extends StatelessWidget {
  final bool arriving;

  const _CompanionMarker({super.key, required this.arriving});

  static const _asset =
      'assets/game/characters/roguelikeChar_transparent.png';

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: arriving ? 0.0 : 0.82, end: 1.0),
      duration: Duration(milliseconds: arriving ? 900 : 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, (1 - value) * 24),
        child: Transform.scale(
          scale: .82 + value * .18,
          child: child,
        ),
      ),
      child: Container(
        width: 62,
        height: 62,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .88),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: .28),
              blurRadius: 12,
              spreadRadius: 2,
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
              _asset,
              width: 918 * 3.2,
              height: 203 * 3.2,
              fit: BoxFit.none,
              filterQuality: FilterQuality.none,
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockBurst extends StatelessWidget {
  const _UnlockBurst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .15, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: .45 + value * .9,
              child: Opacity(
                opacity: (1 - value) * .75,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: value * math.pi * .12,
              child: Opacity(
                opacity: 1 - value,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 48,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircularNode extends StatelessWidget {
  final Color color;
  final bool completed;
  final bool locked;
  final bool current;

  const _CircularNode({
    required this.color,
    required this.completed,
    required this.locked,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: current ? 58 : 52,
      height: current ? 58 : 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: locked ? .72 : 1),
        shape: BoxShape.circle,
        border: Border.all(
          color: current ? AppColors.gold : Colors.white.withValues(alpha: .85),
          width: current ? 3 : 2,
        ),
        boxShadow: [
          if (current)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: .30),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          locked
              ? 'assets/game/rewards/lock.png'
              : completed
                  ? 'assets/game/rewards/checkmark.png'
                  : 'assets/game/rewards/trophy.png',
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String label;

  const _StageChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;

  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 2),
          child: Opacity(
            opacity: index < stars ? 1 : .25,
            child: Image.asset(
              'assets/game/rewards/star.png',
              width: 17,
              height: 17,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final bool fromRight;
  final bool toRight;
  final bool active;

  const _PathPainter({
    required this.fromRight,
    required this.toRight,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = fromRight ? size.width * .78 : size.width * .22;
    final endX = toRight ? size.width * .78 : size.width * .22;
    final paint = Paint()
      ..color = active
          ? AppColors.teal.withValues(alpha: .34)
          : AppColors.locked.withValues(alpha: .24)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(startX, 0)
      ..cubicTo(
        startX,
        size.height * .30,
        endX,
        size.height * .70,
        endX,
        size.height,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.fromRight != fromRight ||
        oldDelegate.toRight != toRight ||
        oldDelegate.active != active;
  }
}

bool _isStageEnd(int order) =>
    const {13, 20, 30, 38, 44, 46, 52}.contains(order);

bool _isStageStart(int order) =>
    const {14, 21, 31, 39, 45, 47}.contains(order);

String _stageFor(int order) {
  if (order <= 13) return 'المرحلة 1 · الأعداد';
  if (order <= 20) return 'المرحلة 2 · العشرات';
  if (order <= 30) return 'المرحلة 3 · المئات والآلاف';
  if (order <= 38) return 'المرحلة 4 · الجمع والطرح';
  if (order <= 44) return 'المرحلة 5 · الضرب';
  if (order <= 46) return 'المرحلة 6 · القسمة';
  return 'المرحلة 7 · الكسور والعشري والجبر';
}

int _stageNumberForOrder(int order) {
  if (order <= 13) return 1;
  if (order <= 20) return 2;
  if (order <= 30) return 3;
  if (order <= 38) return 4;
  if (order <= 44) return 5;
  if (order <= 46) return 6;
  return 7;
}
