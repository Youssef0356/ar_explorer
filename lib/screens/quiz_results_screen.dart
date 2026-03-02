import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/quiz_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/achievement_badge.dart';

class QuizResultsScreen extends StatefulWidget {
  final Quiz quiz;
  final int scorePercent;
  final int correctCount;
  final int totalQuestions;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.scorePercent,
    required this.correctCount,
    required this.totalQuestions,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    final progress = context.read<ProgressService>();
    await progress.saveQuizScore(widget.quiz.id, widget.scorePercent);
    setState(() => _saved = true);
  }

  bool get _passed => widget.scorePercent >= widget.quiz.passingScore;
  bool get _aced => widget.scorePercent >= 80;

  String get _resultEmoji {
    if (widget.scorePercent >= 100) return '🏆';
    if (widget.scorePercent >= 80) return '🌟';
    if (_passed) return '✅';
    return '💪';
  }

  String get _resultMessage {
    if (widget.scorePercent >= 100) {
      return 'Perfect Score! You\'re an AR genius!';
    }
    if (widget.scorePercent >= 80) {
      return 'Outstanding! You really know your stuff!';
    }
    if (_passed) {
      return 'Great job! You passed and unlocked new content!';
    }
    return 'Not quite there yet — but you\'re learning!';
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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Result Icon ──
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _passed
                                ? [
                                    AppTheme.successGreen.withValues(
                                      alpha: 0.3,
                                    ),
                                    AppTheme.accentCyan.withValues(alpha: 0.1),
                                  ]
                                : [
                                    AppTheme.errorRed.withValues(alpha: 0.3),
                                    AppTheme.warningAmber.withValues(
                                      alpha: 0.1,
                                    ),
                                  ],
                          ),
                          border: Border.all(
                            color: _passed
                                ? AppTheme.successGreen.withValues(alpha: 0.4)
                                : AppTheme.errorRed.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _resultEmoji,
                            style: const TextStyle(fontSize: 42),
                          ),
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(),

                  const SizedBox(height: 28),

                  // ── Status Text ──
                  Text(
                    _passed ? 'Congratulations! 🎉' : 'Keep Learning! 💪',
                    style: AppTheme.headingLarge.copyWith(
                      color: _passed
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

                  const SizedBox(height: 8),

                  Text(
                    _resultMessage,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryC(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

                  const SizedBox(height: 36),

                  // ── Score Display ──
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 28,
                        ),
                        decoration: AppTheme.glassCard(isDark),
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: widget.scorePercent.toDouble(),
                              ),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: AppTheme.headingLarge.copyWith(
                                    fontSize: 56,
                                    color: _passed
                                        ? AppTheme.accentCyan
                                        : AppTheme.warningAmber,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.correctCount} of ${widget.totalQuestions} correct',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryC(isDark),
                              ),
                            ),
                            if (_passed) ...[
                              const SizedBox(height: 8),
                              Text(
                                '+${widget.scorePercent * 2} XP earned!',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.accentAmber,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 500))
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ── Achievement Badge ──
                  if (_aced)
                    Column(
                          children: [
                            AchievementBadge(
                              icon: Icons.star_rounded,
                              label: 'Quiz Ace',
                              color: AppTheme.accentAmber,
                              earned: true,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '⭐ Scored 80%+ — Achievement unlocked!',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.accentAmber,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 800))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                        ),

                  const SizedBox(height: 40),

                  // ── Action Buttons ──
                  if (!_passed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: Text('Try Again 🔄', style: AppTheme.buttonText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPink,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 700),
                    ),

                  if (_passed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home_rounded, size: 20),
                        label: Text(
                          'Back to Home 🏠',
                          style: AppTheme.buttonText,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 700),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: Text(
                          'Retake Quiz',
                          style: AppTheme.buttonText.copyWith(
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 800),
                    ),
                  ],

                  if (!_saved)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
