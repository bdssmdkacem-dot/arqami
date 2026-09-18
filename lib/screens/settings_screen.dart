import 'package:flutter/material.dart';

import '../core/profile/learner_profile.dart';
import '../core/theme/game_theme.dart';
import '../core/theme/game_shapes.dart';
import '../core/audio/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _changeAge() async {
    var selectedAge = LearnerProfile.age ?? 6;
    final age = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('عمر المتعلم'),
          content: DropdownButtonFormField<int>(
            initialValue: selectedAge,
            decoration: const InputDecoration(labelText: 'العمر'),
            items: [
              for (var value = 3; value <= 16; value++)
                DropdownMenuItem(value: value, child: Text('$value سنة')),
            ],
            onChanged: (value) {
              if (value != null) {
                setDialogState(() => selectedAge = value);
              }
            },
          ),
          actions: [
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

    if (age == null) return;
    await LearnerProfile.setAge(age);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final age = LearnerProfile.age;

    return Scaffold(
      backgroundColor: GameTheme.sky,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            decoration: GameShapes.softPanel(accent: GameTheme.ocean),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              leading: Container(
                width: 48,
                height: 48,
                decoration: GameShapes.rewardBadge(color: GameTheme.sunshine),
                child: const Icon(Icons.face_rounded, color: GameTheme.ink),
              ),
              title: const Text('عمر المتعلم', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(
                age == null ? 'لم يتم تحديد العمر' : '$age سنة • ${LearnerProfile.band.labelAr}',
              ),
              trailing: const Icon(Icons.edit_rounded),
              onTap: _changeAge,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: GameShapes.softPanel(accent: GameTheme.mint),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              leading: Container(
                width: 48,
                height: 48,
                decoration: GameShapes.rewardBadge(color: GameTheme.mint),
                child: Icon(
                  AudioService.instance.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: GameTheme.ink,
                ),
              ),
              title: const Text('أصوات اللعبة', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('المؤثرات ونطق التعليمات والتغذية الراجعة'),
              trailing: Switch(
                value: !AudioService.instance.isMuted,
                onChanged: (enabled) {
                  AudioService.instance.setMuted(!enabled);
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: GameShapes.softPanel(accent: GameTheme.violet),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_rounded, color: GameTheme.violet, size: 30),
                SizedBox(height: 8),
                Text(
                  'العمر والصوت جزء من تجربة أرقامي',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  'العمر يضبط مستوى الأنشطة، والصوت يساعد الطفل على فهم النجاح والمحاولة التالية.',
                  textAlign: TextAlign.center,
                  style: GameTheme.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
