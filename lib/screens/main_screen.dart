import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';

import '../services/theme_service.dart';
import '../services/sound_service.dart';
import 'home_screen.dart';
import 'roadmap_screen.dart';

import 'achievements_screen.dart';
import 'coding_game_map_screen.dart'; // Code challenges (fill-in-blank)
import 'inspector_game_map_screen.dart'; // XR Builder (Inspector game)

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),             // 0 — HOME
    const RoadmapScreen(),          // 1 — ROADMAP
    const CodingGameMapScreen(),    // 2 — CODE (fill-in-blank coding game)
    const InspectorGameMapScreen(), // 3 — XR BUILDER (Inspector game)
    const AchievementsScreen(),     // 4 — REWARDS
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
          color: AppTheme.cardC(isDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
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
              selectedItemColor: AppTheme.accentCyan,
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
                // ── CODE tab — fill-in-blank coding challenges ──────────────
                BottomNavigationBarItem(
                  icon: Icon(Icons.code_rounded),
                  activeIcon: Icon(Icons.code_rounded),
                  label: 'CODE',
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
