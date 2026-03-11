import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../data/ar_keywords_data.dart';
import '../data/modules_data.dart';
import '../data/quiz_data.dart';
import '../models/module_model.dart';
import '../models/topic_model.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/ad_service.dart';
import '../services/progress_service.dart';
import '../services/review_service.dart'; // Added this import
import '../widgets/animated_google_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/daily_keyword_card.dart';
import '../widgets/module_card.dart';
import 'achievements_screen.dart';
import 'bookmarks_screen.dart';
import 'credits_screen.dart';
import 'interview_screen.dart';
import 'module_detail_screen.dart';
import 'practice_screen.dart';
import 'privacy_policy_screen.dart';
import 'roadmap_screen.dart';
import 'topic_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final themeService = context.watch<ThemeService>(); // Get themeService here

    final soundService = context.read<SoundService>();
    
    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top Row: Logo + Action Buttons ──
                      () {
                        final content = Row(
                          children: [
                            // ── Logo ──
                            () {
                              final logo = Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                              if (themeService.enableAnimations) {
                                return logo
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .shimmer(
                                      duration: const Duration(seconds: 4),
                                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                                    );
                              }
                              return logo;
                            }(),
                            const SizedBox(width: 12),
                            // ── Welcome Text ──
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'AR Explorer',
                                      style: AppTheme.headingLarge.copyWith(
                                        color: AppTheme.textPrimaryC(isDark),
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer<ProgressService>(
                                    builder: (context, progress, _) => FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Welcome, ${progress.username}!',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.accentCyan.withValues(alpha: 0.7),
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ── Action Buttons ──
                            _buildIconButton(
                              icon: Icons.calendar_today_rounded,
                              tooltip: 'Daily Keyword',
                              isDark: isDark,
                              onTap: () {
                                soundService.playTap();
                                final keywordEntry = getDailyKeyword();
                                showDialog(
                                  context: context,
                                  builder: (_) => DailyKeywordCard(
                                    keyword: keywordEntry.key,
                                    definition: keywordEntry.value,
                                  ),
                                );
                              },
                            ),
                            _buildIconButton(
                              icon: Icons.settings_rounded,
                              tooltip: 'Parameters',
                              isDark: isDark,
                              onTap: () {
                                soundService.playTap();
                                _showSettingsModal(context, isDark, themeService);
                              },
                            ),
                          ],
                        );
                        if (themeService.enableAnimations) {
                          return content
                              .animate()
                              .fadeIn(duration: const Duration(milliseconds: 500))
                              .slideY(begin: -0.1, end: 0);
                        }
                        return content;
                      }(),

                      const SizedBox(height: 24),

                      // ── XP & Level Card ──
                      _buildLevelCard(context, isDark, themeService.enableAnimations),
                      const SizedBox(height: 20),

                      // ── Quick Actions: Practice & Interview ──
                      _buildQuickActions(context, isDark, themeService.enableAnimations),

                      const SizedBox(height: 20),

                      // ── Section Title ──
                      Row(
                        children: [
                          const Text('🗺️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'YOUR LEARNING PATH',
                            style: AppTheme.labelMedium.copyWith(
                              letterSpacing: 1.5,
                              color: AppTheme.textMutedC(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Module Cards ──
              Consumer<ProgressService>(
                builder: (context, progress, child) {
                  final firstLockedIndex = allModules.indexWhere((m) => !progress.isModuleUnlocked(m.id, m.requiredQuizId));

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final module = allModules[index];
                        final isLocked = !progress.isModuleUnlocked(
                          module.id,
                          module.requiredQuizId,
                        );
                        final moduleProgress = isLocked
                            ? 0.0
                            : progress.moduleProgress(
                                module.id,
                                module.totalTopics,
                              );
                        final color = AppTheme.getModuleColor(index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ModuleCard(
                            key: ValueKey(module.id),
                            title: module.title,
                            description: module.description,
                            icon: module.icon,
                            accentColor: color,
                            progress: moduleProgress,
                            isLocked: isLocked,
                            index: index,
                            isDark: isDark,
                            enableAnimations: themeService.enableAnimations,
                            onUnlockAd: (isLocked && index == firstLockedIndex) ? () async {
                              soundService.playTap();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Loading Reward Ad...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              final success = await context.read<AdService>().showRewardedAd();
                              if (!context.mounted) return;
                              if (success) {
                                await progress.unlockModuleWithAd(module.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Module Unlocked! 🔓')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to load ad. Please try again later.')),
                                );
                              }
                            } : null,
                            onTap: () {
                              soundService.playTap();
                              if (isLocked) {
                                _showLockedDialog(
                                  context,
                                  isDark,
                                  module,
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context2,
                                        animation,
                                        secondaryAnimation,
                                      ) => ModuleDetailScreen(
                                        module: module,
                                        accentColor: color,
                                      ),
                                  transitionsBuilder:
                                      (context2, anim, secondaryAnim, child) {
                                        return FadeTransition(
                                          opacity: anim,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: anim,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  final p = context.read<ProgressService>();
                                  context.read<ReviewService>().tryShowReviewPrompt(
                                    completedModules: p.completedModuleCount(allModules),
                                  );
                                }
                              });
                            },
                          ),
                        );
                      }, childCount: allModules.length),
                    ),
                  );
                },
              ),

              // ── Certificate Achievement ──
              Consumer<ProgressService>(
                builder: (context, progress, _) {
                  final totalTopics = allModules.fold<int>(0, (sum, m) => sum + m.topics.length);
                  final isComplete = progress.isCurriculumComplete(totalTopics);
                  
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildCertificateCard(context, isDark, isComplete),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: BannerAdWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, bool isDark, bool isUnlocked) {
    return GestureDetector(
      onTap: () {
        context.read<SoundService>().playTap();
        if (isUnlocked) {
          Navigator.pushNamed(context, '/certificate');
        } else {
          _showCertificateLockedDialog(context, isDark);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [AppTheme.accentCyan.withValues(alpha: 0.2), AppTheme.accentCyan.withValues(alpha: 0.05)]
                : [
                    (isDark ? AppTheme.cardDark : AppTheme.cardLightAlt).withValues(alpha: 0.8),
                    (isDark ? AppTheme.cardDark : AppTheme.cardLightAlt).withValues(alpha: 0.4),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked 
              ? AppTheme.accentCyan.withValues(alpha: 0.5) 
              : AppTheme.textMutedC(isDark).withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isUnlocked ? [
            BoxShadow(
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
              size: 48,
              color: isUnlocked ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'AR Explorer Certificate',
              style: AppTheme.headingSmall.copyWith(
                color: isUnlocked ? AppTheme.textPrimaryC(isDark) : AppTheme.textMutedC(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked 
                ? 'Congratulations! Your certificate is ready to be viewed and saved.'
                : 'Complete all topics across all modules to unlock your official certificate.',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(
                color: isUnlocked ? AppTheme.textSecondaryC(isDark) : AppTheme.textMutedC(isDark),
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VIEW CERTIFICATE',
                  style: AppTheme.buttonText.copyWith(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ).animate(target: isUnlocked ? 1 : 0).shimmer(
        duration: const Duration(seconds: 3),
        color: AppTheme.accentCyan.withValues(alpha: 0.3),
      ),
    );
  }

  void _showCertificateLockedDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎓 Certificate Locked'),
        content: const Text(
          'The AR Explorer Certificate is awarded to those who master the entire curriculum.\n\n'
          'To unlock it, you must mark all topics as complete across all modules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I\'ll get there!'),
          ),
        ],
      ),
    );
  }

  // ── Level / XP Card ─────────────────────────────────────────────
  Widget _buildLevelCard(BuildContext context, bool isDark, bool enableAnimations) {
    return Consumer<ProgressService>(
      builder: (context, progress, child) {
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
        final motivMsg = AppTheme.getMotivationalMessage(overallProgress);

        final card = GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: level badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.accentCyan,
                                AppTheme.accentBlue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            levelTitle,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: overallProgress,
                              backgroundColor: AppTheme.accentCyan.withValues(
                                alpha: isDark ? 0.1 : 0.15,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.accentCyan,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedTopics / $totalTopics',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Motivational message
                    Text(
                      motivMsg,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
            
            if (enableAnimations) {
              return card
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(begin: 0.1, end: 0);
            }
            return card;
      },
    );
  }

  // ── Quick Actions (Practice, Interview, Roadmap, Bookmarks) ──────────
  Widget _buildQuickActions(BuildContext context, bool isDark, bool enableAnimations) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  isDark: isDark,
                  title: 'Practice',
                  subtitle: 'Review & Daily',
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppTheme.accentPink,
                  enableAnimations: enableAnimations,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PracticeScreen()),
                  ),
                  delay: 400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  isDark: isDark,
                  title: 'Interview',
                  subtitle: 'Mock Test',
                  icon: Icons.timer_rounded,
                  iconColor: AppTheme.accentAmber,
                  enableAnimations: enableAnimations,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InterviewScreen()),
                  ),
                  delay: 500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  isDark: isDark,
                  title: 'Roadmap',
                  subtitle: 'Learning Path',
                  icon: Icons.map_rounded,
                  iconColor: AppTheme.accentTeal,
                  enableAnimations: enableAnimations,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                  ),
                  delay: 600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  isDark: isDark,
                  title: 'Bookmarks',
                  subtitle: 'Saved Notes',
                  icon: Icons.bookmark_rounded,
                  iconColor: AppTheme.accentPurple,
                  enableAnimations: enableAnimations,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                  ),
                  delay: 700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool enableAnimations,
    required VoidCallback onTap,
    required int delay,
  }) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard(isDark),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTheme.headingSmall.copyWith(
                      fontSize: 14,
                      color: AppTheme.textPrimaryC(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMutedC(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (enableAnimations) {
      return card.animate().fadeIn(
        delay: Duration(milliseconds: delay),
        duration: const Duration(milliseconds: 500),
      );
    }
    return card;
  }

  // ── Locked Module Dialog ─────────────────────────────────────
  void _showLockedDialog(
    BuildContext context,
    bool isDark,
    LearningModule module,
  ) {
    final quizId = module.requiredQuizId;
    final quizTitle = quizId != null
        ? (allQuizzes[quizId]?.title ?? 'the previous quiz')
        : 'the previous quiz';
        
    bool isAdLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.cardC(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Text('🔒', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Module Locked',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To unlock "${module.title}", you need to score 70%+ on:\n\n'
                '📝 $quizTitle\n\n'
                'Alternatively, you can watch a short ad to unlock it immediately.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryC(isDark),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isAdLoading
                      ? null
                      : () async {
                          setState(() => isAdLoading = true);
                          final adService = context.read<AdService>();
                          final success = await adService.showRewardedAd();
                          if (success && ctx.mounted) {
                            await context.read<ProgressService>().unlockModuleWithAd(module.id);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Module Unlocked! 🎉')),
                            );
                          } else {
                            if (ctx.mounted) {
                              setState(() => isAdLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ad could not be loaded or was cancelled.')),
                              );
                            }
                          }
                        },
                  icon: isAdLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.play_circle_fill_rounded, size: 20),
                  label: Text('Watch Ad to Unlock', style: AppTheme.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small icon button helper ─────────────────────────────────

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: AppTheme.textMutedC(isDark), size: 22),
          ),
        ),
      ),
    );
  }

  // ── Settings Modal ───────────────────────────────────────────
  void _showSettingsModal(BuildContext context, bool isDark, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardC(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.textMutedC(isDark).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Settings',
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textPrimaryC(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════════
                    // ── GENERAL SECTION ──
                    // ═══════════════════════════════════════════
                    _settingsSectionHeader('General', Icons.tune_rounded, AppTheme.accentCyan, isDark),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: AppTheme.accentCyan),
                      title: Text(
                        'Change Name',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Navigator.pop(ctx);
                        _showChangeNameDialog(context, isDark);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: AppTheme.accentCyan,
                      ),
                      title: Text(
                        isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        context.read<ThemeService>().toggleTheme();
                        Navigator.pop(ctx);
                      },
                    ),
                    Consumer<ThemeService>(
                      builder: (context, theme, _) => SwitchListTile(
                        secondary: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentPurple),
                        title: Text(
                          'Enhanced Visuals',
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                        ),
                        subtitle: Text(
                          'Animations & background effects',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                        ),
                        value: theme.enableAnimations,
                        activeColor: AppTheme.accentPurple,
                        onChanged: (val) {
                          context.read<SoundService>().playTap();
                          theme.toggleAnimations();
                        },
                      ),
                    ),
                    Consumer<SoundService>(
                      builder: (context, sound, _) => SwitchListTile(
                        secondary: const Icon(Icons.vibration_rounded, color: AppTheme.accentCyan),
                        title: Text(
                          'Vibration',
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                        ),
                        value: sound.isVibrationEnabled,
                        activeColor: AppTheme.accentCyan,
                        onChanged: (val) {
                          sound.toggleVibration();
                          sound.playTap();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: AppTheme.dividerC(isDark)),
                    const SizedBox(height: 8),

                    // ═══════════════════════════════════════════
                    // ── APP SECTION ──
                    // ═══════════════════════════════════════════
                    _settingsSectionHeader('App', Icons.apps_rounded, AppTheme.accentBlue, isDark),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.star_rounded, color: AppTheme.accentAmber),
                      title: Text(
                        'Rate Us',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      subtitle: Text(
                        'Love the app? Leave us a review!',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        context.read<ReviewService>().openStoreListing();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_rounded, color: AppTheme.accentBlue),
                      title: Text(
                        'Share App',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      subtitle: Text(
                        'Share AR Explorer with friends',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Share.share(
                          '🚀 Check out AR Explorer – the ultimate app to learn Augmented Reality concepts!\n\n'
                          'Download it on Google Play:\n'
                          'https://play.google.com/store/apps/details?id=com.example.ar_explorer',
                          subject: 'AR Explorer – Learn Augmented Reality',
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined, color: AppTheme.accentPurple),
                      title: Text(
                        'Privacy Policy',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    Divider(color: AppTheme.dividerC(isDark)),
                    const SizedBox(height: 8),

                    // ═══════════════════════════════════════════
                    // ── DANGER ZONE ──
                    // ═══════════════════════════════════════════
                    _settingsSectionHeader('Danger Zone', Icons.warning_amber_rounded, AppTheme.errorRed, isDark),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.errorRed),
                      title: Text(
                        'Reset Progress',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      subtitle: Text(
                        'Want to test your knowledge again?',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Navigator.pop(ctx);
                        _showResetProgressDialog(context, isDark);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app_rounded, color: AppTheme.errorRed),
                      title: Text(
                        'Quit Application',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorRed),
                      ),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Navigator.pop(ctx);
                        _showQuitDialog(context, isDark);
                      },
                    ),

                    const SizedBox(height: 16),
                    Divider(color: AppTheme.dividerC(isDark)),
                    const SizedBox(height: 8),

                    // ═══════════════════════════════════════════
                    // ── ABOUT SECTION ──
                    // ═══════════════════════════════════════════
                    _settingsSectionHeader('About', Icons.info_outline_rounded, AppTheme.accentCyan, isDark),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppTheme.accentBlue),
                      title: Text(
                        'Credits',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedC(isDark)),
                      onTap: () {
                        context.read<SoundService>().playTap();
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => const CreditsScreen(),
                          ),
                        );
                      },
                    ),
                    // ── Testing Section ──
                    Consumer<ProgressService>(
                      builder: (context, progress, _) => SwitchListTile(
                        secondary: const Icon(Icons.bug_report_rounded, color: AppTheme.accentAmber),
                        title: Text(
                          'Bypass All Locks',
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
                        ),
                        subtitle: Text(
                          'For testing – unlocks all modules',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                        ),
                        value: progress.debugUnlockAll,
                        activeColor: AppTheme.accentAmber,
                        onChanged: (val) => progress.toggleDebugUnlock(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Version Label ──
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : '...';
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'AR Explorer $version',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMutedC(isDark).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Section Header Helper ──
  Widget _settingsSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTheme.labelMedium.copyWith(
              color: color,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reset Progress Dialog ──
  void _showResetProgressDialog(BuildContext context, bool isDark) {
    final progress = context.read<ProgressService>();
    final controller = TextEditingController();
    final soundService = context.read<SoundService>();
    final username = progress.username;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.restart_alt_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            Text(
              'Reset Progress',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentAmber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Want to test your knowledge again? Reset your progress and start your learning journey fresh!',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryC(isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type your name "$username" to confirm:',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
              decoration: AppTheme.inputDecoration(
                label: 'Your Name',
                hint: username,
                isDark: isDark,
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedC(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().toLowerCase() == username.toLowerCase()) {
                soundService.playTap();
                await progress.resetAll();
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress has been reset! Start fresh 🚀'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  SnackBar(
                    content: Text('Please type "$username" to confirm'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  // ── Change Name Dialog ───────────────────────────────────────
  void _showChangeNameDialog(BuildContext context, bool isDark) {
    final progress = context.read<ProgressService>();
    final controller = TextEditingController(text: progress.username == 'Explorer' ? '' : progress.username);
    final soundService = context.read<SoundService>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change Name',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
        ),
        content: TextField(
          controller: controller,
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
          decoration: AppTheme.inputDecoration(
            label: 'Your Name',
            hint: 'Enter your name',
            isDark: isDark,
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              soundService.playTap();
              Navigator.pop(ctx);
            },
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMutedC(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              soundService.playTap();
              if (controller.text.trim().isNotEmpty) {
                progress.updateUsername(controller.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Quit Dialog ──────────────────────────────────────────────
  void _showQuitDialog(BuildContext context, bool isDark) {
    final soundService = context.read<SoundService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text('👋', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'Leaving so soon?',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimaryC(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Your progress is saved automatically.\nSee you next time, explorer!',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryC(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              soundService.playTap();
              Navigator.pop(ctx);
            },
            child: Text(
              'Stay & Learn',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan),
            ),
          ),
          TextButton(
            onPressed: () {
              soundService.playTap();
              Navigator.pop(ctx);
              _exitApp();
            },
            child: Text(
              'Quit',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _exitApp() {
    if (kIsWeb) {
      return; // Can't exit web apps
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }
}

// ── Search Delegate ───────────────────────────────────────────────
class TopicSearchDelegate extends SearchDelegate<String> {
  final bool isDark;

  TopicSearchDelegate({required this.isDark});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textMutedC(isDark),
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              'Search for any AR topic...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textMutedC(isDark),
              ),
            ),
          ],
        ),
      );
    }

    // Filter topics across all modules
    final results = <Map<String, dynamic>>[];
    for (var module in allModules) {
      for (var topic in module.topics) {
        if (topic.title.toLowerCase().contains(query.toLowerCase()) ||
            topic.subtitle.toLowerCase().contains(query.toLowerCase())) {
          results.add({'module': module, 'topic': topic});
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              'No topics found for "$query"',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textMutedC(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        final module = results[index]['module'] as LearningModule;
        final topic = results[index]['topic'] as Topic;
        final color = AppTheme.getModuleColor(allModules.indexOf(module));

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(module.icon, color: color, size: 20),
          ),
          title: Text(
            topic.title,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'In ${module.title}',
            style: AppTheme.bodySmall.copyWith(color: color),
          ),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TopicScreen(
                  topic: topic,
                  moduleId: module.id,
                  accentColor: color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
