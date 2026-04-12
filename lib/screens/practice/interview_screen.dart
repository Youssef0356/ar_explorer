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
import '../settings/paywall_screen.dart';
import 'practice_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  INTERVIEWER MOOD SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════

enum InterviewerMood {
  greeting,    // 👋  Intro screen welcome
  idle,        // 🤔  Waiting for answer
  curious,     // 🧐  Timer pressure building
  impatient,   // 😤  Timer < 90s
  angry,       // 😡  Timer < 30s
  thinking,    // 🧠  User answered, moving to next
  impressed,   // 🤩  Great score result
  mindBlown,   // 🤯  Perfect score
  sad,         // 😢  Poor score
  cool,        // 😎  Good score result
  shocked,     // 😱  Time ran out
  celebrating, // 🥳  User passed
}

extension InterviewerMoodEmoji on InterviewerMood {
  String get emoji {
    switch (this) {
      case InterviewerMood.greeting:     return '👋';
      case InterviewerMood.idle:         return '🤔';
      case InterviewerMood.curious:      return '🧐';
      case InterviewerMood.impatient:    return '😤';
      case InterviewerMood.angry:        return '😡';
      case InterviewerMood.thinking:     return '🧠';
      case InterviewerMood.impressed:    return '🤩';
      case InterviewerMood.mindBlown:    return '🤯';
      case InterviewerMood.sad:          return '😢';
      case InterviewerMood.cool:         return '😎';
      case InterviewerMood.shocked:      return '😱';
      case InterviewerMood.celebrating:  return '🥳';
    }
  }

  Color get glowColor {
    switch (this) {
      case InterviewerMood.greeting:     return const Color(0xFF64B5F6);
      case InterviewerMood.idle:         return const Color(0xFF90CAF9);
      case InterviewerMood.curious:      return const Color(0xFFFFD54F);
      case InterviewerMood.impatient:    return const Color(0xFFFF8A65);
      case InterviewerMood.angry:        return const Color(0xFFEF5350);
      case InterviewerMood.thinking:     return const Color(0xFF7C4DFF);
      case InterviewerMood.impressed:    return const Color(0xFFFFD700);
      case InterviewerMood.mindBlown:    return const Color(0xFFFF6E40);
      case InterviewerMood.sad:          return const Color(0xFF42A5F5);
      case InterviewerMood.cool:         return const Color(0xFF26C6DA);
      case InterviewerMood.shocked:      return const Color(0xFFE040FB);
      case InterviewerMood.celebrating:  return const Color(0xFFFFD700);
    }
  }

