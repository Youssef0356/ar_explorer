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
  String _errorMessage = '';
  int _secondsRemaining = 0;
  Timer? _timer;
  int _starsEarned = 3;

  @override
  void initState() {
    super.initState();
    _slots = List.filled(widget.level.correctSequence.length, null);
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
    });

    bool allCorrect = true;
    int firstWrongIndex = -1;

    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i]?.id != widget.level.correctSequence[i]) {
        allCorrect = false;
        firstWrongIndex = i;
        break;
      }
      await Future.delayed(300.ms);
      setState(() {}); // Trigger refresh for pulse animation
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
      if (widget.level.isBoss) {
        _starsEarned = max(1, _starsEarned - 1);
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
          if (_showFailure && widget.level.isBoss && _secondsRemaining <= 0) 
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
                  style: AppTheme.labelMedium.copyWith(
                    color: widget.level.isBoss ? Colors.red : zone.accentColor,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  widget.level.title,
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
    final color = _secondsRemaining <= 10 ? Colors.red : Colors.white;
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
    ).animate(target: _secondsRemaining <= 10 ? 1 : 0).shake();
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(_slots.length, (index) {
              final node = _slots[index];
              return _buildPipelineSlot(index, node, accentColor);
            }),
          ),
        ),
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
    return GestureDetector(
      onTap: () => _removeNodeFromPipeline(index),
      child: Container(
        width: 80,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: node != null ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: node != null ? accentColor : Colors.white.withValues(alpha: 0.1),
            width: node != null ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (node == null)
              Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white10, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            if (node != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(node.icon, color: accentColor, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    node.name,
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate().scale(curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }

  Widget _buildNodePool() {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
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
    return GestureDetector(
      onTap: isInPipeline ? null : () => _addNodeToPipeline(node),
      child: Opacity(
        opacity: isInPipeline ? 0.3 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(node.icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      node.description,
                      style: const TextStyle(color: Colors.white38, fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black),
              child: const Text('RETURN TO MAP'),
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
