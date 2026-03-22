import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../widgets/animated_google_background.dart';
import 'paywall_screen.dart';
import 'quiz_analytics_screen.dart';
import 'inspector_game_map_screen.dart';
import 'ar_debugger_game.dart';

class PremiumSpaceScreen extends StatelessWidget {
  const PremiumSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, soundService),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (!isPremium) ...[
                      _buildUpgradeTeaser(context, isDark, soundService),
                      const SizedBox(height: 24),
                    ] else ...[
                      _buildPremiumActiveBanner(context, isDark),
                      const SizedBox(height: 24),
                    ],

                    Text('Premium Tools',
                        style: AppTheme.headingMedium
                            .copyWith(color: AppTheme.textPrimaryC(isDark))),
                    const SizedBox(height: 6),
                    Text(
                      'Exclusive features to accelerate your AR career',
                      style: AppTheme.bodySmall
                          .copyWith(color: AppTheme.textMutedC(isDark)),
                    ),
                    const SizedBox(height: 16),

                    // ── AR Scene Debugger (free trial: level 1 only) ──
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'AR Scene Debugger',
                      subtitle: 'Diagnose & fix broken AR apps',
                      description: isPremium
                          ? 'Full access to all debugging scenarios.'
                          : 'First level free. Premium unlocks all scenarios.',
                      icon: Icons.bug_report_rounded,
                      color: AppTheme.accentPurple,
                      badge: isPremium ? null : 'Try Free',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ARDebuggerMapScreen()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── XR Builder (free trial: first level of zone 1) ──
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'XR Builder',
                      subtitle: 'Build AR Inspector setups like a pro',
                      description: isPremium
                          ? 'All 5 zones unlocked.'
                          : 'First level free. Premium unlocks all zones.',
                      icon: Icons.architecture_rounded,
                      color: AppTheme.accentPurple,
                      badge: isPremium ? null : 'Try Free',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InspectorGameMapScreen()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Advanced Analytics ──
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'Advanced Quiz Analytics',
                      subtitle: 'Identify & crush your weak spots',
                      description: 'Heatmaps, score history, and weak area tracking across all modules.',
                      icon: Icons.insights_rounded,
                      color: AppTheme.accentAmber,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QuizAnalyticsScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'More exclusive features coming soon.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textMutedC(isDark),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, SoundService soundService) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              soundService.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassCard(isDark),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimaryC(isDark),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Space',
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
                Text(
                  'Advanced tools for serious AR developers.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCyan,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.workspace_premium_rounded,
            color: AppTheme.accentAmber,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeTeaser(
      BuildContext context, bool isDark, SoundService soundService) {
    return GestureDetector(
      onTap: () {
        soundService.playTap();
        _showPaywall(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentAmber.withOpacity(0.18),
              AppTheme.accentAmber.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accentAmber.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_open_rounded,
                  color: AppTheme.accentAmber, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock Premium',
                      style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.textPrimaryC(isDark))),
                  const SizedBox(height: 4),
                  Text(
                    'One-time payment. Lifetime access.',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryC(isDark)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.accentAmber, size: 22),
          ],
        ),
      ),
    ).animate().shimmer(
          duration: const Duration(seconds: 3),
          color: AppTheme.accentAmber.withOpacity(0.3),
        );
  }

  Widget _buildPremiumActiveBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withOpacity(0.18),
            AppTheme.successGreen.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppTheme.successGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium Active',
                    style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.textPrimaryC(isDark))),
                const SizedBox(height: 4),
                Text('All features unlocked. Thank you!',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryC(isDark))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(seconds: 1));
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required SoundService soundService,
    required bool isPremium,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        soundService.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.glassCard(isDark).copyWith(
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: color.withOpacity(0.3)),
                          ),
                          child: Text(badge,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)),
                        )
                      else if (!isPremium)
                        Icon(Icons.lock_outline_rounded,
                            color: AppTheme.accentAmber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  Text(description,
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryC(isDark),
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }
}
