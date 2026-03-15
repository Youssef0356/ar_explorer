import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../widgets/animated_google_background.dart';

class QuizAnalyticsScreen extends StatelessWidget {
  const QuizAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();
    final progress = context.watch<ProgressService>();

    // Calculate Weak Modules Map
    // Count how many wrong answers belong to which module
    final Map<LearningModule, int> moduleMistakes = {};
    for (var wrongId in progress.wrongAnswers) {
      for (var module in allModules) {
        if (wrongId.startsWith(module.id)) {
          moduleMistakes[module] = (moduleMistakes[module] ?? 0) + 1;
        }
      }
    }

    final sortedModules = moduleMistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, soundService),
              Expanded(
                child: ListView(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                   physics: const BouncingScrollPhysics(),
                   children: [
                      _buildScoreHistoryGraph(isDark, progress),
                      const SizedBox(height: 32),
                      Text(
                        'Weak Areas Map',
                        style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modules with the highest frequency of incorrect answers.',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                      ),
                      const SizedBox(height: 16),
                      if (sortedModules.isEmpty)
                        _buildEmptyState(isDark)
                      else
                        ...sortedModules.map((entry) => _buildHeatmapBar(isDark, entry.key, entry.value, sortedModules.first.value)),
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
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCard(isDark),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimaryC(isDark),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Analytics',
                  style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
                ),
                Text(
                  'Track your performance across modules.',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.accentCyan),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_rounded, color: AppTheme.accentCyan),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHistoryGraph(bool isDark, ProgressService progress) {
     final history = progress.interviewHistory;
     if (history.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassCard(isDark),
          child: Center(
            child: Text(
              'Complete Mock Interviews to see your score trajectory.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
              textAlign: TextAlign.center,
            ),
          ),
        );
     }

     final maxScore = history.reduce(max).toDouble().clamp(10.0, 100.0);

     return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard(isDark).copyWith(
          border: Border.all(color: AppTheme.textMutedC(isDark).withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Interview Trajectory', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
                  Text(
                    'Best: ${progress.interviewBestScore}%',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.accentAmber, fontWeight: FontWeight.bold),
                  ),
                ],
             ),
             const SizedBox(height: 24),
             SizedBox(
               height: 150,
               child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(history.length, (index) {
                     final score = history[index];
                     final heightPercent = score / maxScore;
                     
                     Color barColor = AppTheme.textMutedC(isDark).withValues(alpha: 0.5);
                     if (score >= 80) {
                       barColor = AppTheme.successGreen;
                     } else if (score >= 50) {
                       barColor = AppTheme.accentAmber;
                     } else {
                       barColor = AppTheme.accentPink;
                     }

                     return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                           Text('$score', style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.textMutedC(isDark))),
                           const SizedBox(height: 4),
                           Container(
                              width: 14,
                              height: (100 * heightPercent).toDouble(),
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                           ).animate().scaleY(alignment: Alignment.bottomCenter, duration: const Duration(milliseconds: 600)),
                        ],
                     );
                  }),
               ),
             )
          ],
        ),
     );
  }

  Widget _buildEmptyState(bool isDark) {
     return Container(
       padding: const EdgeInsets.all(32),
       decoration: AppTheme.glassCard(isDark).copyWith(
         border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
       ),
       child: Column(
         children: [
           const Icon(Icons.auto_awesome_rounded, color: AppTheme.successGreen, size: 48),
           const SizedBox(height: 16),
           Text(
              'No Weak Areas Detected!',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
           ),
           const SizedBox(height: 8),
           Text(
              'You haven\'t made any mistakes in the quizzes yet. Attempt more quizzes or flashcards to generate data.',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
           ),
         ],
       ),
     );
  }

  Widget _buildHeatmapBar(bool isDark, LearningModule module, int mistakes, int maxMistakes) {
    final intensity = mistakes / maxMistakes; // 0.0 to 1.0
    // Color ramps from Yellow -> Orange -> Pink/Red based on mistake density
    final Color heatColor = Color.lerp(AppTheme.accentAmber, AppTheme.accentPink, intensity) ?? AppTheme.accentPink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(module.icon, size: 16, color: AppTheme.textSecondaryC(isDark)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.title,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimaryC(isDark), fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$mistakes mistakes',
                style: AppTheme.bodySmall.copyWith(color: heatColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
             height: 12,
             width: double.infinity,
             decoration: BoxDecoration(
                color: AppTheme.textMutedC(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
             ),
             child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: intensity,
                child: Container(
                   decoration: BoxDecoration(
                      color: heatColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                         BoxShadow(
                            color: heatColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                         )
                      ]
                   ),
                ),
             ).animate().scaleX(alignment: Alignment.centerLeft, duration: const Duration(milliseconds: 500)),
          ),
        ],
      ),
    );
  }
}
