import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/achievement.dart';

class ProgressCelebration extends StatelessWidget {
  final int xpEarned;
  final int? newLevel;
  final List<AchievementDefinition> achievements;
  final VoidCallback? onContinue;

  const ProgressCelebration({
    super.key,
    required this.xpEarned,
    required this.newLevel,
    required this.achievements,
    this.onContinue,
  });

  bool get _hasLevel => newLevel != null;
  bool get _hasAchievements => achievements.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .35, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Icon(
                _hasLevel
                    ? Icons.bolt_rounded
                    : Icons.workspace_premium_rounded,
                size: 78,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _hasLevel ? 'مستوى جديد! 🎉' : 'إنجاز جديد! 🏆',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            if (_hasLevel) ...[
              const SizedBox(height: 6),
              Text(
                'وصلت إلى المستوى $newLevel',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
            if (_hasAchievements) ...[
              const SizedBox(height: 12),
              ...achievements.take(3).map(
                    (achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(achievement.icon, color: AppColors.gold),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                achievement.titleAr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
            if (xpEarned > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+$xpEarned XP',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onContinue ?? () => Navigator.of(context).pop(),
                child: const Text('متابعة الرحلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
