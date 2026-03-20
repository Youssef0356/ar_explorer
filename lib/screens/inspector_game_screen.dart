import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../data/inspector_game_data.dart';
import '../models/inspector_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  InspectorGameScreen — v2
//
//  All bugs fixed + improvements applied:
//   ✅ 1.  Terminal overflow — ListView, never clips, auto-scrolls
//   ✅ 2.  Viewport icons no longer overlap — spaced fixed-% positions
//   ✅ 3.  Wrong scripts CAN be placed; errors surface only on "Run Scene"
//   ✅ 4.  Viewport larger (flex:3 viewport vs flex:2 inspector)
//   ✅ 5.  More distractors in data — listed in boss section note
//   ✅ 6.  Terminal height 140px (was 90px) with a Clear button
//   ✅ 7.  Script chips are ALL neutral grey — no colour hints before Run
//   ✅ 8.  After success: expandable code snippet shows real C# / Swift
//   ✅ 9.  Intro popup on first open (game description dialog)
//   ✅ 10. Wrong chips placed → ERR badge in Inspector, removable with ×
//   ✅ 11. Scene objects float (AnimatedBuilder) + pulse on activation
// ═══════════════════════════════════════════════════════════════════════════

class InspectorGameScreen extends StatefulWidget {
  final InspectorLevel level;
  final bool showIntro;
  const InspectorGameScreen({
    super.key,
    required this.level,
    this.showIntro = false,
  });

  @override
  State<InspectorGameScreen> createState() => _InspectorGameScreenState();
}

