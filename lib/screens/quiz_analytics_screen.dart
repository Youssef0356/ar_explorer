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

class QuizAnalyticsScreen extends StatefulWidget {
  const QuizAnalyticsScreen({super.key});

  @override
  State<QuizAnalyticsScreen> createState() => _QuizAnalyticsScreenState();
}

class _QuizAnalyticsScreenState extends State<QuizAnalyticsScreen> {
  int _filterDays = 0; // 0 for ALL, else 7 or 30

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
                      _buildActivityStreak(isDark, progress),
                      const SizedBox(height: 24),
                      _buildMasteryPrediction(isDark, progress),
                      const SizedBox(height: 24),
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
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.accentPurple),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_rounded, color: AppTheme.accentPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHistoryGraph(bool isDark, ProgressService progress) {
     final allHistory = progress.interviewHistory;
     if (allHistory.isEmpty) {
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

     // Filter history
     List<Map<String, dynamic>> filteredHistory = allHistory;
     if (_filterDays > 0) {
        final cutoff = DateTime.now().subtract(Duration(days: _filterDays));
        filteredHistory = allHistory.where((e) {
          final dateStr = e['date'] as String;
          try {
             return DateTime.parse(dateStr).isAfter(cutoff);
          } catch (_) {
             return true; 
          }
        }).toList();
     }

     if (filteredHistory.isEmpty) {
        return Container(
           padding: const EdgeInsets.all(20),
           decoration: AppTheme.glassCard(isDark),
           child: Column(
             children: [
               _buildFilterToggle(isDark),
               const SizedBox(height: 20),
               Text('No data for this period', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark))),
             ],
           ),
        );
     }

     final scores = filteredHistory.map((e) => e['score'] as int).toList();
     final maxScore = scores.reduce(max).toDouble().clamp(10.0, 100.0);

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
                  _buildFilterToggle(isDark),
                ],
             ),
             const SizedBox(height: 8),
             Text(
                'Best: ${progress.interviewBestScore}%',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.accentAmber, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 24),
             SizedBox(
               height: 150,
               child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(filteredHistory.length, (index) {
                     final score = filteredHistory[index]['score'] as int;
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
                                color: barColor.withValues(alpha: index == filteredHistory.length - 1 ? 1.0 : 0.6),
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

  Widget _buildFilterToggle(bool isDark) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('ALL')),
        ButtonSegment(value: 30, label: Text('30D')),
        ButtonSegment(value: 7, label: Text('7D')),
      ],
      selected: {_filterDays},
      onSelectionChanged: (val) {
        setState(() => _filterDays = val.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.transparent,
        selectedBackgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
        selectedForegroundColor: AppTheme.accentPurple,
        foregroundColor: AppTheme.textMutedC(isDark),
        textStyle: AppTheme.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
        side: BorderSide(color: AppTheme.textMutedC(isDark).withValues(alpha: 0.1)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildActivityStreak(bool isDark, ProgressService progress) {
     final streak = progress.currentStreak;
     final dates = progress.activityDates;
     final now = DateTime.now();
     
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: AppTheme.glassCard(isDark),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Icon(Icons.local_fire_department_rounded, color: AppTheme.accentPink, size: 20),
               const SizedBox(width: 8),
               Text('Learning Streak', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
               const Spacer(),
               Text('$streak Days', style: AppTheme.headingSmall.copyWith(color: AppTheme.accentPink)),
             ],
           ),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: List.generate(14, (i) {
               final date = now.subtract(Duration(days: 13 - i));
               final dateStr = date.toIso8601String().substring(0, 10);
               final isActive = dates.contains(dateStr);
               
               return Column(
                 children: [
                   Container(
                     width: 12,
                     height: 12,
                     decoration: BoxDecoration(
                       color: isActive 
                           ? AppTheme.accentPink 
                           : AppTheme.textMutedC(isDark).withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(3),
                       boxShadow: isActive ? [
                         BoxShadow(color: AppTheme.accentPink.withValues(alpha: 0.4), blurRadius: 4)
                       ] : null,
                     ),
                   ).animate(target: isActive ? 1 : 0).shimmer(),
                   const SizedBox(height: 6),
                   Text(
                     date.day.toString(),
                     style: AppTheme.bodySmall.copyWith(
                       fontSize: 8, 
                       color: isActive ? AppTheme.textPrimaryC(isDark) : AppTheme.textMutedC(isDark)
                     ),
                   ),
                 ],
               );
             }),
           ),
         ],
       ),
     );
  }

  Widget _buildMasteryPrediction(bool isDark, ProgressService progress) {
     final daysRemaining = progress.daysToNextCertificate;
     final topicsRemaining = progress.remainingTopicsForNextCert;
     final rate = progress.topicsPerDayLast7Days;
     
     // Determine next tier name
     final comp = progress.computeProgressForPredictions();
     String nextTier = "Professional";
     if (comp.threshold == 5) nextTier = "Bronze Cert";
     else if (comp.threshold == 15) nextTier = "Silver Cert";
     else if (comp.threshold == 30) nextTier = "Gold Cert";
     else if (comp.threshold > 30) nextTier = "Platinum Cert";

     final progressPercent = comp.completed / comp.threshold;

     return Container(
       padding: const EdgeInsets.all(20),
       decoration: AppTheme.glassCard(isDark).copyWith(
         border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.2)),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Icon(Icons.auto_awesome_rounded, color: AppTheme.accentAmber, size: 20),
               const SizedBox(width: 8),
               Text('Mastery Forecast', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
             ],
           ),
           const SizedBox(height: 16),
           Text(
             'Predicted $nextTier',
             style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
           ),
           const SizedBox(height: 4),
           Row(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 'In $daysRemaining Days',
                 style: AppTheme.headingMedium.copyWith(color: AppTheme.accentAmber, fontSize: 24),
               ),
               const SizedBox(width: 8),
               Padding(
                 padding: const EdgeInsets.only(bottom: 4),
                 child: Text(
                   '($topicsRemaining topics left)',
                   style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 16),
           ClipRRect(
             borderRadius: BorderRadius.circular(4),
             child: LinearProgressIndicator(
               value: progressPercent.clamp(0.0, 1.0),
               backgroundColor: AppTheme.textMutedC(isDark).withValues(alpha: 0.1),
               color: AppTheme.accentAmber,
               minHeight: 8,
             ),
           ),
           const SizedBox(height: 12),
           Text(
             'Based on your velocity of ${rate.toStringAsFixed(1)} topics/day',
             style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.textMutedC(isDark), fontStyle: FontStyle.italic),
           ),
         ],
       ),
     ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
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
