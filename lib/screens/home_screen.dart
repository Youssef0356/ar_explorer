import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../models/module_model.dart';
import '../models/topic_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/module_card.dart';
import 'achievements_screen.dart';
import 'credits_screen.dart';
import 'module_detail_screen.dart';
import 'topic_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
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
                      Row(
                            children: [
                              Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.accentCyan,
                                          AppTheme.accentBlue,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.view_in_ar_rounded,
                                      color: AppTheme.primaryDark,
                                      size: 24,
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .shimmer(
                                    duration: const Duration(seconds: 3),
                                    color: AppTheme.accentCyan.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AR Explorer',
                                      style: AppTheme.headingLarge.copyWith(
                                        color: AppTheme.textPrimaryC(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Learn Augmented Reality',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.accentCyan.withValues(
                                          alpha: 0.7,
                                        ),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ── Action Buttons ──
                              _ThemeToggleButton(isDark: isDark),
                              _buildIconButton(
                                icon: Icons.info_outline_rounded,
                                tooltip: 'Credits',
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context2) =>
                                        const CreditsScreen(),
                                  ),
                                ),
                              ),
                              _buildIconButton(
                                icon: Icons.exit_to_app_rounded,
                                tooltip: 'Quit',
                                isDark: isDark,
                                onTap: () => _showQuitDialog(context, isDark),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 600))
                          .slideY(begin: -0.2, end: 0),

                      const SizedBox(height: 24),

                      // ── XP & Level Card ──
                      _buildLevelCard(context, isDark),

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
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final module = allModules[index];
                        final moduleProgress = progress.moduleProgress(
                          module.id,
                          module.totalTopics,
                        );
                        final color = AppTheme.getModuleColor(index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ModuleCard(
                            title: module.title,
                            description: module.description,
                            icon: module.icon,
                            accentColor: color,
                            progress: moduleProgress,
                            isLocked: false,
                            index: index,
                            isDark: isDark,
                            onTap: () {
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
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(0.05, 0),
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
                              );
                            },
                          ),
                        );
                      }, childCount: allModules.length),
                    ),
                  );
                },
              ),

              // ── Bottom padding ──
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Level / XP Card ─────────────────────────────────────────────
  Widget _buildLevelCard(BuildContext context, bool isDark) {
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

        return GestureDetector(
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
            )
            .animate()
            .fadeIn(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 500),
            )
            .slideY(begin: 0.1, end: 0);
      },
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

  // ── Quit Dialog ──────────────────────────────────────────────
  void _showQuitDialog(BuildContext context, bool isDark) {
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Stay & Learn',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan),
            ),
          ),
          TextButton(
            onPressed: () {
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

// ── Animated Theme Toggle Button ─────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;

  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isDark ? 'Light Mode' : 'Dark Mode',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.read<ThemeService>().toggleTheme(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? AppTheme.accentAmber : AppTheme.accentPurple,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
