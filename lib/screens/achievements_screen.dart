import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../services/game_progress_service.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/subscription_service.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/shareable_achievement_card.dart';
import '../widgets/animated_google_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final coreProgress = context.watch<ProgressService>();
    final gameProgress = context.watch<GameProgressService>();

    final totalTopics = allModules.fold<int>(
      0,
      (sum, m) => sum + m.totalTopics,
    );
    final completedTopics = allModules.fold<int>(0, (sum, m) {
      return sum +
          m.topics
              .where((t) => coreProgress.isTopicCompleted('${m.id}_${t.id}'))
              .length;
    });
    final overallProgress = totalTopics > 0
        ? completedTopics / totalTopics
        : 0.0;
    final levelTitle = AppTheme.getLevelTitle(overallProgress);
    final totalQuizScore =
        coreProgress.achievements.where((a) => a.startsWith('quiz_ace_')).length *
        50;
    final xp = AppTheme.getXP(completedTopics, totalQuizScore);

    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: AppTheme.textPrimaryC(isDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Your Achievements',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // ── Level & XP Dashboard ──
                      _buildDashboard(
                        isDark,
                        levelTitle,
                        xp,
                        overallProgress,
                        completedTopics,
                        totalTopics,
                      ),

                      const SizedBox(height: 24),

                      // ── Weekly Challenge ──
                      _buildWeeklyChallenge(context, isDark, coreProgress),

                      const SizedBox(height: 16),

                      // ── Streak Freeze ──
                      _buildStreakFreeze(context, isDark, coreProgress, gameProgress),

                      const SizedBox(height: 24),

                      // ── Sharable Certificates ──
                      _buildCertificates(context, isDark),

                      const SizedBox(height: 24),

                      // ── Premium Aesthetics ──
                      _buildPremiumAesthetics(context, isDark),

                      const SizedBox(height: 32),

                      _sectionTitle('🏆 EARNED BADGES', isDark),
                      const SizedBox(height: 16),

                      _buildBadgeGrid(coreProgress, isDark),

                      const SizedBox(height: 40),
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

  Widget _buildDashboard(
    bool isDark,
    String levelTitle,
    int xp,
    double overallProgress,
    int completed,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(isDark),
      child: Column(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            levelTitle,
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.accentCyan,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$xp TOTAL XP',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.accentAmber,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Overall Progress',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textMutedC(isDark),
                ),
              ),
              const Spacer(),
              Text(
                '${(overallProgress * 100).toInt()}%',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accentCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentCyan,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed of $total topics explored',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textMutedC(isDark),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.accentCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTheme.labelMedium.copyWith(
            letterSpacing: 1.5,
            color: AppTheme.textMutedC(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGrid(ProgressService coreProgress, bool isDark) {
    final badges = [
      _BadgeData(
        id: 'first_steps',
        icon: Icons.rocket_launch_rounded,
        label: 'First Steps',
        color: AppTheme.accentCyan,
        condition: (p) => p.isTopicCompleted(
          '${allModules[0].id}_${allModules[0].topics[0].id}',
        ),
      ),
      _BadgeData(
        id: 'ar_explorer',
        icon: Icons.explore_rounded,
        label: 'AR Explorer',
        color: AppTheme.accentBlue,
        condition: (p) => p.achievements.isNotEmpty,
      ),
      _BadgeData(
        id: 'quiz_master',
        icon: Icons.psychology_rounded,
        label: 'Quiz Ace',
        color: AppTheme.accentAmber,
        condition: (p) => p.achievements.any((a) => a.startsWith('quiz_ace_')),
      ),
      _BadgeData(
        id: 'steady_progress',
        icon: Icons.trending_up_rounded,
        label: 'Consistent',
        color: AppTheme.accentPink,
        condition: (p) =>
            p.achievements.where((a) => a.startsWith('quiz_ace_')).length >= 2,
      ),
      _BadgeData(
        id: 'ar_architect',
        icon: Icons.architecture_rounded,
        label: 'Architect',
        color: AppTheme.accentPurple,
        condition: (p) =>
            p.moduleProgress(allModules[1].id, allModules[1].totalTopics) ==
            1.0,
      ),
      _BadgeData(
        id: 'legendary',
        icon: Icons.auto_awesome_rounded,
        label: 'Legendary',
        color: AppTheme.accentOrange,
        condition: (p) =>
            p.moduleProgress(
              allModules[allModules.length - 1].id,
              allModules[allModules.length - 1].totalTopics,
            ) ==
            1.0,
      ),
      _BadgeData(
        id: 'premium_member',
        icon: Icons.workspace_premium_rounded,
        label: 'Premium',
        color: AppTheme.accentAmber,
        condition: (p) => p.isPremium,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isEarned = badge.condition(coreProgress);

        return GestureDetector(
          onTap: isEarned
              ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ShareableAchievementCard(
                        title: badge.label,
                        subtitle: 'I unlocked this badge in AR Explorer! ✨',
                        icon: badge.icon,
                        color: badge.color,
                        score: '',
                        isDark: isDark,
                      ),
                    ),
                  );
                }
              : null,
          child: AchievementBadge(
            icon: badge.icon,
            label: badge.label,
            color: badge.color,
            earned: isEarned,
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .scale(delay: Duration(milliseconds: 100 * index));
      },
    );
  }

  Widget _buildWeeklyChallenge(BuildContext context, bool isDark, ProgressService progress) {
    final count = progress.weeklyTopicsCount;
    final goal = ProgressService.weeklyTopicsGoal;
    final done = progress.weeklyChallengeDone;
    final pct = (count / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.accentAmber.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done ? Icons.verified_rounded : Icons.calendar_view_week_rounded,
                color: done ? AppTheme.successGreen : AppTheme.accentAmber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  done ? '✅ Weekly Challenge Complete!' : '📅 Weekly Challenge',
                  style: AppTheme.headingSmall.copyWith(
                    color: done ? AppTheme.successGreen : AppTheme.textPrimaryC(isDark),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$count / $goal topics',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accentAmber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'You earned +50 XP bonus this week. Come back Monday for the next challenge!'
                : 'Complete $goal topics this week to earn +50 XP bonus.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                done ? AppTheme.successGreen : AppTheme.accentAmber,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildStreakFreeze(BuildContext context, bool isDark, ProgressService coreProgress, GameProgressService gameProgress) {
    final hasFreeze = coreProgress.hasStreakFreeze;
    final xp = gameProgress.unifiedXP;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFreeze
              ? AppTheme.accentCyan.withValues(alpha: 0.4)
              : AppTheme.dividerC(isDark),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasFreeze
                  ? AppTheme.accentCyan.withValues(alpha: 0.15)
                  : AppTheme.dividerC(isDark).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.ac_unit_rounded,
              color: hasFreeze ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasFreeze ? '🧊 Streak Freeze Active' : 'Streak Freeze',
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: 13,
                    color: hasFreeze ? AppTheme.accentCyan : AppTheme.textPrimaryC(isDark),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasFreeze
                      ? 'Your streak is protected for one missed day.'
                      : 'Spend 50 XP to protect your streak for one day.',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                ),
              ],
            ),
          ),
          if (!hasFreeze)
            GestureDetector(
              onTap: xp >= 50
                  ? () async {
                      final ok = await coreProgress.purchaseStreakFreeze();
                      if (context.mounted && ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🧊 Streak Freeze activated! (-50 XP)'),
                            backgroundColor: AppTheme.accentCyan,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not enough XP!')),
                        );
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: xp >= 50
                      ? AppTheme.accentCyan.withValues(alpha: 0.15)
                      : AppTheme.dividerC(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: xp >= 50
                        ? AppTheme.accentCyan.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  '50 XP',
                  style: AppTheme.labelMedium.copyWith(
                    color: xp >= 50 ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppTheme.accentCyan, size: 24),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildCertificates(BuildContext context, bool isDark) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    
    if (!isPremium) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard(isDark),
        child: Column(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppTheme.accentAmber, size: 40),
            const SizedBox(height: 12),
            Text('Premium Certificates', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
            const SizedBox(height: 8),
            Text('Get official certificates for your AR journey.', 
                 style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                 textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/paywall'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentAmber),
              child: const Text('Unlock with PRO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('🎓 YOUR CERTIFICATES', isDark),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCertificateCard('AR Pipeline Engineer', 'Pipeline Challenge', isDark),
              const SizedBox(width: 16),
              _buildCertificateCard('XR Platform Developer', 'Coding Games', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateCard(String title, String subtitle, bool isDark) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.accentCyan.withValues(alpha: 0.1), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.school, color: AppTheme.accentCyan, size: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                child: const Icon(Icons.verified, color: Colors.black, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppTheme.accentCyan.withValues(alpha: 0.7), fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preparing your certificate for sharing...'))
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.5)),
                foregroundColor: AppTheme.accentCyan,
              ),
              child: const Text('SHARE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAesthetics(BuildContext context, bool isDark) {
    final subService = context.watch<SubscriptionService>();
    if (!subService.isPremium) return const SizedBox.shrink();

    final themeService = context.watch<ThemeService>();
    final isNeon = themeService.isNeonMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNeon ? const Color(0xFF0D0D12) : AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNeon ? AppTheme.neonPurple.withValues(alpha: 0.5) : AppTheme.accentPurple.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          if (isNeon) BoxShadow(color: AppTheme.neonPurple.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 10),
              Text(
                'PREMIUM AESTHETICS',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.accentAmber, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark/Neon Theme',
                      style: AppTheme.headingSmall.copyWith(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deep blacks and vibrant glowing accents.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isNeon,
                activeColor: AppTheme.neonPurple,
                onChanged: (val) => themeService.setNeonMode(val),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _BadgeData {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final bool Function(ProgressService) condition;

  _BadgeData({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.condition,
  });
}
