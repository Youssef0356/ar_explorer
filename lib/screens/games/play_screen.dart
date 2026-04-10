import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../services/sound_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/animated_google_background.dart';
import '../../core/tour_keys.dart';

// Game screens
import 'xr_builder/inspector_game_map_screen.dart';
import 'systems_engineer/coding_game_map_screen.dart';
import 'pipeline_challenge/game_map_screen.dart'; // Pipeline Challenge
import 'ar_debugger/ar_debugger_game.dart';

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
                        
                        KeyedSubtree(
                          key: TourKeys.playGameXRBuilderKey,
                          child: _buildGameCard(
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
                        ),
                        const SizedBox(height: 16),
                        
                        KeyedSubtree(
                          key: TourKeys.playGameSystemsEngineerKey,
                          child: _buildGameCard(
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
                        ),
                        const SizedBox(height: 16),
                        
                        KeyedSubtree(
                          key: TourKeys.playGamePipelineChallengeKey,
                          child: _buildGameCard(
                            context: context,
                            isDark: isDark,
                            sound: soundService,
                            title: 'Pipeline Challenge',
                            subtitle: 'Connect logic pipelines in a spatial mapping puzzle.',
                            icon: Icons.account_tree_rounded,
                            color: AppTheme.accentPurple,
                            onTap: () => _showPipelineExplanation(context, isDark),
                            delay: 300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        KeyedSubtree(
                          key: TourKeys.playGameARDebuggerKey,
                          child: _buildGameCard(
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
    return KeyedSubtree(
      key: TourKeys.playHeaderKey,
      child: Padding(
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

  void _showPipelineExplanation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glassCard(isDark).copyWith(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : Colors.white,
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3), width: 1.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.architecture_rounded, color: AppTheme.accentPurple, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'AR Architect Simulator',
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textPrimaryC(isDark),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'The Pipeline Challenge is essentially an "AR Architect" simulator.',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textPrimaryC(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'In real-world development, Augmented Reality works like a factory assembly line (a Pipeline). To make a virtual character appear on your table, the phone has to do things in a very specific order:',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
                  ),
                  const SizedBox(height: 16),
                  _buildStepItem(isDark, '1', 'See', 'Camera Stream'),
                  _buildStepItem(isDark, '2', 'Track', 'SLAM Tracking'),
                  _buildStepItem(isDark, '3', 'Detect', 'Plane Detection'),
                  _buildStepItem(isDark, '4', 'Calculate', 'Hit Test'),
                  _buildStepItem(isDark, '5', 'Render', '3D Renderer'),
                  const SizedBox(height: 16),
                  Text(
                    'If you try to "Detect a Plane" before the "Camera" is even on, the code crashes. This game teaches you the System Architecture of AR—helping you understand how sensors and algorithms work together as a sequence.',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By solving these, you\'re learning how to "think" like an AR Engine.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const GameMapScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('START CHALLENGE'),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
        );
      },
    );
  }

  Widget _buildStepItem(bool isDark, String num, String action, String component) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: TextStyle(color: AppTheme.accentPurple, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: action,
                    style: TextStyle(
                      color: AppTheme.textPrimaryC(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: '($component)',
                    style: TextStyle(
                      color: AppTheme.textSecondaryC(isDark).withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
