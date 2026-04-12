import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/learning/quiz_data.dart';

import '../../models/quiz_model.dart';
import '../../services/progress_service.dart';
import '../../services/subscription_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/quiz_option_button.dart';

class PracticeScreen extends StatefulWidget {
  final bool autoStartReview;

  const PracticeScreen({super.key, this.autoStartReview = false});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _showingMenu = true;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  
  // ── State for different question types ──
  int? _selectedOption; // For singleChoice
  final Set<int> _currentMultiChoices = {}; // For multiChoice
  String _currentTextAnswer = ''; // For textInput
  final TextEditingController _textController = TextEditingController();

  bool _showResult = false;
  int _correctCount = 0;
  String _mode = '';

  bool get isReviewMode => _mode == 'Review Weak Areas';

  @override
  void initState() {
    super.initState();
    if (widget.autoStartReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startReviewMode();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  List<QuizQuestion> _getAllQuestions() {
    return allQuizzes.values
        .expand((quiz) => quiz.questions)
        .toList();
  }

  void _resetQuestionState() {
    final progress = context.read<ProgressService>();
    final q = _questions.isNotEmpty && _currentIndex < _questions.length ? _questions[_currentIndex] : null;

    _selectedOption = null;
    _currentMultiChoices.clear();
    _currentTextAnswer = '';
    _textController.clear();
    _showResult = false;

    if (_mode == 'Review Weak Areas' && q != null) {
      final detail = progress.getWrongAnswerDetail(q.id);
      if (detail != null) {
        final selection = detail['selection'];
        if (q.type == QuestionType.singleChoice) {
          _selectedOption = selection as int?;
        } else if (q.type == QuestionType.multiChoice) {
          if (selection is List) {
            _currentMultiChoices.addAll(selection.cast<int>());
          }
        } else if (q.type == QuestionType.textInput) {
          _currentTextAnswer = selection as String? ?? '';
          _textController.text = _currentTextAnswer;
        }
      }
    }
  }

  void _revealSolution() {
    setState(() {
      _showResult = true;
    });
  }

  void _startReviewMode() {
    final progress = context.read<ProgressService>();
    final wrongIds = progress.wrongAnswers;
    final all = _getAllQuestions();
    
    // Only include questions that have detail about the last mistake (Skip Old Data)
    final questions = all
        .where((q) => wrongIds.contains(q.id) && progress.hasWrongAnswerDetail(q.id))
        .toList()..shuffle();

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No wrong answers to review yet. Take some quizzes first!'),
          backgroundColor: AppTheme.accentPurple,
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
      _correctCount = 0;
      _showingMenu = false;
      _resetQuestionState();
    });
  }

