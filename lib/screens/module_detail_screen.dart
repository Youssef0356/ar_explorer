import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../core/app_theme.dart';
import '../data/quiz_data.dart';
import '../data/modules_data.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import 'bookmarks_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'topic_screen.dart';

class ModuleDetailScreen extends StatefulWidget {
  final LearningModule module;
  final Color accentColor;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.accentColor,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand if not read yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progress = context.read<ProgressService>();
      if (!progress.hasReadKeyConcepts(widget.module.id)) {
        setState(() => _isExpanded = true);
        progress.markKeyConceptsAsRead(widget.module.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.module.title,
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.textPrimaryC(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.module.description,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textMutedC(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.bookmark_rounded, color: widget.accentColor),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 8),

              // ── Module Progress ──
              Consumer<ProgressService>(
                builder: (context, progress, child) {
                  final moduleProgress = progress.moduleProgress(
                    widget.module.id,
                    widget.module.totalTopics,
                  );
                  final completed = widget.module.topics
                      .where(
                        (t) =>
                            progress.isTopicCompleted('${widget.module.id}_${t.id}'),
                      )
                      .length;

                  final content = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child:
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.moduleCard(widget.accentColor, isDark),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.module.icon,
                                  color: widget.accentColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '$completed of ${widget.module.totalTopics} topics',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: widget.accentColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (moduleProgress == 1.0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successGreen
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              '🏆 Complete!',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: moduleProgress,
                                        backgroundColor: widget.accentColor.withOpacity(
                                          0.1,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              widget.accentColor,
                                            ),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  );

                  if (context.read<ThemeService>().enableAnimations) {
                    return content.animate().fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400),
                        );
                  }
                  return content;
                },
              ),

              const SizedBox(height: 20),

              // ── Key Concepts Card ──
              if (widget.module.keyConcepts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildKeyConceptsCard(isDark),
                ),

              const SizedBox(height: 20),

