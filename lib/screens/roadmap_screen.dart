import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../widgets/animated_google_background.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../data/quiz_data.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/subscription_service.dart';
import 'module_detail_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<ProgressService>();

    return Material(
      color: Colors.transparent,
      child: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  'Learning Roadmap',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
                leading: Navigator.canPop(context) 
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: AppTheme.textPrimaryC(isDark)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Complete each module and pass the quiz at 70%+ to unlock the next stage',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textMutedC(isDark),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 200), // Maximum bottom padding
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = allModules[index];
                      final isLocked = !progress.isModuleUnlocked(module);
                      final moduleProg = isLocked
                          ? 0.0
                          : progress.moduleProgress(module.id, module.totalTopics);
                      final quizScore = _getModuleQuizScore(module.id, progress);
                      final isCompleted = moduleProg >= 1.0;

                      final color = AppTheme.getModuleColor(index);
                      final isLast = index == allModules.length - 1;

                      return _RoadmapNode(
                        title: module.title,
                        icon: module.icon,
                        color: color,
                        isLocked: isLocked,
                        isCompleted: isCompleted,
                        progress: moduleProg,
                        quizScore: quizScore,
                        isDark: isDark,
                        isLast: isLast,
                        index: index,
                        isPremiumModule: module.unlockCost > 0,
                        onTap: isLocked
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ModuleDetailScreen(
                                      module: module,
                                      accentColor: color,
                                    ),
                                  ),
                                ),
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        duration: const Duration(milliseconds: 500),
                      ).slideY(
                        begin: 0.1,
                        end: 0,
                        delay: Duration(milliseconds: 100 * index),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    childCount: allModules.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _getModuleQuizScore(String moduleId, ProgressService progress) {
    for (final entry in allQuizzes.entries) {
      if (entry.value.moduleId == moduleId) {
        return progress.getQuizScore(entry.key);
      }
    }
    return null;
  }
}

class _RoadmapNode extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final bool isCompleted;
  final double progress;
  final int? quizScore;
  final bool isDark;
  final bool isLast;
  final int index;
  final bool isPremiumModule;
  final VoidCallback? onTap;

  const _RoadmapNode({
    required this.title,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.isCompleted,
    required this.progress,
    required this.quizScore,
    required this.isDark,
    required this.isLast,
    required this.index,
    required this.isPremiumModule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Vertical line + dot ──
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked
                            ? AppTheme.cardC(isDark)
                            : isCompleted
                                ? color
                                : color.withOpacity(0.3),
                        border: Border.all(
                          color: isLocked ? AppTheme.dividerC(isDark) : color,
                          width: 2.5,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : isLocked
                              ? Icon(Icons.lock,
                                  size: 12, color: AppTheme.textMutedC(isDark))
                              : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.5,
                          color: isCompleted
                              ? color.withOpacity(0.5)
                              : AppTheme.dividerC(isDark),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Card ──
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppTheme.cardC(isDark).withOpacity(0.5)
                        : AppTheme.cardC(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLocked
                          ? AppTheme.dividerC(isDark)
                          : color.withOpacity(isDark ? 0.3 : 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: isLocked ? AppTheme.textMutedC(isDark) : color,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: AppTheme.headingSmall.copyWith(
                                fontSize: 15,
                                color: isLocked
                                    ? AppTheme.textMutedC(isDark)
                                    : AppTheme.textPrimaryC(isDark),
                              ),
                            ),
                          ),
                          if (!isLocked && !isCompleted)
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTheme.bodySmall.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '✓ Done',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                      if (quizScore != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Quiz best: $quizScore%',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textMutedC(isDark),
                          ),
                        ),
                      ],
                      if (isLocked) ...[
                        const SizedBox(height: 6),
                        Text(
                          isPremiumModule
                              ? '👑 Premium — Unlock for ${context.read<SubscriptionService>().localizedPrice}'
                              : '🔒 Pass previous quiz (70%+)',
                          style: AppTheme.bodySmall.copyWith(
                            color: isPremiumModule
                                ? AppTheme.accentAmber
                                : AppTheme.textMutedC(isDark),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: 0.1, end: 0);
  }
}