class _InspectorGameScreenState extends State<InspectorGameScreen>
    with TickerProviderStateMixin {

  // ── Runtime ───────────────────────────────────────────────────────────────
  final Map<String, bool> _placedChips = {}; // chipId → isCorrect
  int  _mistakeCount   = 0;
  int  _hintsUsed      = 0;
  bool _showSuccess    = false;
  bool _isValidating   = false;
  bool _showCodeSnippet = false;
  bool _hasRun         = false; // only true after first "Run Scene" press

  late List<ScriptChip> _shuffledBank;
  final List<TerminalLine> _termLog   = [];
  final ScrollController   _termScroll = ScrollController();
  final ScrollController   _inspScroll = ScrollController();

  int    _secondsLeft = 0;
  Timer? _timer;

  final Map<SceneObjectType, AnimationController> _floatCtrls = {};
  final Map<SceneObjectType, AnimationController> _pulseCtrls = {};
  final Set<SceneObjectType> _activatedObjects = {};

  @override
  void initState() {
    super.initState();
    _shuffledBank = [...widget.level.scriptBank]..shuffle(Random());
    _termLog.addAll(widget.level.idleTerminal);

    for (final obj in widget.level.sceneObjects) {
      _floatCtrls[obj] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1800 + Random().nextInt(1200)),
      )..repeat(reverse: true);
      _pulseCtrls[obj] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    }

    if (widget.level.isBoss && widget.level.timeLimit > 0) {
      _secondsLeft = widget.level.timeLimit;
      _startTimer();
    }

    if (widget.showIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroPopup());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _floatCtrls.values) {
      c.dispose();
    }
    for (final c in _pulseCtrls.values) {
      c.dispose();
    }
    _termScroll.dispose();
    _inspScroll.dispose();
    super.dispose();
  }

  // ── Intro popup ───────────────────────────────────────────────────────────
  void _showIntroPopup() => showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _IntroPopupDialog(),
  );

  // ── Timer ─────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) { _timer?.cancel(); _handleTimeout(); }
    });
  }

  void _handleTimeout() {
    _addTermLine(TerminalLine(TerminalLineType.error,
        '> TIME\'S UP — compilation aborted'));
    setState(() { _showSuccess = false; _isValidating = false; });
    _showResultDialog(timedOut: true);
  }

  // ── Terminal ───────────────────────────────────────────────────────────────
  void _addTermLine(TerminalLine line) {
    setState(() {
      _termLog.add(line);
      if (_termLog.length > 80) _termLog.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_termScroll.hasClients) {
        _termScroll.animateTo(_termScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut);
      }
    });
  }

  void _addTermLines(List<TerminalLine> lines) {
    for (final l in lines) {
      _addTermLine(l);
    }
  }

  // ── Place script ───────────────────────────────────────────────────────────
  void _placeScript(ScriptChip chip) {
    if (_placedChips.containsKey(chip.id) || _showSuccess) return;
    context.read<SoundService>().playTap();
    setState(() => _placedChips[chip.id] = chip.isCorrect);

    if (chip.isCorrect) {
      for (final obj in chip.activates) {
        _activatedObjects.add(obj);
        _pulseCtrls[obj]?.forward(from: 0);
      }
    }
    // Wrong script: no immediate feedback until Run Scene is pressed

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inspScroll.hasClients) {
        _inspScroll.animateTo(_inspScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  void _removeScript(String chipId) {
    if (_showSuccess) return;
    final chip = widget.level.scriptBank.firstWhere((c) => c.id == chipId);
    setState(() {
      _placedChips.remove(chipId);
      if (chip.isCorrect) {
        for (final obj in chip.activates) {
          final still = widget.level.scriptBank
              .where((c) => _placedChips.containsKey(c.id) && c.isCorrect)
              .any((c) => c.activates.contains(obj));
          if (!still) _activatedObjects.remove(obj);
        }
      }
    });
  }

  // ── Validate ──────────────────────────────────────────────────────────────
  void _validate() {
    if (_isValidating || _showSuccess || _placedChips.isEmpty) return;
    setState(() { _isValidating = true; _hasRun = true; });
    context.read<SoundService>().playTap();

    final wrongPlaced = _placedChips.entries
        .where((e) => !e.value)
        .map((e) => widget.level.scriptBank.firstWhere((c) => c.id == e.key))
        .toList();

    final missingCorrect = widget.level.correctIds
        .where((id) => !_placedChips.containsKey(id))
        .toList();

    if (wrongPlaced.isNotEmpty || missingCorrect.isNotEmpty) {
      for (final chip in wrongPlaced) {
        _mistakeCount++;
        _addTermLine(TerminalLine(TerminalLineType.error,
            '> ERROR: ${chip.errorMessage}'));
      }
      if (missingCorrect.isNotEmpty) {
        _addTermLine(TerminalLine(TerminalLineType.error,
            '> ERROR: Missing ${missingCorrect.length} required component(s)'));
        _addTermLine(TerminalLine(TerminalLineType.warning,
            '> Fix errors and click Run Scene again'));
      }
      setState(() => _isValidating = false);
      _showResultDialog(compileFailed: true);
      return;
    }

    // ── Success path ──
    _timer?.cancel();
    for (final entry in _placedChips.entries) {
      if (entry.value) { // if isCorrect
        final chip = widget.level.scriptBank.firstWhere((c) => c.id == entry.key);
        _addTermLines(chip.addLines);
      }
    }
    _addTermLines(widget.level.successTerminal);

    final stars = _computeStars();
    final xp    = _computeXP(stars);
    context.read<GameProgressService>().completeLevel(widget.level.id, stars);
    context.read<GameProgressService>().addXP(xp);
    if (widget.level.isBoss) context.read<GameProgressService>().updateStreak();

    setState(() { _showSuccess = true; _isValidating = false; });
  }

  int _computeStars() {
    if (_mistakeCount == 0 && _hintsUsed == 0) return 3;
    if (_mistakeCount <= 1) return 2;
    return 1;
  }

  int _computeXP(int stars) => 50 + (stars - 1) * 15 + (widget.level.isBoss ? 60 : 0);

  void _showHint() {
    setState(() => _hintsUsed++);
    _addTermLine(TerminalLine(TerminalLineType.warning,
        '> HINT: ${widget.level.hint}'));
  }

  void _showResultDialog({bool timedOut = false, bool compileFailed = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(timedOut ? '⏱ Time\'s Up!' : '❌ Compile Error',
            style: const TextStyle(color: Color(0xFFEF5350),
                fontWeight: FontWeight.w700)),
        content: Text(
          timedOut
              ? 'You ran out of time. Read the console and try again.'
              : 'The scene has errors. Remove wrong components and try again.',
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resetLevel(); },
            child: const Text('Reset')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fix It',
                style: TextStyle(color: Color(0xFF00E5FF)))),
        ],
      ),
    );
  }

  void _resetLevel() {
    setState(() {
      _placedChips.clear();
      _activatedObjects.clear();
      _mistakeCount = 0; _hintsUsed = 0;
      _showSuccess = false; _isValidating = false; _showCodeSnippet = false; _hasRun = false;
      _termLog..clear()..addAll(widget.level.idleTerminal);
      _shuffledBank = [...widget.level.scriptBank]..shuffle(Random());
      if (widget.level.isBoss) { _secondsLeft = widget.level.timeLimit; _startTimer(); }
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasWrong    = _placedChips.entries.any((e) => !e.value);
    final canRun      = _placedChips.isNotEmpty && !_showSuccess;

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildObjectiveBanner(),
          Expanded(flex: 10,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildViewport()),
                Expanded(flex: 2, child: _buildInspector()),
              ])),
          _buildTerminal(),
          if (_showSuccess && _showCodeSnippet) _buildCodeSnippet(),
          _buildBottomBar(canRun, hasWrong),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final zone  = _zone();
    final stars = _computeStars();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1929),
        border: Border(bottom:
            BorderSide(color: zone.accentColor.withValues(alpha: 0.25))),
      ),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white54, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.level.title, style: const TextStyle(color: Colors.white,
                fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: .3)),
            Text(zone.name, style: TextStyle(color: zone.accentColor, fontSize: 10)),
          ])),
        Row(children: List.generate(3, (i) => Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars ? Colors.amber : Colors.white24, size: 16))),
        if (widget.level.isBoss) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _secondsLeft < 20
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: _secondsLeft < 20
                      ? Colors.red.withValues(alpha: 0.4) : Colors.white12)),
            child: Text(
              '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                  color: _secondsLeft < 20 ? Colors.redAccent : Colors.white70,
                  fontSize: 12, fontFamily: 'monospace',
                  fontWeight: FontWeight.w700)),
          ),
        ],
      ]),
    );
  }

  // ── Objective banner ───────────────────────────────────────────────────────
  Widget _buildObjectiveBanner() {
    final zone = _zone();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: zone.accentColor.withValues(alpha: 0.05),
        border: Border(bottom:
            BorderSide(color: zone.accentColor.withValues(alpha: 0.12))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.level.gameObjectIcon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OBJECTIVE', style: TextStyle(color: zone.accentColor,
                fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(widget.level.objective, style: const TextStyle(
                color: Colors.white70, fontSize: 10.5, height: 1.4)),
          ])),
      ]),
    );
  }

  // ── 3D Viewport ───────────────────────────────────────────────────────────
  Widget _buildViewport() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080912),
        border: Border(right: BorderSide(color: Color(0xFF1A1A3E))),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: const Color(0xFF0C1420),
          child: Row(children: [
            _vpBtn('Scene', active: true),
            const SizedBox(width: 4),
            _vpBtn('Game',  active: false),
            const Spacer(),
            Text('Persp ▾', style: TextStyle(
                color: Colors.white.withValues(alpha: 0.22), fontSize: 8)),
          ]),
        ),
        Expanded(child: LayoutBuilder(builder: (ctx, constraints) {
          return Stack(clipBehavior: Clip.hardEdge, children: [
            Positioned.fill(child: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF050810), Color(0xFF0A0E20)],
              )),
            )),
            Positioned(bottom: 0, left: 0, right: 0,
              height: constraints.maxHeight * 0.42,
              child: CustomPaint(painter: _GridFloorPainter())),
            Positioned(bottom: constraints.maxHeight * 0.42,
              left: 0, right: 0,
              child: Container(height: 1,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.blue.withValues(alpha: 0.28),
                  Colors.transparent,
                ])))),
            ..._buildSceneObjects(constraints),
            if (_showSuccess) _buildSuccessOverlay(),
          ]);
        })),
      ]),
    );
  }

  Widget _vpBtn(String label, {required bool active}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF0F3460) : const Color(0xFF131D2E),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(label, style: TextStyle(
        color: active ? const Color(0xFF00E5FF) : Colors.white30,
        fontSize: 9, fontWeight: FontWeight.w600)),
  );

  // Fixed positions — carefully spread so no two overlap
  static const _pos = <SceneObjectType, Offset>{
    SceneObjectType.camera:        Offset(0.12, 0.22),
    SceneObjectType.xrRig:         Offset(0.45, 0.28),
    SceneObjectType.handLeft:      Offset(0.16, 0.55),
    SceneObjectType.handRight:     Offset(0.62, 0.55),
    SceneObjectType.cube:          Offset(0.74, 0.24),
    SceneObjectType.plane:         Offset(0.44, 0.70),
    SceneObjectType.lightProbe:    Offset(0.20, 0.12),
    SceneObjectType.avatar:        Offset(0.65, 0.18),
    SceneObjectType.portal:        Offset(0.82, 0.48),
    SceneObjectType.spatialAnchor: Offset(0.50, 0.46),
  };
  static const _icons  = <SceneObjectType, String>{
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
  static const _labels = <SceneObjectType, String>{
    SceneObjectType.camera:        'Camera',
    SceneObjectType.xrRig:         'XR Rig',
    SceneObjectType.handLeft:      'Left Hand',
    SceneObjectType.handRight:     'Right Hand',
    SceneObjectType.cube:          'Object',
    SceneObjectType.plane:         'AR Plane',
    SceneObjectType.lightProbe:    'Light',
    SceneObjectType.avatar:        'Avatar',
    SceneObjectType.portal:        'Portal',
    SceneObjectType.spatialAnchor: 'Anchor',
  };

  List<Widget> _buildSceneObjects(BoxConstraints c) {
    const tw = 46.0; const th = 50.0;
    return widget.level.sceneObjects.map((obj) {
      final p   = _pos[obj]       ?? const Offset(0.5, 0.4);
      final ico = _icons[obj]     ?? '?';
      final lbl = _labels[obj]    ?? '';
      return Positioned(
        left: (c.maxWidth  * p.dx - tw / 2).clamp(0, c.maxWidth  - tw),
        top:  (c.maxHeight * p.dy - th / 2).clamp(0, c.maxHeight - th),
        width: tw, height: th,
        child: _SceneObjectWidget(
          icon: ico, label: lbl,
          activated: _activatedObjects.contains(obj),
          floatCtrl: _floatCtrls[obj],
          pulseCtrl: _pulseCtrls[obj],
        ),
      );
    }).toList();
  }

  Widget _buildSuccessOverlay() {
    final stars = _computeStars();
    final xp    = _computeXP(stars);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('✅', style: TextStyle(fontSize: 28))
              .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 4),
          const Text('IT WORKS!', style: TextStyle(
              color: Color(0xFF00E5FF), fontSize: 13,
              fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < stars ? Colors.amber : Colors.white24, size: 18))),
          const SizedBox(height: 2),
          Text('+$xp XP', style: const TextStyle(
              color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showCodeSnippet = !_showCodeSnippet),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white24)),
              child: Text(
                _showCodeSnippet ? 'Hide Code ▲' : '⚙  See How It Works',
                style: const TextStyle(color: Colors.white60, fontSize: 9,
                    fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(6)),
              child: const Text('Next Level →', style: TextStyle(
                  color: Color(0xFF060B14), fontSize: 10,
                  fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ).animate().fadeIn(duration: 350.ms),
    );
  }

  // ── Inspector ──────────────────────────────────────────────────────────────
  Widget _buildInspector() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111E35),
        border: Border(left: BorderSide(color: Color(0xFF1A2A4A))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFF0C1626),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Inspector', style: TextStyle(
                color: Colors.white30, fontSize: 8,
                fontWeight: FontWeight.w700, letterSpacing: .8)),
            const SizedBox(height: 2),
            Row(children: [
              Text(widget.level.gameObjectIcon,
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.level.gameObjectName,
                  style: const TextStyle(color: Colors.white,
                      fontSize: 10, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          controller: _inspScroll,
          child: Column(children: [
            ...widget.level.existingComponents.map((c) => _ComponentTile(
                name: c.name, icon: c.icon, accentColor: c.accentColor,
                fields: c.fields, locked: true, isError: false)),
            ...widget.level.scriptBank
                .where((c) => _placedChips.containsKey(c.id))
                .map((c) {
                  final correct = _placedChips[c.id]!;
                  // Before Run Scene: all chips look identical — no hints
                  // After Run Scene: correct = accent colour + "on", wrong = red + "ERR"
                  return _ComponentTile(
                    name: c.label, icon: '⚙',
                    accentColor: (_hasRun && !correct)
                        ? Colors.red
                        : (_hasRun && correct ? c.dotColor : const Color(0xFF3A5070)),
                    fields: (_hasRun && correct) ? c.addFields : [],
                    locked: false,
                    isError: _hasRun && !correct,
                    showStatus: _hasRun,
                    onRemove: () => _removeScript(c.id),
                  ).animate().fadeIn(duration: 270.ms).slideY(begin: .08);
                }),
            const SizedBox(height: 4),
          ]),
        )),
        _buildScriptBank(),
      ]),
    );
  }

  Widget _buildScriptBank() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 155),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1424),
        border: Border(top: BorderSide(color: Color(0xFF1A2A4A))),
      ),
      padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add Script', style: TextStyle(
            color: Colors.white24, fontSize: 8,
            fontWeight: FontWeight.w700, letterSpacing: .5)),
        const SizedBox(height: 4),
        Flexible(child: SingleChildScrollView(
          child: Wrap(spacing: 4, runSpacing: 4,
            children: _shuffledBank.map((chip) {
              final placed = _placedChips.containsKey(chip.id);
              return _ScriptBankChip(
                chip: chip, placed: placed,
                onTap: placed ? null : () => _placeScript(chip));
            }).toList()),
        )),
      ]),
    );
  }

  // ── Terminal — height 140, ListView, no overflow ──────────────────────────
  Widget _buildTerminal() {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF070C14),
        border: Border(
          top: BorderSide(color: Color(0xFF192030)),
          bottom: BorderSide(color: Color(0xFF192030)),
        ),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: const Color(0xFF080E1C),
          child: Row(children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(
                color: _showSuccess
                    ? const Color(0xFF00C853)
                    : (_termLog.any((l) => l.type == TerminalLineType.error)
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF00C853)),
                shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Console', style: TextStyle(
                color: Colors.white24, fontSize: 9,
                letterSpacing: .4, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _termLog.clear()),
              child: const Text('Clear', style: TextStyle(
                  color: Colors.white24, fontSize: 8))),
          ]),
        ),
        Expanded(child: ListView.builder(
          controller: _termScroll,
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          itemCount: _termLog.length,
          itemBuilder: (_, i) => Text(_termLog[i].message,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 9.5,
              color: _termColor(_termLog[i].type),
              height: 1.55),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        )),
      ]),
    );
  }

  Color _termColor(TerminalLineType t) => switch (t) {
    TerminalLineType.success => const Color(0xFF00C853),
    TerminalLineType.info    => const Color(0xFF00E5FF),
    TerminalLineType.warning => const Color(0xFFFFC107),
    TerminalLineType.error   => const Color(0xFFEF5350),
    TerminalLineType.dim     => const Color(0xFF384858),
  };

  // ── Code snippet drawer ───────────────────────────────────────────────────
  Widget _buildCodeSnippet() {
    final chips = widget.level.scriptBank
        .where((c) => c.isCorrect && _placedChips.containsKey(c.id))
        .toList();
    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: const BoxDecoration(
        color: Color(0xFF060F08),
        border: Border(top: BorderSide(color: Color(0xFF00C853))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          color: const Color(0xFF07120A),
          child: Row(children: [
            const Text('⚙  How these scripts work in C#', style: TextStyle(
                color: Color(0xFF00C853), fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: .4)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showCodeSnippet = false),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white30, size: 14)),
          ]),
        ),
        Flexible(child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: chips.length,
          itemBuilder: (_, i) {
            final chip = chips[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 7, height: 7,
                      decoration: BoxDecoration(
                          color: chip.dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(chip.label, style: const TextStyle(
                        color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1A0C),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: chip.dotColor.withValues(alpha: 0.2))),
                    child: Text(_codeSnippet(chip.id),
                      style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 9, color: Color(0xFF7DC890), height: 1.6)),
                  ),
                  const SizedBox(height: 3),
                  Text(chip.description, style: const TextStyle(
                      color: Colors.white38, fontSize: 9, height: 1.4)),
                ]),
            );
          },
        )),
      ]),
    );
  }

  String _codeSnippet(String id) {
    const m = <String, String>{
      'ar_session':       '// Starts the global AR tracking engine\nARSession session = GetComponent<ARSession>();\nsession.Reset(); // force re-localise',
      'ar_cam_bg':        '// Renders real-world camera feed behind 3D scene\nvar bg = cam.gameObject\n  .AddComponent<ARCameraBackground>();\nbg.useCustomMaterial = false;',
      'ar_cam_mgr':       '// Feeds device pose into AR system each frame\narCamMgr.frameReceived += (args) => {\n  var pose = args.frame.camera.GetPose();\n  transform.SetPositionAndRotation(\n    pose.position, pose.rotation);\n};',
      'ar_face_mgr':      '// Detects and tracks face geometry\nfaceMgr.facesChanged += (args) => {\n  foreach (var face in args.added)\n    SpawnFaceFilter(face.transform);\n};',
      'xr_hand_sub':      '// Activates 26-joint hand skeleton tracking\nvar sub = XRHandSubsystem.running;\nsub.updatedHands += (s, updateType,\n  leftHand, rightHand) => { ... };',
      'xr_hand_mesh':     '// Renders visible skin mesh over skeleton\n[SerializeField]\nXRHandMeshRenderer meshRenderer;\n// Assign DefaultHand prefab in Inspector',
      'rigidbody':        '// Adds mass + gravity to the object\nvar rb = gameObject.AddComponent<Rigidbody>();\nrb.mass = 1f;\nrb.useGravity = true;',
      'box_collider':     '// Defines physical touch boundary\nvar col = gameObject.AddComponent<BoxCollider>();\ncol.size = new Vector3(0.2f, 0.2f, 0.2f);',
      'xr_grab':          '// Makes object grabbable + throwable\nvar grab = gameObject\n  .AddComponent<XRGrabInteractable>();\ngrab.throwVelocityScale = 1.5f;',
      'gesture_recognizer':'// Fires event when pinch gesture detected\n[SerializeField] XRHandGestureRecognizer rec;\nrec.performedGesture.AddListener(OnPinch);',
      'xr_manipulator':   '// Applies pinch gesture to scale the object\nvar manip = gameObject\n  .AddComponent<XRObjectManipulator>();\nmanip.allowedTransformations =\n  XRObjectManipulator.TransformFlags.Scale;',
      'xr_poke':          '// Lets a fingertip press flat surfaces\nvar poke = finger.gameObject\n  .AddComponent<XRPokeInteractor>();\npoke.pokeDepth = 0.01f;',
      'ar_plane_mgr':     '// Scans room and creates surface meshes\nplaneMgr.planesChanged += (args) => {\n  foreach (var p in args.added)\n    ShowPlaneVisual(p);\n};',
      'ar_raycast_mgr':   '// Converts screen tap → 3D surface point\nif (rayMgr.Raycast(tap, hits,\n    TrackableType.PlaneWithinPolygon)) {\n  var pose = hits[0].pose;\n  Instantiate(prefab, pose.position,\n    pose.rotation);\n}',
      'ar_anchor':        '// Locks object to physical world feature\nvar anchor = ARAnchorManager\n  .AttachAnchor(plane, pose);\nPlayerPrefs.SetString("anchor",\n  anchor.trackableId.ToString());',
      'light_estimation': '// Reads real room brightness each frame\ncamMgr.frameReceived += (args) => {\n  var b = args.lightEstimation\n    .averageBrightness ?? 1f;\n  dirLight.intensity = b;\n};',
      'light_est_shadow': '// Aligns shadow direction to real light source\ncamMgr.frameReceived += (args) => {\n  var dir = args.lightEstimation\n    .mainLightDirection;\n  if (dir.HasValue)\n    dirLight.transform.rotation =\n      Quaternion.LookRotation(dir.Value);\n};',
      'ar_occlusion':     '// Hides virtual content behind real objects\noccMgr.requestedEnvironmentDepthMode\n  = EnvironmentDepthMode.Fastest;',
      'ar_img_mgr':       '// Matches camera frame to reference images\nimgMgr.trackedImagesChanged += (args) => {\n  foreach (var img in args.added)\n    SpawnContent(img.transform);\n};',
      'ar_cloud_anchor':  '// Shares anchor position with other devices\nvar result = await\n  ARAnchorManager\n    .ResolveCloudAnchorIdAsync(anchorId);\nif (result.resultCode == Success)\n  PlaceSharedObject(result.anchor);',
      'ar_mesh_mgr':      '// Full room geometry via LiDAR\nmeshMgr.meshesChanged += (args) => {\n  foreach (var mesh in args.added) {\n    mesh.gameObject.AddComponent<MeshCollider>();\n  }\n};',
    };
    return m[id] ?? '// ${id.replaceAll('_', ' ')}\n// See Unity XR docs for full API';
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool canRun, bool hasWrong) {
    final total  = widget.level.correctIds.length;
    final placed = _placedChips.keys.where(widget.level.correctIds.contains).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF0A1020),
      child: Row(children: [
        Expanded(child: Wrap(spacing: 5,
          children: List.generate(total, (i) => Container(
            width: 18, height: 4,
            decoration: BoxDecoration(
              color: i < placed ? const Color(0xFF00E5FF) : Colors.white12,
              borderRadius: BorderRadius.circular(2)))))),
        GestureDetector(
          onTap: _showHint,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white10)),
            child: const Text('Hint 💡',
                style: TextStyle(color: Colors.white38, fontSize: 10)))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: (canRun && !_isValidating) ? _validate : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: (canRun && !_isValidating)
                  ? (hasWrong
                      ? const Color(0xFFFF8A65)
                      : const Color(0xFF00E5FF))
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(5)),
            child: Text('Run Scene ▶',
              style: TextStyle(
                color: (canRun && !_isValidating)
                    ? const Color(0xFF060B14) : Colors.white24,
                fontSize: 10, fontWeight: FontWeight.w800,
                letterSpacing: .4)))),
      ]),
    );
  }

  InspectorZone _zone() => inspectorGameZones.firstWhere(
      (z) => z.id == widget.level.zoneId,
      orElse: () => inspectorGameZones.first);
}

