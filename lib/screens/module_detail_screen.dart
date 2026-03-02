import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/quiz_data.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import 'quiz_screen.dart';
import 'topic_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final LearningModule module;
  final Color accentColor;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.accentColor,
  });

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
                            module.title,
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.textPrimaryC(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            module.description,
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
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 8),

              // ── Module Progress ──
              Consumer<ProgressService>(
                builder: (context, progress, child) {
                  final moduleProgress = progress.moduleProgress(
                    module.id,
                    module.totalTopics,
                  );
                  final completed = module.topics
                      .where(
                        (t) =>
                            progress.isTopicCompleted('${module.id}_${t.id}'),
                      )
                      .length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child:
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.moduleCard(accentColor, isDark),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  module.icon,
                                  color: accentColor,
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
                                          '$completed of ${module.totalTopics} topics',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: accentColor,
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
                                        backgroundColor: accentColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              accentColor,
                                            ),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400),
                        ),
                  );
                },
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
                      itemCount: module.topics.length,
                      itemBuilder: (context, index) {
                        final topic = module.topics[index];
                        final isCompleted = progress.isTopicCompleted(
                          '${module.id}_${topic.id}',
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
                                                moduleId: module.id,
                                                accentColor: accentColor,
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

                                      if (goToNext == true && index + 1 < module.topics.length) {
                                        final nextTopic = module.topics[index + 1];
                                        // Open the next topic immediately.
                                        // We don't wait on the result here to avoid chaining many pushes.
                                        // The user can always navigate back if needed.
                                        // ignore: use_build_context_synchronously
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
                                                  moduleId: module.id,
                                                  accentColor: accentColor,
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
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardC(isDark),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isCompleted
                                              ? accentColor.withValues(
                                                  alpha: 0.3,
                                                )
                                              : AppTheme.dividerC(isDark),
                                          width: 1,
                                        ),
                                        boxShadow: !isDark
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ── Learning Path Visualizer ──
                                          Column(
                                            children: [
                                              // Top line
                                              Container(
                                                width: 2,
                                                height: 16,
                                                color: index == 0
                                                    ? Colors.transparent
                                                    : (progress.isTopicCompleted(
                                                                  '${module.id}_${module.topics[index - 1].id}',
                                                                )
                                                            ? accentColor
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  )
                                                            : AppTheme.dividerC(
                                                                isDark,
                                                              )),
                                              ),
                                              // Number circle
                                              Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isCompleted
                                                          ? accentColor
                                                                .withValues(
                                                                  alpha: 0.15,
                                                                )
                                                          : (isDark
                                                                ? Colors.white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.05,
                                                                      )
                                                                : Colors.grey
                                                                      .withValues(
                                                                        alpha:
                                                                            0.08,
                                                                      )),
                                                      border: Border.all(
                                                        color: isCompleted
                                                            ? accentColor
                                                                  .withValues(
                                                                    alpha: 0.4,
                                                                  )
                                                            : AppTheme.dividerC(
                                                                isDark,
                                                              ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: isCompleted
                                                        ? Icon(
                                                            Icons.check_rounded,
                                                            color: accentColor,
                                                            size: 18,
                                                          )
                                                        : Text(
                                                            '${index + 1}',
                                                            style: AppTheme
                                                                .labelMedium
                                                                .copyWith(
                                                                  color:
                                                                      AppTheme.textMutedC(
                                                                        isDark,
                                                                      ),
                                                                ),
                                                          ),
                                                  )
                                                  .animate(
                                                    target:
                                                        (!isCompleted &&
                                                            (index == 0 ||
                                                                progress.isTopicCompleted(
                                                                  '${module.id}_${module.topics[index - 1].id}',
                                                                )))
                                                        ? 1
                                                        : 0,
                                                    onPlay: (c) => c.repeat(),
                                                  )
                                                  .shimmer(
                                                    duration: 2.seconds,
                                                    color: accentColor
                                                        .withValues(alpha: 0.2),
                                                  ),
                                              // Bottom line
                                              Container(
                                                width: 2,
                                                height:
                                                    40, // Match typical item height extension
                                                color:
                                                    index ==
                                                        module.topics.length - 1
                                                    ? Colors.transparent
                                                    : (isCompleted
                                                          ? accentColor
                                                                .withValues(
                                                                  alpha: 0.3,
                                                                )
                                                          : AppTheme.dividerC(
                                                              isDark,
                                                            )),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 16,
                                                ), // Align with circle
                                                Text(
                                                  topic.title,
                                                  style: AppTheme.headingSmall
                                                      .copyWith(
                                                        fontSize: 15,
                                                        color:
                                                            AppTheme.textPrimaryC(
                                                              isDark,
                                                            ),
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  topic.subtitle,
                                                  style: AppTheme.bodySmall
                                                      .copyWith(
                                                        color:
                                                            AppTheme.textMutedC(
                                                              isDark,
                                                            ),
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 24,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: isCompleted
                                                  ? accentColor
                                                  : AppTheme.textMutedC(isDark),
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 80 * index),
                                    duration: const Duration(milliseconds: 400),
                                  )
                                  .slideX(
                                    begin: 0.05,
                                    end: 0,
                                    delay: Duration(milliseconds: 80 * index),
                                    duration: const Duration(milliseconds: 400),
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

  Widget _buildQuizButton(BuildContext context, bool isDark) {
    final quiz = allQuizzes.values
        .where((q) => q.moduleId == module.id)
        .firstOrNull;
    if (quiz == null) return const SizedBox.shrink();

    return Consumer<ProgressService>(
      builder: (context, progress, child) {
        final bestScore = progress.getQuizScore(quiz.id);
        final hasPassed = progress.hasPassedQuiz(quiz.id, quiz.passingScore);

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
              if (bestScore != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasPassed
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: hasPassed
                            ? AppTheme.successGreen
                            : AppTheme.warningAmber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasPassed
                            ? '✅ Passed! Best: $bestScore%'
                            : '🔄 Best: $bestScore% (need ${quiz.passingScore}%)',
                        style: AppTheme.bodySmall.copyWith(
                          color: hasPassed
                              ? AppTheme.successGreen
                              : AppTheme.warningAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context2, animation, secondaryAnimation) =>
                                QuizScreen(quiz: quiz),
                        transitionsBuilder:
                            (context2, anim, secondaryAnim, child) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.1),
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
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  icon: Icon(
                    hasPassed ? Icons.replay_rounded : Icons.quiz_rounded,
                    size: 20,
                  ),
                  label: Text(
                    hasPassed ? '🔁 Retake Quiz' : '🎯 Take the Quiz!',
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
