import 'package:flutter/material.dart';

import '../core/profile/learner_profile.dart';
import '../core/theme/app_colors.dart';
import 'achievements_screen.dart';
import 'units_map_screen.dart';

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
                'اختر عمر المتعلم لنضبط حجم العناصر وطريقة عرض التحديات.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedAge,
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
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
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
            FilledButton(
              onPressed: () => Navigator.pop(context, selectedAge),
              child: const Text('حفظ'),
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
      appBar: AppBar(
        title: const Text('أرقامي'),
        actions: [
          if (age != null)
            IconButton(
              tooltip: 'تغيير العمر',
              onPressed: () => _showAgePicker(required: false),
              icon: const Icon(Icons.person_rounded),
            ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: AppColors.cardBackground,
        indicatorColor: AppColors.goldLight.withAlpha(90),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.teal),
            label: 'الرحلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon:
                Icon(Icons.emoji_events_rounded, color: AppColors.gold),
            label: 'الإنجازات',
          ),
        ],
      ),
    );
  }
}
