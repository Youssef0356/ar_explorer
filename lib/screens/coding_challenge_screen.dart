import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/coding_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';

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
  WordChip? _selectedChip;
  bool _checked = false;
  Map<String, bool> _results = {}; // slotId -> correct?
  int _timeRemaining = 0;
  Timer? _timer;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    _slotAnswers = {};
    for (var line in widget.level.lines) {
      if (line.slots != null) {
        for (var slot in line.slots!) {
          _slotAnswers[slot.id] = null;
        }
      }
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAnswers() {
    final results = <String, bool>{};
    bool allCorrect = true;

    for (var line in widget.level.lines) {
      if (line.slots != null) {
        for (var slot in line.slots!) {
          final placedChipId = _slotAnswers[slot.id];
          final isCorrect = _wordBank.any((w) => w.id == placedChipId && w.correctSlotId == slot.id);
          results[slot.id] = isCorrect;
          if (!isCorrect) allCorrect = true; // Wait, logic error: allCorrect should be false if any is incorrect
          // Correction:
          if (!isCorrect) allCorrect = false;
        }
      }
    }

    setState(() {
      _results = results;
      _checked = true;
      _showExplanation = true;
    });

    final sound = context.read<SoundService>();
    if (allCorrect) {
      sound.playSuccess();
      context.read<GameProgressService>().addCodingXP(widget.level.isBoss ? 150 : 50);
    } else {
      sound.playFailure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
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

    return DragTarget<WordChip>(
      onAcceptWithDetails: (details) {
        setState(() {
          _slotAnswers[slot.id] = details.data.id;
          _wordBank.removeWhere((w) => w.id == details.data.id);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            if (_checked) return;
            if (chipId != null) {
              setState(() {
                _wordBank.add(chip!);
                _slotAnswers[slot.id] = null;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            constraints: const BoxConstraints(minWidth: 40),
            decoration: BoxDecoration(
              color: _checked
                  ? (isCorrect! ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2))
                  : (chipId != null ? widget.accentColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _checked
                    ? (isCorrect! ? Colors.green : Colors.red)
                    : (chipId != null ? widget.accentColor : Colors.white.withValues(alpha: 0.1)),
              ),
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
      },
    );
  }

  Widget _buildWordBank() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1420),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: allCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: allCorrect ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(allCorrect ? Icons.check_circle_rounded : Icons.error_rounded, color: allCorrect ? Colors.green : Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        allCorrect ? 'Great Job!' : 'Logic Error',
                        style: TextStyle(color: allCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
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
                  ? (allCorrect ? Colors.green : Colors.red) 
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
        ],
      ),
    );
  }
}
