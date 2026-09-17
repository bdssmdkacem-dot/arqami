import 'dart:math' as math;

import 'package:flutter/material.dart';

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

/// خريطة رحلة أرقامي.
///
/// الخريطة تستخدم نفس ترتيب المنهج ونفس ProgressTracker؛ لا توجد حالة
/// منفصلة للخريطة يمكن أن تختلف عن حالة التقدم الحقيقية.
class UnitsMapScreen extends StatefulWidget {
  const UnitsMapScreen({super.key});

  @override
  State<UnitsMapScreen> createState() => _UnitsMapScreenState();
}

class _UnitsMapScreenState extends State<UnitsMapScreen> {
  final List<UnitModel> _units = UnitsData.units;

  bool _isUnitUnlocked(int index) {
    return ProgressTracker.instance.isUnitUnlocked(_units[index].id);
  }

  Future<void> _openUnit(UnitModel unit) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitPlayerScreen(unit: unit)),
    );
    if (mounted) setState(() {});
  }

  void _openNextUnit() {
    final next = ProgressTracker.instance.getNextUnit();
    if (next == null) return;
    _openUnit(next);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        ProgressTracker.instance.getCompletedUnitIds().length;
    final overallProgress =
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
              icon: const Icon(Icons.workspace_premium_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CertificateScreen()),
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
                progress: overallProgress,
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
                        final progress =
                            ProgressTracker.instance.getUnitProgress(unit.id);
                        final previousCompleted = index == 0 ||
                            ProgressTracker.instance
                                .getUnitProgress(_units[index - 1].id)
                                .completed;
                        final nextUnlocked = index + 1 < _units.length &&
                            ProgressTracker.instance.isUnitUnlocked(
                              _units[index + 1].id,
                            );

                        return _MapLevel(
                          unit: unit,
                          progress: progress,
                          unlocked: unlocked,
                          previousCompleted: previousCompleted,
                          nextUnlocked: nextUnlocked,
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppColors.gold,
                    size: 27,
                  ),
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
  final bool nextUnlocked;
  final VoidCallback? onTap;

  const _MapLevel({
    required this.unit,
    required this.progress,
    required this.unlocked,
    required this.previousCompleted,
    required this.nextUnlocked,
    required this.onTap,
  });

  bool get _completed => progress.completed;
  bool get _current => unlocked && !_completed;
  bool get _locked => !unlocked;

  @override
  Widget build(BuildContext context) {
    final isRight = unit.order.isEven;
    final stage = _stageFor(unit.order);

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
                onTap: onTap,
              ),
            ),
          ),
          if (unit.order == 1 || _isStageStart(unit.order))
            Positioned(
              top: 4,
              left: isRight ? null : 10,
              right: isRight ? 10 : null,
              child: _StageChip(label: stage),
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
  final VoidCallback? onTap;

  const _LevelNode({
    required this.unit,
    required this.progress,
    required this.unlocked,
    required this.current,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = locked
        ? AppColors.locked
        : progress.completed
            ? AppColors.completed
            : AppColors.teal;

    return SizedBox(
      width: math.min(MediaQuery.sizeOf(context).width * 0.72, 310),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minWidth: 170, maxWidth: 250),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 14, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(
              alpha: locked ? 0.70 : 1,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: current
                  ? AppColors.gold
                  : nodeColor.withValues(alpha: 0.22),
              width: current ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: current ? 12 : 6,
                offset: const Offset(0, 3),
                color: Colors.black.withValues(
                  alpha: current ? 0.12 : 0.06,
                ),
              ),
            ],
          ),
          child: Row(
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
        ),
      ),
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
        color: color,
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
      child: Icon(
        locked
            ? Icons.lock_rounded
            : completed
                ? Icons.check_rounded
                : Icons.play_arrow_rounded,
        color: Colors.white,
        size: current ? 28 : 24,
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
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.fromRight != fromRight ||
        oldDelegate.toRight != toRight ||
        oldDelegate.active != active;
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
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.gold,
          size: 16,
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

bool _isStageStart(int order) {
  return const {14, 21, 31, 39, 45, 47}.contains(order);
}
