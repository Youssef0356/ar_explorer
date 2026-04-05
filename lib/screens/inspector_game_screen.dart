import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../data/inspector_game_data.dart' as ig_data;
import '../models/inspector_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import '../core/tour_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  InspectorGameScreen — v2
//
//  All bugs fixed + improvements applied:
//   1.  Terminal overflow — ListView, never clips, auto-scrolls
//   2.  Viewport icons no longer overlap — spaced fixed-% positions
//   3.  Wrong scripts CAN be placed; errors surface only on "Run Scene"
//   4.  Viewport larger (flex:3 viewport vs flex:2 inspector)
//   5.  More distractors in data — listed in boss section note
//   6.  Terminal height 140px (was 90px) with a Clear button
//   7.  Script chips are ALL neutral grey — no colour hints before Run
//   8.  After success: expandable code snippet shows real C# / Swift
//   9.  Intro popup on first open (game description dialog)
//   10. Wrong chips placed → ERR badge in Inspector, removable with ×
//   11. Scene objects float (AnimatedBuilder) + pulse on activation
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroPopup();
      });
    } else {
      _checkMinigameTour();
    }
  }

  void _checkMinigameTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool('has_seen_showcase_tour_minigame') ?? false;
    if (!hasSeenTour) {
      await prefs.setBool('has_seen_showcase_tour_minigame', true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) TourKeys.startMinigameTour(context);
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
          _onTimeOut();
        }
      });
    });
  }

  void _onTimeOut() {
    setState(() {
      _hasRun = true;
    });
    _showFailurePopup(timedOut: true);
  }

  void _placeScript(ScriptChip chip) {
    if (_placedChips.containsKey(chip.id)) return;
    setState(() {
      _placedChips[chip.id] = chip.isCorrect;
      _termLog.add(TerminalLine(
        TerminalLineType.info,
        'Attached script: ${chip.label}',
      ));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_termScroll.hasClients) {
          _termScroll.animateTo(_termScroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      });
    });
  }

  void _removeScript(String chipId) {
    setState(() {
      _placedChips.remove(chipId);
      _hasRun = false;
    });
  }

  void _validate() async {
    if (_isValidating) return;
    setState(() {
      _isValidating = true;
      _hasRun = true;
      _termLog.add(TerminalLine(TerminalLineType.dim, 'Compiling scene...'));
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final totalCorrect = widget.level.correctIds.length;
    final placedCorrect = _placedChips.keys.where(widget.level.correctIds.contains).length;
    final placedWrong   = _placedChips.keys.where((id) => !widget.level.correctIds.contains(id)).length;

    if (!mounted) return;

    if (placedCorrect == totalCorrect && placedWrong == 0) {
      _onSuccess();
    } else {
      _onFailure();
    }
  }

  void _onSuccess() {
    setState(() {
      _isValidating = false;
      _showSuccess  = true;
      _activatedObjects.addAll(widget.level.sceneObjects);
      for (final obj in widget.level.sceneObjects) {
        _pulseCtrls[obj]?.forward(from: 0);
      }
      _termLog.add(TerminalLine(TerminalLineType.success, 'Build Successful!'));
      _termLog.add(TerminalLine(TerminalLineType.success, 'Scene running with ${ig_data.allInspectorLevels.length} scripts.'));
    });// Added missing closing brace here

    final progress = context.read<GameProgressService>();
    final stars = _computeStars();
    final xpReward = _computeXPReward();
    progress.completeLevel(widget.level.id, stars, isBoss: widget.level.isBoss, unifiedXPReward: xpReward);
    
    context.read<SoundService>().playAchievement();
  }

  void _onFailure() {
    setState(() {
      _isValidating = false;
      _mistakeCount++;
      _termLog.add(TerminalLine(TerminalLineType.error, 'Compilation Error: scripts mismatch!'));
    });
    _showFailurePopup();
    context.read<SoundService>().playFailure();
  }

  void _showFailurePopup({bool timedOut = false}) {
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
              ? 'You ran out of time! Try harder next time.'
              : 'The scene has errors. Remove wrong components and try again.',
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resetLevel(); },
            child: const Text('Restart', style: TextStyle(color: Colors.white24))),
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
      _termLog.clear();
      _termLog.addAll(widget.level.idleTerminal);
      _hasRun = false;
      _showSuccess = false;
      _secondsLeft = widget.level.timeLimit;
    });
    if (widget.level.isBoss) _startTimer();
  }

  int _computeStars() {
    // Star calculation based on engineer feedback:
    // 0 mistakes, 0 hints = 3 stars, full XP
    // 1-2 mistakes OR hints used = 2 stars, 75% XP
    // 3+ mistakes = 1 star, 50% XP
    if (_mistakeCount == 0 && _hintsUsed == 0) return 3;
    if (_mistakeCount <= 2 || _hintsUsed <= 2) return 2;
    return 1;
  }

  int _computeXPReward() {
    final baseXP = widget.level.isBoss ? 50 : 25;
    final stars = _computeStars();
    if (stars == 3) return baseXP; // Full XP
    if (stars == 2) return (baseXP * 0.75).round(); // 75% XP
    return (baseXP * 0.5).round(); // 50% XP
  }

  @override
  Widget build(BuildContext context) {
    final zone        = ig_data.inspectorGameZones.firstWhere((z) => z.id == widget.level.zoneId);
    final hasWrong    = _placedChips.values.any((correct) => !correct);
    final canRun      = _placedChips.isNotEmpty && !_showSuccess;

    return Theme(data: ThemeData.dark(), child: Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildObjectiveBanner(zone),
          Expanded(child: Row(children: [
            Expanded(flex: 3, child: _buildViewport()),
            Expanded(flex: 2, child: _buildInspector()),
          ])),
          _buildScriptBank(),
          _buildTerminal(),
          _buildBottomBar(hasWrong, canRun),
        ]),
      ),
      bottomNavigationBar: _showCodeSnippet ? _buildCodeSnippet() : null,
    ));
  }

  // ── Header — title, zone, stars ───────────────────────────────────────────
  Widget _buildHeader() {
    final zone  = ig_data.inspectorGameZones.firstWhere((z) => z.id == widget.level.zoneId);
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

  // ── Objective Banner ───────────────────────────────────────────────────────
  Widget _buildObjectiveBanner(InspectorZone zone) {
    return KeyedSubtree(
      key: TourKeys.minigameObjectiveKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: zone.accentColor.withValues(alpha: 0.05),
        border: Border(bottom:
            BorderSide(color: zone.accentColor.withValues(alpha: 0.12))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.level.gameObjectIcon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OBJECTIVE', style: TextStyle(color: zone.accentColor,
                fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(widget.level.objective, style: const TextStyle(
                color: Colors.white70, fontSize: 10.5, height: 1.4)),
          ])),
      ]),
    ),
    );
  }

  // ── Viewport — flex 3 ──────────────────────────────────────────────────────
  Widget _buildViewport() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080912),
        border: Border(right: BorderSide(color: Color(0xFF1A1A3E))),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          color: const Color(0xFF0C1420),
          child: Row(children: [
            Text('3D PREVIEW \u2014 HIERARCHY', style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const Spacer(),
            Text('Persp \u25BE', style: TextStyle(
                color: Colors.white.withValues(alpha: 0.22), fontSize: 8)),
          ]),
        ),
        Expanded(child: LayoutBuilder(builder: (ctx, constraints) {
          return Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF050810), Color(0xFF0A0E20)],
              )),
            )),
            Positioned(bottom: 0, left: 0, right: 0,
              child: CustomPaint(size: Size(constraints.maxWidth, 60), painter: _GridPainter())),
            Positioned(top: constraints.maxHeight * .4,
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



  List<Widget> _buildSceneObjects(BoxConstraints constraints) {
    final List<Widget> list = [];
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;

    // Use valid enum values from inspector_game_models.dart
    final positions = {
      SceneObjectType.camera:        Offset(w * .5,  h * .3),
      SceneObjectType.xrRig:         Offset(w * .2,  h * .5),
      SceneObjectType.handLeft:      Offset(w * .8,  h * .4),
      SceneObjectType.handRight:     Offset(w * .3,  h * .7),
      SceneObjectType.spatialAnchor: Offset(w * .7,  h * .75),
      SceneObjectType.cube:          Offset(w * .5,  h * .1),
      SceneObjectType.plane:         Offset(w * .5,  h * .45),
      SceneObjectType.lightProbe:    Offset(w * .65, h * .6),
      SceneObjectType.avatar:        Offset(w * .4,  h * .55),
      SceneObjectType.portal:        Offset(w * .15, h * .35),
    };

    for (final obj in widget.level.sceneObjects) {
      final pos = positions[obj] ?? Offset(w * .5, h * .5);
      final active = _activatedObjects.contains(obj);

      list.add(Positioned(
        left: pos.dx - 20,
        top: pos.dy - 30,
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatCtrls[obj], _pulseCtrls[obj]]),
          builder: (context, _) {
            final fVal = _floatCtrls[obj]?.value ?? 0;
            final pVal = _pulseCtrls[obj]?.value ?? 0;
            return Transform.translate(
              offset: Offset(0, fVal * 10 - 5),
              child: Transform.scale(
                scale: 1.0 + pVal * 0.4,
                child: Column(children: [
                  Text(widget.level.gameObjectIcon,
                    style: TextStyle(fontSize: 24,
                        shadows: active ? [
                          const Shadow(color: Color(0xFF00E5FF), blurRadius: 15)
                        ] : null)),
                  const SizedBox(height: 2),
                  Text(widget.level.gameObjectName,
                    style: TextStyle(color: active ? const Color(0xFF00E5FF) : Colors.white24,
                        fontSize: 8, fontWeight: FontWeight.bold)),
                ]),
              ),
            );
          },
        ),
      ));
    }
    return list;
  }

  Widget _buildSuccessOverlay() {
    final xp    = widget.level.isBoss ? 50 : 25;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('\u2705', style: TextStyle(fontSize: 28))
              .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 8),
          const Text('IT WORKS!', style: TextStyle(
              color: Color(0xFF00E5FF), fontSize: 13,
              fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Icon(
              i < _computeStars() ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < _computeStars() ? Colors.amber : Colors.white24, size: 18))),
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
                _showCodeSnippet ? 'Hide Code \u25B2' : '\u2699  See How It Works',
                style: const TextStyle(color: Colors.white60, fontSize: 9,
                    fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(6)),
              child: const Text('Next Level \u2192', style: TextStyle(
                  color: Color(0xFF060B14), fontSize: 10,
                  fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  // ── Inspector — flex 2 ────────────────────────────────────────────────────
  Widget _buildInspector() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111E35),
        border: Border(left: BorderSide(color: Color(0xFF1A2A4A))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
                  // After Run Scene: correct = accent colour + "on", wrong = red + "ERR"
                  return _ComponentTile(
                    name: c.label, icon: '\u2699',
                    accentColor: (_hasRun && !correct)
                        ? Colors.red
                        : (_hasRun && correct ? c.dotColor : const Color(0xFF3A5070)),
                    fields: (_hasRun && correct) ? c.addFields : [],
                    locked: false,
                    isError: _hasRun && !correct,
                    onRemove: () => _removeScript(c.id),
                  );
                }),
          ])),
        ),
      ]),
    );
  }

  // ── Script Bank — height 155, Wrap ──────────────────────────────────────────
  Widget _buildScriptBank() {
    return KeyedSubtree(
      key: TourKeys.minigameWorkAreaKey,
      child: Container(
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
                chip: chip, 
                placed: placed,
                validated: _hasRun, // Only highlight after Run Scene
                onTap: placed ? null : () => _placeScript(chip));
            }).toList()),
        )),
      ]),
    ),
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
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: const BoxDecoration(
        color: Color(0xFF060F08),
        border: Border(top: BorderSide(color: Color(0xFF00C853))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: const Color(0xFF07120A),
          child: Row(children: [
            const Text('\u2699  How these scripts work in C#', style: TextStyle(
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: chips.length,
          itemBuilder: (context, i) {
            final chip = chips[i];
            return Padding(
                padding: const EdgeInsets.only(bottom: 15),
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

  String _codeSnippet(String chipId) {
    final snippets = {
      'ar_session': 'void Start() {\n  arSession.enabled = true;\n}',
      'anchor_mgr': 'var anchor = anchorMgr.AddAnchor(pose);\nDebug.Log("Anchor set");',
      'raycast_mgr': 'if (raycastMgr.Raycast(pos, hits)) {\n  spawnObject(hits[0]);\n}',
      'plane_mgr': 'planeMgr.planesChanged += (args) => {\n  updateVisuals(args);\n};',
      'face_mgr': 'faceMgr.facesChanged += OnFacesChanged;',
      'light_est': 'void Update() {\n  var brightness = cameraMgr.brightness;\n}',
      'point_cloud': 'void OnEnable() {\n  cloudMgr.pointCloudUpdated += OnUpdate;\n}',
      'body_track': 'foreach (var body in args.added) {\n  IdentifyJoints(body);\n}',
      'env_probe': 'probeMgr.automaticPlacement = true;\nprobeMgr.RefreshAll();',
      'mesh_mgr': 'meshMgr.generateMeshVisuals = true;\nmeshMgr.SetMeshDensity(0.8f);',
      'occlusion_mgr': 'occlusionMgr.humanSegmentationStencilMode = true;',
      'depth_mgr': 'var depthTexture = depthMgr.depthTexture;',
      'image_mgr': 'if (imgMgr.trackedImage.name == "Target") {\n  ShowARContent();\n}',
      'object_mgr': 'foreach (var obj in args.added) {\n  PlaceModel(obj.pose);\n}',
    };
    return snippets[chipId] ?? '// Logic for $chipId applied automatically';
  }

  // ── Bottom Controls ────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool hasWrong, bool canRun) {
    final total  = widget.level.correctIds.length;
    // Progress starts at 0 and only fills once validated
    final placed = _showSuccess ? total : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF0A1020),
      child: Row(children: [
        Expanded(child: Wrap(spacing: 5,
          children: List.generate(total, (i) => Container(
            width: 14, height: 3,
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
            child: const Text('Hint \ud83d\udca1',
                style: TextStyle(color: Colors.white38, fontSize: 10)))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: (canRun && !_isValidating) ? _validate : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: (canRun && !_isValidating)
                  ? (hasWrong
                      ? const Color(0xFFFF8A65)
                      : const Color(0xFF00E5FF))
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(5)),
            child: Text('Run Scene \u25B6',
              style: TextStyle(
                color: (canRun && !_isValidating)
                    ? const Color(0xFF060B14) : Colors.white24,
                fontSize: 10, fontWeight: FontWeight.w800,
                letterSpacing: .4)))),
      ]),
    );
  }

  void _showHint() {
    _hintsUsed++;
    final missing = widget.level.correctIds.firstWhere((id) => !_placedChips.containsKey(id));
    final label   = widget.level.scriptBank.firstWhere((c) => c.id == missing).label;

    _termLog.add(TerminalLine(TerminalLineType.warning, 'HINT: Try attaching "$label"'));
    setState(() {});
  }

  void _showIntroPopup() {
    showDialog(context: context, builder: (_) => const _IntroDialog());
  }
}

// ── Shared Widgets ──────────────────────────────────────────────────────────



class _ScriptBankChip extends StatelessWidget {
  final ScriptChip chip;
  final bool placed;
  final bool validated; // New: only true after Run Scene
  final VoidCallback? onTap;
  const _ScriptBankChip({required this.chip, required this.placed, this.validated = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final activated = placed && validated; // Only highlight after validation
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
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
          child: Center(child: Text('\u2699', // Gear icon as ScriptChip has no icon
            style: TextStyle(
              fontSize: 16,
              color: activated ? null : const Color(0xFF3A4060))))),
        const SizedBox(height: 2),
        Text(chip.label,
          style: TextStyle(
            color: activated ? Colors.white54 : Colors.white24,
            fontSize: 7),
          overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}

class _ComponentTile extends StatefulWidget {
  final String name;
  final String icon;
  final Color  accentColor;
  final List<InspectorField> fields;
  final bool locked;
  final bool isError;
  final VoidCallback? onRemove;
  const _ComponentTile({
    required this.name, required this.icon,
    required this.accentColor, required this.fields,
    required this.locked, this.isError = false,
    this.onRemove});

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _exp = false;
  @override
  Widget build(BuildContext context) {
    final bdr = widget.isError
        ? Colors.red.withValues(alpha: 0.35)
        : (widget.locked
            ? const Color(0xFF1E3255)
            : widget.accentColor.withValues(alpha: 0.28));
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
      decoration: BoxDecoration(
        color: widget.isError
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
              const SizedBox(width: 5),
              Expanded(child: Text(widget.name,
                style: TextStyle(
                  color: widget.isError
                      ? const Color(0xFFEF7070)
                      : const Color(0xFFC0D8F0),
                  fontSize: 9, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
              if (widget.isError)
                const Text(' ERR ', style: TextStyle(
                    color: Color(0xFFEF5350), fontSize: 7,
                    fontWeight: FontWeight.w800))
              else if (!widget.locked && !widget.isError)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: const Color(0xFF00C853).withValues(alpha: 0.28))),
                  child: const Text('\u25cf on', style: TextStyle(
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
        if (_exp)
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.0;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IntroDialog extends StatelessWidget {
  const _IntroDialog();
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
                child: const Center(child: Text('\u2b21',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 20)))),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XR Builder', style: TextStyle(
                      color: Color(0xFF00E5FF), fontSize: 15,
                      fontWeight: FontWeight.w800, letterSpacing: .5)),
                  Text('Simulate real Unity development \u2014 no code required',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
                ])),
            ])),
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _introStep('1. Inspect', 'Drag correctly named scripts into the GameObject inspector.', '\ud83d\udd0d'),
              const SizedBox(height: 18),
              _introStep('2. Simulate', 'Hit "Run Scene" to see your components in action.', '\u25b6'),
              const SizedBox(height: 18),
              _introStep('3. Debug', 'Check the console for errors and fix your build.', '\ud83d\udc1e'),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('Let\'s Build  \u2192',
                      style: TextStyle(
                        color: Color(0xFF060B14), fontSize: 13,
                        fontWeight: FontWeight.w800, letterSpacing: .5))),
                  ),
                )),
          ),
        ]),
      ),
    );
  }

  Widget _introStep(String title, String body, String icon) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
          shape: BoxShape.circle),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 12))),
      ),
      const SizedBox(width: 12),
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
