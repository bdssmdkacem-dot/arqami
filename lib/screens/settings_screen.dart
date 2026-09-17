import 'package:flutter/material.dart';

import '../core/profile/learner_profile.dart';
import '../core/theme/game_theme.dart';

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
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: GameTheme.sunshine,
                child: Icon(Icons.face_rounded),
              ),
              title: const Text(
                'عمر المتعلم',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                age == null
                    ? 'لم يتم تحديد العمر'
                    : '${age} سنة • ${LearnerProfile.band.labelAr}',
              ),
              trailing: const Icon(Icons.edit_rounded),
              onTap: _changeAge,
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'العمر يساعد أرقامي على ضبط مستوى الأنشطة والأسئلة والتحديات المناسبة للمتعلم.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
