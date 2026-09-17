import 'package:flutter/material.dart';

import '../core/progress/player_xp.dart';
import '../core/progress/progress_tracker.dart';
import '../core/theme/app_colors.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final tracker = ProgressTracker.instance;
    final unlocked = tracker.getUnlockedAchievementsCount();
    final total = Achievements.all.length;
    final stars = tracker.getTotalStars();
    final stages = tracker.getCompletedStages();
    final rewards = tracker.getClaimedStageRewards().length;
    final xp = PlayerXp.totalXp(tracker);
    final level = PlayerXp.levelFromXp(xp);
    final levelProgress = PlayerXp.levelProgress(xp);
    final visible = Achievements.all.where((achievement) {
      return _filter == null || achievement.category == _filter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإنجازات'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _SummaryCard(
              unlocked: unlocked,
              total: total,
              stars: stars,
              stages: stages,
              rewards: rewards,
              xp: xp,
              level: level,
              levelProgress: levelProgress,
            ),
            const SizedBox(height: 16),
            _FilterBar(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 12),
            ...visible.map((achievement) => _AchievementCard(
                  achievement: achievement,
                  tracker: tracker,
                )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.unlocked,
    required this.total,
    required this.stars,
    required this.stages,
    required this.rewards,
    required this.xp,
    required this.level,
    required this.levelProgress,
  });

  final int unlocked;
  final int total;
  final int stars;
  final int stages;
  final int rewards;
  final int xp;
  final int level;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Card(
      elevation: 0,
      color: AppColors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.gold,
                  child: Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('رحلة أرقامي',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('$unlocked من $total إنجاز',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: AppColors.goldLight, size: 24),
                      const SizedBox(width: 6),
                      Text('المستوى $level',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const Spacer(),
                      Text('$xp XP',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.goldLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${PlayerXp.xpToNextLevel(xp)} XP للمستوى التالي',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(icon: Icons.star_rounded, value: '$stars', label: 'نجمة'),
                _Stat(icon: Icons.map_rounded, value: '$stages/7', label: 'مراحل'),
                _Stat(icon: Icons.card_giftcard_rounded, value: '$rewards/7', label: 'جوائز'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldLight),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final AchievementCategory? selected;
  final ValueChanged<AchievementCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('الكل'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        FilterChip(
          label: const Text('التقدم'),
          selected: selected == AchievementCategory.progress,
          onSelected: (_) => onChanged(AchievementCategory.progress),
        ),
        FilterChip(
          label: const Text('النجوم'),
          selected: selected == AchievementCategory.stars,
          onSelected: (_) => onChanged(AchievementCategory.stars),
        ),
        FilterChip(
          label: const Text('المراحل'),
          selected: selected == AchievementCategory.stages,
          onSelected: (_) => onChanged(AchievementCategory.stages),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.tracker});

  final AchievementDefinition achievement;
  final ProgressTracker tracker;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = tracker.isAchievementUnlocked(achievement.id);
    final value = tracker.getAchievementProgress(achievement.id);
    final ratio = (value / achievement.target).clamp(0.0, 1.0).toDouble();
    final unlockedAt = tracker.getAchievementUnlockedAt(achievement.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isUnlocked ? 2 : 0,
      color: isUnlocked ? AppColors.cardBackground : Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor:
                  isUnlocked ? AppColors.gold : AppColors.locked.withAlpha(60),
              child: Icon(
                isUnlocked ? achievement.icon : Icons.lock_rounded,
                color: isUnlocked ? Colors.white : AppColors.locked,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(achievement.titleAr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      if (isUnlocked)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.completed, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(achievement.descriptionAr,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 9),
                  if (!isUnlocked) ...[
                    LinearProgressIndicator(value: ratio, minHeight: 7),
                    const SizedBox(height: 4),
                    Text('$value / ${achievement.target}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ] else if (unlockedAt != null)
                    Text(
                      'تم فتحه في ${_formatDate(unlockedAt)}',
                      style: const TextStyle(
                          color: AppColors.completed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
