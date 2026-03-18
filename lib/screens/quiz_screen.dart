import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../models/quiz_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../widgets/quiz_option_button.dart';
import 'quiz_results_screen.dart';
import 'topic_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  final List<int?> _answers = [];

  QuizQuestion get _currentQuestion => _questions[_currentIndex];
  int get _totalQuestions => _questions.length;
  double get _progress => (_currentIndex + 1) / _totalQuestions;

  @override
  void initState() {
    super.initState();
    // Randomize the question set for this attempt. Take up to 6
    // questions from the full pool.
    _questions = List<QuizQuestion>.from(widget.quiz.questions);
    _questions.shuffle();
    if (_questions.length > 6) {
      _questions = _questions.take(6).toList();
    }

    _answers.addAll(List.filled(_totalQuestions, null));
  }

  void _selectOption(int index) {
    if (_showResult) return;
    context.read<SoundService>().playTap();
    setState(() {
      _selectedOption = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;
    context.read<SoundService>().playTap();
    setState(() {
      _showResult = true;
      _answers[_currentIndex] = _selectedOption;
      if (_selectedOption == _currentQuestion.correctIndex) {
        _correctCount++;
        context.read<ProgressService>().removeWrongAnswer(_currentQuestion.id);
      } else {
        context.read<ProgressService>().saveWrongAnswer(_currentQuestion.id);
      }
    });
  }

  void _nextQuestion() {
    context.read<SoundService>().playTap();
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showResult = false;
      });
    } else {
      final scorePercent = ((_correctCount / _totalQuestions) * 100).round();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context2, animation, secondaryAnimation) =>
              QuizResultsScreen(
                quiz: widget.quiz,
                scorePercent: scorePercent,
                correctCount: _correctCount,
                totalQuestions: _totalQuestions,
              ),
          transitionsBuilder: (context2, anim, secondaryAnim, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();

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
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.textPrimaryC(isDark),
                      onPressed: () {
                        soundService.playTap();
                        _showExitDialog(context, isDark);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.quiz.title,
                            style: AppTheme.headingSmall.copyWith(
                              fontSize: 16,
                              color: AppTheme.textPrimaryC(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '❓ Question ${_currentIndex + 1} of $_totalQuestions',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.accentPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Streak indicator
                    if (_correctCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 $_correctCount',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.accentAmber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Progress Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppTheme.accentPink.withValues(
                        alpha: 0.1,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentPink,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ),

              // ── Question Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Container(
                            key: ValueKey(_currentIndex),
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.glassCard(isDark),
                            child: Text(
                              _currentQuestion.question,
                              style: AppTheme.headingSmall.copyWith(
                                fontSize: 17,
                                height: 1.5,
                                color: AppTheme.textPrimaryC(isDark),
                              ),
                            ),
                          )
                          .animate(key: ValueKey('q_$_currentIndex'))
                          .fadeIn(duration: const Duration(milliseconds: 400))
                          .slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 24),

                      // Options
                      ...List.generate(
                        _currentQuestion.options.length,
                        (i) =>
                            Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: QuizOptionButton(
                                    text: _currentQuestion.options[i],
                                    index: i,
                                    isSelected: _selectedOption == i,
                                    isCorrect:
                                        i == _currentQuestion.correctIndex,
                                    showResult: _showResult,
                                    isDark: isDark,
                                    onTap: () => _selectOption(i),
                                  ),
                                )
                                .animate(
                                  key: ValueKey('opt_${_currentIndex}_$i'),
                                )
                                .fadeIn(
                                  delay: Duration(milliseconds: 100 * i),
                                  duration: const Duration(milliseconds: 400),
                                )
                                .slideX(
                                  begin: 0.05,
                                  end: 0,
                                  delay: Duration(milliseconds: 100 * i),
                                ),
                      ),

                      // Explanation
                      if (_showResult) ...[
                        const SizedBox(height: 8),
                        Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCyan.withValues(
                                  alpha: isDark ? 0.08 : 0.06,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.accentCyan.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: AppTheme.accentCyan,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '💡 Explanation',
                                          style: AppTheme.labelMedium.copyWith(
                                            color: AppTheme.accentCyan,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _currentQuestion.explanation,
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textSecondaryC(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                        if (_currentQuestion.relatedTopicId != null) ...[
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              soundService.playTap();
                                              final moduleId = _currentQuestion.relatedModuleId ?? widget.quiz.moduleId;
                                              final module = allModules.firstWhere((m) => m.id == moduleId);
                                              final topicIndex = module.topics.indexWhere((t) => t.id == _currentQuestion.relatedTopicId);
                                              
                                              if (topicIndex != -1) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => TopicScreen(
                                                      topic: module.topics[topicIndex],
                                                      moduleId: module.id,
                                                      accentColor: AppTheme.getModuleColor(allModules.indexOf(module)),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.menu_book_rounded, size: 16),
                                            label: Text(
                                              'Deep Dive',
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.accentCyan,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.accentCyan,
                                              side: BorderSide(color: AppTheme.accentCyan.withOpacity(0.5)),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 400))
                            .slideY(begin: 0.1, end: 0),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Action Button ──
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showResult
                        ? _nextQuestion
                        : (_selectedOption != null ? _submitAnswer : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showResult
                          ? AppTheme.accentPink
                          : AppTheme.accentCyan,
                      disabledBackgroundColor: AppTheme.cardC(isDark),
                      disabledForegroundColor: AppTheme.textMutedC(isDark),
                    ),
                    child: Text(
                      _showResult
                          ? (_currentIndex < _totalQuestions - 1
                                ? 'Next Question →'
                                : 'See Results 🎉')
                          : 'Submit Answer ✅',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context, bool isDark) {
    final soundService = context.read<SoundService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text('😢', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'Leave Quiz?',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimaryC(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Your progress will be lost.\nAre you sure?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryC(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              soundService.playTap();
              Navigator.pop(ctx);
            },
            child: Text(
              'Stay 💪',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan),
            ),
          ),
          TextButton(
            onPressed: () {
              soundService.playTap();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'Leave',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
