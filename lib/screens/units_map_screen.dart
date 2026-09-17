import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio/audio_service.dart';
import '../core/progress/progress_tracker.dart';
import '../core/progress/unit_progress.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
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

  bool _isUnitUnlocked(int index) =>
      ProgressTracker.instance.isUnitUnlocked(_units[index].id);

  Future<void> _openUnit(UnitModel unit) async {
    final completedBefore = ProgressTracker.instance
        .getCompletedUnitIds()
        .toSet();

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitPlayerScreen(unit: unit)),
    );

    if (!mounted) return;

    final completedAfter =
        ProgressTracker.instance.getCompletedUnitIds().toSet();
    final newlyCompleted = completedAfter.difference(completedBefore);
    UnitModel? newlyUnlocked;

    for (final completedId in newlyCompleted) {
      final index = _units.indexWhere((candidate) => candidate.id == completedId);
      if (index >= 0 && index + 1 < _units.length) {
        newlyUnlocked = _units[index + 1];
        break;
      }
    }

    setState(() {
      _newlyUnlockedUnitId = newlyUnlocked?.id;
    });

    if (newlyUnlocked != null) {
      await AudioService.instance.playUnlock();
      Future<void>.delayed(const Duration(milliseconds: 2200), () {
        if (mounted && _newlyUnlockedUnitId == newlyUnlocked!.id) {
          setState(() => _newlyUnlockedUnitId = null);
        }
      });
    }
  }

  void _openNextUnit() {
    final next = ProgressTracker.instance.getNextUnit();
    if (next != null) _openUnit(next);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        ProgressTracker.instance.getCompletedUnitIds().length;
    final progress =
        ProgressTracker.instance.getOverallProgress(_units.length);
    final nextUnit = ProgressTracker.instance.getNextUnit();
    final allCompleted = completedCount == _units.length;

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
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CertificateScreen()),
              ),
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
                onContinue: nextUnit == null ? null : _openNextUnit,
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
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        final unit = _units[index];
                        final unlocked = _isUnitUnlocked(index);
                        final unitProgress =
                            ProgressTracker.instance.getUnitProgress(unit.id);
                        final previousCompleted = index == 0 ||
                            ProgressTracker.instance
                                .getUnitProgress(_units[index - 1].id)
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
}

class _JourneyHeader extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final UnitModel? nextUnit;
  final VoidCallback? onContinue;

  const _JourneyHeader({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.nextUnit,
    required this.onContinue,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completedCount من $totalCount مراحل مكتملة',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
            const SizedBox(height: 11),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: AppColors.teal.withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              ),
            ),
            if (nextUnit != null) ...[
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('تابع: ${nextUnit!.titleAr}'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 9),
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

  bool get _completed => progress.completed;
  bool get _current => unlocked && !_completed;
  bool get _locked => !unlocked;

  @override
  Widget build(BuildContext context) {
    final isRight = unit.order.isEven;
    return SizedBox(
      height: 126,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(
                fromRight: unit.order > 1 && !isRight,
                toRight: isRight,
                active: previousCompleted || _completed,
              ),
            ),
          ),
          Align(
            alignment: Alignment(isRight ? 0.78 : -0.78, 0),
            child: Semantics(
              button: unlocked,
              label: 'المستوى ${unit.order}: ${unit.titleAr}',
              child: _LevelNode(
                unit: unit,
                progress: progress,
                unlocked: unlocked,
                current: _current,
                locked: _locked,
                highlight: highlight,
                onTap: onTap,
              ),
            ),
          ),
          if (highlight)
            Positioned.fill(
              child: IgnorePointer(
                child: _UnlockBurst(),
              ),
            ),
          if (unit.order == 1 || _isStageStart(unit.order))
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

class _LevelNode extends StatelessWidget {
  final UnitModel unit;
  final UnitProgress progress;
  final bool unlocked;
  final bool current;
  final bool locked;
  final bool highlight;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.unit,
    required this.progress,
    required this.unlocked,
    required this.current,
    required this.locked,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = locked
        ? AppColors.locked
        : progress.completed
            ? AppColors.completed
            : AppColors.teal;

    final width = math.min(MediaQuery.sizeOf(context).width * 0.72, 310.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: highlight ? 0.86 : 1, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minWidth: 170, maxWidth: 250),
            padding: const EdgeInsetsDirectional.fromSTEB(9, 8, 14, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: highlight
                    ? AppColors.gold
                    : current
                        ? AppColors.gold
                        : nodeColor.withValues(alpha: 0.28),
                width: highlight ? 3 : (current ? 2.5 : 1),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: highlight ? 22 : (current ? 12 : 6),
                  spreadRadius: highlight ? 3 : 0,
                  offset: const Offset(0, 3),
                  color: highlight
                      ? AppColors.gold.withValues(alpha: 0.34)
                      : Colors.black.withValues(alpha: current ? 0.12 : 0.06),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Opacity(
                      opacity: locked ? 0.32 : 0.90,
                      child: Image.asset(
                        'assets/game/ui/kenney_button.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _CircularNode(
                      order: unit.order,
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
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: nodeColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            unit.titleAr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: locked ? AppColors.locked : null,
                                ),
                          ),
                          if (progress.completed) ...[
                            const SizedBox(height: 2),
                            _StarsRow(stars: progress.stars),
                          ] else if (current) ...[
                            const SizedBox(height: 2),
                            Text(
                              'ابدأ الآن',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }
}

class _UnlockBurst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.15, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 0.45 + value * 0.9,
              child: Opacity(
                opacity: (1 - value) * 0.75,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: value * math.pi * 0.12,
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
  final int order;
  final Color color;
  final bool completed;
  final bool locked;
  final bool current;

  const _CircularNode({
    required this.order,
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
        color: color.withValues(alpha: locked ? 0.72 : 1),
        shape: BoxShape.circle,
        border: Border.all(
          color: current ? AppColors.gold : Colors.white.withValues(alpha: 0.85),
          width: current ? 3 : 2,
        ),
        boxShadow: [
          if (current)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.30),
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
          filterQuality: FilterQuality.high,
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
    final startX = fromRight ? size.width * 0.78 : size.width * 0.22;
    final endX = toRight ? size.width * 0.78 : size.width * 0.22;
    final paint = Paint()
      ..color = active
          ? AppColors.teal.withValues(alpha: 0.34)
          : AppColors.locked.withValues(alpha: 0.24)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(startX, 0)
      ..cubicTo(
        startX,
        size.height * 0.30,
        endX,
        size.height * 0.70,
        endX,
        size.height,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.fromRight != fromRight ||
      oldDelegate.toRight != toRight ||
      oldDelegate.active != active;
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
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 2),
          child: Opacity(
            opacity: index < stars ? 1 : 0.25,
            child: Image.asset(
              'assets/game/rewards/star.png',
              width: 17,
              height: 17,
              color: AppColors.gold,
            ),
          ),
        );
      }),
    );
  }
}

String _stageFor(int order) {
  if (order <= 13) return 'المرحلة 1 · الأعداد 0–10';
  if (order <= 20) return 'المرحلة 2 · العشرات';
  if (order <= 30) return 'المرحلة 3 · المئات والآلاف';
  if (order <= 38) return 'المرحلة 4 · الجمع والطرح';
  if (order <= 44) return 'المرحلة 5 · الضرب';
  if (order <= 46) return 'المرحلة 6 · القسمة';
  if (order <= 52) return 'المرحلة 7 · الكسور والعشري والجبر';
  return 'رحلة أرقامي';
}

bool _isStageStart(int order) =>
    const {14, 21, 31, 39, 45, 47}.contains(order);
