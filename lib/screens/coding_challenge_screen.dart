import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/coding_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';
import '../services/progress_service.dart';
import '../data/coding_game_data.dart';
import '../widgets/shareable_achievement_card.dart';
import 'paywall_screen.dart';

class CodingChallengeScreen extends StatefulWidget {
  final CodingLevel level;
  final Color accentColor;

  const CodingChallengeScreen({
    super.key,
    required this.level,
    required this.accentColor,
  });

  @override
  State<CodingChallengeScreen> createState() => _CodingChallengeScreenState();
}

class _CodingChallengeScreenState extends State<CodingChallengeScreen> {
  late Map<String, String?> _slotAnswers; // slotId -> wordChipId
  late List<WordChip> _wordBank;
  final ScrollController _wordBankController = ScrollController();
  bool _checked = false;
  Map<String, bool> _results = {}; // slotId -> correct?
  int _timeRemaining = 0;
  Timer? _timer;
  bool _showExplanation = false;
  String? _hintSlotId; 
  int _mistakes = 0; 
  bool _isHintAdLoading = false;

  @override
  void initState() {
    super.initState();
    final isPremium = context.read<SubscriptionService>().isPremium;
    if (!isPremium && !widget.level.id.startsWith('v1_')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context); // Pop off challenge screen
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      });
      // Initialize dummies to prevent errors before popping
      _slotAnswers = {};
      _wordBank = [];
      return;
    }

    final progress = context.read<GameProgressService>();
    final isCompleted = progress.isCodingLevelCompleted(widget.level.id);

    _slotAnswers = {};
    for (var line in widget.level.lines) {
      if (line.slots != null) {
        for (var slot in line.slots!) {
          if (isCompleted) {
             final correctChip = widget.level.wordBank.firstWhere((w) => w.correctSlotId == slot.id);
             _slotAnswers[slot.id] = correctChip.id;
             _results[slot.id] = true;
          } else {
             _slotAnswers[slot.id] = null;
          }
        }
      }
    }

    if (isCompleted) {
      _wordBank = [];
      _checked = true;
      _showExplanation = true;
    } else {
      _wordBank = List.from(widget.level.wordBank)..shuffle();
      
      if (widget.level.timeLimit > 0) {
        _timeRemaining = widget.level.timeLimit;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeRemaining > 0) {
            setState(() => _timeRemaining--);
          } else {
            _timer?.cancel();
            _checkAnswers();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wordBankController.dispose();
    super.dispose();
  }

  void _checkAnswers() {
    final results = <String, bool>{};
    bool allCorrect = true;

    for (var line in widget.level.lines) {
      if (line.slots != null) {
        for (var slot in line.slots!) {
          final placedChipId = _slotAnswers[slot.id];
          final isCorrect = widget.level.wordBank.any((w) => w.id == placedChipId && w.correctSlotId == slot.id);
          results[slot.id] = isCorrect;
          if (!isCorrect) allCorrect = false;
        }
      }
    }

    if (!allCorrect) {
      _mistakes++;
    }

    setState(() {
      _results = results;
      _checked = true;
      _showExplanation = true;
    });

    final sound = context.read<SoundService>();
    if (allCorrect) {
      sound.playSuccess();
      final progress = context.read<GameProgressService>();
      final xpEarned = widget.level.isBoss ? 50 : 25;
      progress.addCodingXP(xpEarned);
      
      // Calculate stars: 0 mistakes = 3, 1-2 = 2, 3+ = 1
      int stars = 3;
      if (_mistakes >= 3) {
        stars = 1;
      } else if (_mistakes >= 1) { stars = 2; }
      
      progress.completeCodingLevel(widget.level.id, stars, isBoss: widget.level.isBoss);
      progress.updateCodingStreak();

      if (widget.level.isBoss) {
        context.read<AdService>().showInterstitialAdWithProbability(0.25); // Reduced from 50% — boss wins are high-emotion moments
      }

      
      _showVictoryDialog(xpEarned, stars);
    } else {
      sound.playFailure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildMascotHint(),
                    const SizedBox(height: 24),
                    _buildEditor(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (!_checked) _buildWordBank(),
            _buildBottomBar(),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.level.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.level.goal,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (widget.level.timeLimit > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _timeRemaining < 10 ? Colors.red.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _timeRemaining < 10 ? Colors.red : Colors.white24),
              ),
              child: Text(
                '$_timeRemaining s',
                style: TextStyle(color: _timeRemaining < 10 ? Colors.red : Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMascotHint() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.psychology_rounded, color: widget.accentColor, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              widget.level.mascotHint,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _buildEditor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B29),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, color: Colors.white24, size: 14),
                const SizedBox(width: 8),
                Text('editor.script', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontFamily: 'monospace')),
                const Spacer(),
                const Icon(Icons.more_horiz_rounded, color: Colors.white24, size: 14),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.level.lines.length, (index) {
                final line = widget.level.lines[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white12, fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(width: line.indent * 16),
                            if (line.isPlain)
                              Text(
                                line.text!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            if (line.hasSlots)
                              ...line.slots!.map((slot) => _buildSlot(slot)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(CodeSlot slot) {
    final chipId = _slotAnswers[slot.id];
    final chip = chipId != null ? widget.level.wordBank.firstWhere((w) => w.id == chipId) : null;
    
    final isCorrect = _results[slot.id];
    final isHinted = _hintSlotId == slot.id;

    return DragTarget<WordChip>(
      onAcceptWithDetails: (details) {
        setState(() {
          if (chip != null) _wordBank.add(chip);
          _slotAnswers[slot.id] = details.data.id;
          _wordBank.removeWhere((w) => w.id == details.data.id);
          if (_hintSlotId == slot.id) _hintSlotId = null; // Clear hint if user fills it
        });
      },
      builder: (context, candidateData, rejectedData) {
        Widget slotContent = GestureDetector(
          onTap: () {
            if (_checked) return;
            if (chipId != null) {
              setState(() {
                _wordBank.add(chip!);
                _slotAnswers[slot.id] = null;
                if (_hintSlotId == slot.id) _hintSlotId = null; // Clear hint if user interacts
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            constraints: const BoxConstraints(minWidth: 40),
            decoration: BoxDecoration(
              color: _checked
                  ? (isCorrect! ? AppTheme.accentBlue.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2))
                  : (chipId != null 
                      ? widget.accentColor.withValues(alpha: 0.15) 
                      : (isHinted ? Colors.amber.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05))),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _checked
                    ? (isCorrect! ? AppTheme.accentBlue : Colors.red)
                    : (isHinted 
                        ? Colors.amber 
                        : (chipId != null ? widget.accentColor : Colors.white.withValues(alpha: 0.1))),
                width: isHinted ? 2 : 1,
              ),
              boxShadow: [
                if (isHinted) BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Text(
              chip?.label ?? '_____',
              style: TextStyle(
                color: chipId != null ? Colors.white : Colors.white24,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: chipId != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );

        if (_checked && isCorrect == false) {
           slotContent = slotContent.animate(target: 1).shakeX(amount: 3);
        }

        if (chipId != null && !_checked) {
           final WordChip activeChip = chip as WordChip;
           return Draggable<WordChip>(
             data: activeChip,
             feedback: Material(color: Colors.transparent, child: _buildChipUI(activeChip, isDragging: true)),
             childWhenDragging: Container(
               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               constraints: const BoxConstraints(minWidth: 40),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.05),
                 borderRadius: BorderRadius.circular(6),
                 border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
               ),
               child: const Text('_____', style: TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'monospace')),
             ),
             onDragCompleted: () {
                setState(() {
                   _slotAnswers[slot.id] = null;
                });
             },
             onDraggableCanceled: (velocity, offset) {
                setState(() {
                   _wordBank.add(activeChip);
                   _slotAnswers[slot.id] = null;
                });
             },
             child: slotContent,
           );
        }

        return slotContent;
      },
    );
  }

  Widget _buildWordBank() {
    return Container(
      height: 140, // Increased height to make scrolling easier
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1420),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Scrollbar(
        controller: _wordBankController,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: ListView.builder(
          controller: _wordBankController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          itemCount: _wordBank.length,
          itemBuilder: (context, index) {
            final chip = _wordBank[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Draggable<WordChip>(
                data: chip,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildChipUI(chip, isDragging: true),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _buildChipUI(chip)),
                child: _buildChipUI(chip),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChipUI(WordChip chip, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          if (isDragging) BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10),
        ],
      ),
      child: Text(
        chip.label,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBottomBar() {
    final allFilled = !_slotAnswers.containsValue(null);
    final allCorrect = _checked && _results.values.every((v) => v);
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showExplanation)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: allCorrect ? AppTheme.accentBlue.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: allCorrect ? AppTheme.accentBlue.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(allCorrect ? Icons.check_circle_rounded : Icons.error_rounded, color: allCorrect ? AppTheme.accentBlue : Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        allCorrect ? 'Great Job!' : 'Logic Error',
                        style: TextStyle(color: allCorrect ? AppTheme.accentBlue : Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.level.feedbackExplanation,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checked 
                ? (allCorrect ? () => Navigator.pop(context, true) : () => setState(() {
                    _checked = false;
                    _showExplanation = false;
                  })) 
                : (allFilled ? _checkAnswers : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _checked 
                  ? (allCorrect ? AppTheme.accentBlue : Colors.red) 
                  : widget.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _checked ? (allCorrect ? 'CONTINUE' : 'TRY AGAIN') : 'CHECK',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: _checked ? 12 : 0),
          if (!_checked)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isHintAdLoading ? null : _showHintWithAd,
                icon: _isHintAdLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2))
                    : const Icon(Icons.lightbulb_outline_rounded, color: Colors.orange),
                label: Text(_isHintAdLoading ? 'WAIT...' : (isPremium ? 'GET HINT' : 'GET HINT (WATCH AD)'), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          if (_checked && !allCorrect) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                 onPressed: _isHintAdLoading ? null : _showHintWithAd,
                 icon: _isHintAdLoading
                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                     : const Icon(Icons.play_circle_filled_rounded, color: Colors.black),
                 label: Text(_isHintAdLoading ? 'WAIT...' : (isPremium ? 'GET HINT' : 'WATCH AD FOR HINT'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black)),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.amber,
                   padding: const EdgeInsets.symmetric(vertical: 18),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showHintWithAd() async {
    if (_isHintAdLoading) return;
    setState(() => _isHintAdLoading = true);

    final isPremium = context.read<SubscriptionService>().isPremium;
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading Rewarded Ad...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final adService = context.read<AdService>();
    bool success = await adService.showRewardedAd();
    
    if (!mounted) return;
    setState(() => _isHintAdLoading = false);

    if (success) {
       // Find the first incorrect or empty slot that has a chip in the bank
       String? slotToFix;
       WordChip? correctChip;

       for (var line in widget.level.lines) {
         if (line.slots != null) {
           for (var slot in line.slots!) {
             final currentChipId = _slotAnswers[slot.id];
             final correctChipForSlot = widget.level.wordBank.firstWhere((w) => w.correctSlotId == slot.id);
             
             // If slot is empty or has a wrong chip
             if (currentChipId == null || currentChipId != correctChipForSlot.id) {
               slotToFix = slot.id;
               correctChip = correctChipForSlot;
               break;
             }
           }
         }
         if (slotToFix != null) break;
       }
       
       if (slotToFix != null && mounted) {
          setState(() {
             _hintSlotId = slotToFix;
             _checked = false;
             _showExplanation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Hint: Place "${correctChip?.label ?? 'the correct statement'}" in the highlighted slot!'), 
               backgroundColor: Colors.amber[900],
               duration: const Duration(seconds: 4),
             ),
          );
       }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load ad. Check your connection or try again later.'), 
            backgroundColor: Colors.redAccent,
          ),
       );
    }
  }

  void _showVictoryDialog(int xp, int stars) {
    // Check if this was the last level to award certificate
    final progress = context.read<ProgressService>();
    final gameProgress = context.read<GameProgressService>();
    
    // Check if all coding levels are completed
    bool allCodingDone = true;
    for (var zone in codingGameZones) {
       for (var level in zone.levels) {
          if (level.id != widget.level.id && !gameProgress.isCodingLevelCompleted(level.id)) {
             allCodingDone = false;
             break;
          }
       }
       if (!allCodingDone) break;
    }

    if (allCodingDone) {
       progress.unlockCertificate(ProgressService.certPlatformDeveloper);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1420),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LEVEL COMPLETE', style: TextStyle(color: widget.accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < stars ? Colors.amber : Colors.white12,
                    size: 40,
                  ).animate(target: index < stars ? 1 : 0).scale(delay: (index * 100).ms, duration: 400.ms, curve: Curves.elasticOut);
                }),
              ),
              const SizedBox(height: 16),
              Text(
                stars == 3 ? 'Perfect Execution!' : stars == 2 ? 'Great Job!' : 'Level Passed!',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              ShareableAchievementCard(
                title: widget.level.title,
                subtitle: 'Completed with $stars Stars!',
                icon: widget.level.isBoss ? Icons.military_tech_rounded : Icons.code_rounded,
                color: widget.accentColor,
                score: '+$xp XP',
                isDark: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to map
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('CONTINUE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

