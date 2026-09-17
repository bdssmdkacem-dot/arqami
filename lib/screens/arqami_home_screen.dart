import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
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
