import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/learning/modules_data.dart';
import '../../data/learning/quiz_data.dart';
import '../../models/quiz_model.dart';
import '../../services/progress_service.dart';
import '../../services/theme_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/quiz_option_button.dart';
import '../settings/paywall_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  INTERVIEWER MOOD SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════

enum InterviewerMood {
  greeting,    // 👋  Intro screen welcome
  idle,        // 🤔  Waiting for answer
  curious,     // 🧐  Timer 30-60s
  impatient,   // 😤  Timer < 15s
  angry,       // 😡  Timer < 5s
  suspicious,  // 🤨  User selected an option (pre-reveal)
  happy,       // 😄  Correct answer
  celebrating, // 🥳  Streak 3+
  disappointed,// 😞  Wrong answer
  shocked,     // 😱  Time ran out
  impressed,   // 🤩  Great score result
  mindBlown,   // 🤯  Perfect score
  sad,         // 😢  Poor score
  cool,        // 😎  Good score result
}

extension InterviewerMoodEmoji on InterviewerMood {
  String get emoji {
    switch (this) {
      case InterviewerMood.greeting:     return '👋';
      case InterviewerMood.idle:         return '🤔';
      case InterviewerMood.curious:      return '🧐';
      case InterviewerMood.impatient:    return '😤';
      case InterviewerMood.angry:        return '😡';
      case InterviewerMood.suspicious:   return '🤨';
      case InterviewerMood.happy:        return '😄';
      case InterviewerMood.celebrating:  return '🥳';
      case InterviewerMood.disappointed: return '😞';
      case InterviewerMood.shocked:      return '😱';
      case InterviewerMood.impressed:    return '🤩';
      case InterviewerMood.mindBlown:    return '🤯';
      case InterviewerMood.sad:          return '😢';
      case InterviewerMood.cool:         return '😎';
    }
  }

  Color get glowColor {
    switch (this) {
      case InterviewerMood.greeting:     return const Color(0xFF64B5F6);
      case InterviewerMood.idle:         return const Color(0xFF90CAF9);
      case InterviewerMood.curious:      return const Color(0xFFFFD54F);
      case InterviewerMood.impatient:    return const Color(0xFFFF8A65);
      case InterviewerMood.angry:        return const Color(0xFFEF5350);
      case InterviewerMood.suspicious:   return const Color(0xFFFFB74D);
      case InterviewerMood.happy:        return const Color(0xFF66BB6A);
      case InterviewerMood.celebrating:  return const Color(0xFFFFD700);
      case InterviewerMood.disappointed: return const Color(0xFF78909C);
      case InterviewerMood.shocked:      return const Color(0xFFE040FB);
      case InterviewerMood.impressed:    return const Color(0xFFFFD700);
      case InterviewerMood.mindBlown:    return const Color(0xFFFF6E40);
      case InterviewerMood.sad:          return const Color(0xFF42A5F5);
      case InterviewerMood.cool:         return const Color(0xFF26C6DA);
    }
  }

