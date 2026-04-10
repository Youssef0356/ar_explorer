import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourKeys {
  static TutorialCoachMark? _currentMark;
  static List<TargetFocus> _currentTargets = [];
  static int _currentIndex = 0;
  
  /// Flag to prevent auto-triggering tours when manually triggered from settings
  static bool _justManuallyTriggered = false;
  
  /// Check if a tour was just manually triggered (for preventing double-trigger)
  static bool get wasJustManuallyTriggered => _justManuallyTriggered;
  
  /// Mark that a tour is about to be manually triggered
  static void markManualTrigger() {
    _justManuallyTriggered = true;
  }
  
  /// Clear the manual trigger flag (call after tour starts or after a delay)
  static void clearManualTrigger() {
    _justManuallyTriggered = false;
  }

  static void dismiss() {
    _currentMark?.finish();
    _currentMark = null;
    _currentTargets = [];
    _currentIndex = 0;
  }

  /// Global advancement logic. Scrolls to the next target BEFORE advancing the highlight.
  static void _advance() {
    _currentIndex++;
    if (_currentIndex < _currentTargets.length) {
      final nextTarget = _currentTargets[_currentIndex];
      final nextContext = (nextTarget.keyTarget as GlobalKey).currentContext;
      if (nextContext != null) {
        // Instant scroll to the next target so it is in position before highlight calculates its rect.
        Scrollable.ensureVisible(
          nextContext,
          duration: Duration.zero,
          alignment: 0.5,
        );
      }
    }
    _currentMark?.next();
  }

  /// Helper to add a target only if its widget is currently visible on screen
  static void _addIfVisible(List<TargetFocus> targets, TargetFocus target) {
    // If the widget isn't in the tree at all, skip it
    final context = (target.keyTarget as GlobalKey).currentContext;
    if (context == null) return;
    
    // If the widget is in the tree but has no size (e.g., inside a zero-height Visibility), skip it
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.size.height > 0) {
      targets.add(target);
    }
  }

  // ── Existing ──
  static final GlobalKey homeXpKey      = GlobalKey();
  static final GlobalKey homeTabKey     = GlobalKey();
  static final GlobalKey roadmapTabKey  = GlobalKey();
  static final GlobalKey playTabKey     = GlobalKey();
  static final GlobalKey rewardsTabKey  = GlobalKey();

  // ── HOME TAB ──
  static final GlobalKey homePracticeKey  = GlobalKey();
  static final GlobalKey homeKeywordKey   = GlobalKey();
  static final GlobalKey homeInterviewKey = GlobalKey();
  static final GlobalKey homeAnalyticsKey = GlobalKey();
  static final GlobalKey homeBookmarksKey = GlobalKey();
  static final GlobalKey homeModulesKey   = GlobalKey();
  static final GlobalKey homeCertificatesKey = GlobalKey();

  // ── ROADMAP TAB ──
  static final GlobalKey roadmapTitleKey  = GlobalKey();

  // ── PLAY TAB ──
  static final GlobalKey playHeaderKey    = GlobalKey();
  static final GlobalKey playGameXRBuilderKey = GlobalKey();
  static final GlobalKey playGameSystemsEngineerKey = GlobalKey();
  static final GlobalKey playGamePipelineChallengeKey = GlobalKey();
  static final GlobalKey playGameARDebuggerKey = GlobalKey();
  static final GlobalKey playGamesListKey = GlobalKey(); // Legacy, keep just in case

  // ── REWARDS TAB ──
  static final GlobalKey rewardsDashboardKey = GlobalKey();
  static final GlobalKey rewardsBadgesKey    = GlobalKey();

  // ── MINI-GAMES (UNIQUE KEYS TO AVOID DUPLICATE GLOBALKEY ERRORS) ──
  // Pipeline Challenge (Systems Engineer)
  static final GlobalKey pipelineObjectiveKey = GlobalKey();
  static final GlobalKey pipelineSceneKey     = GlobalKey();
  static final GlobalKey pipelineWorkAreaKey  = GlobalKey();
  static final GlobalKey pipelineSubmitKey    = GlobalKey();

  // AR Debugger
  static final GlobalKey debuggerObjectiveKey  = GlobalKey();
  static final GlobalKey debuggerSceneKey      = GlobalKey();
  static final GlobalKey debuggerWorkAreaKey    = GlobalKey();

  // Inspector Game
  static final GlobalKey inspectorObjectiveKey = GlobalKey();
  static final GlobalKey inspectorSceneKey     = GlobalKey();
  static final GlobalKey inspectorWorkAreaKey  = GlobalKey();

  // XR Coding
  static final GlobalKey codingObjectiveKey    = GlobalKey();
  static final GlobalKey codingCodeAreaKey     = GlobalKey();
  static final GlobalKey codingWorkAreaKey     = GlobalKey();

  /// The main on-boarding tour triggered on first launch.
  static void startHomeTour(BuildContext context, {ScrollController? scrollController}) {
    final targets = <TargetFocus>[];

    _addIfVisible(targets, _target(
      key: homeXpKey,
      identify: 'xp_bar',
      title: 'Your XP Progress',
      description: 'You earn XP by exploring modules, succeeding in mini-games, completing daily challenges, and answering quiz questions correctly.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: homePracticeKey,
      identify: 'practice_btn',
      title: 'Daily Practice',
      description: 'Review saved notes and answer daily questions here.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: homeInterviewKey,
      identify: 'interview_banner',
      title: 'Practice Interviews',
      description: 'Prepare for real-world scenarios with our AI-powered interview practice.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: homeAnalyticsKey,
      identify: 'quiz_analytics',
      title: 'Quiz Analytics',
      description: 'Track your performance across all quizzes to identify areas for improvement.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: homeBookmarksKey,
      identify: 'bookmarks',
      title: 'Bookmarks',
      description: 'Quickly access your saved notes and topics from any module.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: homeModulesKey,
      identify: 'modules_list',
      title: 'Learning Path',
      description: 'Interactive modules from AR Basics to Advanced Scene Understanding.',
      contentAlign: ContentAlign.top,
    ));

    _addIfVisible(targets, _target(
      key: homeCertificatesKey,
      identify: 'certificates',
      title: 'Certificates',
      description: 'Earn Bronze, Silver, Gold, and Platinum certificates by mastering units.',
      contentAlign: ContentAlign.top,
    ));

    _show(context, targets, 'home_tour');
  }

  static void startRoadmapTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: roadmapTitleKey,
        identify: 'roadmap_title',
        title: 'Learning Roadmap',
        description: 'This map represents your journey to becoming an AR Master. Complete modules sequentially to unlock the next levels!',
        contentAlign: ContentAlign.bottom,
      ),
    ];
    _show(context, targets, 'roadmap_tour');
  }

  static void startPlayTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: playHeaderKey,
        identify: 'play_header',
        title: 'AR Sandbox',
        description: 'This is where you solve engineering challenges and practice AR debugging.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: playGameXRBuilderKey,
        identify: 'xr_builder',
        title: 'XR Builder',
        description: 'Build robust setups by deploying spatial components physically in 3D.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: playGameSystemsEngineerKey,
        identify: 'systems_engineer',
        title: 'Systems Engineer',
        description: 'Connect scripts to anchors and surfaces to build logic.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: playGamePipelineChallengeKey,
        identify: 'pipeline_challenge',
        title: 'Pipeline Challenge',
        description: 'Wire up inputs and outputs to achieve desired XR behaviors.',
        contentAlign: ContentAlign.top,
      ),
      _target(
        key: playGameARDebuggerKey,
        identify: 'ar_debugger',
        title: 'AR Debugger',
        description: 'Diagnose faults and find bugs in pre-built broken AR applications.',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'play_tour');
  }

  static void startRewardsTour(BuildContext context) {
    final targets = <TargetFocus>[];
    
    _addIfVisible(targets, _target(
      key: rewardsDashboardKey,
      identify: 'rewards_dashboard',
      title: 'XP Dashboard',
      description: 'View your total progress, level title, and overall curriculum completion.',
      contentAlign: ContentAlign.bottom,
    ));

    _addIfVisible(targets, _target(
      key: rewardsBadgesKey,
      identify: 'badges_grid',
      title: 'Earned Badges',
      description: 'Unlock unique badges by completing challenges and mastering AR modules.',
      contentAlign: ContentAlign.top,
    ));

    _show(context, targets, 'rewards_tour');
  }

  static void startInspectorTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: inspectorObjectiveKey,
        identify: 'inspector_objective',
        title: 'Mission Objective',
        description: 'Read your mission and goals here before you start configuring the scene.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: inspectorSceneKey,
        identify: 'inspector_scene',
        title: '3D Preview',
        description: 'This is the AR scene you need to fix. Watch it closely for feedback as you apply scripts.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: inspectorWorkAreaKey,
        identify: 'inspector_workarea',
        title: 'Script Bank',
        description: 'Drag scripts from here to the Inspector on the right to build your solution.',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'inspector_tour');
  }

  static void startPipelineTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: pipelineObjectiveKey,
        identify: 'pipeline_objective',
        title: 'Welcome, AR Architect! 🏗️',
        description: 'You\'ve been hired by Spatial Dreams Inc. to build the logic pipelines of the future. This is your "Client Brief"—read it carefully to understand the problem you need to solve.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: pipelineSceneKey,
        identify: 'pipeline_flow',
        title: 'The Assembly Line ⚙️',
        description: 'This is your processing pipeline. Like a real-world factory, data flows from left to right. If you miss a step or swap the order, the system will crash!',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: pipelineWorkAreaKey,
        identify: 'pipeline_pool',
        title: 'The Component Toolkit 🧰',
        description: 'These are your sensors and algorithms. Tap them to add them to your assembly line in the correct engineering order.',
        contentAlign: ContentAlign.top,
      ),
      _target(
        key: pipelineSubmitKey,
        identify: 'pipeline_submit',
        title: 'Run Diagnostics ▶️',
        description: 'Once your pipeline is built, hit this button to test it on the device and see if it meets the client\'s requirements!',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'pipeline_tour');
  }

  static void startDebuggerTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: debuggerObjectiveKey,
        identify: 'debugger_objective',
        title: 'Debugger Scenario',
        description: 'Read about the broken AR behavior and the symptoms reported.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: debuggerSceneKey,
        identify: 'debugger_bug',
        title: 'Visual Symptom',
        description: 'See the issue visually in this app preview to understand what is wrong.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: debuggerWorkAreaKey,
        identify: 'debugger_toolbox',
        title: 'Fix Toolkit',
        description: 'Drag matching fix cards onto the symptoms reported below to repair the app.',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'debugger_tour');
  }

  static void startCodingGameTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: codingObjectiveKey,
        identify: 'coding_objective',
        title: 'Mission Objective',
        description: 'Read your mission and goals here before you start placing components.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: codingCodeAreaKey,
        identify: 'coding_code_area',
        title: 'The Code',
        description: 'This is the code snippet you need to fix or complete.',
        contentAlign: ContentAlign.top,
      ),
      _target(
        key: codingWorkAreaKey,
        identify: 'coding_workarea',
        title: 'Your Toolkit',
        description: 'Drag and drop chips from here into the code slots above to build your solution!',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'coding_game_tour');
  }

  static void _show(BuildContext context, List<TargetFocus> targets, String tag) {
    if (targets.isEmpty) return;

    // Map tag to SharedPreferences flag
    final flagMap = {
      'home_tour': 'has_seen_showcase_tour_home_v2',
      'roadmap_tour': 'has_seen_showcase_tour_roadmap',
      'play_tour': 'has_seen_showcase_tour_play',
      'rewards_tour': 'has_seen_showcase_tour_rewards',
      'inspector_tour': 'has_seen_showcase_tour_inspector',
      'pipeline_tour': 'has_seen_showcase_tour_pipeline',
      'debugger_tour': 'has_seen_showcase_tour_debugger',
      'coding_game_tour': 'has_seen_showcase_tour_coding',
    };
    final flag = flagMap[tag];

    // Helper to mark tour as seen
    void markTourAsSeen() {
      if (flag != null) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool(flag, true);
        });
      }
    }

    dismiss(); // Ensure no other tour is running
    _currentTargets = targets;
    _currentIndex = 0;

    _currentMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.85,
      onClickTarget: (target) => _advance(),
      onClickOverlay: (target) => _advance(),
      onFinish: () {
        _currentMark = null;
        _currentTargets = [];
        _currentIndex = 0;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('has_seen_showcase_tour_home_v2', true);
        });
      },
      onSkip: () {
        _currentMark = null;
        _currentTargets = [];
        _currentIndex = 0;
        markTourAsSeen(); // Mark as seen when skipped
        return true;
      },
      alignSkip: Alignment.topRight,
      textSkip: "SKIP",
      focusAnimationDuration: const Duration(milliseconds: 200),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      pulseAnimationDuration: const Duration(milliseconds: 200),
    )..show(context: context);
  }

  static TargetFocus _target({
    required GlobalKey key,
    required String identify,
    required String title,
    required String description,
    required ContentAlign contentAlign,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: 12,
      // CRITICAL: Disable internal library advancement handlers.
      // We take full manual control via _advance() to ensure scrolls happen BEFORE highlight moves.
      enableOverlayTab: false,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: contentAlign,
          builder: (context, controller) {
            return _CoachContent(
              title: title,
              description: description,
              onAdvance: _advance,
            );
          },
        ),
      ],
    );
  }
}

class _CoachContent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onAdvance;

  const _CoachContent({
    required this.title,
    required this.description,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onAdvance,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'NEXT  →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
