import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/tour_keys.dart';
import '../../data/learning/modules_data.dart';
import '../../services/game_progress_service.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/animated_google_background.dart';
import '../../widgets/shareable_achievement_card.dart';
import 'certificate_progression_screen.dart';

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
    final xp = gameProgress.unifiedXP;

    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Text(
                      'Your Achievements',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                        fontSize: 28,
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
                      KeyedSubtree(
                        key: TourKeys.rewardsDashboardKey,
                        child: _buildDashboard(
                          isDark,
                          levelTitle,
                          xp,
                          overallProgress,
                          completedTopics,
                          totalTopics,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Weekly Challenge ──
                      _buildWeeklyChallenge(context, isDark, coreProgress),

                      const SizedBox(height: 16),

                      // ── Streak Freeze ──
                      _buildStreakFreeze(context, isDark, coreProgress, gameProgress),

                      const SizedBox(height: 24),

                      // ── Certificate Progress ──
                      _buildCertificateProgress(context, isDark),

                      const SizedBox(height: 32),

                      _sectionTitleWithIcon(PhosphorIcons.trophy(), 'EARNED BADGES', isDark),
                      const SizedBox(height: 16),

                      KeyedSubtree(
                        key: TourKeys.rewardsBadgesKey,
                        child: _buildBadgeGrid(coreProgress, isDark),
                      ),

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
          Icon(PhosphorIcons.lightning(), size: 48, color: AppTheme.accentCyan),
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

  Widget _sectionTitleWithIcon(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentCyan),
        const SizedBox(width: 8),
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
                        subtitle: 'I unlocked this badge in AR Explorer!',
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasFreeze) ...[
                      Icon(PhosphorIcons.snowflake(), size: 14, color: AppTheme.accentCyan),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      hasFreeze ? 'Streak Freeze Active' : 'Streak Freeze',
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: 13,
                        color: hasFreeze ? AppTheme.accentCyan : AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                  ],
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
                            content: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.snowflake(), color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                const Text('Streak Freeze activated! (-50 XP)'),
                              ],
                            ),
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

  Widget _buildCertificateProgress(BuildContext context, bool isDark) {
    return Consumer2<ProgressService, GameProgressService>(
      builder: (context, progress, gameProgress, _) {
        final certData = computeProgress(progress, gameProgress);
        final tier = certData.highestUnlocked;
        final tierInfo = tier != null
            ? kTiers.firstWhere((t) => t.tier == tier)
            : null;
        final hasTier = tierInfo != null;
        final accentColor = hasTier ? tierInfo.color : AppTheme.accentCyan;
        
        // Next tier progress
        final nextTierIdx = hasTier
            ? kTiers.indexOf(tierInfo) + 1
            : 0;
        final hasNextTier = nextTierIdx < kTiers.length;
        final nextProgress = hasNextTier
            ? certData.tierProgress(kTiers[nextTierIdx].tier)
            : 1.0;

        return GestureDetector(
          onTap: () {
            context.read<SoundService>().playTap();
            Navigator.pushNamed(context, '/certificate');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  hasTier ? PhosphorIcons.trophy() : PhosphorIcons.target(),
                  size: 40,
                  color: accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  hasTier ? '${tierInfo.name} Certificate Earned' : 'Earn Your First Certificate',
                  style: AppTheme.headingSmall.copyWith(
                    color: hasTier ? accentColor : AppTheme.textPrimaryC(isDark),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasTier
                      ? tierInfo.description
                      : 'Complete 3 modules to unlock your Bronze certificate.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryC(isDark),
                    height: 1.4,
                  ),
                ),
                if (hasNextTier) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Next: ${kTiers[nextTierIdx].name}',
                        style: TextStyle(
                          color: kTiers[nextTierIdx].color.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(nextProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: kTiers[nextTierIdx].color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: nextProgress,
                      backgroundColor: kTiers[nextTierIdx].color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(kTiers[nextTierIdx].color),
                      minHeight: 5,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'VIEW ALL TIERS',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: 11,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.05, end: 0);
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
