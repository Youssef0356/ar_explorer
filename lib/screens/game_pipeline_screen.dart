import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
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
  List<ARNode?> _slots = [];
  List<ARNode> _pool = [];
  bool _isValidating = false;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _isTimeout = false;
  String _errorMessage = '';
  int _secondsRemaining = 0;
  Timer? _timer;
  int _starsEarned = 3;
  List<bool> _nodesPulsed = [];
  int _failureCount = 0;
  ARNode? _hintNode;

  @override
  void initState() {
    super.initState();
    _slots = List.filled(widget.level.correctSequence.length, null);
    _nodesPulsed = List.filled(widget.level.correctSequence.length, false);
    _pool = List.from(widget.level.availableNodes)..shuffle();
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

  void _startTimer() {
    _timer = Timer.periodic(1.seconds, (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    setState(() {
      _isTimeout = true;
      _showFailure = true;
      _errorMessage = 'SYSTEM CRITICAL: Session Timeout';
      _starsEarned = 0;
    });
  }

  void _addNodeToPipeline(ARNode node) {
    if (_isValidating || _showSuccess) return;

    final emptyIndex = _slots.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _slots[emptyIndex] = node;
      });
      context.read<SoundService>().playTap();

      if (!_slots.contains(null)) {
        _validatePipeline();
      }
    }
  }

  void _removeNodeFromPipeline(int index) {
    if (_isValidating || _showSuccess || _slots[index] == null) return;

    setState(() {
      _slots[index] = null;
    });
    context.read<SoundService>().playTap();
  }

  Future<void> _validatePipeline() async {
    setState(() {
      _isValidating = true;
      _showFailure = false;
      _nodesPulsed = List.filled(_slots.length, false);
    });

    bool allCorrect = true;
    int firstWrongIndex = -1;

    // Run validation synchronously to determine the outcome
    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i]?.id != widget.level.correctSequence[i]) {
        allCorrect = false;
        firstWrongIndex = i;
        break;
      }
    }

    // Trigger visual pulse animation regardless of outcome (up to failure point)
    int animateUntil = allCorrect ? _slots.length : firstWrongIndex + 1;
    for (int i = 0; i < animateUntil; i++) {
      await Future.delayed(300.ms);
      if (!mounted) return;
      setState(() {
        _nodesPulsed[i] = true;
      });
      context.read<SoundService>().playTap();
    }

    if (allCorrect) {
      _onSuccess();
    } else {
      _onFailure(firstWrongIndex);
    }
  }

  void _onSuccess() {
    _timer?.cancel();
    setState(() {
      _isValidating = false;
      _showSuccess = true;
    });
    context.read<GameProgressService>().completeLevel(widget.level.id, _starsEarned);
  }

  void _onFailure(int wrongIndex) {
    setState(() {
      _isValidating = false;
      _showFailure = true;
      _failureCount++;
      if (widget.level.isBoss) {
        _starsEarned = max(1, _starsEarned - 1);
      }
      
      // Hint system: Reveal first node after 2 failures
      if (_failureCount >= 2 && widget.level.isBoss) {
        _hintNode = widget.level.availableNodes.firstWhere(
          (n) => n.id == widget.level.correctSequence[0]
        );
      }

      _errorMessage = _slots[wrongIndex]?.errorMessage ?? 'Error: Invalid sequence at node ${wrongIndex + 1}';
      
      // Auto-clear wrong slots after a delay
      Future.delayed(1500.ms, () {
        if (mounted && _showFailure) {
          setState(() {
             _slots[wrongIndex] = null;
             _showFailure = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final zone = arGameZones.firstWhere((z) => z.id == widget.level.zoneId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(zone),
                _buildGoalSection(),
                const Spacer(),
                _buildPipelineArea(zone.accentColor),
                const Spacer(),
                _buildNodePool(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(zone.accentColor),
          if (_isTimeout && widget.level.isBoss) 
            _buildBossFailureOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(ARZone zone) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.level.isBoss ? 'BOSS CHALLENGE' : zone.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.labelMedium.copyWith(
                    color: widget.level.isBoss ? Colors.red : zone.accentColor,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  widget.level.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.headingSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          if (widget.level.isBoss) _buildBossTimer(),
        ],
      ),
    );
  }

  Widget _buildBossTimer() {
    final color = _secondsRemaining <= 10 ? Colors.red : (_secondsRemaining <= 30 ? Colors.amber : Colors.white);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            '${_secondsRemaining}s',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate(target: _secondsRemaining <= 10 ? 1 : 0).shake().scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
  }

  Widget _buildGoalSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.level.goal,
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineArea(Color accentColor) {
    return Column(
      children: [
        Text(
          'PIPELINE SEQUENCE',
          style: AppTheme.labelMedium.copyWith(color: Colors.white38, letterSpacing: 2),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
              stops: const [0.0, 0.05, 0.95, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstOut,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_slots.length, (index) {
                final node = _slots[index];
                return _buildPipelineSlot(index, node, accentColor);
              }),
            ),
          ),
        ),
        if (widget.level.correctSequence.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '← swipe to view more →',
              style: AppTheme.bodySmall.copyWith(color: Colors.white24, fontSize: 10),
            ),
          ).animate().fadeIn().fadeOut(delay: 2.seconds),
        if (_showFailure)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ).animate().shake().fadeOut(delay: 2.seconds),
          ),
      ],
    );
  }

  Widget _buildPipelineSlot(int index, ARNode? node, Color accentColor) {
    final isPulsing = _nodesPulsed[index];
    return GestureDetector(
      onTap: () => _removeNodeFromPipeline(index),
      child: AnimatedContainer(
        duration: 300.ms,
        width: 80,
        height: 80, // Reduced from 100
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: node != null ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPulsing ? accentColor : (node != null ? accentColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
            width: isPulsing ? 3 : (node != null ? 2 : 1),
          ),
          boxShadow: isPulsing ? [
            BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
          ] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 4,
              left: 4,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: node != null ? Colors.white24 : Colors.white10,
                  fontSize: 10,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            if (node != null)
              Icon(node.icon, color: accentColor, size: 28)
                  .animate(target: isPulsing ? 1 : 0)
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildNodePool() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pool.length,
        itemBuilder: (context, index) {
          final node = _pool[index];
          final isInPipeline = _slots.contains(node);
          return _buildPoolNode(node, isInPipeline);
        },
      ),
    );
  }

  Widget _buildPoolNode(ARNode node, bool isInPipeline) {
    final isHint = _hintNode?.id == node.id;
    return GestureDetector(
      onTap: () {
        if (isInPipeline) {
          final slotIdx = _slots.indexOf(node);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Already placed in slot ${slotIdx + 1}'),
              duration: 1.seconds,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _addNodeToPipeline(node);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isInPipeline ? 0.02 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHint ? Colors.amber : (isInPipeline ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.1)),
            width: isHint ? 2 : 1,
          ),
          boxShadow: isHint ? [
            BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 8)
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(node.icon, color: isHint ? Colors.amber : Colors.white70, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        node.name,
                        style: TextStyle(
                          color: isInPipeline ? Colors.white24 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      if (isHint) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 14),
                      ],
                    ],
                  ),
                  Text(
                    node.description,
                    style: TextStyle(
                      color: isInPipeline ? Colors.white10 : Colors.white38,
                      fontSize: 11
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isInPipeline)
              const Icon(Icons.check_circle_rounded, color: Colors.white10, size: 20)
            else
              const Icon(Icons.add_circle_outline_rounded, color: Colors.white24, size: 20),
          ],
        ),
      ).animate(target: isHint ? 1 : 0).shimmer(delay: 1.seconds),
    );
  }

  Widget _buildSuccessOverlay(Color accentColor) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 100)
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'SYSTEM ONLINE',
              style: AppTheme.headingLarge.copyWith(color: Colors.green, letterSpacing: 4),
            ).animate().fadeIn().then().shimmer(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(
                Icons.star_rounded,
                size: 40,
                color: i < _starsEarned ? Colors.amber : Colors.white10,
              ).animate(delay: (200 * i).ms).scale().fadeIn()),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                final currentZoneIndex = arGameZones.indexWhere((z) => z.id == widget.level.zoneId);
                final currentLevelIndex = arGameZones[currentZoneIndex].levels.indexWhere((l) => l.id == widget.level.id);
                
                if (currentLevelIndex < arGameZones[currentZoneIndex].levels.length - 1) {
                  // Next level in same zone
                  final nextLevel = arGameZones[currentZoneIndex].levels[currentLevelIndex + 1];
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => GamePipelineScreen(level: nextLevel)),
                  );
                } else if (currentZoneIndex < arGameZones.length - 1) {
                  // First level in next zone
                  final nextLevel = arGameZones[currentZoneIndex + 1].levels.first;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => GamePipelineScreen(level: nextLevel)),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black),
              child: const Text('NEXT LEVEL'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('RETURN TO MAP', style: TextStyle(color: accentColor)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildBossFailureOverlay() {
    return Container(
      color: Colors.red.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100).animate().shake(),
            const SizedBox(height: 24),
            const Text(
              'SYSTEM CRASHED',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _slots = List.filled(widget.level.correctSequence.length, null);
                  _showFailure = false;
                  _secondsRemaining = widget.level.timeLimit;
                  _startTimer();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
              child: const Text('RETRY SESSION'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