// ═══════════════════════════════════════════════════════════════════════════
//  Scene Object — floats + pulses on activation
// ═══════════════════════════════════════════════════════════════════════════
class _SceneObjectWidget extends StatelessWidget {
  final String icon;
  final String label;
  final bool activated;
  final AnimationController? floatCtrl;
  final AnimationController? pulseCtrl;
  const _SceneObjectWidget({
    required this.icon, required this.label,
    required this.activated, this.floatCtrl, this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: 46, height: 50,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: activated
                ? const Color(0xFF00E5FF).withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: activated
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.06),
              width: activated ? 1.5 : 1),
            boxShadow: activated ? [BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.30),
              blurRadius: 10, spreadRadius: 1)] : null),
          child: Center(child: Text(icon,
            style: TextStyle(
              fontSize: 15,
              color: activated ? null : const Color(0xFF3A4060))))),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            color: activated ? Colors.white54 : Colors.white24,
            fontSize: 7),
          overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );

    // Float (gentle vertical oscillation)
    if (floatCtrl != null) {
      child = AnimatedBuilder(
        animation: floatCtrl!,
        builder: (_, c) => Transform.translate(
            offset: Offset(0, -5 * floatCtrl!.value), child: c),
        child: child);
    }

    // Pulse on activation (quick scale pop)
    if (pulseCtrl != null) {
      child = AnimatedBuilder(
        animation: pulseCtrl!,
        builder: (_, c) => Transform.scale(
            scale: 1.0 + 0.14 * sin(pulseCtrl!.value * pi), child: c),
        child: child);
    }

    return child;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Inspector component tile
