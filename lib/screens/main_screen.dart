import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';

import '../services/theme_service.dart';
import '../services/sound_service.dart';
import 'home_screen.dart';
import 'roadmap_screen.dart';

import 'achievements_screen.dart';
// Code challenges moved to Premium Space
// import 'coding_game_map_screen.dart';
import 'inspector_game_map_screen.dart'; // XR Builder (Inspector game)

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),             // 0 — HOME
    const RoadmapScreen(),          // 1 — ROADMAP
    const InspectorGameMapScreen(), // 2 — XR BUILDER (Inspector game)
    const AchievementsScreen(),     // 3 — REWARDS
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.primaryDark.withValues(alpha: 0.95) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.accentPurple.withValues(alpha: 0.3) : AppTheme.dividerColorLight,
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppTheme.accentPurple.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                soundService.playTap();
                setState(() => _currentIndex = index);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.accentPurple,
              unselectedItemColor: AppTheme.textMutedC(isDark),
              selectedLabelStyle: AppTheme.labelMedium.copyWith(
                  fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  AppTheme.labelMedium.copyWith(fontSize: 10),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'HOME',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_rounded),
                  activeIcon: Icon(Icons.map_rounded),
                  label: 'ROADMAP',
                ),

                // ── XR BUILDER tab — Inspector simulator game ───────────────
                BottomNavigationBarItem(
                  icon: Icon(Icons.architecture_rounded),
                  activeIcon: Icon(Icons.architecture_rounded),
                  label: 'XR BUILD',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_rounded),
                  activeIcon: Icon(Icons.emoji_events_rounded),
                  label: 'REWARDS',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
