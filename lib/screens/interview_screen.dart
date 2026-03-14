import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/quiz_option_button.dart';
import 'paywall_screen.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  static const _secondsPerQuestion = 90;
  static const _totalQuestions = 10;

  bool _started = false;
  bool _finished = false;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  bool _limitReached = false;
  int _secondsRemaining = _secondsPerQuestion;
  Timer? _timer;
  final Stopwatch _totalStopwatch = Stopwatch();
  String? _selectedCategory;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startInterview() async {
    final progress = context.read<ProgressService>();
    if (progress.interviewAttemptsLeft <= 0 && !progress.isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }

    if (!progress.isPremium) {
       await progress.useInterviewAttempt();
    }

    Iterable<QuizQuestion> all = [];
    if (_selectedCategory == null) {
       // All topics
       all = allQuizzes.values.expand((quiz) => quiz.questions);
    } else {
       // Filtered by Module title
       final module = allModules.firstWhere((m) => m.title == _selectedCategory);
       final relatedQuizzes = module.topics.where((t) => t.quizId != null).map((t) => allQuizzes[t.quizId!]);
       all = relatedQuizzes.where((q) => q != null).expand((quiz) => quiz!.questions);
    }

    final shuffled = all.toList()..shuffle(Random());
    if (shuffled.isEmpty) {
        // Fallback safety
        shuffled.addAll(allQuizzes.values.expand((quiz) => quiz.questions).toList()..shuffle(Random()));
    }

    setState(() {
      _questions = shuffled.take(min(_totalQuestions, shuffled.length)).toList();
      _started = true;
      _finished = false;
      _currentIndex = 0;
      _selectedOption = null;
      _showResult = false;
      _correctCount = 0;
      _secondsRemaining = _secondsPerQuestion;
    });

    _totalStopwatch
      ..reset()
      ..start();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        _timeUp();
      }
    });
  }

  void _timeUp() {
    _timer?.cancel();
    if (!_showResult) {
      setState(() {
        _showResult = true;
        _selectedOption = -1; // no selection
      });
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _selectOption(int index) {
    if (_showResult) return;
    _timer?.cancel();

    final q = _questions[_currentIndex];
    final isCorrect = index == q.correctIndex;
    if (isCorrect) _correctCount++;

    setState(() {
      _selectedOption = index;
      _showResult = true;
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showResult = false;
      });
      _startTimer();
    } else {
      _finishInterview();
    }
  }

  void _finishInterview() {
    _timer?.cancel();
    _totalStopwatch.stop();
    final scorePercent =
        ((_correctCount / _questions.length) * 100).round();
    context.read<ProgressService>().saveInterviewScore(scorePercent);
    setState(() => _finished = true);
  }

  String get _readinessTier {
    final pct = ((_correctCount / _questions.length) * 100).round();
    if (pct >= 91) return '🏆 AR Expert / Lead';
    if (pct >= 71) return '⚡ Senior AR Dev';
    if (pct >= 51) return '🔍 Mid-Level AR Dev';
    if (pct >= 31) return '📱 Junior AR Dev';
    return '📚 Needs More Study';
  }

  Color get _tierColor {
    final pct = ((_correctCount / _questions.length) * 100).round();
    if (pct >= 91) return AppTheme.accentAmber;
    if (pct >= 71) return AppTheme.accentCyan;
    if (pct >= 51) return AppTheme.accentBlue;
    if (pct >= 31) return AppTheme.accentOrange;
    return AppTheme.accentPink;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: _finished
              ? _buildResults(isDark)
              : _started
                  ? _buildQuiz(isDark)
                  : _buildIntro(isDark),
        ),
      ),
    );
  }

  Widget _buildIntro(bool isDark) {
    final bestScore =
        context.watch<ProgressService>().interviewBestScore;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: AppTheme.textPrimaryC(isDark)),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.work_rounded,
                    color: AppTheme.accentAmber,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mock Interview',
                  style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.textPrimaryC(isDark)),
                ),
                const SizedBox(height: 12),
                Text(
                  '10 questions • 90 seconds each\nNo hints • Timed • Scored',
                  style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryC(isDark)),
                  textAlign: TextAlign.center,
                ),
                if (bestScore > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Best: $bestScore%',
                      style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accentCyan,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Consumer<ProgressService>(
                  builder: (context, progress, _) {
                    if (progress.isPremium) {
                       return Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                             color: AppTheme.successGreen.withValues(alpha: 0.15),
                             borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                                const Icon(Icons.all_inclusive_rounded, color: AppTheme.successGreen, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                   'Unlimited Premium Attempts',
                                   style: AppTheme.labelMedium.copyWith(color: AppTheme.successGreen),
                                )
                             ],
                          ),
                       );
                    }
                    final left = progress.interviewAttemptsLeft;
                    return Text(
                      'Daily attempts: $left / 2',
                      style: AppTheme.bodySmall.copyWith(
                        color: left > 0 ? AppTheme.accentCyan : AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                Consumer<ProgressService>(
                   builder: (context, progress, _) {
                      if (!progress.isPremium) return const SizedBox(height: 32);
                      return Padding(
                         padding: const EdgeInsets.symmetric(vertical: 24.0),
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('Topic Focus (Premium)', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondaryC(isDark))),
                               const SizedBox(height: 8),
                               Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: AppTheme.glassCard(isDark),
                                  child: DropdownButtonHideUnderline(
                                     child: DropdownButton<String>(
                                        value: _selectedCategory,
                                        isExpanded: true,
                                        hint: Text('All Modules (Mixed)', style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
                                        dropdownColor: AppTheme.cardC(isDark),
                                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
                                        icon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textMutedC(isDark)),
                                        items: [
                                           DropdownMenuItem(value: null, child: Text('All Modules (Mixed)')),
                                           ...allModules.map((m) => DropdownMenuItem(value: m.title, child: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis))),
                                        ],
                                        onChanged: (val) => setState(() => _selectedCategory = val),
                                     ),
                                  ),
                               )
                            ],
                         ),
                      );
                   },
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _startInterview,
                    child: const Text('Start Interview'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentIndex];
    final timerFraction = _secondsRemaining / _secondsPerQuestion;
    final timerColor = _secondsRemaining <= 15
        ? AppTheme.errorRed
        : _secondsRemaining <= 30
            ? AppTheme.warningAmber
            : AppTheme.accentCyan;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Text(
                'Question ${_currentIndex + 1} / ${_questions.length}',
                style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimaryC(isDark)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded,
                        color: timerColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_secondsRemaining}s',
                      style: AppTheme.labelMedium.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Timer Bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timerFraction,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(timerColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),

          // ── Question ──
          Text(
            q.question,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 20),

          // ── Options ──
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'See Results',
                ),
              ),
            ),
          ],
          if (!_showResult) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    final pct = ((_correctCount / _questions.length) * 100).round();
    final elapsed = _totalStopwatch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimaryC(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  _readinessTier,
                  style: AppTheme.headingLarge.copyWith(
                      color: _tierColor, fontSize: 26),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _tierColor.withValues(alpha: 0.3),
                        _tierColor.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                        color: _tierColor.withValues(alpha: 0.5),
                        width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: AppTheme.headingLarge.copyWith(
                        color: _tierColor,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$_correctCount / ${_questions.length} correct',
                  style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.textPrimaryC(isDark)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${minutes}m ${seconds}s',
                  style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textMutedC(isDark)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _startInterview,
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Home',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.accentCyan),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
              ),
          const Spacer(),
        ],
      ),
    );
  }
}