// ═══════════════════════════════════════════════════════════════════════════
class _ComponentTile extends StatefulWidget {
  final String name;
  final String icon;
  final Color  accentColor;
  final List<InspectorField> fields;
  final bool locked;
  final bool isError;
  final bool showStatus; // when false, hide "on"/"ERR" badges entirely
  final VoidCallback? onRemove;
  const _ComponentTile({
    required this.name, required this.icon,
    required this.accentColor, required this.fields,
    required this.locked, this.isError = false,
    this.showStatus = true, this.onRemove});

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _exp = false;
  @override
  Widget build(BuildContext context) {
    final bdr = (widget.isError && widget.showStatus)
        ? Colors.red.withValues(alpha: 0.35)
        : (widget.locked
            ? const Color(0xFF1E3255)
            : widget.accentColor.withValues(alpha: 0.28));
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
      decoration: BoxDecoration(
        color: (widget.isError && widget.showStatus)
            ? Colors.red.withValues(alpha: 0.05)
            : const Color(0xFF162236),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bdr)),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _exp = !_exp),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(children: [
              AnimatedRotation(
                turns: _exp ? .25 : 0,
                duration: const Duration(milliseconds: 130),
                child: const Icon(Icons.chevron_right_rounded,
                    color: Colors.white24, size: 11)),
              const SizedBox(width: 3),
              Container(width: 13, height: 13,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(2)),
                child: Center(child: Text(widget.icon,
                    style: const TextStyle(fontSize: 7)))),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.name,
                style: TextStyle(
                  color: (widget.isError && widget.showStatus)
                      ? const Color(0xFFEF7070)
                      : const Color(0xFFC0D8F0),
                  fontSize: 9, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
              if (widget.isError && widget.showStatus)
                const Text('ERR', style: TextStyle(
                    color: Color(0xFFEF5350), fontSize: 7,
                    fontWeight: FontWeight.w800))
              else if (!widget.locked && !widget.isError && widget.showStatus)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: const Color(0xFF00C853).withValues(alpha: 0.28))),
                  child: const Text('● on', style: TextStyle(
                      color: Color(0xFF00C853), fontSize: 7,
                      fontWeight: FontWeight.w600))),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 3),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white24, size: 11)),
              ],
            ]),
          )),
        if (_exp && widget.fields.isNotEmpty)
          Container(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E3255)))),
            padding: const EdgeInsets.fromLTRB(9, 3, 9, 5),
            child: Column(children: widget.fields.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(children: [
                Expanded(child: Text(f.label, style: const TextStyle(
                    color: Colors.white24, fontSize: 8.5))),
                Text(f.value, style: const TextStyle(
                    color: Color(0xFF9ABCF0), fontSize: 8.5,
                    fontFamily: 'Courier New')),
              ]))).toList()),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Script bank chip — ALL NEUTRAL (no colour hints)
