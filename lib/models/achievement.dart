import 'package:flutter/material.dart';

import 'stage_reward.dart';

enum AchievementCategory { progress, stars, stages }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.titleAr,
    required this.descriptionAr,
    required this.category,
    required this.icon,
    required this.target,
    this.stage,
  });

  final String id;
  final String titleAr;
  final String descriptionAr;
  final AchievementCategory category;
  final IconData icon;
  final int target;
  final int? stage;

  bool get isStageAchievement => stage != null;
}

class Achievements {
  Achievements._();

  static final List<AchievementDefinition> all = [
    const AchievementDefinition(
      id: 'first_step',
      titleAr: 'الخطوة الأولى',
      descriptionAr: 'أكمل أول وحدة في أرقامي.',
      category: AchievementCategory.progress,
      icon: Icons.flag_rounded,
      target: 1,
    ),
    const AchievementDefinition(
      id: 'five_units',
      titleAr: 'بداية قوية',
      descriptionAr: 'أكمل 5 وحدات.',
      category: AchievementCategory.progress,
      icon: Icons.directions_run_rounded,
      target: 5,
    ),
    const AchievementDefinition(
      id: 'ten_units',
      titleAr: 'عشر خطوات',
      descriptionAr: 'أكمل 10 وحدات.',
      category: AchievementCategory.progress,
      icon: Icons.format_list_numbered_rounded,
      target: 10,
    ),
    const AchievementDefinition(
      id: 'first_stage',
      titleAr: 'حارس الأعداد',
      descriptionAr: 'أكمل المرحلة الأولى كاملة.',
      category: AchievementCategory.progress,
      icon: Icons.shield_rounded,
      target: 13,
    ),
    const AchievementDefinition(
      id: 'twenty_five_units',
      titleAr: 'ربع الطريق',
      descriptionAr: 'أكمل 25 وحدة.',
      category: AchievementCategory.progress,
      icon: Icons.map_rounded,
      target: 25,
    ),
    const AchievementDefinition(
      id: 'half_curriculum',
      titleAr: 'نصف الطريق',
      descriptionAr: 'أكمل 26 وحدة.',
      category: AchievementCategory.progress,
      icon: Icons.route_rounded,
      target: 26,
    ),
    const AchievementDefinition(
      id: 'all_units',
      titleAr: 'بطل أرقامي',
      descriptionAr: 'أكمل الوحدات الـ52 كلها.',
      category: AchievementCategory.progress,
      icon: Icons.workspace_premium_rounded,
      target: 52,
    ),
    const AchievementDefinition(
      id: 'three_star_unit',
      titleAr: 'إتقان أول',
      descriptionAr: 'احصل على 3 نجوم في وحدة واحدة.',
      category: AchievementCategory.stars,
      icon: Icons.star_rounded,
      target: 1,
    ),
    const AchievementDefinition(
      id: 'ten_stars',
      titleAr: 'جامع النجوم',
      descriptionAr: 'اجمع 10 نجوم.',
      category: AchievementCategory.stars,
      icon: Icons.auto_awesome_rounded,
      target: 10,
    ),
    const AchievementDefinition(
      id: 'thirty_stars',
      titleAr: 'سماء مليئة بالنجوم',
      descriptionAr: 'اجمع 30 نجمة.',
      category: AchievementCategory.stars,
      icon: Icons.stars_rounded,
      target: 30,
    ),
    ...StageRewards.all.map(
      (reward) => AchievementDefinition(
        id: reward.achievementId,
        titleAr: reward.titleAr,
        descriptionAr: 'أكمل المرحلة ${reward.stage} واجمع مكافأتها.',
        category: AchievementCategory.stages,
        icon: reward.stage == StageRewards.all.length
            ? Icons.emoji_events_rounded
            : Icons.military_tech_rounded,
        target: reward.endOrder - reward.startOrder + 1,
        stage: reward.stage,
      ),
    ),
    const AchievementDefinition(
      id: 'all_rewards',
      titleAr: 'جامع الجوائز',
      descriptionAr: 'اجمع مكافآت المراحل السبع كلها.',
      category: AchievementCategory.stages,
      icon: Icons.emoji_events_rounded,
      target: 7,
    ),
  ];

  static AchievementDefinition byId(String id) =>
      all.firstWhere((achievement) => achievement.id == id);
}
