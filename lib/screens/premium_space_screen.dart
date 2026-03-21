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
import 'interview_screen.dart';
import 'certificate_progression_screen.dart';
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
                    Text('What\'s included', style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark))),
                    const SizedBox(height: 16),
                    _buildPremiumFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'AR Scene Debugger',
                      subtitle: 'Diagnose & Fix AR Issues',
                      icon: Icons.bug_report_rounded,
                      color: AppTheme.accentCyan,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ARDebuggerMapScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'XR Builder',
                      subtitle: 'Build AR Scenes Visually',
                      icon: Icons.architecture_rounded,
                      color: AppTheme.accentPurple,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InspectorGameMapScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'Mock Interview',
                      subtitle: 'Unlimited Practice Trials',
                      icon: Icons.timer_rounded,
                      color: AppTheme.accentAmber,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InterviewScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'Advanced Quiz Analytics',
                      subtitle: 'Visualize Performance',
                      icon: Icons.insights_rounded,
                      color: AppTheme.accentAmber,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizAnalyticsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumFeatureCard(
                      context: context,
                      isDark: isDark,
                      soundService: soundService,
                      isPremium: isPremium,
                      title: 'Professional Certificates',
                      subtitle: 'Tiered AR Credentials',
                      icon: Icons.workspace_premium_rounded,
                      color: AppTheme.accentCyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const CertificateProgressionScreen()),
                        );
                      },
                    ),

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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, SoundService soundService) {
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
                  'Exclusive tools to master AR.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.workspace_premium_rounded,
            color: AppTheme.accentAmber,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeTeaser(BuildContext context, bool isDark, SoundService soundService) {
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
              AppTheme.accentAmber.withValues(alpha: 0.2),
              AppTheme.accentAmber.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accentAmber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: AppTheme.accentAmber,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Premium Space',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.textPrimaryC(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get instant access to advanced analytics, PDF exports, and the coding game.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryC(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().shimmer(
      duration: const Duration(seconds: 3),
      color: AppTheme.accentAmber.withValues(alpha: 0.3),
    );
  }

  Widget _buildPremiumActiveBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.2),
             AppTheme.successGreen.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Active',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thank you for subscribing! Enjoy your exclusive tools.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryC(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(seconds: 1));
  }

  Widget _buildPremiumFeatureCard({
    required BuildContext context,
    required bool isDark,
    required SoundService soundService,
    required bool isPremium,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        soundService.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard(isDark).copyWith(
          border: Border.all(
            color: isPremium ? color.withValues(alpha: 0.3) : AppTheme.textMutedC(isDark).withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPremium ? color.withValues(alpha: 0.15) : AppTheme.textMutedC(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isPremium ? color : AppTheme.textMutedC(isDark),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTheme.headingSmall.copyWith(
                            color: isPremium ? AppTheme.textPrimaryC(isDark) : AppTheme.textMutedC(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: AppTheme.accentAmber,
                        ),
                      ],
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: color,
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: isPremium ? AppTheme.textSecondaryC(isDark) : AppTheme.textMutedC(isDark).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaywallScreen(),
      ),
    );
  }
}