  String get comment {
    switch (this) {
      case InterviewerMood.greeting:     return "Ready for your interview? Let's go! 🎤";
      case InterviewerMood.idle:         return 'Hmm, take your time...';
      case InterviewerMood.curious:      return 'Interesting... what do you think?';
      case InterviewerMood.impatient:    return 'Tick tock! Time is running out!';
      case InterviewerMood.angry:        return 'HURRY UP!! ⏰';
      case InterviewerMood.suspicious:   return 'Are you sure about that? 🤨';
      case InterviewerMood.happy:        return 'Nailed it! Great answer! ✅';
      case InterviewerMood.celebrating:  return "You're on FIRE! 🔥🔥🔥";
      case InterviewerMood.disappointed: return 'Oops, not quite right...';
      case InterviewerMood.shocked:      return "Time's up! Oh no! ⏰";
      case InterviewerMood.impressed:    return 'Outstanding performance! 🌟';
      case InterviewerMood.mindBlown:    return 'PERFECT?! You absolute legend!! 🏆';
      case InterviewerMood.sad:          return 'Keep studying, you got this! 💪';
      case InterviewerMood.cool:         return 'Solid work! Well done! 😎';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  INTERVIEW SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const _totalInterviewSeconds = 900; // 15 mins total
  static const _totalQuestions = 10;

  bool _started = false;
  bool _finished = false;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  int _secondsRemaining = _totalInterviewSeconds;
  Timer? _timer;
  final Stopwatch _totalStopwatch = Stopwatch();
  String? _selectedCategory;

  // ── New: Mood & streak ────────────────────────────────────────────────────
  InterviewerMood _currentMood = InterviewerMood.greeting;
  int _streak = 0;
  bool _showConfetti = false;
  late AnimationController _emojiAnimController;
  late AnimationController _pulseController;

  late final Map<String, List<String>> _moduleTitleToQuizIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buildModuleQuizMap();
    _emojiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

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
    _emojiAnimController.dispose();
    _pulseController.dispose();
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
      setState(() {
        _secondsRemaining--;
        _updateMoodFromTimer();
      });
      if (_secondsRemaining <= 0) _timeUp();
    });
  }

  // ── Mood updates ──────────────────────────────────────────────────────────
  void _updateMoodFromTimer() {
    if (_showResult) return;
    if (_secondsRemaining <= 5) {
      _setMood(InterviewerMood.angry);
    } else if (_secondsRemaining <= 15) {
      _setMood(InterviewerMood.impatient);
    } else if (_secondsRemaining <= 45) {
      _setMood(InterviewerMood.curious);
    } else {
      _setMood(InterviewerMood.idle);
    }
  }

  void _setMood(InterviewerMood mood) {
    if (_currentMood != mood) {
      setState(() => _currentMood = mood);
      _emojiAnimController.forward(from: 0);
    }
  }

  // ── Start ─────────────────────────────────────────────────────────────────
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
      pool = allQuizzes.values.expand((q) => q.questions).toList();
    } else {
      final quizIds = _moduleTitleToQuizIds[_selectedCategory] ?? [];
      for (final id in quizIds) {
        final quiz = allQuizzes[id];
        if (quiz != null) pool.addAll(quiz.questions);
      }
      if (pool.isEmpty) {
        pool = allQuizzes.values.expand((q) => q.questions).toList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No quiz questions found for "$_selectedCategory" — showing mixed questions.'),
            backgroundColor: AppTheme.warningAmber,
          ));
        }
      }
    }

    pool.shuffle(Random());

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
      _streak = 0;
      _secondsRemaining = _totalInterviewSeconds;
      _currentMood = InterviewerMood.idle;
    });

    _totalStopwatch
      ..reset()
      ..start();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining--;
        _updateMoodFromTimer();
      });
      if (_secondsRemaining <= 0) _timeUp();
    });
  }

  void _timeUp() {
    _timer?.cancel();
    if (!_showResult) {
      _streak = 0;
      _setMood(InterviewerMood.shocked);
      context.read<SoundService>().playFailure();
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
    final isCorrect = index == q.correctIndex;

    if (isCorrect) {
      _correctCount++;
      _streak++;
      if (_streak >= 3) {
        _setMood(InterviewerMood.celebrating);
      } else {
        _setMood(InterviewerMood.happy);
      }
      context.read<SoundService>().playSuccess();
    } else {
      _streak = 0;
      _setMood(InterviewerMood.disappointed);
      context.read<SoundService>().playFailure();
    }

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
        _currentMood = InterviewerMood.idle;
      });
      _startTimer();
    } else {
      _finishInterview();
    }
  }

  void _finishInterview() {
    _timer?.cancel();
    _totalStopwatch.stop();
    final scorePercent = ((_correctCount / _questions.length) * 100).round();
    context.read<ProgressService>().saveInterviewScore(scorePercent);
    context.read<SoundService>().playAchievement();

    // Set result mood
    if (scorePercent == 100) {
      _currentMood = InterviewerMood.mindBlown;
      _showConfetti = true;
    } else if (scorePercent >= 80) {
      _currentMood = InterviewerMood.impressed;
      _showConfetti = true;
    } else if (scorePercent >= 60) {
      _currentMood = InterviewerMood.cool;
    } else {
      _currentMood = InterviewerMood.sad;
    }

    setState(() => _finished = true);
  }

  void _handleBack() {
    _timer?.cancel();
    _totalStopwatch.stop();
    if (_started && !_finished) {
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
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('😰', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text('Leaving already?',
                style: AppTheme.headingSmall
                    .copyWith(color: AppTheme.textPrimaryC(isDark))),
          ],
        ),
        content: Text(
            'Your interviewer will be sad... Session will be lost!',
            style: AppTheme.bodyMedium
                .copyWith(color: AppTheme.textSecondaryC(isDark))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Stay 💪',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.successGreen)),
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
            child: Text('Leave 👋',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed)),
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
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🎟️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(child: Text('Unlock Attempt', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)))),
          ],
        ),
        content: Text('No free attempts left. Spend 50 XP to enter?',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedC(isDark))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
    if (pct >= 91) return const Color(0xFFFFD700);
    if (pct >= 71) return AppTheme.accentCyan;
    if (pct >= 51) return AppTheme.accentBlue;
    if (pct >= 31) return AppTheme.accentOrange;
    return AppTheme.accentPink;
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0D0D1A), const Color(0xFF1A0A2E), const Color(0xFF0D0D1A)]
                  : [const Color(0xFFF0F4FF), const Color(0xFFE8E0F0), const Color(0xFFF5F0FF)],
            ),
          ),
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

  // ═════════════════════════════════════════════════════════════════════════
  //  INTERVIEWER FACE WIDGET
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildInterviewerFace({
    double size = 80,
    bool showTimer = false,
    bool large = false,
  }) {
    final glowColor = _currentMood.glowColor;

    Widget face = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: child,
      ),
      child: Text(
        _currentMood.emoji,
        key: ValueKey(_currentMood),
        style: TextStyle(fontSize: large ? size * 0.55 : size * 0.5),
      ),
    );

    // Add mood-specific animations
    if (_currentMood == InterviewerMood.angry || _currentMood == InterviewerMood.impatient) {
      face = face.animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 800.ms, color: glowColor.withValues(alpha: 0.3))
          .shake(hz: _currentMood == InterviewerMood.angry ? 6 : 3, offset: const Offset(2, 0));
    } else if (_currentMood == InterviewerMood.celebrating || _currentMood == InterviewerMood.mindBlown) {
      face = face.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 400.ms);
    } else if (_currentMood == InterviewerMood.shocked) {
      face = face.animate()
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.elasticOut);
    } else if (_currentMood == InterviewerMood.disappointed || _currentMood == InterviewerMood.sad) {
      face = face.animate()
          .slideY(begin: 0, end: 0.05, duration: 600.ms, curve: Curves.easeInOut);
    }

    Widget faceContainer = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                glowColor.withValues(alpha: 0.2 + _pulseController.value * 0.1),
                glowColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.4 + _pulseController.value * 0.2),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.2 + _pulseController.value * 0.15),
                blurRadius: 20 + _pulseController.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: face),
        );
      },
    );

    if (!showTimer) return faceContainer;

    // Wrap with circular timer ring
    final timerFraction = _secondsRemaining / _totalInterviewSeconds;
    final timerColor = _secondsRemaining <= 60
        ? AppTheme.errorRed
        : _secondsRemaining <= 180
            ? AppTheme.warningAmber
            : AppTheme.accentCyan;

    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Timer ring
          SizedBox(
            width: size + 14,
            height: size + 14,
            child: CircularProgressIndicator(
              value: timerFraction,
              strokeWidth: 4,
              backgroundColor: timerColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(timerColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          faceContainer,
        ],
      ),
    );
  }

  // ── Speech bubble ─────────────────────────────────────────────────────────
  Widget _buildSpeechBubble(String text, bool isDark, {bool isComment = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: isComment ? 0.04 : 0.06)
            : Colors.black.withValues(alpha: isComment ? 0.03 : 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: isComment ? 0.06 : 0.08)
              : Colors.black.withValues(alpha: isComment ? 0.06 : 0.08),
        ),
      ),
      child: Text(
        text,
        style: isComment
            ? AppTheme.bodySmall.copyWith(
                color: _currentMood.glowColor.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                fontSize: 12,
              )
            : AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimaryC(isDark),
                height: 1.5,
                fontSize: 15,
              ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  INTRO SCREEN
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildIntro(bool isDark) {
    final bestScore = context.watch<ProgressService>().interviewBestScore;
    final isPremium = context.watch<ProgressService>().isPremium;
    final availableCategories = _moduleTitleToQuizIds.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimaryC(isDark)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 24),

          // Greeting emoji
          _buildInterviewerFace(size: 100, large: true)
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms),

          const SizedBox(height: 20),

          // Speech bubble greeting
          _buildSpeechBubble(_currentMood.comment, isDark, isComment: true)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 28),

          // Title
          Text(
            'Mock Interview',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontSize: 28,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 12),

          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip('📝 10 Questions', isDark),
              _buildInfoChip('⏱️ 15m Total', isDark),
              _buildInfoChip('🚫 No Hints', isDark),
            ],
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 20),

          // Best score
          if (bestScore > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentCyan.withValues(alpha: 0.12),
                    AppTheme.accentPurple.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Personal Best: $bestScore%',
                      style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accentCyan,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 16),

          // Attempts / Premium status
          Consumer<ProgressService>(
            builder: (context, progress, _) {
              if (progress.isPremium) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.successGreen.withValues(alpha: 0.12),
                        AppTheme.successGreen.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.all_inclusive_rounded,
                          color: AppTheme.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Text('Unlimited PRO Attempts',
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
              child: Text('🎯 Topic Focus',
                  style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textSecondaryC(isDark))),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: Text('All Modules (Mixed)',
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textPrimaryC(isDark))),
                  dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
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

          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 8),
                  Text('Start Interview',
                      style: AppTheme.headingSmall.copyWith(color: Colors.black, fontSize: 16)),
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white.withValues(alpha: 0.15)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(text, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark), fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCategoryPreview(bool isDark) {
    final quizIds = _moduleTitleToQuizIds[_selectedCategory] ?? [];
    final count =
        quizIds.fold<int>(0, (sum, id) => sum + (allQuizzes[id]?.questions.length ?? 0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded,
            size: 13, color: AppTheme.accentCyan.withValues(alpha: 0.7)),
        const SizedBox(width: 5),
        Text(
          '$count questions available in this topic',
          style: AppTheme.bodySmall.copyWith(
              color: AppTheme.accentCyan.withValues(alpha: 0.8), fontSize: 11),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  QUIZ SCREEN
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // ── Top bar: Back + Progress + Timer text ──────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: _handleBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimaryC(isDark), size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} / ${_questions.length}',
                      style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textPrimaryC(isDark),
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    // Mini progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation(AppTheme.accentCyan.withValues(alpha: 0.6)),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Streak badge
              if (_streak >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('$_streak', style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      )),
                    ],
                  ),
                ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                    duration: 400.ms),
              // Timer text
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _timerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                    style: AppTheme.labelMedium.copyWith(
                        color: _timerColor, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Interviewer face with circular timer ───────────────────────
          _buildInterviewerFace(size: 72, showTimer: true)
              .animate(target: _showResult ? 1 : 0)
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 300.ms),

          const SizedBox(height: 8),

          // ── Mood comment ──────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _currentMood.comment,
              key: ValueKey(_currentMood),
              style: AppTheme.bodySmall.copyWith(
                color: _currentMood.glowColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // ── Question in speech bubble ──────────────────────────────────
          Flexible(
            flex: 0,
            child: _buildSpeechBubble(q.question, isDark),
          ),

          const SizedBox(height: 16),

          // ── Answer options ────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, i) {
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
              },
            ),
          ),

          // ── Next button ──────────────────────────────────────────────
          if (_showResult)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next Question →'
                        : '🏁 See Results'),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Color get _timerColor {
    if (_secondsRemaining <= 60) return AppTheme.errorRed;
    if (_secondsRemaining <= 180) return AppTheme.warningAmber;
    return AppTheme.accentCyan;
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  RESULTS SCREEN
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildResults(bool isDark) {
    final pct = ((_correctCount / _questions.length) * 100).round();
    final elapsed = _totalStopwatch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final categoryLabel = _selectedCategory ?? 'All Modules';
    final xpEarned = pct >= 90 ? 110 : (pct >= 70 ? 80 : 30);

    return Stack(
      children: [
        // Confetti layer
        if (_showConfetti) _buildConfettiOverlay(),

        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimaryC(isDark)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),

              // Big result emoji
              _buildInterviewerFace(size: 110, large: true)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1),
                      curve: Curves.elasticOut, duration: 800.ms),

              const SizedBox(height: 16),

              // Mood comment as speech bubble
              _buildSpeechBubble(_currentMood.comment, isDark, isComment: true)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Tier label
              Text(
                _readinessTier,
                style: AppTheme.headingLarge
                    .copyWith(color: _tierColor, fontSize: 24),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 6),

              Text(
                'Topic: $categoryLabel',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
              ),

              const SizedBox(height: 28),

              // Score circle
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _tierColor.withValues(alpha: 0.2),
                      _tierColor.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                      color: _tierColor.withValues(alpha: 0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _tierColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$pct%',
                          style: AppTheme.headingLarge
                              .copyWith(color: _tierColor, fontSize: 36)),
                      Text('score',
                          style: AppTheme.bodySmall
                              .copyWith(color: _tierColor.withValues(alpha: 0.7), fontSize: 11)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

              const SizedBox(height: 24),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard('✅', '$_correctCount / ${_questions.length}', 'Correct', isDark),
                  const SizedBox(width: 16),
                  _buildStatCard('⏱️', '${minutes}m ${seconds}s', 'Time', isDark),
                  const SizedBox(width: 16),
                  _buildStatCard('⭐', '+$xpEarned', 'XP', isDark),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _started = false;
                    _finished = false;
                    _showConfetti = false;
                    _currentMood = InterviewerMood.greeting;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tierColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Try Again 🔄'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Home',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentCyan)),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textPrimaryC(isDark), fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textMutedC(isDark), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    final rng = Random(42);
    final confettiColors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
      const Color(0xFF48DBFB),
      const Color(0xFF5FD068),
      const Color(0xFFA855F7),
      const Color(0xFFFF9F43),
    ];

    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: List.generate(30, (i) {
            final left = rng.nextDouble() * MediaQuery.of(context).size.width;
            final delay = rng.nextInt(2000);
            final size = 6.0 + rng.nextDouble() * 8;
            final color = confettiColors[rng.nextInt(confettiColors.length)];
            final isCircle = rng.nextBool();

            return Positioned(
              left: left,
              top: -20,
              child: Container(
                width: size,
                height: isCircle ? size : size * 1.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: isCircle
                      ? BorderRadius.circular(size)
                      : BorderRadius.circular(2),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .slideY(
                      begin: 0,
                      end: MediaQuery.of(context).size.height / size + 5,
                      duration: Duration(milliseconds: 2500 + rng.nextInt(1500)),
                      delay: Duration(milliseconds: delay),
                      curve: Curves.linear)
                  .rotate(
                      begin: 0,
                      end: rng.nextDouble() * 2 - 1,
                      duration: Duration(milliseconds: 2000 + rng.nextInt(1000)))
                  .fadeOut(delay: Duration(milliseconds: 3000 + delay), duration: 500.ms),
            );
          }),
        ),
      ),
    );
  }
}
