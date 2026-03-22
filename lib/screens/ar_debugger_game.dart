import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import 'paywall_screen.dart';

// ═══════════════════════════════════════════════════════════════════
//  AR SCENE DEBUGGER — Data Models
// ═══════════════════════════════════════════════════════════════════

enum SymptomSeverity { critical, warning, info }

class DebugSymptom {
  final String id;
  final String icon;
  final String label;
  final String detail;
  final SymptomSeverity severity;

  const DebugSymptom({
    required this.id,
    required this.icon,
    required this.label,
    required this.detail,
    required this.severity,
  });
}

class FixCard {
  final String id;
  final String icon;
  final String label;
  final String explanation;
  final String correctSymptomId;
  final bool isDistractor;

  const FixCard({
    required this.id,
    required this.icon,
    required this.label,
    required this.explanation,
    required this.correctSymptomId,
    this.isDistractor = false,
  });
}

class DebugLevel {
  final String id;
  final String title;
  final String scenario;
  final String screenshotDesc; // describes what's broken visually
  final String screenshotEmoji;
  final Color accentColor;
  final List<DebugSymptom> symptoms;
  final List<FixCard> fixCards; // correct + distractors
  final String successMessage;
  final bool isBoss;
  final bool isFree;

  const DebugLevel({
    required this.id,
    required this.title,
    required this.scenario,
    required this.screenshotDesc,
    required this.screenshotEmoji,
    required this.accentColor,
    required this.symptoms,
    required this.fixCards,
    required this.successMessage,
    this.isBoss = false,
    this.isFree = false,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  LEVEL DATA
// ═══════════════════════════════════════════════════════════════════

final List<DebugLevel> debugLevels = [
  DebugLevel(
    id: 'dbg_1',
    title: 'The Black Screen',
    scenario: 'You just launched your AR app. The camera should show the real world, but the screen is completely black.',
    screenshotDesc: 'Solid black screen — no camera feed',
    screenshotEmoji: '⬛',
    accentColor: const Color(0xFF00E5FF),
    isFree: true,
    symptoms: [
      const DebugSymptom(
        id: 's1',
        icon: '📷',
        label: 'No camera feed',
        detail: 'The screen is black — the real world isn\'t showing through.',
        severity: SymptomSeverity.critical,
      ),
    ],
    fixCards: [
      const FixCard(
        id: 'f1',
        icon: '🖼️',
        label: 'Add AR Camera Background',
        explanation: 'AR Camera Background is the component that renders the live camera feed behind your 3D scene. Without it, only the skybox (black by default) is visible.',
        correctSymptomId: 's1',
      ),
      const FixCard(
        id: 'f2',
        icon: '🔆',
        label: 'Enable Light Estimation',
        explanation: 'Light Estimation adjusts the brightness of virtual objects — it doesn\'t affect the camera feed rendering.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f3',
        icon: '🔧',
        label: 'Restart AR Session',
        explanation: 'Restarting the session resets tracking data but won\'t fix a missing camera background renderer.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
    ],
    successMessage: 'Camera feed is live! The real world is now visible behind your 3D content.',
  ),

  DebugLevel(
    id: 'dbg_2',
    title: 'The Floating Ghost',
    scenario: 'Your virtual sofa is placed on the floor — but when you walk around it, it slowly drifts and floats away from where you put it.',
    screenshotDesc: 'Sofa drifting 30cm off the floor after walking',
    screenshotEmoji: '🛋️',
    accentColor: const Color(0xFF2979FF),
    isFree: true,
    symptoms: [
      const DebugSymptom(
        id: 's1',
        icon: '💨',
        label: 'Object drifts from position',
        detail: 'Virtual objects were placed on the floor but float away after the user moves around.',
        severity: SymptomSeverity.critical,
      ),
    ],
    fixCards: [
      const FixCard(
        id: 'f1',
        icon: '📌',
        label: 'Attach an AR Anchor',
        explanation: 'An AR Anchor locks a virtual object to a specific real-world point. Without it, the object\'s position is only relative to the session origin, which accumulates drift.',
        correctSymptomId: 's1',
      ),
      const FixCard(
        id: 'f2',
        icon: '📐',
        label: 'Recalibrate plane detection',
        explanation: 'Plane recalibration updates the surface mesh but doesn\'t prevent object drift — only anchors do that.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f3',
        icon: '🎨',
        label: 'Lower texture resolution',
        explanation: 'Texture resolution affects visual quality and performance — it has no effect on object positioning.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
    ],
    successMessage: 'Object anchored! The sofa stays exactly where you placed it, even after walking around.',
  ),

  DebugLevel(
    id: 'dbg_3',
    title: 'The Hovering Box',
    scenario: 'You tapped to place a virtual box but it\'s hovering 50cm above the table instead of sitting on its surface.',
    screenshotDesc: 'Box floating in mid-air above a detected table',
    screenshotEmoji: '📦',
    accentColor: const Color(0xFFD1C4E9),
    symptoms: [
      const DebugSymptom(
        id: 's1',
        icon: '🪂',
        label: 'Object placed above surface',
        detail: 'The placed object appears to float above the detected plane rather than resting on it.',
        severity: SymptomSeverity.critical,
      ),
    ],
    fixCards: [
      const FixCard(
        id: 'f1',
        icon: '🎯',
        label: 'Use AR Raycast hit.pose',
        explanation: 'A hit test returns the exact surface pose. Placing your object at hit.pose.position uses the real hit point — not an arbitrary offset. The common bug is adding +Y offset accidentally.',
        correctSymptomId: 's1',
      ),
      const FixCard(
        id: 'f2',
        icon: '💡',
        label: 'Increase ambient light',
        explanation: 'Light settings affect rendering quality, not the spatial position of placed objects.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f3',
        icon: '📏',
        label: 'Scale the object down',
        explanation: 'Scaling changes object size but not its vertical position above the surface.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
    ],
    successMessage: 'Box sits perfectly on the table. The hit test pose is used correctly.',
  ),

  DebugLevel(
    id: 'dbg_4',
    title: 'The Glass Table Problem',
    scenario: 'Your AR app cannot detect any surfaces in the user\'s room. Plane detection is enabled but nothing is found after 30 seconds of scanning.',
    screenshotDesc: 'Scanning animation loops forever — no planes detected',
    screenshotEmoji: '🔍',
    accentColor: const Color(0xFFFFC107),
    symptoms: [
      const DebugSymptom(
        id: 's1',
        icon: '❌',
        label: 'No planes detected',
        detail: 'ARPlaneManager is running but no horizontal or vertical planes are being found after extended scanning.',
        severity: SymptomSeverity.critical,
      ),
      const DebugSymptom(
        id: 's2',
        icon: '🪞',
        label: 'Surface is reflective/transparent',
        detail: 'The user is pointing at a glass table — SLAM cannot extract visual features from it.',
        severity: SymptomSeverity.warning,
      ),
    ],
    fixCards: [
      const FixCard(
        id: 'f1',
        icon: '📋',
        label: 'Guide user to textured surfaces',
        explanation: 'SLAM requires visual feature points. Transparent, reflective, or plain-white surfaces have almost none. The fix is UX: show a hint asking the user to point at a textured surface like carpet or a wooden desk.',
        correctSymptomId: 's1',
      ),
      const FixCard(
        id: 'f2',
        icon: '🔄',
        label: 'Increase plane update rate',
        explanation: 'Plane update rate affects how quickly boundaries expand — it won\'t help when no features exist to detect a plane from.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f3',
        icon: '🌐',
        label: 'Switch to GPS-based AR',
        explanation: 'GPS AR is for outdoor location-based experiences. It doesn\'t solve indoor plane detection issues.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f4',
        icon: '🏷️',
        label: 'Use an image target instead',
        explanation: 'For environments with featureless surfaces, an image target (like a printed card) provides a reliable anchor — this IS a valid workaround for the reflective surface problem.',
        correctSymptomId: 's2',
      ),
    ],
    successMessage: 'User guided to textured surfaces. Planes detected immediately on the wooden floor.',
  ),

  DebugLevel(
    id: 'dbg_5',
    title: 'The X-Ray Chair',
    scenario: 'A virtual character walks behind a real chair — but the character renders in FRONT of the chair. It looks like the chair is transparent.',
    screenshotDesc: 'Virtual avatar visible through solid real furniture',
    screenshotEmoji: '🕶️',
    accentColor: const Color(0xFFFF4081),
    isBoss: true,
    symptoms: [
      const DebugSymptom(
        id: 's1',
        icon: '👁️',
        label: 'Virtual content ignores real geometry',
        detail: 'Virtual objects render in front of physical objects they should be hidden behind.',
        severity: SymptomSeverity.critical,
      ),
      const DebugSymptom(
        id: 's2',
        icon: '📉',
        label: 'Frame rate drops during occlusion',
        detail: 'When occlusion is active, rendering performance decreases noticeably.',
        severity: SymptomSeverity.warning,
      ),
    ],
    fixCards: [
      const FixCard(
        id: 'f1',
        icon: '🌊',
        label: 'Enable AR Occlusion Manager',
        explanation: 'AR Occlusion Manager uses the depth sensor or ML to generate a depth mask. This mask hides virtual pixels that are behind real-world geometry, solving the X-ray effect.',
        correctSymptomId: 's1',
      ),
      const FixCard(
        id: 'f2',
        icon: '⚡',
        label: 'Set depth mode to Fastest',
        explanation: 'Occlusion Manager depth mode "Fastest" uses less GPU bandwidth, which reduces the frame rate hit from occlusion processing.',
        correctSymptomId: 's2',
      ),
      const FixCard(
        id: 'f3',
        icon: '🎭',
        label: 'Use a shadow-only shader',
        explanation: 'Shadow-only shaders help with virtual shadow casting — they don\'t create real-world occlusion masking.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
      const FixCard(
        id: 'f4',
        icon: '🔃',
        label: 'Increase texture atlas size',
        explanation: 'Texture atlasing reduces draw calls but has no effect on depth-based occlusion.',
        correctSymptomId: 'none',
        isDistractor: true,
      ),
    ],
    successMessage: 'Occlusion working! The avatar correctly disappears behind the chair. Boss cleared! 🔥',
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  MAP SCREEN
// ═══════════════════════════════════════════════════════════════════

class ARDebuggerMapScreen extends StatelessWidget {
  const ARDebuggerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Theme(data: ThemeData.dark(), child: Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, progress, isPremium),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                itemCount: debugLevels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final level = debugLevels[i];
                  final isLocked = i > 0 &&
                      !progress.isLevelCompleted(debugLevels[i - 1].id);
                  final isCompleted = progress.isLevelCompleted(level.id);
                  final stars = progress.getStars(level.id);

                  final isPremiumLocked = !level.isFree && !isPremium;
                  return _LevelCard(
                    level: level,
                    index: i,
                    isLocked: isLocked || isPremiumLocked,
                    isPremiumLocked: isPremiumLocked,
                    isCompleted: isCompleted,
                    stars: stars,
                    onTap: isPremiumLocked
                        ? () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PaywallScreen()))
                        : isLocked
                            ? null
                            : () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ARDebuggerGameScreen(level: level),
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader(BuildContext context, GameProgressService progress, bool isPremium) {
    final completed = debugLevels
        .where((l) => progress.isLevelCompleted(l.id))
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF060B14).withOpacity(0.95),
        border: Border(
            bottom: BorderSide(
                color: const Color(0xFF00E5FF).withOpacity(0.15))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white70, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AR SCENE DEBUGGER',
                        style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5)),
                    const Text('Fix the broken AR app',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$completed / ${debugLevels.length}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (!isPremium)
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: Colors.amber, size: 11),
                    SizedBox(width: 5),
                    Text('Unlock all 5 levels with Premium',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final DebugLevel level;
  final int index;
  final bool isLocked;
  final bool isPremiumLocked;
  final bool isCompleted;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.index,
    required this.isLocked,
    this.isPremiumLocked = false,
    required this.isCompleted,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.white.withOpacity(0.02)
              : isCompleted
                  ? level.accentColor.withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLocked
                ? Colors.white.withOpacity(0.06)
                : isCompleted
                    ? level.accentColor.withOpacity(0.35)
                    : level.accentColor.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            // Screenshot preview circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.white.withOpacity(0.04)
                    : level.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isLocked
                        ? Colors.white.withOpacity(0.08)
                        : level.accentColor.withOpacity(0.3)),
              ),
              child: Center(
                child: isPremiumLocked
                    ? const Icon(Icons.workspace_premium_rounded,
                        color: Colors.amber, size: 26)
                    : Text(
                        isLocked ? '🔒' : level.screenshotEmoji,
                        style: TextStyle(
                            fontSize: isLocked ? 22 : 26),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (level.isBoss)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('BOSS',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900)),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.title,
                              style: TextStyle(
                                color: isLocked
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isPremiumLocked)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium_rounded,
                                        color: Colors.amber, size: 10),
                                    SizedBox(width: 4),
                                    Text('PREMIUM',
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.screenshotDesc,
                    style: TextStyle(
                      color: isLocked
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Symptom count chips
                  if (!isLocked)
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ...level.symptoms.map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _severityColor(s.severity)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _severityColor(s.severity),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(s.label,
                                      style: TextStyle(
                                          color: _severityColor(s.severity),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Stars / status
            if (isCompleted)
              Column(
                children: List.generate(
                    3,
                    (i) => Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < stars ? Colors.amber : Colors.white12,
                          size: 14,
                        )),
              )
            else if (!isLocked)
              Icon(Icons.chevron_right_rounded,
                  color: level.accentColor.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05);
  }

  Color _severityColor(SymptomSeverity s) {
    switch (s) {
      case SymptomSeverity.critical:
        return const Color(0xFFEF5350);
      case SymptomSeverity.warning:
        return const Color(0xFFFFCA28);
      case SymptomSeverity.info:
        return const Color(0xFF4FC3F7);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  GAME SCREEN
// ═══════════════════════════════════════════════════════════════════

class ARDebuggerGameScreen extends StatefulWidget {
  final DebugLevel level;
  const ARDebuggerGameScreen({super.key, required this.level});

  @override
  State<ARDebuggerGameScreen> createState() => _ARDebuggerGameScreenState();
}

class _ARDebuggerGameScreenState extends State<ARDebuggerGameScreen>
    with TickerProviderStateMixin {
  // Which fix has been dragged onto which symptom: symptomId → fixId
  final Map<String, String?> _assignments = {};

  // Fix cards remaining in the toolbox
  late List<FixCard> _toolbox;

  // Track wrong attempts for star deduction
  int _wrongAttempts = 0;

  // Feedback: symptomId → correct/wrong/null
  final Map<String, bool?> _feedback = {};

  bool _showSuccess = false;
  bool _isChecking = false;
  String? _expandedFixId; // for explanation popover

  // Animation controllers
  late AnimationController _shakeCtrl;
  late AnimationController _successCtrl;

  @override
  void initState() {
    super.initState();
    if (!widget.level.isFree) {
      final isPremium = context.read<SubscriptionService>().isPremium;
      if (!isPremium) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()));
        });
        return;
      }
    }
    for (final s in widget.level.symptoms) {
      _assignments[s.id] = null;
      _feedback[s.id] = null;
    }
    _toolbox = List.from(widget.level.fixCards)..shuffle(Random());

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  bool get _allAssigned =>
      _assignments.values.every((v) => v != null);

  void _assignFix(String symptomId, String fixId) {
    final current = _assignments[symptomId];
    if (current != null) {
      // Return current fix to toolbox
      final returned = widget.level.fixCards.firstWhere((f) => f.id == current);
      if (!_toolbox.any((f) => f.id == current)) {
        setState(() => _toolbox.add(returned));
      }
    }
    // Remove from toolbox
    setState(() {
      _toolbox.removeWhere((f) => f.id == fixId);
      _assignments[symptomId] = fixId;
      _feedback[symptomId] = null; // reset feedback when reassigned
    });
  }

  void _removeAssignment(String symptomId) {
    final fixId = _assignments[symptomId];
    if (fixId == null) return;
    final fix = widget.level.fixCards.firstWhere((f) => f.id == fixId);
    setState(() {
      _assignments[symptomId] = null;
      _feedback[symptomId] = null;
      if (!_toolbox.any((f) => f.id == fixId)) _toolbox.add(fix);
    });
  }

  Future<void> _checkAnswers() async {
    if (!_allAssigned || _isChecking) return;
    setState(() => _isChecking = true);
    context.read<SoundService>().playTap();

    bool allCorrect = true;
    final newFeedback = <String, bool?>{};

    for (final s in widget.level.symptoms) {
      final fixId = _assignments[s.id];
      final fix = widget.level.fixCards.firstWhere((f) => f.id == fixId);
      final correct = fix.correctSymptomId == s.id;
      newFeedback[s.id] = correct;
      if (!correct) {
        allCorrect = false;
        _wrongAttempts++;
      }
    }

    setState(() => _feedback.addAll(newFeedback));

    if (allCorrect) {
      context.read<SoundService>().playSuccess();
      await Future.delayed(const Duration(milliseconds: 400));
      _successCtrl.forward();

      final stars = _computeStars();
      final xp = widget.level.isBoss ? 50 : 25;
      context.read<GameProgressService>().completeLevel(widget.level.id, stars, isBoss: widget.level.isBoss);
      context.read<GameProgressService>().addXP(xp);

      setState(() => _showSuccess = true);
    } else {
      context.read<SoundService>().playFailure();
      _shakeCtrl.forward(from: 0);
      // Auto-remove wrong assignments so user can retry
      await Future.delayed(const Duration(milliseconds: 1200));
      for (final s in widget.level.symptoms) {
        if (_feedback[s.id] == false) {
          _removeAssignment(s.id);
        }
      }
      setState(() {
        _isChecking = false;
        // Keep correct ones locked
      });
    }
  }

  int _computeStars() {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts <= 2) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildScenarioBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScreenshotPreview(),
                        const SizedBox(height: 20),
                        _buildSymptomSection(),
                        const SizedBox(height: 20),
                        _buildToolboxSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    ));
  }

  Widget _buildHeader() {
    final stars = _computeStars();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1120),
        border: Border(
            bottom: BorderSide(color: Color(0xFF1A2A3A))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.level.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('AR Scene Debugger',
                    style: TextStyle(
                        color: widget.level.accentColor.withOpacity(0.7),
                        fontSize: 11)),
              ],
            ),
          ),
          // Live star display
          Row(
            children: List.generate(
                3,
                (i) => Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                          color: i < stars ? Colors.amber : Colors.white12,
                      size: 16,
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: widget.level.accentColor.withOpacity(0.06),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📋', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCENARIO',
                    style: TextStyle(
                        color: widget.level.accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5)),
                const SizedBox(height: 3),
                Text(widget.level.scenario,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: widget.level.accentColor.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          // Fake phone chrome top bar
          Row(
            children: [
              Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF5350), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFCA28), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), shape: BoxShape.circle)),
              const Spacer(),
              Text('AR App',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                      fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 20),
          Text(widget.level.screenshotEmoji,
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: const Color(0xFFEF5350).withOpacity(0.3)),
            ),
            child: Text(
              widget.level.screenshotDesc,
              style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🩺', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            const Text('SYMPTOMS TO FIX',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2)),
            const Spacer(),
            Text('Drop a fix card on each symptom',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.2), fontSize: 9)),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.level.symptoms.map((s) => _buildSymptomSlot(s)),
      ],
    );
  }

  Widget _buildSymptomSlot(DebugSymptom symptom) {
    final assignedFixId = _assignments[symptom.id];
    final assignedFix = assignedFixId != null
        ? widget.level.fixCards.firstWhere((f) => f.id == assignedFixId)
        : null;
    final fb = _feedback[symptom.id];

    Color borderColor;
    Color bgColor;
    if (fb == true) {
      borderColor = const Color(0xFF4CAF50);
      bgColor = const Color(0xFF4CAF50).withOpacity(0.08);
    } else if (fb == false) {
      borderColor = const Color(0xFFEF5350);
      bgColor = const Color(0xFFEF5350).withOpacity(0.08);
    } else if (assignedFix != null) {
      borderColor = widget.level.accentColor.withOpacity(0.5);
      bgColor = widget.level.accentColor.withOpacity(0.07);
    } else {
      borderColor = Colors.white.withOpacity(0.1);
      bgColor = Colors.white.withOpacity(0.03);
    }

    return DragTarget<FixCard>(
      onWillAcceptWithDetails: (details) =>
          _assignments[symptom.id] == null || true,
      onAcceptWithDetails: (details) =>
          _assignFix(symptom.id, details.data.id),
      builder: (ctx, candidates, rejected) {
        final isHovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? widget.level.accentColor.withOpacity(0.12)
                : bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovering
                  ? widget.level.accentColor.withOpacity(0.7)
                  : borderColor,
              width: isHovering ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Severity dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _severityColor(symptom.severity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              // Symptom info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symptom.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(symptom.detail,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 10,
                            height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Fix slot
              if (assignedFix != null)
                GestureDetector(
                  onTap: fb == true ? null : () => _removeAssignment(symptom.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    constraints: const BoxConstraints(maxWidth: 120),
                    decoration: BoxDecoration(
                      color: fb == true
                          ? const Color(0xFF4CAF50).withOpacity(0.15)
                          : fb == false
                              ? const Color(0xFFEF5350).withOpacity(0.15)
                              : widget.level.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: fb == true
                              ? const Color(0xFF4CAF50).withOpacity(0.5)
                              : fb == false
                                  ? const Color(0xFFEF5350).withOpacity(0.5)
                                  : widget.level.accentColor.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(assignedFix.icon,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(assignedFix.label,
                              style: TextStyle(
                                color: fb == true
                                    ? const Color(0xFF4CAF50)
                                    : fb == false
                                        ? const Color(0xFFEF5350)
                                        : widget.level.accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (fb != true) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.close_rounded,
                              color: Colors.white38, size: 11),
                        ] else ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_rounded,
                              color: Color(0xFF4CAF50), size: 11),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? widget.level.accentColor.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isHovering
                            ? widget.level.accentColor.withOpacity(0.6)
                            : Colors.white.withOpacity(0.1),
                        style: BorderStyle.solid),
                  ),
                  child: Text(
                    isHovering ? 'Drop here!' : 'Drop fix here',
                    style: TextStyle(
                      color: isHovering
                          ? widget.level.accentColor
                          : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolboxSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🧰', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            const Text('FIX TOOLKIT',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2)),
            const SizedBox(width: 8),
            Text('• drag onto a symptom',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.2), fontSize: 9)),
          ],
        ),
        const SizedBox(height: 10),
        ..._toolbox.map((fix) => _buildFixCardWidget(fix)),
      ],
    );
  }

  Widget _buildFixCardWidget(FixCard fix) {
    final isExpanded = _expandedFixId == fix.id;

    return Draggable<FixCard>(
      data: fix,
      feedback: Material(
        color: Colors.transparent,
        child: _FixCardDragging(fix: fix, accentColor: widget.level.accentColor),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _FixCardStatic(
          fix: fix,
          accentColor: widget.level.accentColor,
          isExpanded: false,
          onToggleExpand: null,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(
            () => _expandedFixId = isExpanded ? null : fix.id),
        child: _FixCardStatic(
          fix: fix,
          accentColor: widget.level.accentColor,
          isExpanded: isExpanded,
          onToggleExpand: () => setState(
              () => _expandedFixId = isExpanded ? null : fix.id),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: const Color(0xFF0A1120),
      child: Row(
        children: [
          // Progress indicators
          Expanded(
            child: Row(
              children: widget.level.symptoms.map((s) {
                final assigned = _assignments[s.id] != null;
                final correct = _feedback[s.id] == true;
                return Container(
                  width: 28,
                  height: 5,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: correct
                        ? const Color(0xFF4CAF50)
                        : assigned
                            ? widget.level.accentColor.withOpacity(0.5)
                            : Colors.white12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _allAssigned && !_isChecking ? _checkAnswers : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _allAssigned && !_isChecking
                    ? widget.level.accentColor
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Run Diagnostics ▶',
                style: TextStyle(
                  color: _allAssigned && !_isChecking
                      ? Colors.black
                      : Colors.white24,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    final stars = _computeStars();
    final xp = widget.level.isBoss ? 50 : 25;

    return Container(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐛', style: TextStyle(fontSize: 48))
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text('BUG SQUASHED!',
                  style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2))
                  .animate()
                  .fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(widget.level.successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5))
                  .animate()
                  .fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < stars ? Colors.amber : Colors.white12,
                          size: 36,
                        ).animate(delay: Duration(milliseconds: 500 + i * 150))
                            .scale(curve: Curves.elasticOut)),
              ),
              const SizedBox(height: 8),
              Text('+$xp XP',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w800))
                  .animate()
                  .fadeIn(delay: 900.ms),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // to map
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.level.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Continue →',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(SymptomSeverity s) {
    switch (s) {
      case SymptomSeverity.critical:
        return const Color(0xFFEF5350);
      case SymptomSeverity.warning:
        return const Color(0xFFFFCA28);
      case SymptomSeverity.info:
        return const Color(0xFF4FC3F7);
    }
  }
}

// ── Fix card sub-widgets ───────────────────────────────────────────────────

class _FixCardStatic extends StatelessWidget {
  final FixCard fix;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const _FixCardStatic({
    required this.fix,
    required this.accentColor,
    required this.isExpanded,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isExpanded
            ? accentColor.withOpacity(0.07)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? accentColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child:
                        Text(fix.icon, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(fix.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.drag_indicator_rounded,
                        color: Colors.white24, size: 16),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.info_outline_rounded,
                      color: accentColor.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(fix.explanation,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        height: 1.5)),
              ),
            ).animate().fadeIn(duration: 180.ms).slideY(begin: -0.05),
        ],
      ),
    );
  }
}

class _FixCardDragging extends StatelessWidget {
  final FixCard fix;
  final Color accentColor;

  const _FixCardDragging({required this.fix, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 180),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fix.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(fix.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                maxLines: 2),
          ),
        ],
      ),
    );
  }
}