              // ── Section label ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'TOPICS',
                        style: AppTheme.labelMedium.copyWith(
                          letterSpacing: 1.5,
                          color: AppTheme.textMutedC(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Topic List ──
              Expanded(
                child: Consumer<ProgressService>(
                  builder: (context, progress, child) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: widget.module.topics.length,
                      itemBuilder: (context, index) {
                        final topic = widget.module.topics[index];
                        final isCompleted = progress.isTopicCompleted(
                          '${widget.module.id}_${topic.id}',
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child:
                              GestureDetector(
                                    onTap: () async {
                                      final goToNext = await Navigator.push<bool>(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context2,
                                                animation,
                                                secondaryAnimation,
                                              ) => TopicScreen(
                                                topic: topic,
                                                moduleId: widget.module.id,
                                                accentColor: widget.accentColor,
                                              ),
                                          transitionsBuilder:
                                              (
                                                context2,
                                                anim,
                                                secondaryAnim,
                                                child,
                                              ) {
                                                return FadeTransition(
                                                  opacity: anim,
                                                  child: child,
                                                );
                                              },
                                          transitionDuration: const Duration(
                                            milliseconds: 300,
                                          ),
                                        ),
                                      );

                                      if (goToNext == true && index + 1 < widget.module.topics.length) {
                                        final nextTopic = widget.module.topics[index + 1];
                                        // Open the next topic immediately.
                                        // We don't wait on the result here to avoid chaining many pushes.
                                        // The user can always navigate back if needed.
                                        if (!context.mounted) return;
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder:
                                                (
                                                  context2,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => TopicScreen(
                                                  topic: nextTopic,
                                                  moduleId: widget.module.id,
                                                  accentColor: widget.accentColor,
                                                ),
                                            transitionsBuilder:
                                                (
                                                  context2,
                                                  anim,
                                                  secondaryAnim,
                                                  child,
                                                ) {
                                                  return FadeTransition(
                                                    opacity: anim,
                                                    child: child,
                                                  );
                                                },
                                            transitionDuration:
                                                const Duration(milliseconds: 300),
                                          ),
                                        );
                                      }
                                    },
                                    child: _buildTopicTile(context, index, topic, isCompleted, isDark, progress),
                              ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ── Quiz Button ──
              _buildQuizButton(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyConceptsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Consumer<ProgressService>(
          builder: (_, progress, _) {
            final hasRead = progress.hasReadKeyConcepts(widget.module.id);
            return ExpansionTile(
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isExpanded = expanded);
                if (expanded) {
                  progress.markKeyConceptsAsRead(widget.module.id);
                }
              },
              leading: Icon(Icons.lightbulb_rounded, color: widget.accentColor),
              title: Text(
                'Key Concepts',
                style: AppTheme.headingSmall.copyWith(
                  fontSize: 16,
                  color: AppTheme.textPrimaryC(isDark),
                ),
              ),
              trailing: hasRead
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 12, color: AppTheme.successGreen),
                        const SizedBox(width: 4),
                        Text(
                          'Reviewed',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successGreen,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : Icon(Icons.expand_more_rounded,
                    color: widget.accentColor.withValues(alpha: 0.6), size: 20),
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.module.keyConcepts.map((concept) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: TextStyle(color: widget.accentColor, fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            concept,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryC(isDark),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

  // Refactored helper to keep build clean
  Widget _buildTopicTile(BuildContext context, int index, topic, bool isCompleted, bool isDark, progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? widget.accentColor.withValues(alpha: 0.3)
              : AppTheme.dividerC(isDark),
          width: 1,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Left index/check indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? widget.accentColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? widget.accentColor
                        : AppTheme.dividerC(isDark),
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: widget.accentColor,
                        size: 18,
                      )
                    : Text(
                        '${index + 1}',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textMutedC(isDark),
                        ),
                      ),
              ).animate(
                target: (!isCompleted && (index == 0 || progress.isTopicCompleted('${widget.module.id}_${widget.module.topics[index - 1].id}'))) ? 1 : 0,
                onPlay: (c) => c.repeat(),
              ).shimmer(duration: 2.seconds, color: widget.accentColor.withValues(alpha: 0.2)),
              // Bottom line
              Container(
                width: 2,
                height: 40,
                color: index == widget.module.topics.length - 1
                    ? Colors.transparent
                    : (isCompleted ? widget.accentColor.withValues(alpha: 0.3) : AppTheme.dividerC(isDark)),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  topic.title,
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: 15,
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMutedC(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isCompleted ? widget.accentColor : AppTheme.textMutedC(isDark),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedModulePreview(BuildContext context, bool isDark) {
    // Find the next module in sequence (order = current order + 1)
    final currentOrder = widget.module.order;
    final nextModule = allModules.firstWhereOrNull(
      (m) => m.order == currentOrder + 1,
    );
    if (nextModule == null) return const SizedBox.shrink();

    final concepts = nextModule.keyConcepts.take(3).toList();
    if (concepts.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Content behind blur
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassCard(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlocks next: ${nextModule.title}',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.accentCyan,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...concepts.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(color: AppTheme.accentCyan)),
                        Expanded(
                          child: Text(
                            c,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryC(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Semi-transparent overlay (replaces BackdropFilter for performance)
          Positioned.fill(
            child: Container(
              color: AppTheme.cardC(isDark).withValues(alpha: 0.85),
              child: Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 28,
                  color: AppTheme.accentCyan.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context, bool isDark) {
    final quiz = allQuizzes.values.where((q) => q.moduleId == widget.module.id).firstOrNull;
    if (quiz == null) return const SizedBox.shrink();

    return Consumer<ProgressService>(
      builder: (context, progress, child) {
        final bestScore = progress.getQuizScore(quiz.id);
        final hasPassed = progress.hasPassedQuiz(quiz.id, quiz.passingScore);
        final hasReadConcepts = progress.hasReadKeyConcepts(widget.module.id);
        final allTopicsDone = progress.isModuleTopicsCompleted(widget.module.id, widget.module.totalTopics);

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.scaffoldC(isDark).withValues(alpha: 0.0),
                AppTheme.scaffoldC(isDark),
              ],
            ),
          ),
          child: Column(
            children: [
              if (!allTopicsDone)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: AppTheme.warningAmber),
                        const SizedBox(width: 8),
                        Text(
                          'Finish all topics to unlock quiz',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.warningAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (bestScore != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasPassed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        size: 16,
                        color: hasPassed ? AppTheme.successGreen : AppTheme.warningAmber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasPassed
                            ? '✅ Passed! Best: $bestScore%'
                            : '🔄 Best: $bestScore% (need ${quiz.passingScore}%)',
                        style: AppTheme.bodySmall.copyWith(
                          color: hasPassed ? AppTheme.successGreen : AppTheme.warningAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              // Flashcards button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreen(
                          moduleId: widget.module.id,
                          moduleTitle: widget.module.title,
                          accentColor: widget.accentColor,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.style_rounded, size: 20),
                  label: Text(
                    '📇 Flashcards',
                    style: AppTheme.buttonText.copyWith(color: widget.accentColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.accentColor,
                    side: BorderSide(color: widget.accentColor.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !allTopicsDone 
                      ? null 
                      : () {
                          if (!hasReadConcepts && bestScore == null) {
                            _showConceptNudge(context, quiz);
                          } else {
                            _startQuiz(context, quiz);
                          }
                        },
                  icon: Icon(
                    hasPassed
                        ? Icons.replay_rounded
                        : !hasReadConcepts
                            ? Icons.lightbulb_outline_rounded
                            : Icons.quiz_rounded,
                    size: 20,
                  ),
                  label: Text(
                    hasPassed
                        ? '🔁 Retake Quiz'
                        : !hasReadConcepts
                            ? '💡 Review First, Then Quiz →'
                            : '🎯 Take the Quiz!',
                    style: AppTheme.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allTopicsDone ? widget.accentColor : AppTheme.dividerC(isDark),
                    foregroundColor: allTopicsDone ? Colors.white : AppTheme.textMutedC(isDark),
                  ),
                ),
              ),
              if (!hasPassed && allTopicsDone) ...[
                const SizedBox(height: 12),
                _buildLockedModulePreview(context, isDark),
              ],
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }

  void _showConceptNudge(BuildContext context, quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardC(context.watch<ThemeService>().isDarkMode),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('💡 Quick Review?'),
        content: const Text('Would you like to review the Key Concepts before starting the quiz? It only takes a minute!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz(context, quiz);
            },
            child: Text('Skip', style: TextStyle(color: AppTheme.textMutedC(context.watch<ThemeService>().isDarkMode))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isExpanded = true);
              context.read<ProgressService>().markKeyConceptsAsRead(widget.module.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review Concepts'),
          ),
        ],
      ),
    );
  }

  void _startQuiz(BuildContext context, quiz) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context2, animation, secondaryAnimation) => QuizScreen(quiz: quiz),
        transitionsBuilder: (context2, anim, secondaryAnim, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
