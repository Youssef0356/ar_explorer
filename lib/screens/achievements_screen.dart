import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/shareable_achievement_card.dart';
import '../widgets/animated_google_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<ProgressService>();

    final totalTopics = allModules.fold<int>(
      0,
      (sum, m) => sum + m.totalTopics,
    );
    final completedTopics = allModules.fold<int>(0, (sum, m) {
      return sum +
          m.topics
              .where((t) => progress.isTopicCompleted('${m.id}_${t.id}'))
              .length;
    });
    final overallProgress = totalTopics > 0
        ? completedTopics / totalTopics
        : 0.0;
    final levelTitle = AppTheme.getLevelTitle(overallProgress);
    final totalQuizScore =
        progress.achievements.where((a) => a.startsWith('quiz_ace_')).length *
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

                      const SizedBox(height: 32),

                      _sectionTitle('🏆 EARNED BADGES', isDark),
                      const SizedBox(height: 16),

                      _buildBadgeGrid(progress, isDark),

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

  Widget _buildBadgeGrid(ProgressService progress, bool isDark) {
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
        final isEarned = badge.condition(progress);

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