  String get comment {
    switch (this) {
      case InterviewerMood.greeting:     return "Ready for your interview? Let's go! 🎤";
      case InterviewerMood.idle:         return 'Take your time, read carefully...';
      case InterviewerMood.curious:      return 'Interesting... what do you think?';
      case InterviewerMood.impatient:    return 'Tick tock! Time is running out!';
      case InterviewerMood.angry:        return 'HURRY UP!! ⏰';
      case InterviewerMood.thinking:     return 'Noted! Moving on... 📝';
      case InterviewerMood.impressed:    return 'Outstanding performance! 🌟';
      case InterviewerMood.mindBlown:    return 'PERFECT?! You absolute legend!! 🏆';
      case InterviewerMood.sad:          return 'Keep studying, you got this! 💪';
      case InterviewerMood.cool:         return 'Solid work! Well done! 😎';
      case InterviewerMood.shocked:      return "Time's up! Let's see how you did... ⏰";
      case InterviewerMood.celebrating:  return "You're ready for an AR post! 🎉";
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
  static const _totalInterviewSeconds = 300; // 5 mins total
  static const _totalQuestions = 10;
  static const _passingThreshold = 70; // 70% to pass

  bool _started = false;
  bool _finished = false;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _secondsRemaining = _totalInterviewSeconds;
  Timer? _timer;
  final Stopwatch _totalStopwatch = Stopwatch();
  String? _selectedCategory;

  // ── Answer tracking (no feedback during exam) ──────────────────
  // For singleChoice: stores the selected option index (or -1 for unanswered)
  // For multiChoice: uses _multiChoiceSelections map
  // For textInput: uses _textInputAnswers map
  List<int?> _userAnswers = [];
  final Map<int, Set<int>> _multiChoiceSelections = {};
  final Map<int, String> _textInputAnswers = {};
  final Map<int, TextEditingController> _textControllers = {};

  // ── Mood system ────────────────────────────────────────────────
  InterviewerMood _currentMood = InterviewerMood.greeting;
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
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started || _finished) return;
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

  // ── Mood updates (timer-based only, no correct/wrong) ──────────
  void _updateMoodFromTimer() {
    if (_secondsRemaining <= 30) {
      _setMood(InterviewerMood.angry);
    } else if (_secondsRemaining <= 90) {
      _setMood(InterviewerMood.impatient);
    } else if (_secondsRemaining <= 180) {
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

  // ── Start ─────────────────────────────────────────────────────
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
      // Only shuffle options for singleChoice questions
      if (q.type == QuestionType.singleChoice) {
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
          type: q.type,
          correctIndices: q.correctIndices,
          correctText: q.correctText,
        );
      } else if (q.type == QuestionType.multiChoice) {
        // Shuffle options for multiChoice too, adjusting correctIndices
        final indices = List<int>.generate(q.options.length, (i) => i);
        indices.shuffle(rng);
        final newOptions = [for (final i in indices) q.options[i]];
        final newCorrectIndices = q.correctIndices?.map((ci) => indices.indexOf(ci)).toList();
        return QuizQuestion(
          id: q.id,
          question: q.question,
          options: newOptions,
          correctIndex: 0,
          explanation: q.explanation,
          relatedTopicId: q.relatedTopicId,
          relatedModuleId: q.relatedModuleId,
          type: q.type,
          correctIndices: newCorrectIndices,
          correctText: q.correctText,
        );
      }
      // textInput — no shuffle needed
      return q;
    }).toList();

    // Clear old text controllers
    for (final c in _textControllers.values) {
      c.dispose();
    }
    _textControllers.clear();
    _multiChoiceSelections.clear();
    _textInputAnswers.clear();

