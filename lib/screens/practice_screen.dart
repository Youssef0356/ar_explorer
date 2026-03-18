import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/quiz_option_button.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _showingMenu = true;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  String _mode = '';

  List<QuizQuestion> _getAllQuestions() {
    return allQuizzes.values
        .expand((quiz) => quiz.questions)
        .toList();
  }

  void _startReviewMode() {
    final progress = context.read<ProgressService>();
    final wrongIds = progress.wrongAnswers;
    final all = _getAllQuestions();
    final questions =
        all.where((q) => wrongIds.contains(q.id)).toList()..shuffle();

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No wrong answers to review yet. Take some quizzes first!'),
          backgroundColor: AppTheme.accentCyan,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _mode = 'Review Weak Areas';
      _questions = questions.take(10).toList();
      _currentIndex = 0;
      _selectedOption = null;
      _showResult = false;
      _correctCount = 0;
      _showingMenu = false;
    });
  }

  void _startDailyChallenge() {
    final progress = context.read<ProgressService>();
    if (progress.hasDoneDailyChallenge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Daily challenge completed! Come back tomorrow 🌅'),
          backgroundColor: AppTheme.accentAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final all = _getAllQuestions()..shuffle(Random());

    setState(() {
      _mode = 'Daily Challenge';
      _questions = all.take(5).toList();
      _currentIndex = 0;
      _selectedOption = null;
      _showResult = false;
      _correctCount = 0;
      _showingMenu = false;
    });
  }

  void _selectOption(int index) {
    if (_showResult) return;
    final progress = context.read<ProgressService>();
    final q = _questions[_currentIndex];
    final isCorrect = index == q.correctIndex;

    if (isCorrect) {
      _correctCount++;
      progress.removeWrongAnswer(q.id);
    } else {
      progress.saveWrongAnswer(q.id);
    }

    setState(() {
      _selectedOption = index;
      _showResult = true;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showResult = false;
      });
    } else {
      // Done
      if (_mode == 'Daily Challenge') {
        context.read<ProgressService>().markDailyChallengeComplete();
      }
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final isDark = context.read<ThemeService>().isDarkMode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$_mode Complete!',
          style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimaryC(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctCount / ${_questions.length} correct',
              style: AppTheme.headingLarge.copyWith(color: AppTheme.accentCyan),
            ),
            const SizedBox(height: 12),
            Text(
              _correctCount == _questions.length
                  ? '🎉 Perfect! You nailed it!'
                  : _correctCount > _questions.length / 2
                      ? '💪 Good job! Keep practicing!'
                      : '📚 Review the topics and try again!',
              style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryC(isDark)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _showingMenu = true);
            },
            child: Text('Done',
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: _showingMenu
              ? _buildMenu(isDark)
              : _buildQuiz(isDark),
        ),
      ),
    );
  }

  Widget _buildMenu(bool isDark) {
    final progress = context.watch<ProgressService>();
    final weakCount = progress.wrongAnswers.length;
    final doneDailyToday = progress.hasDoneDailyChallenge;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimaryC(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Practice Mode',
                style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimaryC(isDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Strengthen your weak areas and stay sharp with daily challenges',
            style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textMutedC(isDark)),
          ),
          const SizedBox(height: 32),

          // ── Review Weak Areas ──
          _PracticeModeCard(
            icon: Icons.replay_circle_filled_rounded,
            title: 'Review Weak Areas',
            subtitle: weakCount > 0
                ? '$weakCount questions to review'
                : 'No wrong answers yet!',
            color: AppTheme.accentPink,
            isDark: isDark,
            enabled: weakCount > 0,
            onTap: _startReviewMode,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

          const SizedBox(height: 16),

          // ── Daily Challenge ──
          _PracticeModeCard(
            icon: Icons.bolt_rounded,
            title: 'Daily Challenge',
            subtitle: doneDailyToday
                ? '✅ Completed! Come back tomorrow'
                : '5 random questions — test yourself!',
            color: AppTheme.accentAmber,
            isDark: isDark,
            enabled: !doneDailyToday,
            onTap: _startDailyChallenge,
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              ),

          const Spacer(),
          Center(
            child: Text(
              '💡 Wrong answers from quizzes are automatically saved here',
              style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textMutedC(isDark)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimaryC(isDark)),
                onPressed: () => setState(() => _showingMenu = true),
              ),
              const SizedBox(width: 8),
              Text(
                _mode,
                style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimaryC(isDark)),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentCyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            q.question,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(q.options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: QuizOptionButton(
                text: q.options[i],
                index: i,
                isSelected: _selectedOption == i,
                isCorrect: i == q.correctIndex,
                showResult: _showResult,
                isDark: isDark,
                onTap: () => _selectOption(i),
              ),
            );
          }),
          if (_showResult) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardC(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerC(isDark)),
              ),
              child: Text(
                q.explanation,
                style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryC(isDark)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Finish',
                ),
              ),
            ),
          ],
          if (!_showResult) const Spacer(),
        ],
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardC(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? color.withOpacity(isDark ? 0.3 : 0.2)
                : AppTheme.dividerC(isDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(enabled ? 0.15 : 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled ? color : AppTheme.textMutedC(isDark),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headingSmall.copyWith(
                      color: enabled
                          ? AppTheme.textPrimaryC(isDark)
                          : AppTheme.textMutedC(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: enabled ? color : AppTheme.textMutedC(isDark),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