  void _startDailyChallenge() async {
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

    if (!progress.isPremium) {
      if (progress.xp < 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough XP. Daily Challenge requires 20 XP!'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final confirm = await _showDailyChallengeCostDialog(progress);
      if (confirm != true) return;
    }

    final all = _getAllQuestions()..shuffle(Random());

    setState(() {
      _mode = 'Daily Challenge';
      _questions = all.take(5).toList();
      _currentIndex = 0;
      _correctCount = 0;
      _showingMenu = false;
      _resetQuestionState();
    });
  }

  // Handle single choice selection
  void _selectSingleOption(int index) {
    if (_showResult) return;
    _validateAndShowScore(index);
  }

  // Handle multi choice toggling
  void _toggleMultiOption(int index) {
    if (_showResult) return;
    setState(() {
      if (_currentMultiChoices.contains(index)) {
        _currentMultiChoices.remove(index);
      } else {
        _currentMultiChoices.add(index);
      }
    });
  }

  // Handle multi choice submission
  void _submitMultiChoice() {
    if (_showResult || _currentMultiChoices.isEmpty) return;
    _validateAndShowScore();
  }

  // Handle text input submission
  void _submitTextInput() {
    final answer = _textController.text.trim();
    if (_showResult || answer.isEmpty) return;
    
    _currentTextAnswer = answer;
    _validateAndShowScore();
  }

  void _validateAndShowScore([int? singleIdx]) {
    final progress = context.read<ProgressService>();
    final q = _questions[_currentIndex];
    bool isCorrect = false;

    if (q.type == QuestionType.singleChoice) {
      isCorrect = singleIdx == q.correctIndex;
      _selectedOption = singleIdx;
    } else if (q.type == QuestionType.multiChoice) {
      isCorrect = q.isMultiChoiceCorrect(_currentMultiChoices);
    } else if (q.type == QuestionType.textInput) {
      isCorrect = q.isTextAnswerCorrect(_currentTextAnswer);
    }

    if (isCorrect) {
      _correctCount++;
      progress.removeWrongAnswer(q.id);
    } else {
      progress.saveWrongAnswer(q.id);
    }

    setState(() {
      _showResult = true;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _resetQuestionState();
      });
    } else {
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
              style: AppTheme.headingLarge.copyWith(color: AppTheme.accentPurple),
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
                    .copyWith(color: AppTheme.accentPurple)),
          ),
          if (_mode == 'Review Weak Areas')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _startReviewMode();
              },
              child: Text('Practice Again',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentPink)),
            ),
        ],
      ),
    );
  }

  Future<bool?> _showDailyChallengeCostDialog(ProgressService progress) {
    final isDark = context.read<ThemeService>().isDarkMode;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppTheme.accentAmber),
            const SizedBox(width: 8),
            Text('Daily Challenge', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
          ],
        ),
        content: Text('Unlock today\'s Daily Challenge for 20 XP?', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedC(isDark))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentAmber),
            onPressed: () async {
              final ok = await progress.spendXP(20);
              Navigator.pop(ctx, ok);
            },
            child: Text('-20 XP', style: AppTheme.bodyMedium.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
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
                'Strengthen Your Knowledge',
                style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimaryC(isDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Strengthen your knowledge and stay interview-ready',
            style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textMutedC(isDark)),
          ),
          const SizedBox(height: 28),

          // ── Daily Challenge ── (moved to top)
          _PracticeModeCard(
            icon: Icons.bolt_rounded,
            title: 'Daily Challenge',
            subtitle: doneDailyToday
                ? '✅ Completed! Come back tomorrow'
                : 'Costs 20 XP • Test yourself!',
            color: AppTheme.accentAmber,
            isDark: isDark,
            enabled: !doneDailyToday,
            onTap: _startDailyChallenge,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

          const SizedBox(height: 14),

          // ── Review Weak Areas ──
          _PracticeModeCard(
            icon: Icons.replay_circle_filled_rounded,
            title: 'Review Weak Areas',
            subtitle: weakCount > 0
                ? '$weakCount questions to review — with explanations'
                : 'No wrong answers yet — start quizzes first!',
            color: AppTheme.accentPink,
            isDark: isDark,
            enabled: weakCount > 0,
            onTap: _startReviewMode,
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              ),

          const SizedBox(height: 14),

          // ── Info box ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentPurple, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complete the daily challenge or review your wrong answers. '
                    'In Weak Areas mode you\'ll see explanations for each answer.',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryC(isDark)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

          const SizedBox(height: 20),

          // ── Banner Ad (low-emotion zone / browsing) ──
          Builder(builder: (context) {
            final isPremium = context.watch<SubscriptionService>().isPremium;
            if (isPremium) return const SizedBox.shrink();
            return const Center(child: BannerAdWidget());
          }),
        ],
      ),
    );
  }

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentIndex];
    final isReviewMode = _mode == 'Review Weak Areas';
    
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
              Expanded(
                child: Text(
                  _mode,
                  style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.textPrimaryC(isDark)),
                ),
              ),
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accentPurple),
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
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentPurple),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          // Question type badge (like in interview screen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _questionTypeBadgeColor(q.type).withOpacity(0.12),
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
          const SizedBox(height: 12),
          Text(
            q.question,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 20),
          
          // ── Dynamic Answer Area ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAnswerInput(q, isDark),
                  
                  // ── Action Buttons for Review ──
                  if (isReviewMode && !_showResult) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _revealSolution,
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Reveal Correct Answer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                  ],

                  // ── Feedback / Explanation ──
                  if (_showResult) ...[
                    const SizedBox(height: 20),
                    _buildFeedbackSection(q, isDark, isReviewMode),
                  ],
                ],
              ),
            ),
          ),

          if (_showResult) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next Question →'
                      : 'Finish ✨',
                  style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput(QuizQuestion q, bool isDark) {
    switch (q.type) {
      case QuestionType.singleChoice:
        return Column(
          children: List.generate(q.options.length, (i) {
            final isWrongChoice = isReviewMode && _selectedOption == i && i != q.correctIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: QuizOptionButton(
                text: q.options[i],
                index: i,
                isSelected: _selectedOption == i,
                isCorrect: i == q.correctIndex,
                showResult: _showResult,
                isReviewHighlight: isWrongChoice && !_showResult,
                isDark: isDark,
                onTap: isReviewMode ? () {} : () => _selectSingleOption(i),
              ),
            );
          }),
        );
      case QuestionType.multiChoice:
        return Column(
          children: [
            ...List.generate(q.options.length, (i) {
              final isChecked = _currentMultiChoices.contains(i);
              final isCorrectPart = q.correctIndices?.contains(i) ?? false;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _toggleMultiOption(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _showResult
                          ? (isCorrectPart 
                              ? AppTheme.successGreen.withOpacity(isDark ? 0.15 : 0.1)
                              : (isChecked ? AppTheme.errorRed.withOpacity(isDark ? 0.15 : 0.1) : AppTheme.cardC(isDark)))
                          : (isReviewMode && isChecked && !isCorrectPart
                              ? AppTheme.errorRed.withOpacity(isDark ? 0.15 : 0.1)
                              : (isChecked ? AppTheme.accentPurple.withOpacity(isDark ? 0.15 : 0.1) : AppTheme.cardC(isDark))),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showResult
                            ? (isCorrectPart ? AppTheme.successGreen : (isChecked ? AppTheme.errorRed : AppTheme.dividerC(isDark)))
                            : (isReviewMode && isChecked && !isCorrectPart
                                ? AppTheme.errorRed
                                : (isChecked ? AppTheme.accentPurple : AppTheme.dividerC(isDark))),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isReviewMode && isChecked && !isCorrectPart
                                  ? AppTheme.errorRed
                                  : isChecked ? AppTheme.accentPurple : AppTheme.textMutedC(isDark),
                              width: 2,
                            ),
                          ),
                          child: isChecked ? Icon(
                            isReviewMode && !isCorrectPart ? Icons.close_rounded : Icons.check_rounded,
                            size: 16,
                            color: isReviewMode && !isCorrectPart ? AppTheme.errorRed : AppTheme.accentPurple
                          ) : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Text(q.options[i], style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimaryC(isDark)))),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (!_showResult) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentMultiChoices.isNotEmpty ? _submitMultiChoice : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
                  child: const Text('Confirm Selections'),
                ),
              ),
            ],
          ],
        );
      case QuestionType.textInput:
        return Column(
          children: [
            TextField(
              controller: _textController,
              enabled: !_showResult,
              onSubmitted: (_) => _submitTextInput(),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedC(isDark)),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(
                  color: isReviewMode && !_showResult ? AppTheme.errorRed : AppTheme.dividerC(isDark)
                )),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(
                  color: isReviewMode && !_showResult ? AppTheme.errorRed : AppTheme.accentPurple
                )),
              ),
            ),
            if (!_showResult) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTextInput,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
                  child: const Text('Submit Answer'),
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildFeedbackSection(QuizQuestion q, bool isDark, bool isReviewMode) {
    bool isCorrect = false;
    if (q.type == QuestionType.singleChoice) isCorrect = _selectedOption == q.correctIndex;
    else if (q.type == QuestionType.multiChoice) isCorrect = q.isMultiChoiceCorrect(_currentMultiChoices);
    else if (q.type == QuestionType.textInput) isCorrect = q.isTextAnswerCorrect(_currentTextAnswer);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.successGreen.withOpacity(isDark ? 0.08 : 0.05)
            : AppTheme.errorRed.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.errorRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_rounded, color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed, size: 20),
              const SizedBox(width: 8),
              Text(isCorrect ? 'Excellent!' : 'Reviewing the Fact:', style: AppTheme.headingSmall.copyWith(color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed, fontSize: 16)),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text('Correct Answer:', style: AppTheme.labelMedium.copyWith(color: AppTheme.textPrimaryC(isDark), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _buildCorrectAnswerDisplay(q),
          ],
          const SizedBox(height: 12),
          Text(q.explanation, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark), height: 1.5)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildCorrectAnswerDisplay(QuizQuestion q) {
    if (q.type == QuestionType.singleChoice) {
      return Text(q.options[q.correctIndex], style: AppTheme.bodyMedium.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.w600));
    } else if (q.type == QuestionType.multiChoice) {
      final corrects = q.correctIndices?.map((i) => q.options[i]).join(', ') ?? '';
      return Text(corrects, style: AppTheme.bodyMedium.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.w600));
    } else {
      return Text(q.correctText ?? '', style: AppTheme.bodyMedium.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.w600));
    }
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice: return 'SINGLE CHOICE';
      case QuestionType.multiChoice: return 'MULTI-SELECT';
      case QuestionType.textInput: return 'TEXT INPUT';
    }
  }

  Color _questionTypeBadgeColor(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice: return AppTheme.accentPurple;
      case QuestionType.multiChoice: return AppTheme.accentPink;
      case QuestionType.textInput: return AppTheme.accentAmber;
    }
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
