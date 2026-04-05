import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../core/tour_keys.dart';

import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/game_progress_service.dart';
import 'home_screen.dart';
import 'roadmap_screen.dart';

import 'achievements_screen.dart';
import 'play_screen.dart';
import '../services/navigation_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationService>().setTab(widget.initialIndex);
      _checkAndStartTour();
    });
  }

  void _checkAndStartTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHomeTour = prefs.getBool('has_seen_showcase_tour_home') ?? false;
    if (!hasSeenHomeTour) {
      await prefs.setBool('has_seen_showcase_tour_home', true);
      // Small delay so all keys are rendered and attached
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        TourKeys.startHomeTour(context);
      }
    }
  }

  void _checkTabTour(int index) async {
    final prefs = await SharedPreferences.getInstance();
    if (index == 2) { // PLAY
      final hasSeenPlayTour = prefs.getBool('has_seen_showcase_tour_play') ?? false;
      if (!hasSeenPlayTour) {
        await prefs.setBool('has_seen_showcase_tour_play', true);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) TourKeys.startPlayTour(context);
      }
    } else if (index == 3) { // REWARDS
      final hasSeenRewardsTour = prefs.getBool('has_seen_showcase_tour_rewards') ?? false;
      if (!hasSeenRewardsTour) {
        await prefs.setBool('has_seen_showcase_tour_rewards', true);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) TourKeys.startRewardsTour(context);
      }
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoadmapScreen(),
    const PlayScreen(),
    const AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;
    final isNeon = themeService.isNeonMode;
    final soundService = context.read<SoundService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProgressService>().isPremium = isPremium;
    });

    final navigationService = context.watch<NavigationService>();
    final currentIndex = navigationService.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isNeon
              ? const Color(0xFF030303)
              : (isDark ? AppTheme.primaryDark.withValues(alpha: 0.95) : Colors.white),
          border: Border(
            top: BorderSide(
              color: isNeon
                  ? AppTheme.neonPurple.withValues(alpha: 0.5)
                  : (isDark
                      ? AppTheme.accentPurple.withValues(alpha: 0.3)
                      : AppTheme.dividerColorLight),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isNeon
                  ? AppTheme.neonPurple.withValues(alpha: 0.15)
                  : (isDark
                      ? AppTheme.accentPurple.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                soundService.playTap();
                navigationService.setTab(index);
                _checkTabTour(index);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor:
                  isNeon ? AppTheme.neonPurple : AppTheme.accentPurple,
              unselectedItemColor:
                  isNeon ? Colors.white30 : AppTheme.textMutedC(isDark),
              selectedLabelStyle:
                  AppTheme.labelMedium.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTheme.labelMedium.copyWith(fontSize: 10),
              items: [
                BottomNavigationBarItem(
                  icon: KeyedSubtree(
                    key: TourKeys.homeTabKey,
                    child: const Icon(Icons.home_rounded),
                  ),
                  activeIcon: KeyedSubtree(
                    key: TourKeys.homeTabKey,
                    child: const Icon(Icons.home_rounded),
                  ),
                  label: 'HOME',
                ),
                BottomNavigationBarItem(
                  icon: KeyedSubtree(
                    key: TourKeys.roadmapTabKey,
                    child: const Icon(Icons.map_rounded),
                  ),
                  activeIcon: KeyedSubtree(
                    key: TourKeys.roadmapTabKey,
                    child: const Icon(Icons.map_rounded),
                  ),
                  label: 'ROADMAP',
                ),
                BottomNavigationBarItem(
                  icon: KeyedSubtree(
                    key: TourKeys.playTabKey,
                    child: const Icon(Icons.gamepad_rounded),
                  ),
                  activeIcon: KeyedSubtree(
                    key: TourKeys.playTabKey,
                    child: const Icon(Icons.gamepad_rounded),
                  ),
                  label: 'PLAY',
                ),
                BottomNavigationBarItem(
                  icon: KeyedSubtree(
                    key: TourKeys.rewardsTabKey,
                    child: const Icon(Icons.emoji_events_rounded),
                  ),
                  activeIcon: KeyedSubtree(
                    key: TourKeys.rewardsTabKey,
                    child: const Icon(Icons.emoji_events_rounded),
                  ),
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
