import 'package:flutter/material.dart';

import '../core/profile/learner_profile.dart';
import '../core/theme/app_colors.dart';
import '../widgets/shared/arqami_brand_mark.dart';
import 'achievements_screen.dart';
import 'units_map_screen.dart';
import 'settings_screen.dart';

class ArqamiHomeScreen extends StatefulWidget {
  const ArqamiHomeScreen({super.key});

  @override
  State<ArqamiHomeScreen> createState() => _ArqamiHomeScreenState();
}

class _ArqamiHomeScreenState extends State<ArqamiHomeScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    UnitsMapScreen(),
    AchievementsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAgeProfile());
  }

  Future<void> _ensureAgeProfile() async {
    if (!mounted || LearnerProfile.isConfigured) return;
    await _showAgePicker(required: true);
  }

  Future<void> _showAgePicker({required bool required}) async {
    int selectedAge = LearnerProfile.age ?? 6;
    final age = await showDialog<int>(
      context: context,
      barrierDismissible: !required,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('لمن نتعلم اليوم؟'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر عمر المتعلم لنضبط الأنشطة والتحديات المناسبة له.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedAge,
                decoration: const InputDecoration(labelText: 'العمر'),
                items: [
                  for (var age = 3; age <= 16; age++)
                    DropdownMenuItem(value: age, child: Text('$age سنة')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedAge = value);
                },
              ),
              const SizedBox(height: 10),
              Text(
                AgeBand.fromAge(selectedAge).labelAr,
                style: const TextStyle(
                  color: AppColors.brandEmerald,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            if (!required)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, selectedAge),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('هيا نبدأ'),
            ),
          ],
        ),
      ),
    );

    if (age != null) {
      await LearnerProfile.setAge(age);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = LearnerProfile.age;

    return Scaffold(
      backgroundColor: AppColors.brandCream,
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArqamiBrandMark(size: 44, compact: true),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('أرقامي'),
                Text(
                  'نتعلم خطوة بخطوة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandEmeraldSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
          if (age != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: InkWell(
                onTap: () => _showAgePicker(required: false),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.brandEmerald.withValues(alpha: .16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.face_rounded,
                        size: 18,
                        color: AppColors.brandEmerald,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$age سنة',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route_rounded),
                label: 'رحلتي',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'تقدمي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
