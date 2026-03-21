import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../data/game_data.dart';
import '../data/modules_data.dart';
import '../models/game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import 'module_detail_screen.dart';
import 'paywall_screen.dart';

class GamePipelineScreen extends StatefulWidget {
  final ARLevel level;
  const GamePipelineScreen({super.key, required this.level});

  @override
  State<GamePipelineScreen> createState() => _GamePipelineScreenState();
}

class _GamePipelineScreenState extends State<GamePipelineScreen> {
  late List<ARNode?> _slots;
  late List<bool>   _slotPulsed;
  late List<ARNode> _pool;

  bool   _isValidating   = false;
  bool   _showSuccess    = false;
  bool   _showFailure    = false;
  bool   _isTimeout      = false;
  int    _starsEarned    = 3;
  int    _failureCount   = 0;
  int    _wrongSlotIndex = -1;
  ARNode? _hintNode;
  String  _errorMessage  = '';

  int  _secondsRemaining = 0;

  // ── Pipeline scroll controller (auto-scroll to latest slot) ──────────────
  final ScrollController _pipelineScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _slots      = List.filled(widget.level.correctSequence.length, null);
    _slotPulsed = List.filled(widget.level.correctSequence.length, false);
    _pool       = List.from(widget.level.availableNodes)..shuffle();
    if (widget.level.isBoss) {
      _secondsRemaining = widget.level.timeLimit;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _pipelineScrollCtrl.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        setState(() {
          _isTimeout   = true;
          _starsEarned = 0;
          _errorMessage = 'Time\'s up! The system crashed.';
        });
        return false;
      }
      return !_showSuccess;
    });
  }

  // ── Node placement / removal ──────────────────────────────────────────────
  void _tapNode(ARNode node) {
    if (_isValidating || _showSuccess || _isTimeout) return;
    final idx = _slots.indexOf(node);
    if (idx != -1) {
      setState(() {
        _slots[idx] = null;
        _wrongSlotIndex = -1;
      });
      context.read<SoundService>().playTap();
      return;
    }
    final empty = _slots.indexOf(null);
    if (empty == -1) return;
    setState(() {
      _slots[empty] = node;
      _wrongSlotIndex = -1;
    });
    context.read<SoundService>().playTap();

    // ── Auto-scroll pipeline to the newly filled slot ──
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pipelineScrollCtrl.hasClients) return;
      // Each slot is ~80 wide + 12 separator ≈ 92
      const slotWidth = 92.0;
      final targetOffset = (empty * slotWidth)
          .clamp(0.0, _pipelineScrollCtrl.position.maxScrollExtent);
      _pipelineScrollCtrl.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

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
      _isValidating   = true;
      _showFailure    = false;
      _slotPulsed     = List.filled(_slots.length, false);
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
    if (widget.level.isBoss) setState(() {}); // stop timer display
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
      _pool           = List.from(widget.level.availableNodes)..shuffle();
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

  // ── "Learn This" — navigate to module most relevant to this level ─────────
  void _openLearnModule(BuildContext context, Color accentColor) {
    // Map zone → module id (best-effort mapping)
    const zoneToModule = {
      'zone_1': 'foundations_camera',      // Camera / AR basics module
      'zone_2': 'foundations_coordinate_systems',
      'zone_3': 'mod_dev',
      'zone_4': 'mod_openxr',
      'zone_5': 'mod_advanced',
    };
    final moduleId = zoneToModule[widget.level.zoneId];
    final module = moduleId != null
        ? allModules.firstWhereOrNull((m) => m.id == moduleId)
        : null;

    if (module == null) {
      // Fallback — just pop back to modules list
      Navigator.pop(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ModuleDetailScreen(
        module: module,
        accentColor: accentColor,
      )),
    );
  }

  // ── Node long-press info sheet ─────────────────────────────────────────────
  void _showNodeInfo(BuildContext context, ARNode node, Color accentColor) {
    // Each node maps to a short explanation + why it comes first/last
    final Map<String, Map<String, String>> nodeExplain = {
      'camera': {
        'what': 'The Camera Stream captures the live video feed from your device\'s physical camera. '
            'It is the raw pixel data the phone sees — think of it as the "eyes" of your AR system.',
        'why': 'It always comes first because every other step (tracking, detection, rendering) '
            'needs the real-world image as input. Without it, there\'s nothing to overlay onto.',
      },
      'imu': {
        'what': 'IMU (Inertial Measurement Unit) bundles the accelerometer and gyroscope. '
            'They measure how fast the device is moving and rotating in 3D space.',
        'why': 'It pairs with the camera to give SLAM a second data source. '
            'IMU updates at ~200 Hz — much faster than camera frames — so it smooths tracking between frames.',
      },
      'slam': {
        'what': 'SLAM = Simultaneous Localization And Mapping. It builds a 3D map of the environment '
            'while also tracking where the device is inside that map.',
        'why': 'Needed before any surface detection or object placement — you must know "where you are" '
            'before you can say "put this object here".',
      },
      'plane_detection': {
        'what': 'Plane Detection analyses the SLAM map to find flat horizontal or vertical surfaces '
            '(floors, tables, walls).',
        'why': 'Required before Hit Testing — you can\'t tap to place an object unless the system knows '
            'where the surfaces are.',
      },
      'hit_test': {
        'what': 'Hit Test casts an invisible ray from your screen tap into the 3D world and returns '
            'the real-world point where it intersects a detected plane.',
        'why': 'Translates "I tapped here on the screen" → "this exact real-world position". '
            'Without it you can\'t interactively place objects.',
      },
      'anchor': {
        'what': 'An Anchor pins a virtual object to a specific real-world position. '
            'Even as the camera moves, the anchor keeps the object stable in space.',
        'why': 'Without an anchor, objects would drift or float when you move the phone.',
      },
      'renderer': {
        'what': 'The 3D Renderer draws your virtual objects on top of the camera feed, '
            'compositing the digital and physical worlds together on screen.',
        'why': 'Always last — it is the final output step. All the tracking and detection '
            'work upstream just feeds this final drawing step.',
      },
      'light_estimation': {
        'what': 'Light Estimation analyses the camera image to guess the real-world lighting '
            'direction and colour temperature.',
        'why': 'Makes virtual objects cast realistic shadows and have matching colours, '
            'so they look like they truly belong in the scene.',
      },
      'occlusion': {
        'what': 'Occlusion uses a depth map to determine which real objects are in front of virtual ones, '
            'then hides the virtual geometry behind them.',
        'why': 'Without it, a virtual cube placed behind a real table would visually float in front of it.',
      },
      'openxr': {
        'what': 'OpenXR is a cross-platform, open standard by the Khronos Group. '
            'Instead of writing different code for ARCore, ARKit, and HoloLens, '
            'you write once against the OpenXR API.',
        'why': 'Acts as a universal adapter layer between your app and the underlying hardware platform.',
      },
      'relocalization': {
        'what': 'Relocalization recovers tracking after it has been lost — for example after '
            'the camera is covered or rapid movement confuses SLAM.',
        'why': 'Compares the current camera view against previously seen keyframes to re-establish '
            'the device\'s position in the map.',
      },
      'spatial_anchor': {
        'what': 'Spatial Anchors store anchor data in the cloud so that other users or '
            'future sessions can resolve the same anchor.',
        'why': 'Enables persistent, shared AR — multiple users see the same virtual content '
            'at the same real-world location.',
      },
    };

    final info = nodeExplain[node.id];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E1621),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Icon + name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Icon(node.icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(node.description,
                      style: TextStyle(
                        color: accentColor.withValues(alpha: 0.8),
                        fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (info != null) ...[
              if (info['what']?.isNotEmpty == true)
                _infoSection('🔍 What is it?', info['what']!),
              if (info['what']?.isNotEmpty == true && info['why']?.isNotEmpty == true)
                const SizedBox(height: 14),
              if (info['why']?.isNotEmpty == true)
                _infoSection('💡 Why does it go here in the pipeline?', info['why']!),
            ] else
              Text(node.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String heading, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading,
          style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(body,
          style: const TextStyle(
            color: Colors.white70, fontSize: 13, height: 1.55)),
      ],
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final zone = arGameZones.firstWhere((z) => z.id == widget.level.zoneId);

    return Theme(data: ThemeData.dark(), child: Scaffold(
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
                _buildContextSection(zone.accentColor),
                const SizedBox(height: 8),
                // ── Pipeline slots ──
                _buildPipelineRow(zone.accentColor),
                // ── Error / hint message ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _showFailure
                      ? _buildErrorBanner(zone.accentColor)
                      : const SizedBox.shrink(),
                ),
                // ── "Learn This" appears after 2 failures ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: (_failureCount >= 2 && !_showSuccess)
                      ? _buildLearnThisBanner(zone.accentColor)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                // ── Node pool ──
                Expanded(child: _buildNodePool(zone.accentColor)),
                // ── Submit button ──
                _buildSubmitBar(zone.accentColor),
              ],
            ),
          ),
          // ── Success overlay ──
          if (_showSuccess) _buildSuccessOverlay(zone),
          // ── Timeout overlay ──
          if (_isTimeout) _buildTimeoutOverlay(zone),
        ],
      ),
    ));
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ARZone zone) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.level.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w800)),
                Text(zone.name,
                  style: TextStyle(
                    color: zone.accentColor.withValues(alpha: 0.7),
                    fontSize: 11)),
              ],
            ),
          ),
          // Timer (boss only)
          if (widget.level.isBoss && !_showSuccess)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (_secondsRemaining < 15 ? Colors.red : Colors.white)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (_secondsRemaining < 15 ? Colors.red : Colors.white)
                      .withValues(alpha: 0.25)),
              ),
              child: Text(
                '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: _secondsRemaining < 15 ? Colors.red : Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w800,
                  fontFamily: 'monospace')),
            ),
          // Stars
          const SizedBox(width: 8),
          Row(
            children: List.generate(3, (i) => Icon(
              Icons.star_rounded, size: 16,
              color: i < _starsEarned
                  ? Colors.amber
                  : Colors.white.withValues(alpha: 0.12))),
          ),
        ],
      ),
    );
  }

  // ── Goal banner ───────────────────────────────────────────────────────────
  Widget _buildGoalBanner(ARZone zone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: zone.accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: zone.accentColor.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Task - the concrete scenario
          if (widget.level.projectTask.isNotEmpty)
            Text(widget.level.projectTask,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
          if (widget.level.projectTask.isNotEmpty && widget.level.goal.isNotEmpty)
            const SizedBox(height: 6),
          // Goal - the short directive
          if (widget.level.goal.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag_rounded, color: zone.accentColor, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(widget.level.goal,
                    style: TextStyle(
                      color: zone.accentColor.withValues(alpha: 0.9),
                      fontSize: 11, fontWeight: FontWeight.w500, height: 1.4))),
              ],
            ),
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
          Icon(Icons.touch_app_rounded,
            color: accentColor.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Tap nodes below to build the pipeline. Long-press any node for an explanation.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  // ── Build Context expandable section ────────────────────────────────────
  Widget _buildContextSection(Color accentColor) {
    if (widget.level.buildContext.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        collapsedBackgroundColor: Colors.white.withValues(alpha: 0.03),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        iconColor: accentColor,
        collapsedIconColor: Colors.white.withValues(alpha: 0.4),
        title: Text(
          'About this build step',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Text(
            widget.level.buildContext,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pipeline slots row ────────────────────────────────────────────────────
  Widget _buildPipelineRow(Color accentColor) {
    final slotCount = _slots.length;
    return Column(
      children: [
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Scrollbar(
            controller: _pipelineScrollCtrl,
            thumbVisibility: slotCount > 4, // show scrollbar when >4 slots
            child: ListView.separated(
              controller: _pipelineScrollCtrl,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: slotCount,
              separatorBuilder: (_, index) => Center(
                child: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.15), size: 12),
              ),
              itemBuilder: (_, i) => _buildSlot(i, accentColor),
            ),
          ),
        ),
        // Scroll hint only when there are more than 4 slots
        if (slotCount > 4)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded,
                  color: accentColor.withValues(alpha: 0.4), size: 12),
                const SizedBox(width: 4),
                Text('Scroll to see all $slotCount slots',
                  style: TextStyle(
                    color: accentColor.withValues(alpha: 0.4),
                    fontSize: 10)),
              ],
            ),
          ),
      ],
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
                  color: (isWrong ? Colors.red : accentColor)
                      .withValues(alpha: 0.25),
                  blurRadius: 10)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15)),
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

  // ── Error banner ──────────────────────────────────────────────────────────
  Widget _buildErrorBanner(Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage,
              style: const TextStyle(
                color: Colors.red, fontSize: 11, height: 1.3))),
        ],
      ),
    );
  }

  // ── "Learn This" banner (appears after 2 failures) ────────────────────────
  Widget _buildLearnThisBanner(Color accentColor) {
    return GestureDetector(
      onTap: () => _openLearnModule(context, accentColor),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.35))),
        child: Row(
          children: [
            Icon(Icons.school_rounded, color: accentColor, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Not sure about this?',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Tap to read the related learning module →',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
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
                  fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
              const Spacer(),
              Text('${_slots.where((s) => s != null).length} / ${_slots.length} placed',
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.6),
                  fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              // "hold for info" label
              Text('· hold for info',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 9)),
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
    final slotIndex = _slots.indexOf(node);
    final isPlaced  = slotIndex != -1;
    final isHint    = _hintNode?.id == node.id;

    return GestureDetector(
      onTap: () => _tapNode(node),
      // Long press → show explanation sheet
      onLongPress: () => _showNodeInfo(context, node, accentColor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaced
              ? Colors.white.withValues(alpha: 0.02)
              : isHint
                  ? accentColor.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaced
                ? Colors.white.withValues(alpha: 0.06)
                : isHint
                    ? accentColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
            width: isHint ? 1.5 : 1)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPlaced
                    ? Colors.white.withValues(alpha: 0.03)
                    : accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(node.icon,
                color: isPlaced
                    ? Colors.white.withValues(alpha: 0.2)
                    : accentColor,
                size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(node.name,
                        style: TextStyle(
                          color: isPlaced
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 13, fontWeight: FontWeight.w700)),
                      if (isHint) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text('START HERE',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 8, fontWeight: FontWeight.w800,
                              letterSpacing: 0.8))),
                      ],
                    ],
                  ),
                  Text(node.description,
                    style: TextStyle(
                      color: isPlaced
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.45),
                      fontSize: 11)),
                  if (node.hint.isNotEmpty && !isPlaced)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        node.hint,
                        style: TextStyle(
                          color: accentColor.withValues(alpha: 0.55),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (isPlaced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text('SLOT ${slotIndex + 1}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 9, fontWeight: FontWeight.w800)))
            else
              Icon(Icons.info_outline_rounded,
                color: Colors.white.withValues(alpha: 0.15), size: 14),
          ],
        ),
      ),
    );
  }

  // ── Submit bar ────────────────────────────────────────────────────────────
  Widget _buildSubmitBar(Color accentColor) {
    final filledCount = _slots.where((s) => s != null).length;
    final allFilled   = filledCount == _slots.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isValidating || !allFilled || _showSuccess || _isTimeout)
                  ? null
                  : _validate,
              style: ElevatedButton.styleFrom(
                backgroundColor: allFilled ? accentColor : Colors.white12,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      allFilled
                          ? 'RUN PIPELINE'
                          : 'FILL ALL SLOTS  ($filledCount/${_slots.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13, letterSpacing: 1)),
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
                  border: Border.all(
                    color: zone.accentColor.withValues(alpha: 0.4), width: 2)),
                child: Icon(Icons.check_rounded,
                  color: zone.accentColor, size: 56),
              ).animate().scale(
                curve: Curves.elasticOut,
                duration: 600.ms),

              const SizedBox(height: 20),
              const Text('PIPELINE ONLINE',
                style: TextStyle(
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: 3),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star_rounded,
                    size: 38,
                    color: i < _starsEarned
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.1)),
                ).animate(delay: Duration(milliseconds: 500 + i * 150))
                    .scale(curve: Curves.elasticOut)),
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                      child: const Text('RETRY',
                        style: TextStyle(
                          fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if we just finished the last free level
                        final isLastFree = widget.level.id == 'z1_l2';
                        final isPremium = context.read<SubscriptionService>().isPremium;

                        if (isLastFree && !isPremium) {
                          _showPremiumPrompt(context);
                        } else {
                          _goNextLevel();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: zone.accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                        elevation: 0),
                      child: const Text('CONTINUE',
                        style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13,
                          letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.workspace_premium_rounded, size: 64, color: Color(0xFFFFC107)),
            const SizedBox(height: 20),
            const Text('Enjoyed the Trial?',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'You\'ve mastered the AR basics! Unlock Premium to access all 5 Zones, 15+ complex pipelines, and professional engineering challenges.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close prompt
                  Navigator.pop(context); // Exit game screen
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONTINUE WITH PREMIUM',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close prompt
                Navigator.pop(context); // Exit game screen
              },
              child: Text('Maybe Later',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            ),
          ],
        ),
      ),
    );
  }

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
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.4), width: 2)),
                child: const Icon(Icons.timer_off_rounded,
                  color: Colors.red, size: 56),
              ).animate().shake(hz: 2),

              const SizedBox(height: 20),
              Text(_errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800)),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: zone.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                  child: const Text('TRY AGAIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Extension helper ──────────────────────────────────────────────────────────
extension _IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