    setState(() {
      _questions = shuffled;
      _started = true;
      _finished = false;
      _currentIndex = 0;
      _userAnswers = List<int?>.filled(shuffled.length, null);
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
    _setMood(InterviewerMood.shocked);
    // Immediately finish — no waiting
    _finishInterview();
  }

  // ── Select answer (NO feedback, NO timer stop) ─────────────────
  void _selectSingleOption(int index) {
    setState(() {
      _userAnswers[_currentIndex] = index;
    });
  }

  void _toggleMultiOption(int index) {
    setState(() {
      _multiChoiceSelections[_currentIndex] ??= {};
      final set = _multiChoiceSelections[_currentIndex]!;
      if (set.contains(index)) {
        set.remove(index);
      } else {
        set.add(index);
      }
    });
  }

  void _updateTextAnswer(String text) {
    _textInputAnswers[_currentIndex] = text;
  }

  // ── Navigation ─────────────────────────────────────────────────
  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _setMood(InterviewerMood.idle);
      });
    } else {
      _finishInterview();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  bool _hasAnsweredCurrent() {
    final q = _questions[_currentIndex];
    switch (q.type) {
      case QuestionType.singleChoice:
        return _userAnswers[_currentIndex] != null;
      case QuestionType.multiChoice:
        return (_multiChoiceSelections[_currentIndex]?.isNotEmpty ?? false);
      case QuestionType.textInput:
        return (_textInputAnswers[_currentIndex]?.trim().isNotEmpty ?? false);
    }
  }

  // ── Scoring & Finish ───────────────────────────────────────────
  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      switch (q.type) {
        case QuestionType.singleChoice:
          if (_userAnswers[i] == q.correctIndex) correct++;
          break;
        case QuestionType.multiChoice:
          final selected = _multiChoiceSelections[i] ?? {};
          if (q.isMultiChoiceCorrect(selected)) correct++;
          break;
        case QuestionType.textInput:
          final answer = _textInputAnswers[i] ?? '';
          if (q.isTextAnswerCorrect(answer)) correct++;
          break;
      }
    }
    return correct;
  }

  bool _isQuestionCorrect(int index) {
    final q = _questions[index];
    switch (q.type) {
      case QuestionType.singleChoice:
        return _userAnswers[index] == q.correctIndex;
      case QuestionType.multiChoice:
        final selected = _multiChoiceSelections[index] ?? {};
        return q.isMultiChoiceCorrect(selected);
      case QuestionType.textInput:
        final answer = _textInputAnswers[index] ?? '';
        return q.isTextAnswerCorrect(answer);
    }
  }

  void _finishInterview() {
    _timer?.cancel();
    _totalStopwatch.stop();

    final correctCount = _calculateScore();
    final scorePercent = (correctCount / _questions.length * 100).round();
    final passed = scorePercent >= _passingThreshold;

    final progress = context.read<ProgressService>();
    progress.saveInterviewScore(scorePercent);

    // Save wrong answers with details for Review Weak Areas in Practice tab
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (!_isQuestionCorrect(i)) {
        dynamic selection;
        switch (q.type) {
          case QuestionType.singleChoice: selection = _userAnswers[i]; break;
          case QuestionType.multiChoice: selection = _multiChoiceSelections[i]; break;
          case QuestionType.textInput: selection = _textInputAnswers[i]; break;
        }
        progress.saveWrongAnswer(q.id, selection: selection, type: q.type);
      } else {
        progress.removeWrongAnswer(q.id);
      }
    }

    // Play SFX based on result
    final sound = context.read<SoundService>();
    if (passed) {
      sound.playSuccess();
    } else {
      sound.playFailure();
    }

    // Set result mood
    if (scorePercent == 100) {
      _currentMood = InterviewerMood.mindBlown;
      _showConfetti = true;
    } else if (scorePercent >= 80) {
      _currentMood = InterviewerMood.impressed;
      _showConfetti = true;
    } else if (scorePercent >= _passingThreshold) {
      _currentMood = InterviewerMood.celebrating;
      _showConfetti = true;
    } else if (scorePercent >= 50) {
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
    final pct = (_calculateScore() / _questions.length * 100).round();
    if (pct >= 91) return '🏆 AR Expert / Lead';
    if (pct >= 71) return '⚡ Senior AR Dev';
    if (pct >= 51) return '🔍 Mid-Level AR Dev';
    if (pct >= 31) return '📱 Junior AR Dev';
    return '📚 Needs More Study';
  }

  Color get _tierColor {
    final pct = (_calculateScore() / _questions.length * 100).round();
    if (pct >= 91) return const Color(0xFFFFD700);
    if (pct >= 71) return AppTheme.accentCyan;
    if (pct >= 51) return AppTheme.accentBlue;
    if (pct >= 31) return AppTheme.accentOrange;
    return AppTheme.accentPink;
  }

  // ═════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
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

  // ═════════════════════════════════════════════════════════════════
  //  INTERVIEWER FACE WIDGET
  // ═════════════════════════════════════════════════════════════════

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
    } else if (_currentMood == InterviewerMood.sad) {
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
        : _secondsRemaining <= 120
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

  // ── Speech bubble ─────────────────────────────────────────────
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

  // ═════════════════════════════════════════════════════════════════
  //  INTRO SCREEN
  // ═════════════════════════════════════════════════════════════════

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
              _buildInfoChip('⏱️ 5m Total', isDark),
              _buildInfoChip('🚫 No Hints', isDark),
              _buildInfoChip('📊 70% to Pass', isDark),
            ],
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 12),

          // Exam format note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.accentPurple, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Exam mode: No feedback per question. Multiple question types: '
                    'single choice, multi-select, and text input. Results shown at the end.',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryC(isDark), fontSize: 11),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 550.ms),

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

          // ── Category selector (Premium only) ──────────────────
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

  // ═════════════════════════════════════════════════════════════════
  //  QUIZ SCREEN (Exam mode — no feedback)
  // ═════════════════════════════════════════════════════════════════

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // ── Top bar: Back + Progress + Timer text ──────────────
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
              // Question type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _questionTypeBadgeColor(q.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _questionTypeLabel(q.type),
                  style: AppTheme.bodySmall.copyWith(
                    color: _questionTypeBadgeColor(q.type),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
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

          // ── Interviewer face with circular timer ───────────────
          _buildInterviewerFace(size: 64, showTimer: true),

          const SizedBox(height: 6),

          // ── Mood comment ──────────────────────────────────────
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

          // ── Question in speech bubble ──────────────────────────
          Flexible(
            flex: 0,
            child: _buildSpeechBubble(q.question, isDark),
          ),

          const SizedBox(height: 16),

          // ── Answer area (depends on question type) ─────────────
          Expanded(
            child: _buildAnswerArea(q, isDark),
          ),

          const SizedBox(height: 8),

          // ── Navigation buttons ─────────────────────────────────
          Row(
            children: [
              // Previous button
              if (_currentIndex > 0)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondaryC(isDark),
                        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              // Next / Submit button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex < _questions.length - 1
                          ? AppTheme.accentCyan
                          : AppTheme.successGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1
                          ? (_hasAnsweredCurrent() ? 'Next Question →' : 'Skip →')
                          : '🏁 Submit Exam',
                      style: AppTheme.labelMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Answer area builders ────────────────────────────────────────
  Widget _buildAnswerArea(QuizQuestion q, bool isDark) {
    switch (q.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceOptions(q, isDark);
      case QuestionType.multiChoice:
        return _buildMultiChoiceOptions(q, isDark);
      case QuestionType.textInput:
        return _buildTextInputArea(q, isDark);
    }
  }

  Widget _buildSingleChoiceOptions(QuizQuestion q, bool isDark) {
    final labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    final selectedIdx = _userAnswers[_currentIndex];

    return ListView.builder(
      itemCount: q.options.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (ctx, i) {
        final isSelected = selectedIdx == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _selectSingleOption(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentCyan.withValues(alpha: isDark ? 0.15 : 0.1)
                    : AppTheme.cardC(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentCyan.withValues(alpha: 0.5)
                      : AppTheme.dividerC(isDark),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Radio-style indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
                        width: 2,
                      ),
                      color: isSelected
                          ? AppTheme.accentCyan.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentCyan.withValues(alpha: 0.2)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      i < labels.length ? labels[i] : '${i + 1}',
                      style: AppTheme.labelMedium.copyWith(
                        color: isSelected ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q.options[i],
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiChoiceOptions(QuizQuestion q, bool isDark) {
    final selected = _multiChoiceSelections[_currentIndex] ?? {};

    return ListView.builder(
      itemCount: q.options.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (ctx, i) {
        final isChecked = selected.contains(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _toggleMultiOption(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppTheme.accentPurple.withValues(alpha: isDark ? 0.15 : 0.1)
                    : AppTheme.cardC(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isChecked
                      ? AppTheme.accentPurple.withValues(alpha: 0.5)
                      : AppTheme.dividerC(isDark),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Checkbox-style indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isChecked ? AppTheme.accentPurple : AppTheme.textMutedC(isDark),
                        width: 2,
                      ),
                      color: isChecked
                          ? AppTheme.accentPurple.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: isChecked
                        ? const Icon(Icons.check_rounded, size: 16, color: AppTheme.accentPurple)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      q.options[i],
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInputArea(QuizQuestion q, bool isDark) {
    _textControllers[_currentIndex] ??= TextEditingController(
      text: _textInputAnswers[_currentIndex] ?? '',
    );
    final controller = _textControllers[_currentIndex]!;

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.keyboard_rounded,
                      color: AppTheme.accentCyan.withValues(alpha: 0.7), size: 18),
                  const SizedBox(width: 8),
                  Text('Type your answer below',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                onChanged: _updateTextAnswer,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimaryC(isDark),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your answer...',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textMutedC(isDark),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentCyan,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentCyan, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Answer is case-insensitive. Type the exact answer.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCyan.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice: return 'SINGLE';
      case QuestionType.multiChoice: return 'MULTI';
      case QuestionType.textInput: return 'TEXT';
    }
  }

  Color _questionTypeBadgeColor(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice: return AppTheme.accentCyan;
      case QuestionType.multiChoice: return AppTheme.accentPurple;
      case QuestionType.textInput: return AppTheme.accentOrange;
    }
  }

  Color get _timerColor {
    if (_secondsRemaining <= 60) return AppTheme.errorRed;
    if (_secondsRemaining <= 120) return AppTheme.warningAmber;
    return AppTheme.accentCyan;
  }

  // ═════════════════════════════════════════════════════════════════
  //  RESULTS SCREEN
  // ═════════════════════════════════════════════════════════════════

  Widget _buildResults(bool isDark) {
    final correctCount = _calculateScore();
    final pct = (correctCount / _questions.length * 100).round();
    final passed = pct >= _passingThreshold;
    final elapsed = _totalStopwatch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final categoryLabel = _selectedCategory ?? 'All Modules';
    final xpEarned = pct >= 90 ? 110 : (pct >= 70 ? 80 : 30);
    final wrongCount = _questions.length - correctCount;

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

              // PASS / FAIL badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: passed
                        ? [AppTheme.successGreen.withValues(alpha: 0.2), AppTheme.successGreen.withValues(alpha: 0.08)]
                        : [AppTheme.errorRed.withValues(alpha: 0.2), AppTheme.errorRed.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: passed
                        ? AppTheme.successGreen.withValues(alpha: 0.4)
                        : AppTheme.errorRed.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  passed ? '✅ PASSED' : '❌ FAILED',
                  style: AppTheme.headingMedium.copyWith(
                    color: passed ? AppTheme.successGreen : AppTheme.errorRed,
                    fontSize: 22,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

              const SizedBox(height: 16),

              // Mood comment as speech bubble
              _buildSpeechBubble(
                passed
                    ? _currentMood.comment
                    : 'Keep studying! Check your wrong answers in Practice → Review Weak Areas 💪',
                isDark,
                isComment: true,
              ).animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Tier label
              Text(
                _readinessTier,
                style: AppTheme.headingLarge
                    .copyWith(color: _tierColor, fontSize: 24),
              ).animate().fadeIn(delay: 500.ms),

              // Passed message
              if (passed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.15),
                        AppTheme.successGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "You're capable for an AR post!",
                          style: AppTheme.bodyMedium.copyWith(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],

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
                  _buildStatCard('✅', '$correctCount / ${_questions.length}', 'Correct', isDark),
                  const SizedBox(width: 16),
                  _buildStatCard('⏱️', '${minutes}m ${seconds}s', 'Time', isDark),
                  const SizedBox(width: 16),
                  _buildStatCard('⭐', '+$xpEarned', 'XP', isDark),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 28),

              // ── Review Wrong Answers button ──────────────────────
              if (wrongCount > 0)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PracticeScreen(autoStartReview: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_rounded, size: 20),
                    label: Text('Review Wrong Answers ($wrongCount)',
                        style: AppTheme.labelMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPink,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              // Try Again button
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
