import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/quiz_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../services/sound_service.dart';
import '../data/modules_data.dart';
import '../widgets/shareable_achievement_card.dart';
import 'main_screen.dart';
import 'paywall_screen.dart';
import 'practice_screen.dart';

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
  List<String> _newlyUnlockedModuleIds = [];

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    final progress = context.read<ProgressService>();
    final newlyUnlocked = await progress.saveQuizScore(widget.quiz.id, widget.scorePercent);
    if (mounted) {
      setState(() {
        _saved = true;
        _newlyUnlockedModuleIds = newlyUnlocked;
      });
    }

    if (mounted) {
      final wrongCount = widget.totalQuestions - widget.correctCount;
      if (wrongCount >= 2) {
        final isDark = context.read<ThemeService>().isDarkMode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$wrongCount mistakes made. Want to strengthen your weak areas?',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
            ),
            backgroundColor: AppTheme.cardC(isDark),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Practice Now',
              textColor: AppTheme.accentPink,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PracticeScreen()),
                );
              },
            ),
          ),
        );
      }
    }

    // Show interstitial ad with 1/3 probability
    if (mounted) {
      context.read<AdService>().showInterstitialAdWithProbability(0.33);
    }
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
                                    AppTheme.successGreen.withOpacity(
                                      0.3,
                                    ),
                                    AppTheme.accentCyan.withValues(alpha: 0.1),
                                  ]
                                : [
                                    AppTheme.errorRed.withValues(alpha: 0.3),
                                    AppTheme.warningAmber.withOpacity(
                                      0.1,
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
                                        ? AppTheme.accentPurple
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
                                '+${_aced ? 100 : 60} XP earned!',
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

                  // ── Newly Unlocked Module Card ──
                  if (_newlyUnlockedModuleIds.isNotEmpty)
                    ..._newlyUnlockedModuleIds.map((id) {
                      final module = allModules.firstWhere((m) => m.id == id, orElse: () => allModules[0]);
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                        child: ShareableAchievementCard(
                          title: 'New Module Unlocked! 🔓',
                          subtitle: module.title,
                          icon: module.icon,
                          color: AppTheme.accentPurple,
                          score: '',
                          isDark: isDark,
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 600)).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                      );
                    }),

                  // ── Achievement Badge ──
                  // ── Shareable Achievement Card ──
                  if (_aced)
                    Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ShareableAchievementCard(
                            title: 'Quiz Ace',
                            subtitle: '⭐ Scored 80%+ — Achievement unlocked!',
                            icon: Icons.star_rounded,
                            color: AppTheme.accentAmber,
                            score: '${widget.scorePercent}%',
                            isDark: isDark,
                          ),
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
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 800),
                    ),
                    if (widget.quiz.id == 'quiz_intro') ...[
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.dividerC(isDark)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.glassCard(isDark).copyWith(
                          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🚀 You\'ve Mastered the Basics!',
                              style: AppTheme.headingSmall.copyWith(color: AppTheme.accentPurple),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unlock Advanced AR modules (SLAM, Technical, WebAR) to continue your journey.',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PaywallScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentPurple,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Unlock Everything'),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: const Duration(seconds: 1)),
                    ],
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
                  
                  const SizedBox(height: 32),
                  _buildXRBuilderPromo(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildXRBuilderPromo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black, // Dark focus for cyberpunk style
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🛠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Try the XR Builder',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.accentPurple, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Master 3D spatial alignment in our interactive simulator. Learn coding through building!',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall.copyWith(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<SoundService>().playTap();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Play Now 🚀'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 1200)).slideY(begin: 0.2, end: 0);
  }
}