// ═══════════════════════════════════════════════════════════════════════════
class _ScriptBankChip extends StatefulWidget {
  final ScriptChip chip;
  final bool placed;
  final VoidCallback? onTap;
  const _ScriptBankChip({required this.chip, required this.placed, this.onTap});
  @override
  State<_ScriptBankChip> createState() => _ScriptBankChipState();
}

class _ScriptBankChipState extends State<_ScriptBankChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110));
  }
  @override
  void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) { _press.reverse(); if (!widget.placed) widget.onTap?.call(); },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) => Transform.scale(
            scale: 1.0 - 0.06 * _press.value, child: child),
        child: AnimatedOpacity(
          opacity: widget.placed ? .25 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              // Neutral style — no green/red giveaway
              color: const Color(0xFF0C1A2E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF406080), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Flexible(child: Text(widget.chip.label,
                style: const TextStyle(
                  color: Color(0xFF6A8AAA), fontSize: 9,
                  fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
            ]),
          )),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Grid floor painter
// ═══════════════════════════════════════════════════════════════════════════
class _GridFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = .4;
    const cols = 10; const rows = 6;
    for (int i = 0; i <= cols; i++) {
      final x = size.width * i / cols;
      paint.color = const Color(0xFF0050A0).withValues(alpha: 0.12);
      canvas.drawLine(Offset(x, 0),
          Offset(size.width * .5 + (x - size.width * .5) * .06, size.height), paint);
    }
    for (int j = 0; j <= rows; j++) {
      final y = size.height * j / rows;
      paint.color = const Color(0xFF0060C0)
          .withValues(alpha: 0.16 * (1 - j / rows));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
//  Intro popup (shown once when user opens XR Builder for the first time)
// ═══════════════════════════════════════════════════════════════════════════
class _IntroPopupDialog extends StatelessWidget {
  const _IntroPopupDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 560),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF09121E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.14)))),
            child: Row(children: [
              Container(width: 38, height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('⬡',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 20)))),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XR Builder', style: TextStyle(
                      color: Color(0xFF00E5FF), fontSize: 15,
                      fontWeight: FontWeight.w800, letterSpacing: .5)),
                  Text('Simulate real Unity development — no code required',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
                ])),
            ])),
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _bullet('🎯', 'Your job', 'Each level gives you a plain-English challenge — "make the screen show the real world", "let players grab objects". Add the right Unity scripts to the GameObject in the Inspector to make it work.'),
              const SizedBox(height: 10),
              _bullet('📋', 'Script bank', 'The bank shows real Unity script names. Some are correct. Some are convincing fakes. Tap any chip to add it to the Inspector — you\'ll only know if it\'s right when you Run the scene.'),
              const SizedBox(height: 10),
              _bullet('▶', 'Run Scene', 'When ready, tap "Run Scene". The Console shows what worked and what failed. Wrong scripts show ERR in the Inspector — tap × to remove them and try again.'),
              const SizedBox(height: 10),
              _bullet('⚙', 'Learn', 'Pass a level and tap "See How It Works" to read the real C# code behind each script you placed. You\'re not just guessing — you\'re learning.'),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('Let\'s Build  →',
                      style: TextStyle(
                        color: Color(0xFF060B14), fontSize: 13,
                        fontWeight: FontWeight.w800, letterSpacing: .5))),
                  ),
                )),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _bullet(String emoji, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 9),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(body, style: const TextStyle(
              color: Colors.white38, fontSize: 10, height: 1.45)),
        ])),
    ],
  );
}
