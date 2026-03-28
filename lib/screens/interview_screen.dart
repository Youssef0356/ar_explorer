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

class _InterviewScreenState extends State<InterviewScreen>
    with WidgetsBindingObserver {
  static const _secondsPerQuestion = 90;
  static const _totalQuestions = 10;

  bool _started = false;
  bool _finished = false;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  int _secondsRemaining = _secondsPerQuestion;
  Timer? _timer;
  final Stopwatch _totalStopwatch = Stopwatch();
  String? _selectedCategory;

  // Map of module title → quiz IDs that belong to that module
  // Built once so the dropdown and filtering are always in sync
  late final Map<String, List<String>> _moduleTitleToQuizIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buildModuleQuizMap();
  }

  /// Build a lookup: moduleTitle → [quizId, ...] using allQuizzes.moduleId
  void _buildModuleQuizMap() {
    final map = <String, List<String>>{};
    for (final module in allModules) {
      final quizIds = allQuizzes.entries
          .where((e) => e.value.moduleId == module.id)
          .map((e) => e.key)
          .toList();
      if (quizIds.isNotEmpty) {
        map[module.title] = quizIds;
      }
    }
    _moduleTitleToQuizIds = map;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started || _finished || _showResult) return;
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _totalStopwatch.stop();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
      _totalStopwatch.start();
    }
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) _timeUp();
    });
  }

  void _startInterview() async {
    final progress = context.read<ProgressService>();
    
    if (!progress.isPremium) {
      if (progress.interviewAttemptsLeft <= 0) {
        if (progress.xp >= 50) {
          final confirm = await _showXpUnlockDialog(progress);
          if (confirm != true) return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough XP (50 required) and no free attempts left. Earn more XP or Upgrade to PRO!'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
          return;
        }
      } else {
        await progress.useInterviewAttempt();
      }
    }

    List<QuizQuestion> pool = [];

    if (_selectedCategory == null) {
      // All topics — draw from every quiz
      pool = allQuizzes.values.expand((q) => q.questions).toList();
    } else {
      // Filter by the selected module: use the pre-built quiz ID map
      final quizIds = _moduleTitleToQuizIds[_selectedCategory] ?? [];
      for (final id in quizIds) {
        final quiz = allQuizzes[id];
        if (quiz != null) pool.addAll(quiz.questions);
      }

      // Safety: if module has no mapped quizzes, fall back gracefully
      if (pool.isEmpty) {
        pool = allQuizzes.values.expand((q) => q.questions).toList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'No quiz questions found for "$_selectedCategory" — showing mixed questions.'),
            backgroundColor: AppTheme.warningAmber,
          ));
        }
      }
    }

    pool.shuffle(Random());

    // Shuffle the OPTIONS within each question so the correct answer
    // doesn't always sit at the same index (the raw data is biased to index 1).
    final rng = Random();
    final shuffled = pool.take(min(_totalQuestions, pool.length)).map((q) {
      final indices = List<int>.generate(q.options.length, (i) => i);
      indices.shuffle(rng);
      final newOptions = [for (final i in indices) q.options[i]];
      final newCorrect = indices.indexOf(q.correctIndex);
      return QuizQuestion(
        id: q.id,
        question: q.question,
        options: newOptions,
        correctIndex: newCorrect,
        explanation: q.explanation,
        relatedTopicId: q.relatedTopicId,
        relatedModuleId: q.relatedModuleId,
      );
    }).toList();

    setState(() {
      _questions = shuffled;
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
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) _timeUp();
    });
  }

  void _timeUp() {
    _timer?.cancel();
    if (!_showResult) {
      setState(() {
        _showResult = true;
        _selectedOption = -1;
      });
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _selectOption(int index) {
    if (_showResult) return;
    _timer?.cancel();
    final q = _questions[_currentIndex];
    if (index == q.correctIndex) _correctCount++;
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

  // ── Back navigation — always cancel timer ────────────────────────────────
  void _handleBack() {
    _timer?.cancel();
    _totalStopwatch.stop();
    if (_started && !_finished) {
      // Confirm exit mid-interview
      _showExitConfirm();
    } else {
      Navigator.pop(context);
    }
  }

  void _showExitConfirm() {
    final isDark = context.read<ThemeService>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Exit Interview?',
            style: AppTheme.headingSmall
                .copyWith(color: AppTheme.textPrimaryC(isDark))),
        content: Text(
            'Your current session will be lost. Exit anyway?',
            style: AppTheme.bodyMedium
                .copyWith(color: AppTheme.textSecondaryC(isDark))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Going',
                style:
                    AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _started = false;
                _finished = false;
              });
              Navigator.pop(context);
            },
            child: Text('Exit',
                style:
                    AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showXpUnlockDialog(ProgressService progress) {
    final isDark = context.read<ThemeService>().isDarkMode;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text('Unlock Attempt', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
          ],
        ),
        content: Text('You are out of free attempts. Unlock a new mock interview attempt for 50 XP?', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedC(isDark))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan),
            onPressed: () async {
              final ok = await progress.spendXP(50);
              Navigator.pop(ctx, ok);
            },
            child: Text('-50 XP', style: AppTheme.bodyMedium.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        body: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
          child: SafeArea(
            child: _finished
                ? _buildResults(isDark)
                : _started
                    ? _buildQuiz(isDark)
                    : _buildIntro(isDark),
          ),
        ),
      ),
    );
  }

  // ── Intro ─────────────────────────────────────────────────────────────────
  Widget _buildIntro(bool isDark) {
    final bestScore = context.watch<ProgressService>().interviewBestScore;
    final isPremium = context.watch<ProgressService>().isPremium;

    // Only show modules that actually have quizzes
    final availableCategories = _moduleTitleToQuizIds.keys.toList();

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
                    color: AppTheme.accentAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: AppTheme.accentAmber, size: 40),
                ),
                const SizedBox(height: 24),
                Text('Mock Interview',
                    style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textPrimaryC(isDark))),
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
                      color: AppTheme.accentCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Best: $bestScore%',
                        style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 12),
                Consumer<ProgressService>(
                  builder: (context, progress, _) {
                    if (progress.isPremium) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.all_inclusive_rounded,
                                color: AppTheme.successGreen, size: 16),
                            const SizedBox(width: 8),
                            Text('Unlimited Premium Attempts',
                                style: AppTheme.labelMedium
                                    .copyWith(color: AppTheme.successGreen)),
                          ],
                        ),
                      );
                    }
                    final left = progress.interviewAttemptsLeft;
                    final hasFree = left > 0;
                    return Column(
                      children: [
                        Text(
                          'Free Attempts: $left / 2',
                          style: AppTheme.bodySmall.copyWith(
                            color: hasFree ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!hasFree) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Costs 50 XP per attempt',
                            style: AppTheme.bodySmall.copyWith(
                              color: progress.xp >= 50 ? AppTheme.accentCyan : AppTheme.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]
                      ],
                    );
                  },
                ),

                // ── Category selector (Premium only) ──────────────────────
                if (isPremium) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Topic Focus',
                        style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondaryC(isDark))),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: AppTheme.glassCard(isDark),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        hint: Text('All Modules (Mixed)',
                            style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textPrimaryC(isDark))),
                        dropdownColor: AppTheme.cardC(isDark),
                        style: AppTheme.bodySmall
                            .copyWith(color: AppTheme.textPrimaryC(isDark)),
                        icon: Icon(Icons.arrow_drop_down_rounded,
                            color: AppTheme.textMutedC(isDark)),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Modules (Mixed)'),
                          ),
                          ...availableCategories.map((title) =>
                              DropdownMenuItem<String>(
                                value: title,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val),
                      ),
                    ),
                  ),
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildCategoryPreview(isDark),
                    ),
                ],

                const SizedBox(height: 32),
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

  /// Small preview showing how many questions are available for chosen category
  Widget _buildCategoryPreview(bool isDark) {
    final quizIds = _moduleTitleToQuizIds[_selectedCategory] ?? [];
    final count =
        quizIds.fold<int>(0, (sum, id) => sum + (allQuizzes[id]?.questions.length ?? 0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded,
            size: 13, color: AppTheme.accentCyan.withOpacity(0.7)),
        const SizedBox(width: 5),
        Text(
          '$count questions available in this topic',
          style: AppTheme.bodySmall.copyWith(
              color: AppTheme.accentCyan.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────
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
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimaryC(isDark)),
                onPressed: _handleBack,
              ),
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
                  color: timerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, color: timerColor, size: 18),
                    const SizedBox(width: 4),
                    Text('${_secondsRemaining}s',
                        style: AppTheme.labelMedium.copyWith(
                            color: timerColor, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timerFraction,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(timerColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            q.question,
            style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimaryC(isDark), fontSize: 17),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'See Results'),
              ),
            ),
          ],
          if (!_showResult) const Spacer(),
        ],
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _buildResults(bool isDark) {
    final pct = ((_correctCount / _questions.length) * 100).round();
    final elapsed = _totalStopwatch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final categoryLabel = _selectedCategory ?? 'All Modules';

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
                Text(_readinessTier,
                    style: AppTheme.headingLarge
                        .copyWith(color: _tierColor, fontSize: 26)),
                const SizedBox(height: 8),
                Text(
                  'Topic: $categoryLabel',
                  style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMutedC(isDark)),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      _tierColor.withOpacity(0.3),
                      _tierColor.withOpacity(0.1),
                    ]),
                    border: Border.all(
                        color: _tierColor.withOpacity(0.5), width: 3),
                  ),
                  child: Center(
                    child: Text('$pct%',
                        style: AppTheme.headingLarge
                            .copyWith(color: _tierColor, fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('$_correctCount / ${_questions.length} correct',
                    style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark))),
                const SizedBox(height: 8),
                Text('Time: ${minutes}m ${seconds}s',
                    style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMutedC(isDark))),
                const SizedBox(height: 12),
                Text(
                  '+${pct >= 90 ? 110 : (pct >= 70 ? 80 : 30)} XP earned!',
                  style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentAmber,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _started = false;
                      _finished = false;
                    }),
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Home',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.accentCyan)),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .scale(
                  begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
          const Spacer(),
        ],
      ),
    );
  }
}
