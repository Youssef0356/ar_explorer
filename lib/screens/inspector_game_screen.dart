import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/inspector_game_data.dart';
import '../models/inspector_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  InspectorGameScreen
//  Layout (portrait):
//
//  ┌──────────────────────────────────────────────────┐
//  │  HEADER  (level title, stars, timer)             │
//  ├──────────────────────────────────────────────────┤
//  │  OBJECTIVE BANNER  (plain-English task)          │
//  ├───────────────────┬──────────────────────────────┤
//  │  3D VIEWPORT      │  INSPECTOR PANEL             │
//  │  (fake Unity      │  ┌ GameObject header ──────┐ │
//  │   scene preview)  │  │ Existing components     │ │
//  │                   │  │ Placed scripts          │ │
//  │                   │  └─────────────────────────┘ │
//  │                   │  ┌ ADD SCRIPT ─────────────┐ │
//  │                   │  │  Script chip bank       │ │
//  │                   │  └─────────────────────────┘ │
//  ├───────────────────┴──────────────────────────────┤
//  │  TERMINAL  (scrollable log output)               │
//  ├──────────────────────────────────────────────────┤
//  │  BOTTOM BAR (progress pips, hint, Run Scene ▶)  │
//  └──────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

class InspectorGameScreen extends StatefulWidget {
  final InspectorLevel level;
  const InspectorGameScreen({super.key, required this.level});

  @override
  State<InspectorGameScreen> createState() => _InspectorGameScreenState();
}

