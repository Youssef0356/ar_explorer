import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/sound_service.dart';
import '../services/theme_service.dart';
import '../widgets/animated_google_background.dart';

// Game screens
import 'inspector_game_map_screen.dart';
import 'coding_game_map_screen.dart';
import 'game_map_screen.dart'; // Pipeline Challenge
import 'ar_debugger_game.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();

    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Master AR concepts by solving real engineering challenges. Earn XP and climb the leaderboard!',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryC(isDark),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      
                      _buildGameCard(
                        context: context,
                        isDark: isDark,
                        sound: soundService,
                        title: 'XR Builder',
                        subtitle: 'Build AR Inspector setups like a pro',
                        icon: Icons.architecture_rounded,
                        color: AppTheme.accentCyan,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InspectorGameMapScreen())),
                        delay: 100,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildGameCard(
                        context: context,
                        isDark: isDark,
                        sound: soundService,
                        title: 'Systems Engineer',
                        subtitle: 'Master AR logic & master scripts.',
                        icon: Icons.code_rounded,
                        color: const Color(0xFF00E5FF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CodingGameMapScreen())),
                        delay: 200,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildGameCard(
                        context: context,
                        isDark: isDark,
                        sound: soundService,
                        title: 'Pipeline Challenge',
                        subtitle: 'Connect logic pipelines in a spatial mapping puzzle.',
                        icon: Icons.account_tree_rounded,
                        color: AppTheme.accentPurple,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameMapScreen()));
                        },
                        delay: 300,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildGameCard(
                        context: context,
                        isDark: isDark,
                        sound: soundService,
                        title: 'AR Debugger',
                        subtitle: 'Diagnose & fix broken AR apps',
                        icon: Icons.bug_report_rounded,
                        color: AppTheme.errorRed,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ARDebuggerMapScreen()));
                        },
                        delay: 400,
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gamepad_rounded, color: AppTheme.accentCyan, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AR Sandbox',
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                    fontSize: 26,
                  ),
                ),
                Text(
                  'Engineering Challenges',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.accentCyan,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildGameCard({
    required BuildContext context,
    required bool isDark,
    required SoundService sound,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
    bool isPremiumPromo = false,
  }) {
    return GestureDetector(
      onTap: () {
        sound.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard(isDark).copyWith(
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textPrimaryC(isDark),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (isPremiumPromo)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.accentAmber, size: 10),
                              const SizedBox(width: 4),
                              Text('PRO', style: TextStyle(color: AppTheme.accentAmber, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryC(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.play_circle_fill_rounded, color: color.withValues(alpha: 0.8), size: 32),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.05, end: 0);
  }
}
