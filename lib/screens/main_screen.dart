import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';

import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/game_progress_service.dart';
import 'home_screen.dart';
import 'roadmap_screen.dart';

import 'achievements_screen.dart';
import 'play_screen.dart'; // Unified Play Tab

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
    const HomeScreen(),         // 0 — HOME
    const RoadmapScreen(),      // 1 — ROADMAP
    const PlayScreen(),         // 2 — PLAY (Unified games tab)
    const AchievementsScreen(), // 3 — REWARDS
  ];

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;
    final isNeon = themeService.isNeonMode;
    final soundService = context.read<SoundService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;
    
    // Sync premium status to progress service for XP multipliers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProgressService>().isPremium = isPremium;
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isNeon ? const Color(0xFF030303) : (isDark ? AppTheme.primaryDark.withValues(alpha: 0.95) : Colors.white),
          border: Border(
            top: BorderSide(
              color: isNeon ? AppTheme.neonPurple.withValues(alpha: 0.5) : (isDark ? AppTheme.accentPurple.withValues(alpha: 0.3) : AppTheme.dividerColorLight),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isNeon ? AppTheme.neonPurple.withValues(alpha: 0.15) : (isDark ? AppTheme.accentPurple.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
              blurRadius: 15,
              offset: const Offset(0, -3),
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
              selectedItemColor: isNeon ? AppTheme.neonPurple : AppTheme.accentPurple,
              unselectedItemColor: isNeon ? Colors.white30 : AppTheme.textMutedC(isDark),
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

                // ── PLAY tab — Unified games hub ───────────────
                BottomNavigationBarItem(
                  icon: Icon(Icons.gamepad_rounded),
                  activeIcon: Icon(Icons.gamepad_rounded),
                  label: 'PLAY',
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
