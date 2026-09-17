import 'package:flutter/material.dart';

import '../core/progress/progress_tracker.dart';
import '../core/progress/unit_progress.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
import '../models/unit_model.dart';
import '../models/units_data.dart';
import '../widgets/shared/banner_ad_widget.dart';
import 'certificate_screen.dart';
import 'unit_player_screen.dart';

/// الشاشة الرئيسية: خريطة الوحدات الـ52 بترتيب تصاعدي.
/// كل وحدة مقفلة حتى تكتمل الوحدة التي قبلها.
class UnitsMapScreen extends StatefulWidget {
  const UnitsMapScreen({super.key});

  @override
  State<UnitsMapScreen> createState() => _UnitsMapScreenState();
}

class _UnitsMapScreenState extends State<UnitsMapScreen> {
  final List<UnitModel> _units = UnitsData.units;

  bool _isUnitUnlocked(int indexInList) {
    if (indexInList == 0) return true;
    final previousUnit = _units[indexInList - 1];
    return ProgressTracker.instance.getUnitProgress(previousUnit.id).completed;
  }

  Future<void> _openUnit(UnitModel unit) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitPlayerScreen(unit: unit)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        ProgressTracker.instance.getOverallProgress(_units.length);
    final completedCount =
        ProgressTracker.instance.getCompletedUnitIds().length;
    final allCompleted = completedCount == _units.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أرقامي'),
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
              child: _OverallProgressCard(
                progress: overallProgress,
                completedCount: completedCount,
                totalCount: _units.length,
              ),
            ),
            Expanded(
              child: Responsive.constrainedCenter(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: _units.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final unit = _units[index];
                    final unlocked = _isUnitUnlocked(index);
                    final progress =
                        ProgressTracker.instance.getUnitProgress(unit.id);
                    return _UnitCard(
                      unit: unit,
                      unlocked: unlocked,
                      progress: progress,
                      onTap: unlocked ? () => _openUnit(unit) : null,
                    );
                  },
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

class _OverallProgressCard extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;

  const _OverallProgressCard({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رحلة الأرقام',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount من $totalCount وحدات مكتملة',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.teal,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: const Color(0x1A00695C),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final UnitModel unit;
  final bool unlocked;
  final UnitProgress progress;
  final VoidCallback? onTap;

  const _UnitCard({
    required this.unit,
    required this.unlocked,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = !unit.isImplemented;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.55,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _OrderBadge(
                  order: unit.order,
                  completed: progress.completed,
                  locked: !unlocked,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.titleAr, style: titleStyle),
                      if (isPending) ...[
                        const SizedBox(height: 4),
                        Text(
                          'قيد الإنشاء',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (unlocked && progress.completed)
                  _StarsRow(stars: progress.stars)
                else if (!unlocked)
                  const Icon(Icons.lock_rounded, color: AppColors.locked),
                if (unlocked && !progress.completed)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 6),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.teal,
                      size: 26,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int order;
  final bool completed;
  final bool locked;

  const _OrderBadge({
    required this.order,
    required this.completed,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = locked
        ? AppColors.locked
        : (completed ? AppColors.completed : AppColors.inProgress);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 25)
          : Text(
              '$order',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.gold,
          size: 20,
        );
      }),
    );
  }
}
