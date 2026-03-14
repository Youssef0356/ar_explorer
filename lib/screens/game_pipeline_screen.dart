import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../data/game_data.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';

class GamePipelineScreen extends StatefulWidget {
  final ARLevel level;
  const GamePipelineScreen({super.key, required this.level});

  @override
  State<GamePipelineScreen> createState() => _GamePipelineScreenState();
}

class _GamePipelineScreenState extends State<GamePipelineScreen> {
  late List<ARNode?> _slots;
  late List<ARNode>  _pool;
  bool   _isValidating  = false;
  bool   _showSuccess   = false;
  bool   _showFailure   = false;
  bool   _isTimeout     = false;
  String _errorMessage  = '';
  int    _secondsRemaining = 0;
  Timer? _timer;
  int    _starsEarned   = 3;
  List<bool> _slotPulsed = [];
  int    _failureCount  = 0;
  ARNode? _hintNode;

  // Track which slot index had the last wrong entry (for red highlight)
  int _wrongSlotIndex = -1;

  @override
  void initState() {
    super.initState();
    _slots      = List.filled(widget.level.correctSequence.length, null);
    _slotPulsed = List.filled(widget.level.correctSequence.length, false);
    _pool       = List.from(widget.level.availableNodes)..shuffle();
    if (widget.level.isBoss && widget.level.timeLimit > 0) {
      _secondsRemaining = widget.level.timeLimit;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isTimeout = true;
          _showFailure = true;
          _errorMessage = 'Time\'s up! The system crashed.';
          _starsEarned = 0;
        }
      });
    });
  }

  // ── Node placement / removal ──────────────────────────────────────────────
  void _tapNode(ARNode node) {
    if (_isValidating || _showSuccess || _isTimeout) return;
    // If already in pipeline, remove it
    final idx = _slots.indexOf(node);
    if (idx != -1) {
      setState(() {
        _slots[idx] = null;
        _wrongSlotIndex = -1;
      });
      context.read<SoundService>().playTap();
      return;
    }
    // Place in next empty slot
    final empty = _slots.indexOf(null);
    if (empty == -1) return;
    setState(() {
      _slots[empty] = node;
      _wrongSlotIndex = -1;
    });
    context.read<SoundService>().playTap();
    if (!_slots.contains(null)) _validate();
  }

  void _removeSlot(int index) {
    if (_isValidating || _showSuccess || _isTimeout) return;
    setState(() {
      _slots[index] = null;
      _wrongSlotIndex = -1;
    });
    context.read<SoundService>().playTap();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  Future<void> _validate() async {
    setState(() {
      _isValidating  = true;
      _showFailure   = false;
      _slotPulsed    = List.filled(_slots.length, false);
      _wrongSlotIndex = -1;
    });

    int firstWrong = -1;
    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i]?.id != widget.level.correctSequence[i]) {
        firstWrong = i;
        break;
      }
    }
    final allCorrect = firstWrong == -1;

    // Animate slots up to first wrong (or all if correct)
    final animateUntil = allCorrect ? _slots.length : firstWrong + 1;
    for (int i = 0; i < animateUntil; i++) {
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      setState(() => _slotPulsed[i] = true);
      context.read<SoundService>().playTap();
    }

    if (allCorrect) {
      _onSuccess();
    } else {
      _onFailure(firstWrong);
    }
  }

  void _onSuccess() {
    _timer?.cancel();
    setState(() {
      _isValidating = false;
      _showSuccess  = true;
    });
    context.read<GameProgressService>().completeLevel(widget.level.id, _starsEarned);
  }

  void _onFailure(int wrongIndex) {
    setState(() {
      _isValidating   = false;
      _showFailure    = true;
      _wrongSlotIndex = wrongIndex;
      _failureCount++;
      if (widget.level.isBoss) _starsEarned = max(1, _starsEarned - 1);
      if (_failureCount >= 2) {
        _hintNode = widget.level.availableNodes.firstWhere(
          (n) => n.id == widget.level.correctSequence[0],
          orElse: () => widget.level.availableNodes.first,
        );
      }
      _errorMessage = _slots[wrongIndex]?.errorMessage ??
          'Wrong node at step ${wrongIndex + 1}. Try again!';
    });
    // Auto-clear the wrong slot after 1.5 s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _showFailure) {
        setState(() {
          _slots[wrongIndex] = null;
          _showFailure       = false;
          _wrongSlotIndex    = -1;
        });
      }
    });
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
  void _goNextLevel() {
    final zIdx = arGameZones.indexWhere((z) => z.id == widget.level.zoneId);
    final lIdx = arGameZones[zIdx].levels.indexWhere((l) => l.id == widget.level.id);
    ARLevel? next;
    if (lIdx < arGameZones[zIdx].levels.length - 1) {
      next = arGameZones[zIdx].levels[lIdx + 1];
    } else if (zIdx < arGameZones.length - 1) {
      next = arGameZones[zIdx + 1].levels.first;
    }
    if (next != null) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => GamePipelineScreen(level: next!)));
    } else {
      Navigator.pop(context);
    }
  }

  void _retry() {
    setState(() {
      _slots          = List.filled(widget.level.correctSequence.length, null);
      _slotPulsed     = List.filled(widget.level.correctSequence.length, false);
      _showFailure    = false;
      _isTimeout      = false;
      _wrongSlotIndex = -1;
      _starsEarned    = 3;
      _failureCount   = 0;
      _hintNode       = null;
      if (widget.level.isBoss) {
        _secondsRemaining = widget.level.timeLimit;
        _startTimer();
      }
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final zone = arGameZones.firstWhere((z) => z.id == widget.level.zoneId);

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(zone),
                _buildGoalBanner(zone),
                _buildHowToPlay(zone.accentColor),
                const SizedBox(height: 8),
                // ── Pipeline slots ──
                _buildPipelineRow(zone.accentColor),
                // ── Error message ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _showFailure
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMessage,
                                    style: const TextStyle(color: Colors.red, fontSize: 12))),
                              ],
                            ),
                          ).animate().shake(),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 4),
                // ── Node pool ──
                Expanded(child: _buildNodePool(zone.accentColor)),
                // ── Validate button ──
                _buildValidateButton(zone.accentColor),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(zone),
          if (_isTimeout)   _buildTimeoutOverlay(zone),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ARZone zone) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.7)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.level.isBoss ? '⚡ BOSS CHALLENGE' : zone.name.toUpperCase(),
                  style: TextStyle(
                    color: widget.level.isBoss ? Colors.red : zone.accentColor,
                    fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                Text(widget.level.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (widget.level.isBoss) _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final secs = _secondsRemaining;
    final color = secs <= 10 ? Colors.red : secs <= 30 ? Colors.amber : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, color: color, size: 16),
          const SizedBox(width: 4),
          Text('${secs}s',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    ).animate(target: secs <= 10 ? 1 : 0).shake(hz: 2);
  }

  // ── Goal banner ───────────────────────────────────────────────────────────
  Widget _buildGoalBanner(ARZone zone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: zone.accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: zone.accentColor.withValues(alpha: 0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_rounded, color: zone.accentColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.level.goal,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  // ── How-to-play strip ─────────────────────────────────────────────────────
  Widget _buildHowToPlay(Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: accentColor.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Tap nodes below to build the pipeline in the correct order. '
              'Tap a placed node to remove it.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  // ── Pipeline slots row ────────────────────────────────────────────────────
  Widget _buildPipelineRow(Color accentColor) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _slots.length,
        separatorBuilder: (_, index) => Center(
          child: Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.15), size: 12),
        ),
        itemBuilder: (_, i) => _buildSlot(i, accentColor),
      ),
    );
  }

  Widget _buildSlot(int index, Color accentColor) {
    final node     = _slots[index];
    final isPulsed = _slotPulsed[index];
    final isWrong  = _wrongSlotIndex == index;

    final borderColor = isWrong
        ? Colors.red
        : isPulsed
            ? Colors.green
            : node != null
                ? accentColor.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: node != null ? () => _removeSlot(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: node != null
              ? (isWrong
                  ? Colors.red.withValues(alpha: 0.1)
                  : isPulsed
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.06))
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (isPulsed || isWrong) ? 2 : 1),
          boxShadow: isPulsed || isWrong
              ? [BoxShadow(
                  color: (isWrong ? Colors.red : accentColor).withValues(alpha: 0.25),
                  blurRadius: 10)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Slot number
            Text('${index + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (node != null) ...[
              Icon(node.icon,
                color: isWrong ? Colors.red : isPulsed ? Colors.green : accentColor,
                size: 24)
                  .animate(target: isPulsed ? 1 : 0)
                  .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(node.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9, height: 1.2)),
              ),
            ] else ...[
              Icon(Icons.add_rounded,
                color: Colors.white.withValues(alpha: 0.15), size: 20),
              const SizedBox(height: 2),
              Text('EMPTY',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.12),
                  fontSize: 8, letterSpacing: 0.5)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Node pool ─────────────────────────────────────────────────────────────
  Widget _buildNodePool(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text('AVAILABLE NODES',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const Spacer(),
              Text('${_slots.where((s) => s != null).length} / ${_slots.length} placed',
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.6),
                  fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: _pool.length,
            itemBuilder: (_, i) => _buildPoolNode(_pool[i], accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPoolNode(ARNode node, Color accentColor) {
    final slotIndex  = _slots.indexOf(node);
    final isPlaced   = slotIndex != -1;
    final isHint     = _hintNode?.id == node.id;

    return GestureDetector(
      onTap: () => _tapNode(node),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaced
              ? Colors.white.withValues(alpha: 0.02)
              : isHint
                  ? Colors.amber.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHint
                ? Colors.amber.withValues(alpha: 0.5)
                : isPlaced
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.1))),
        child: Row(
          children: [
            // ── Icon box ──
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isPlaced
                    ? Colors.white.withValues(alpha: 0.03)
                    : accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPlaced
                      ? Colors.white.withValues(alpha: 0.06)
                      : accentColor.withValues(alpha: 0.3))),
              child: Icon(node.icon,
                color: isPlaced
                    ? Colors.white.withValues(alpha: 0.2)
                    : isHint ? Colors.amber : accentColor,
                size: 20),
            ),
            const SizedBox(width: 12),
            // ── Name + description ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.name,
                    style: TextStyle(
                      color: isPlaced
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(node.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: isPlaced ? 0.18 : 0.4),
                      fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ── Status badge ──
            if (isPlaced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text('SLOT ${slotIndex + 1}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              )
            else if (isHint)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: const Text('HINT',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              )
            else
              Icon(Icons.add_circle_outline_rounded,
                color: Colors.white.withValues(alpha: 0.2), size: 18),
          ],
        ),
      ).animate(target: isHint ? 1 : 0).shimmer(delay: 1.seconds, duration: 1.5.seconds),
    );
  }

  // ── Validate button ───────────────────────────────────────────────────────
  Widget _buildValidateButton(Color accentColor) {
    final filledCount = _slots.where((s) => s != null).length;
    final allFilled   = filledCount == _slots.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          // ── Clear all button ──
          GestureDetector(
            onTap: () {
              if (_isValidating || _showSuccess) return;
              setState(() {
                _slots       = List.filled(_slots.length, null);
                _showFailure = false;
                _wrongSlotIndex = -1;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: Icon(Icons.refresh_rounded,
                color: Colors.white.withValues(alpha: 0.5), size: 20),
            ),
          ),
          const SizedBox(width: 10),
          // ── Submit button ──
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: allFilled && !_isValidating ? 1.0 : 0.4,
              child: ElevatedButton(
                onPressed: (!allFilled || _isValidating || _showSuccess) ? null : _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                child: _isValidating
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black.withValues(alpha: 0.6)))
                    : Text(
                        allFilled ? 'RUN PIPELINE' : 'FILL ALL SLOTS  ($filledCount/${_slots.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Success overlay ───────────────────────────────────────────────────────
  Widget _buildSuccessOverlay(ARZone zone) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: zone.accentColor.withValues(alpha: 0.1),
                  border: Border.all(color: zone.accentColor.withValues(alpha: 0.4), width: 2)),
                child: Icon(Icons.check_rounded, color: zone.accentColor, size: 56),
              ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

              const SizedBox(height: 20),
              const Text('PIPELINE ONLINE',
                style: TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: 3),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star_rounded,
                    size: 38,
                    color: i < _starsEarned ? Colors.amber : Colors.white.withValues(alpha: 0.1)),
                ).animate(delay: Duration(milliseconds: 400 + i * 150)).scale(
                    curve: Curves.elasticOut)),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goNextLevel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: zone.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                  child: const Text('NEXT LEVEL',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('RETURN TO MAP',
                  style: TextStyle(color: zone.accentColor.withValues(alpha: 0.7), fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  // ── Timeout overlay ───────────────────────────────────────────────────────
  Widget _buildTimeoutOverlay(ARZone zone) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 2)),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 56),
              ).animate().shake(),

              const SizedBox(height: 20),
              const Text('SYSTEM CRASHED',
                style: TextStyle(color: Colors.red, fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: 3)),
              const SizedBox(height: 8),
              Text('Time ran out. The AR pipeline failed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                  child: const Text('RETRY',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('BACK TO MAP',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}