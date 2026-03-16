import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';

class CodeGameScreen extends StatefulWidget {
  final CodeChallenge challenge;
  final Color zoneColor;

  const CodeGameScreen({
    super.key,
    required this.challenge,
    required this.zoneColor,
  });

  @override
  State<CodeGameScreen> createState() => _CodeGameScreenState();
}

class _CodeGameScreenState extends State<CodeGameScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  late Map<String, String?> _filledBlanks;     // blankId → placed token
  late List<String> _wordBank;                  // available tokens
  String? _selectedToken;                       // currently selected chip
  bool _checked = false;
  Map<String, bool> _blankResults = {};         // blankId → correct?
  int _mistakes = 0;
  int _hintsUsed = 0;
  bool _showHint = false;
  String _currentHint = '';

  // Timer
  Timer? _timer;
  int _timeRemaining = 0;

  @override
  void initState() {
    super.initState();
    _filledBlanks = { for (var b in widget.challenge.blanks) b.id: null };
    _wordBank = List.from(widget.challenge.allTokens);

    if (widget.challenge.timeLimit > 0) {
      _timeRemaining = widget.challenge.timeLimit;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeRemaining <= 1) {
          setState(() { _timeRemaining = 0; });
          _timer?.cancel();
          _checkAnswers();
        } else {
          setState(() => _timeRemaining--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sound = context.read<SoundService>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(sound),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleCard(),
                    const SizedBox(height: 16),
                    _buildCodeEditor(),
                    const SizedBox(height: 16),
                    if (_checked) _buildFeedbackPanel(),
                    if (_showHint && !_checked) _buildHintBubble(),
                  ],
                ),
              ),
            ),
            if (!_checked) _buildWordBank(sound),
            _buildBottomActions(sound),
          ],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar(SoundService sound) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              sound.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // Progress dots
          Expanded(
            child: Row(
              children: widget.challenge.blanks.asMap().entries.map((e) {
                final blankId = e.value.id;
                final filled = _filledBlanks[blankId] != null;
                final correct = _blankResults[blankId];
                Color dotColor;
                if (correct == true) {
                  dotColor = const Color(0xFF4CAF50);
                } else if (correct == false) {
                  dotColor = const Color(0xFFFF5252);
                } else if (filled) {
                  dotColor = widget.zoneColor;
                } else {
                  dotColor = Colors.white.withValues(alpha: 0.15);
                }
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 12),
          // Timer or language badge
          if (widget.challenge.timeLimit > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _timeRemaining <= 10
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _timeRemaining <= 10
                      ? Colors.red.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_rounded,
                      color: _timeRemaining <= 10 ? Colors.red : Colors.white54,
                      size: 14),
                  const SizedBox(width: 4),
                  Text('${_timeRemaining}s',
                      style: TextStyle(
                          color: _timeRemaining <= 10
                              ? Colors.red
                              : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.zoneColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.challenge.language.toUpperCase(),
                style: TextStyle(
                    color: widget.zoneColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1),
              ),
            ),
        ],
      ),
    );
  }

  // ── Title card ──────────────────────────────────────────────────────────────
  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.zoneColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.zoneColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.zoneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.challenge.isBoss
                  ? Icons.local_fire_department_rounded
                  : Icons.code_rounded,
              color: widget.zoneColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.challenge.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                if (widget.challenge.subtitle.isNotEmpty)
                  Text(widget.challenge.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05);
  }

  // ── Code editor ─────────────────────────────────────────────────────────────
  Widget _buildCodeEditor() {
    // Parse template into segments: text and blanks
    final segments = _parseTemplate(widget.challenge.codeTemplate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.zoneColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _fileExtension(widget.challenge.language),
              style: TextStyle(
                  color: widget.zoneColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
          // Code content with blanks
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.7,
                color: Color(0xFFE0E0E0),
              ),
              children: segments.map((seg) {
                if (seg.isBlank) {
                  return WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _buildBlankSlot(seg.blankId!),
                  );
                }
                return TextSpan(
                  text: seg.text,
                  style: TextStyle(
                    color: _syntaxColor(seg.text ?? ''),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildBlankSlot(String blankId) {
    final filled = _filledBlanks[blankId];
    final result = _blankResults[blankId];
    final isSelected = _selectedToken != null && filled == null;

    Color bgColor;
    Color borderColor;
    if (result == true) {
      bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.15);
      borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.5);
    } else if (result == false) {
      bgColor = Colors.red.withValues(alpha: 0.15);
      borderColor = Colors.red.withValues(alpha: 0.5);
    } else if (filled != null) {
      bgColor = widget.zoneColor.withValues(alpha: 0.12);
      borderColor = widget.zoneColor.withValues(alpha: 0.4);
    } else {
      bgColor = Colors.white.withValues(alpha: isSelected ? 0.1 : 0.04);
      borderColor = isSelected
          ? widget.zoneColor.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.15);
    }

    return GestureDetector(
      onTap: () {
        if (_checked) return;
        if (filled != null) {
          // Remove placed token back to bank
          setState(() {
            _wordBank.add(filled);
            _filledBlanks[blankId] = null;
          });
        } else if (_selectedToken != null) {
          // Place selected token
          setState(() {
            _filledBlanks[blankId] = _selectedToken;
            _wordBank.remove(_selectedToken);
            _selectedToken = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        constraints: const BoxConstraints(minWidth: 80),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          filled ?? '______',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: filled != null ? FontWeight.w700 : FontWeight.w400,
            color: filled != null
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  // ── Word bank ───────────────────────────────────────────────────────────────
  Widget _buildWordBank(SoundService sound) {
    if (_wordBank.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORD BANK',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _wordBank.map((token) {
              final isSelected = _selectedToken == token;
              return GestureDetector(
                onTap: () {
                  sound.playTap();
                  setState(() {
                    _selectedToken = isSelected ? null : token;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.zoneColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? widget.zoneColor.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color:
                                    widget.zoneColor.withValues(alpha: 0.2),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: Text(
                    token,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? widget.zoneColor
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Bottom actions ──────────────────────────────────────────────────────────
  Widget _buildBottomActions(SoundService sound) {
    final allFilled = !_filledBlanks.containsValue(null);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Hint button
          if (!_checked)
            GestureDetector(
              onTap: () {
                sound.playTap();
                _showNextHint();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.amber, size: 20),
              ),
            ),
          if (!_checked) const SizedBox(width: 12),
          // CHECK / CONTINUE button
          Expanded(
            child: ElevatedButton(
              onPressed: _checked
                  ? _onContinue
                  : (allFilled ? _checkAnswers : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _checked
                    ? (_blankResults.values.every((v) => v)
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252))
                    : widget.zoneColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _checked
                    ? (_blankResults.values.every((v) => v)
                        ? 'CONTINUE'
                        : 'TRY AGAIN')
                    : 'CHECK',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hint bubble ─────────────────────────────────────────────────────────────
  Widget _buildHintBubble() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_currentHint,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13)),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  // ── Feedback panel ──────────────────────────────────────────────────────────
  Widget _buildFeedbackPanel() {
    final allCorrect = _blankResults.values.every((v) => v);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allCorrect
            ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allCorrect
              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allCorrect
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: allCorrect
                    ? const Color(0xFF4CAF50)
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                allCorrect ? 'Perfect!' : 'Not quite right',
                style: TextStyle(
                  color: allCorrect
                      ? const Color(0xFF4CAF50)
                      : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show explanation for each blank
          ...widget.challenge.blanks.map((blank) {
            final correct = _blankResults[blank.id] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    correct ? Icons.check_rounded : Icons.close_rounded,
                    color: correct
                        ? const Color(0xFF4CAF50)
                        : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blank.correctToken,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          blank.explanation,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  // ── Logic ─────────────────────────────────────────────────────────────────
  void _checkAnswers() {
    final results = <String, bool>{};
    for (var blank in widget.challenge.blanks) {
      results[blank.id] = _filledBlanks[blank.id] == blank.correctToken;
    }

    final allCorrect = results.values.every((v) => v);
    if (!allCorrect) _mistakes++;

    setState(() {
      _blankResults = results;
      _checked = true;
      _showHint = false;
    });

    _timer?.cancel();

    if (allCorrect) {
      // Award XP
      final progress = context.read<GameProgressService>();
      int xp = 50; // base
      if (_mistakes == 0 && _hintsUsed == 0) xp = 80; // perfect
      if (widget.challenge.isBoss) xp += 50; // boss bonus
      progress.addXP(xp);

      // Stars: 3 = no mistakes no hints, 2 = ≤1 mistake, 1 = completed
      int stars = 1;
      if (_mistakes == 0 && _hintsUsed == 0) {
        stars = 3;
      } else if (_mistakes <= 1) {
        stars = 2;
      }
      progress.completeLevel(widget.challenge.id, stars);
    }
  }

  void _onContinue() {
    final allCorrect = _blankResults.values.every((v) => v);
    if (allCorrect) {
      Navigator.pop(context, true); // signal completion
    } else {
      // Reset for retry
      setState(() {
        _checked = false;
        _blankResults = {};
        // Return incorrectly placed tokens to bank
        for (var blank in widget.challenge.blanks) {
          if (_filledBlanks[blank.id] != null &&
              _filledBlanks[blank.id] != blank.correctToken) {
            _wordBank.add(_filledBlanks[blank.id]!);
            _filledBlanks[blank.id] = null;
          }
        }
      });
    }
  }

  void _showNextHint() {
    // Find first unfilled blank and show its hint
    for (var blank in widget.challenge.blanks) {
      if (_filledBlanks[blank.id] == null && blank.hint.isNotEmpty) {
        setState(() {
          _showHint = true;
          _currentHint = blank.hint;
          _hintsUsed++;
        });
        return;
      }
    }
    // If all filled, hint for the first one
    if (widget.challenge.blanks.isNotEmpty) {
      setState(() {
        _showHint = true;
        _currentHint = widget.challenge.blanks.first.hint;
        _hintsUsed++;
      });
    }
  }

  // ── Template parser ─────────────────────────────────────────────────────────
  List<_CodeSegment> _parseTemplate(String template) {
    final segments = <_CodeSegment>[];
    final regex = RegExp(r'___(\w+)___');
    int lastEnd = 0;

    for (final match in regex.allMatches(template)) {
      if (match.start > lastEnd) {
        segments
            .add(_CodeSegment(text: template.substring(lastEnd, match.start)));
      }
      segments.add(_CodeSegment(blankId: match.group(1)));
      lastEnd = match.end;
    }
    if (lastEnd < template.length) {
      segments.add(_CodeSegment(text: template.substring(lastEnd)));
    }
    return segments;
  }

  Color _syntaxColor(String text) {
    // Very simple keyword highlighting
    final keywords = {
      'class', 'public', 'private', 'protected', 'override', 'void', 'var',
      'val', 'let', 'func', 'fun', 'return', 'if', 'else', 'for', 'true',
      'false', 'new', 'const', 'final', 'static', 'async', 'await', 'import',
      'super', 'this', 'null'
    };
    final trimmed = text.trim();
    if (keywords.contains(trimmed)) {
      return const Color(0xFFBB86FC); // purple for keywords
    }
    return const Color(0xFFE0E0E0);
  }

  String _fileExtension(String language) {
    switch (language) {
      case 'swift':
        return '◆ main.swift';
      case 'kotlin':
        return '◆ main.kt';
      case 'cpp':
        return '◆ main.cpp';
      default:
        return '◆ script.cs';
    }
  }
}

class _CodeSegment {
  final String? text;
  final String? blankId;
  bool get isBlank => blankId != null;

  _CodeSegment({this.text, this.blankId});
}
