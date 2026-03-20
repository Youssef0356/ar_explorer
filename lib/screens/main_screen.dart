import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../data/game_data.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import 'home_screen.dart';
import 'roadmap_screen.dart';
import 'bookmarks_screen.dart';
import 'achievements_screen.dart';
import 'paywall_screen.dart';
import 'game_map_screen.dart';
import 'code_map_screen.dart';           // ← Coding challenge game (fill-in-blank)
import 'inspector_game_map_screen.dart'; // ← XR Builder (Inspector game)
import '../widgets/animated_google_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ── Screen list — index must match nav items below exactly ──────────────────
  final List<Widget> _screens = [
    const HomeScreen(),           // 0 — HOME
    const RoadmapScreen(),        // 1 — ROADMAP
    const _EngineerEntryScreen(), // 2 — ENGINEER  (pipeline drag-drop game)
    const CodeMapScreen(),        // 3 — CODE       (fill-in-blank coding game)
    const InspectorGameMapScreen(), // 4 — XR BUILDER (Inspector game)
    const BookmarksScreen(),      // 5 — SAVED
    const AchievementsScreen(),   // 6 — REWARDS
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.terminal_rounded),
                  activeIcon: Icon(Icons.terminal_rounded),
                  label: 'ENGINEER',
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
                  icon: Icon(Icons.bookmark_rounded),
                  activeIcon: Icon(Icons.bookmark_rounded),
                  label: 'SAVED',
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

// ── Engineer Entry Screen (Premium Gate) ──────────────────────────────────────
class _EngineerEntryScreen extends StatelessWidget {
  const _EngineerEntryScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldC(isDark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            if (context.watch<ThemeService>().enableAnimations)
              const Positioned.fill(child: AnimatedGoogleBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Text(
                      'AR Systems',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                    Text(
                      'Engineer',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.accentCyan,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chain. Deploy.',
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.accentCyan,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag-and-drop AR pipeline nodes in the correct order to pass each level. '
                      'Master 5 zones from fundamentals to advanced production systems.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryC(isDark),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Zone Preview Cards ──
                    Text(
                      'GAME ZONES',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textMutedC(isDark),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildZonePreviewCards(isDark),

                    const SizedBox(height: 28),

                    // ── CTA Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isPremium) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const GameMapScreen()),
                            );
                          } else {
                            final hasFreeLevels = arGameZones
                                .any((z) => z.levels.any((l) => l.isFree));
                            if (hasFreeLevels) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const GameMapScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PaywallScreen()),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isPremium
                              ? Icons.play_arrow_rounded
                              : Icons.workspace_premium_rounded,
                          size: 22,
                        ),
                        label: Text(isPremium
                            ? 'LAUNCH ENGINEER GAME'
                            : 'TRY FREE LEVELS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPremium
                              ? AppTheme.accentCyan
                              : AppTheme.accentAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: AppTheme.buttonText
                              .copyWith(letterSpacing: 1),
                        ),
                      ),
                    ),

                    if (!isPremium) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'First 2 levels free — Unlock all 5 zones with Premium',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textMutedC(isDark),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildZonePreviewCards(bool isDark) {
    final zones = [
      (
        name: 'Zone 1 — Fundamentals',
        description: 'Camera, IMU, Plane Detection basics',
        color: const Color(0xFF00E5FF),
        icon: Icons.flag_rounded,
        levels: '3 levels',
      ),
      (
        name: 'Zone 2 — Tracking',
        description: 'SLAM, ARKit, 6DOF tracking chains',
        color: const Color(0xFF2979FF),
        icon: Icons.track_changes_rounded,
        levels: '3 levels',
      ),
      (
        name: 'Zone 3 — Platforms',
        description: 'Unity AR Foundation, Vuforia, OpenXR',
        color: const Color(0xFFD1C4E9),
        icon: Icons.devices_rounded,
        levels: '3 levels',
      ),
      (
        name: 'Zone 4 — Advanced',
        description: 'OpenXR standards, Occlusion depth',
        color: const Color(0xFFFFC107),
        icon: Icons.auto_awesome_rounded,
        levels: '3 levels',
      ),
      (
        name: 'Zone 5 — Master',
        description: 'Light estimation, Spatial anchors',
        color: const Color(0xFFFF4081),
        icon: Icons.workspace_premium_rounded,
        levels: '3 levels',
      ),
    ];

    return zones.asMap().entries.map((entry) {
      final zone = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardC(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: zone.color.withValues(alpha: isDark ? 0.2 : 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: zone.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(zone.icon, color: zone.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textPrimaryC(isDark),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zone.description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMutedC(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: zone.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                zone.levels,
                style: AppTheme.labelMedium.copyWith(
                  color: zone.color,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
