import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../widgets/animated_google_background.dart';
import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../models/module_model.dart';
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
        glowColors: const [
          Color(0xFF2979FF),
          Color(0xFF00D4AA),
          Color(0xFF7B1FA2),
        ],
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Roadmap',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                    Text(
                      'Your path to AR mastery',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentPurple.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded,
                            color: AppTheme.textPrimaryC(isDark)),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
              ),
              // Map header info
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentPurple.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppTheme.accentPurple, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Complete each module and pass its quiz at 70%+ to unlock the next stage.',
                            style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.accentPurple.withValues(alpha: 0.9)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 204 + MediaQuery.paddingOf(context).bottom),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = allModules[index];
                      final isLocked = !progress.isModuleUnlocked(module);
                      final moduleProg = isLocked
                          ? 0.0
                          : progress.moduleProgress(
                              module.id, module.totalTopics);
                      final quizScore =
                          _getModuleQuizScore(module.id, progress);
                      final isCompleted = moduleProg >= 1.0;
                      final color = AppTheme.getModuleColor(index);
                      final isLast = index == allModules.length - 1;

                      return _RoadmapNode(
                        module: module,
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
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 80 * index),
                            duration: const Duration(milliseconds: 450),
                          )
                          .slideY(
                            begin: 0.12,
                            end: 0,
                            delay: Duration(milliseconds: 80 * index),
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
  final LearningModule module;
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
    required this.module,
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
        padding: const EdgeInsets.only(bottom: 0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left side: vertical connector ──
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    // Node circle
                    _buildNodeCircle(),
                    if (!isLast)
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Main connector line
                            Container(
                              width: 2.5,
                              color: isCompleted
                                  ? color.withValues(alpha: 0.55)
                                  : AppTheme.dividerC(isDark),
                            ),
                            // Dashed overlay for locked
                            if (!isCompleted)
                              Positioned.fill(
                                child: Column(
                                  children: List.generate(
                                    8,
                                    (i) => Expanded(
                                      child: Container(
                                        margin:
                                            const EdgeInsets.symmetric(vertical: 3),
                                        width: 2.5,
                                        color: i.isEven
                                            ? Colors.transparent
                                            : AppTheme.dividerC(isDark)
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Right side: card ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 4),
                  child: _buildCard(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeCircle() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Outer glow ring for active node
        if (!isLocked && !isCompleted)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15),
                  duration: 1800.ms)
              .then()
              .scale(begin: const Offset(1.15, 1.15), end: const Offset(1.0, 1.0),
                  duration: 1800.ms),

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLocked
                ? AppTheme.cardC(isDark)
                : isCompleted
                    ? color
                    : color.withValues(alpha: 0.25),
            border: Border.all(
              color: isLocked ? AppTheme.dividerC(isDark) : color,
              width: 2.5,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : isLocked
                  ? Icon(Icons.lock,
                      size: 12, color: AppTheme.textMutedC(isDark))
                  : Icon(Icons.play_arrow_rounded, size: 16, color: color),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final subscriptionService = context.read<SubscriptionService>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked
            ? AppTheme.cardC(isDark).withValues(alpha: 0.5)
            : AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? AppTheme.dividerC(isDark)
              : color.withValues(alpha: isDark ? 0.3 : 0.22),
          width: 1.5,
        ),
        boxShadow: !isLocked && !isDark
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppTheme.dividerC(isDark).withValues(alpha: 0.5)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  module.icon,
                  color: isLocked ? AppTheme.textMutedC(isDark) : color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: 14,
                    color: isLocked
                        ? AppTheme.textMutedC(isDark)
                        : AppTheme.textPrimaryC(isDark),
                  ),
                ),
              ),
              if (!isLocked && !isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTheme.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✓ Done',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          // ── Progress bar ──
          if (!isLocked) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],

          // ── Quiz score ──
          if (quizScore != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.quiz_rounded,
                    size: 12, color: AppTheme.textMutedC(isDark)),
                const SizedBox(width: 4),
                Text(
                  'Quiz best: $quizScore%',
                  style: AppTheme.bodySmall.copyWith(
                    color: quizScore! >= 70
                        ? AppTheme.successGreen
                        : AppTheme.textMutedC(isDark),
                    fontWeight: quizScore! >= 70 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],

          // ── Lock message ──
          if (isLocked) ...[
            const SizedBox(height: 10),
            Text(
              isPremiumModule
                  ? '👑 Premium — Unlock for ${subscriptionService.localizedPrice}'
                  : '🔒 Pass previous quiz (70%+) to unlock',
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
    );
  }
}