class _InspectorGameScreenState extends State<InspectorGameScreen>
    with TickerProviderStateMixin {

  // ── Runtime state ─────────────────────────────────────────────────────────
  final Set<String> _placedIds   = {};
  int _mistakeCount  = 0;
  int _hintsUsed     = 0;
  bool _showSuccess  = false;
  bool _isValidating = false;

  // Randomised chip order (set once on init)
  late List<ScriptChip> _shuffledBank;

  // Terminal log lines (displayed newest-at-bottom, max 7 visible)
  final List<TerminalLine> _termLog = [];

  // Timer (boss levels)
  int _secondsLeft = 0;
  Timer? _timer;

  // Scene object animation controllers (one per SceneObjectType)
  final Map<SceneObjectType, AnimationController> _sceneControllers = {};

  // Inspector scroll
  final ScrollController _inspScroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // Shuffle the script bank once
    _shuffledBank = [...widget.level.scriptBank]..shuffle(Random());

    // Seed terminal with idle lines
    _termLog.addAll(widget.level.idleTerminal);

    // Scene object fade-in controllers
    for (final obj in widget.level.sceneObjects) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..forward();
      _sceneControllers[obj] = ctrl;
    }

    // Boss timer
    if (widget.level.isBoss && widget.level.timeLimit > 0) {
      _secondsLeft = widget.level.timeLimit;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _sceneControllers.values) c.dispose();
    _inspScroll.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _showSuccess = false;
      _isValidating = false;
    });
    _addTermLine(TerminalLine(TerminalLineType.error, '> TIME\'S UP — scene compilation failed'));
    _showFailureDialog(timedOut: true);
  }

  // ── Terminal helpers ───────────────────────────────────────────────────────
  void _addTermLine(TerminalLine line) {
    setState(() {
      _termLog.add(line);
      if (_termLog.length > 40) _termLog.removeAt(0);
    });
  }

  void _addTermLines(List<TerminalLine> lines) {
    for (final l in lines) _addTermLine(l);
  }

  // ── Place script ───────────────────────────────────────────────────────────
  void _placeScript(ScriptChip chip) {
    if (_placedIds.contains(chip.id) || _showSuccess || _isValidating) return;
    context.read<SoundService>().playTap();

    if (!chip.isCorrect) {
      // Wrong script
      setState(() => _mistakeCount++);
      _addTermLine(
        TerminalLine(TerminalLineType.error,
          '> ERROR: ${chip.errorMessage}'),
      );
      return;
    }

    setState(() {
      _placedIds.add(chip.id);
    });

    // Add chip's terminal lines
    _addTermLines(chip.addLines);

    // Animate scene objects that this chip activates
    for (final obj in chip.activates) {
      // If the object was already visible, pulse it; otherwise bring it in
      final ctrl = _sceneControllers[obj];
      if (ctrl != null) {
        ctrl
          ..reset()
          ..forward();
      }
    }

    // Auto-scroll inspector
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inspScroll.hasClients) {
        _inspScroll.animateTo(
          _inspScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Check if all correct placed → enable validate button
    final allDone = widget.level.correctIds.every(_placedIds.contains);
    if (allDone) {
      setState(() {});
    }
  }

  // ── Validate (Run Scene ▶) ─────────────────────────────────────────────────
  void _validate() {
    if (_isValidating || _showSuccess) return;
    setState(() => _isValidating = true);
    context.read<SoundService>().playTap();

    _timer?.cancel();
    _addTermLines(widget.level.successTerminal);

    final stars = _computeStars();

    // Save progress
    final progress = context.read<GameProgressService>();
    final xp = _computeXP(stars);
    progress.completeLevel(widget.level.id, stars);
    progress.addXP(xp);
    if (widget.level.isBoss) progress.updateStreak();

    setState(() {
      _showSuccess  = true;
      _isValidating = false;
    });
  }

  int _computeStars() {
    if (_mistakeCount == 0 && _hintsUsed == 0) return 3;
    if (_mistakeCount <= 1) return 2;
    return 1;
  }

  int _computeXP(int stars) {
    int base = 50 + (stars - 1) * 15;
    if (widget.level.isBoss) base += 60;
    return base;
  }

  // ── Hint ──────────────────────────────────────────────────────────────────
  void _showHint() {
    setState(() => _hintsUsed++);
    _addTermLine(
      TerminalLine(TerminalLineType.warning, '> HINT: ${widget.level.hint}'),
    );
  }

  // ── Failure dialog ────────────────────────────────────────────────────────
  void _showFailureDialog({bool timedOut = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          timedOut ? '⏱ Time\'s Up!' : '❌ Scene Crashed',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.errorRed),
        ),
        content: Text(
          timedOut
              ? 'You ran out of time. Try again and work faster!'
              : 'One or more required scripts are missing or wrong.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetLevel();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _resetLevel() {
    setState(() {
      _placedIds.clear();
      _mistakeCount = 0;
      _hintsUsed    = 0;
      _showSuccess  = false;
      _isValidating = false;
      _termLog
        ..clear()
        ..addAll(widget.level.idleTerminal);
      _shuffledBank = [...widget.level.scriptBank]..shuffle(Random());
      if (widget.level.isBoss) {
        _secondsLeft = widget.level.timeLimit;
        _startTimer();
      }
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final allPlaced = widget.level.correctIds.every(_placedIds.contains);

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildObjectiveBanner(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT: 3D Viewport
                  Expanded(child: _buildViewport()),
                  // RIGHT: Inspector
                  _buildInspector(),
                ],
              ),
            ),
            _buildTerminal(),
            _buildBottomBar(allPlaced),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final zone = inspectorGameZones.firstWhere(
      (z) => z.id == widget.level.zoneId,
      orElse: () => inspectorGameZones.first,
    );
    final stars = _computeStars();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1929),
        border: Border(
          bottom: BorderSide(color: zone.accentColor.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 10),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.level.title,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w700, letterSpacing: .3)),
                Text(zone.name,
                  style: TextStyle(color: zone.accentColor, fontSize: 10)),
              ],
            ),
          ),
          // Stars
          Row(
            children: List.generate(3, (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < stars ? Colors.amber : Colors.white24,
              size: 16,
            )),
          ),
          // Timer (boss only)
          if (widget.level.isBoss) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _secondsLeft < 20
                    ? Colors.red.withValues(alpha: .15)
                    : Colors.white.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _secondsLeft < 20
                      ? Colors.red.withValues(alpha: .4)
                      : Colors.white12),
              ),
              child: Text(
                '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: _secondsLeft < 20 ? Colors.redAccent : Colors.white70,
                  fontSize: 12, fontFamily: 'monospace',
                  fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  // ── Objective Banner ──────────────────────────────────────────────────────
  Widget _buildObjectiveBanner() {
    final zone = inspectorGameZones.firstWhere(
      (z) => z.id == widget.level.zoneId,
      orElse: () => inspectorGameZones.first,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: zone.accentColor.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(color: zone.accentColor.withValues(alpha: .12)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.level.gameObjectIcon,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OBJECTIVE',
                  style: TextStyle(
                    color: zone.accentColor,
                    fontSize: 9, fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(widget.level.objective,
                  style: const TextStyle(
                    color: Colors.white70, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3D Viewport ───────────────────────────────────────────────────────────
  Widget _buildViewport() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1A),
        border: Border(right: BorderSide(color: Color(0xFF1A1A3E))),
      ),
      child: Column(
        children: [
          // Toolbar strip (mimics Unity)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: const Color(0xFF111828),
            child: Row(
              children: [
                _vpBtn('Scene'),
                const SizedBox(width: 4),
                _vpBtn('Game', active: false),
                const Spacer(),
                Text('Persp',
                  style: TextStyle(color: Colors.white.withValues(alpha: .3),
                    fontSize: 9)),
              ],
            ),
          ),
          // Scene area
          Expanded(
            child: Stack(
              children: [
                // Grid floor (perspective illusion)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: 120,
                  child: CustomPaint(painter: _GridFloorPainter()),
                ),
                // Horizon line
                Positioned(
                  bottom: 120, left: 0, right: 0,
                  child: Container(
                    height: 1,
                    color: Colors.blue.withValues(alpha: .15),
                  ),
                ),
                // Scene Objects
                ..._buildSceneObjects(),
                // Success overlay
                if (_showSuccess) _buildSuccessOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vpBtn(String label, {bool active = true}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: active
          ? const Color(0xFF0F3460)
          : const Color(0xFF1A2840),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(label,
      style: TextStyle(
        color: active ? const Color(0xFF00E5FF) : Colors.white38,
        fontSize: 9, fontWeight: FontWeight.w600)),
  );

  List<Widget> _buildSceneObjects() {
    const positions = <SceneObjectType, Offset>{
      SceneObjectType.camera:       Offset(0.12, 0.55),
      SceneObjectType.xrRig:        Offset(0.45, 0.45),
      SceneObjectType.handLeft:     Offset(0.28, 0.62),
      SceneObjectType.handRight:    Offset(0.58, 0.62),
      SceneObjectType.cube:         Offset(0.62, 0.35),
      SceneObjectType.plane:        Offset(0.40, 0.72),
      SceneObjectType.lightProbe:   Offset(0.20, 0.30),
      SceneObjectType.avatar:       Offset(0.55, 0.38),
      SceneObjectType.portal:       Offset(0.75, 0.45),
      SceneObjectType.spatialAnchor:Offset(0.50, 0.58),
    };
    const icons = <SceneObjectType, String>{
      SceneObjectType.camera:        '📷',
      SceneObjectType.xrRig:         '🥽',
      SceneObjectType.handLeft:      '🤚',
      SceneObjectType.handRight:     '🖐',
      SceneObjectType.cube:          '📦',
      SceneObjectType.plane:         '▭',
      SceneObjectType.lightProbe:    '💡',
      SceneObjectType.avatar:        '🧍',
      SceneObjectType.portal:        '🌀',
      SceneObjectType.spatialAnchor: '📌',
    };
    const labels = <SceneObjectType, String>{
      SceneObjectType.camera:        'Camera',
      SceneObjectType.xrRig:         'XR Rig',
      SceneObjectType.handLeft:      'Left Hand',
      SceneObjectType.handRight:     'Right Hand',
      SceneObjectType.cube:          'Object',
      SceneObjectType.plane:         'AR Plane',
      SceneObjectType.lightProbe:    'Light Probe',
      SceneObjectType.avatar:        'Avatar',
      SceneObjectType.portal:        'Portal',
      SceneObjectType.spatialAnchor: 'Anchor',
    };

    return widget.level.sceneObjects.map((obj) {
      final ctrl = _sceneControllers[obj];
      final pos  = positions[obj] ?? const Offset(0.5, 0.5);

      // Is this object "activated" (has a chip been placed that activates it)?
      final activated = widget.level.scriptBank
          .where((c) => _placedIds.contains(c.id))
          .any((c) => c.activates.contains(obj));

      return Positioned.fill(
        child: LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Positioned(
            left: w * pos.dx - 22,
            top:  h * pos.dy - 30,
            child: FadeTransition(
              opacity: ctrl ?? const AlwaysStoppedAnimation(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: activated
                          ? Colors.white.withValues(alpha: .08)
                          : Colors.white.withValues(alpha: .03),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: activated
                            ? const Color(0xFF00E5FF).withValues(alpha: .5)
                            : Colors.white.withValues(alpha: .08)),
                      boxShadow: activated
                          ? [BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: .25),
                              blurRadius: 12)]
                          : null,
                    ),
                    child: Center(
                      child: Text(icons[obj] ?? '?',
                        style: TextStyle(
                          fontSize: 16,
                          color: activated ? null : Colors.white24.withValues(alpha: .4)))),
                  ),
                  const SizedBox(height: 3),
                  Text(labels[obj] ?? '',
                    style: TextStyle(
                      color: activated ? Colors.white54 : Colors.white24,
                      fontSize: 8)),
                ],
              ),
            ),
          );
        }),
      );
    }).toList();
  }

  Widget _buildSuccessOverlay() {
    final stars = _computeStars();
    final xp    = _computeXP(stars);
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .6),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: .4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 32))
                .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 6),
            const Text('IT WORKS!',
              style: TextStyle(
                color: Color(0xFF00E5FF), fontSize: 15,
                fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars ? Colors.amber : Colors.white24,
                size: 20)),
            ),
            const SizedBox(height: 4),
            Text('+$xp XP',
              style: const TextStyle(
                color: Colors.amber, fontSize: 12,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Next Level →',
                  style: TextStyle(
                    color: Color(0xFF0A1628), fontSize: 11,
                    fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  // ── Inspector Panel ────────────────────────────────────────────────────────
  Widget _buildInspector() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        border: Border(left: BorderSide(color: Color(0xFF1A2A4A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: const Color(0xFF0F1929),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inspector',
                  style: TextStyle(
                    color: Colors.white54, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: .8)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(widget.level.gameObjectIcon,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(widget.level.gameObjectName,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              controller: _inspScroll,
              child: Column(
                children: [
                  // Existing (locked) components
                  ...widget.level.existingComponents.map(_buildLockedComponent),
                  // Placed scripts
                  ...widget.level.scriptBank
                      .where((c) => c.isCorrect && _placedIds.contains(c.id))
                      .map(_buildPlacedComponent),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
          // Script bank
          _buildScriptBank(),
        ],
      ),
    );
  }

  Widget _buildLockedComponent(ExistingComponent comp) {
    return _ComponentTile(
      name: comp.name,
      icon: comp.icon,
      accentColor: comp.accentColor,
      fields: comp.fields,
      locked: true,
    );
  }

  Widget _buildPlacedComponent(ScriptChip chip) {
    final comp = ExistingComponent(
      name: chip.label,
      icon: '⚙',
      accentColor: chip.dotColor,
      fields: chip.addFields,
    );
    return _ComponentTile(
      name: comp.name,
      icon: comp.icon,
      accentColor: comp.accentColor,
      fields: comp.fields,
      locked: false,
    ).animate().fadeIn(duration: 300.ms).slideY(begin: .1, end: 0);
  }

  Widget _buildScriptBank() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1929),
        border: Border(top: BorderSide(color: Color(0xFF1A2A4A))),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Script',
            style: TextStyle(
              color: Colors.white24, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: .5)),
          const SizedBox(height: 5),
          // Chips in a wrap
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _shuffledBank.map((chip) {
              final placed  = _placedIds.contains(chip.id);
              return _ScriptBankChip(
                chip: chip,
                placed: placed,
                onTap: placed ? null : () => _placeScript(chip),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Terminal ──────────────────────────────────────────────────────────────
  Widget _buildTerminal() {
    // Show last 6 lines
    final visible = _termLog.length > 6
        ? _termLog.sublist(_termLog.length - 6)
        : _termLog;

    return Container(
      height: 90,
      color: const Color(0xFF0A0F1A),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              const Text('Console',
                style: TextStyle(
                  color: Colors.white24, fontSize: 9,
                  letterSpacing: .5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: visible.map((line) => Text(
                line.message,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 9.5,
                  color: _termColor(line.type),
                  height: 1.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _termColor(TerminalLineType t) {
    switch (t) {
      case TerminalLineType.success: return const Color(0xFF00C853);
      case TerminalLineType.info:    return const Color(0xFF00E5FF);
      case TerminalLineType.warning: return const Color(0xFFFFC107);
      case TerminalLineType.error:   return const Color(0xFFEF5350);
      case TerminalLineType.dim:     return Colors.white24;
    }
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool allPlaced) {
    final total   = widget.level.correctIds.length;
    final placed  = _placedIds
        .where(widget.level.correctIds.contains)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF0F1929),
      child: Row(
        children: [
          // Progress pips
          Expanded(
            child: Wrap(
              spacing: 5,
              children: List.generate(total, (i) => Container(
                width: 20, height: 4,
                decoration: BoxDecoration(
                  color: i < placed
                      ? const Color(0xFF00E5FF)
                      : Colors.white12,
                  borderRadius: BorderRadius.circular(2)),
              )),
            ),
          ),
          // Hint
          GestureDetector(
            onTap: _showHint,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12)),
              child: const Text('Hint 💡',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
            ),
          ),
          const SizedBox(width: 8),
          // Run Scene button
          GestureDetector(
            onTap: allPlaced ? _validate : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: allPlaced
                    ? const Color(0xFF00E5FF)
                    : Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Run Scene ▶',
                style: TextStyle(
                  color: allPlaced
                      ? const Color(0xFF0A1628)
                      : Colors.white24,
                  fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: .5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

/// A collapsible component row in the Inspector
class _ComponentTile extends StatefulWidget {
  final String name;
  final String icon;
  final Color accentColor;
  final List<InspectorField> fields;
  final bool locked;

  const _ComponentTile({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.fields,
    required this.locked,
  });

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 3, 6, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2840),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.locked
              ? const Color(0xFF1E3255)
              : widget.accentColor.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _expanded ? .25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white24, size: 13),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(2)),
                    child: Center(
                      child: Text(widget.icon,
                        style: const TextStyle(fontSize: 8))),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(widget.name,
                      style: const TextStyle(
                        color: Color(0xFFC0D8F0), fontSize: 10,
                        fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
                  if (!widget.locked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: const Color(0xFF00C853).withValues(alpha: .3)),
                      ),
                      child: const Text('● on',
                        style: TextStyle(
                          color: Color(0xFF00C853), fontSize: 8,
                          fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
          if (_expanded && widget.fields.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E3255))),
              ),
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Column(
                children: widget.fields.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(f.label,
                          style: const TextStyle(
                            color: Colors.white38, fontSize: 9))),
                      Text(f.value,
                        style: const TextStyle(
                          color: Color(0xFF9ABCF0), fontSize: 9,
                          fontFamily: 'Courier New')),
                    ],
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// A draggable / tappable chip in the script bank
class _ScriptBankChip extends StatefulWidget {
  final ScriptChip chip;
  final bool placed;
  final VoidCallback? onTap;
  const _ScriptBankChip({
    required this.chip,
    required this.placed,
    this.onTap,
  });

  @override
  State<_ScriptBankChip> createState() => _ScriptBankChipState();
}

class _ScriptBankChipState extends State<_ScriptBankChip> {
  bool _shaking = false;

  void _handleWrong() async {
    setState(() => _shaking = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _shaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWrong = !widget.chip.isCorrect;
    final dim     = widget.placed || (widget.chip.isCorrect && widget.placed);

    return GestureDetector(
      onTap: () {
        if (dim) return;
        if (isWrong) _handleWrong();
        widget.onTap?.call();
      },
      child: AnimatedOpacity(
        opacity: dim ? .25 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _shaking
              ? (Matrix4.identity()..translate(4.0, 0.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1929),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _shaking
                  ? Colors.red.withValues(alpha: .6)
                  : Colors.white.withValues(alpha: .08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: widget.chip.dotColor,
                  shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(widget.chip.label,
                  style: const TextStyle(
                    color: Color(0xFF80A0C0), fontSize: 9,
                    fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Grid Floor Painter (perspective-illusion floor grid)
// ═══════════════════════════════════════════════════════════════════════════
class _GridFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0050A0).withValues(alpha: .12)
      ..strokeWidth = .5;

    const cols = 8;
    const rows = 5;

    for (int i = 0; i <= cols; i++) {
      final x = size.width * i / cols;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width * .5 + (x - size.width * .5) * .1, size.height),
        paint);
    }
    for (int j = 0; j <= rows; j++) {
      final y = size.height * j / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
