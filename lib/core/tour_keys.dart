import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TourKeys {
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

  static TutorialCoachMark? _currentMark;

  static void dismiss() {
    _currentMark?.finish();
    _currentMark = null;
  }

  /// The main on-boarding tour triggered on first launch.
  static void startHomeTour(BuildContext context, {ScrollController? scrollController}) {
    final targets = <TargetFocus>[];

    if (homeXpKey.currentContext != null) {
      targets.add(_target(
        key: homeXpKey,
        identify: 'xp_bar',
        title: 'Your XP Progress',
        description: 'Level up by exploring modules, games, and daily challenges.',
        contentAlign: ContentAlign.bottom,
      ));
    }

    if (homePracticeKey.currentContext != null) {
      targets.add(_target(
        key: homePracticeKey,
        identify: 'practice_btn',
        title: 'Daily Practice',
        description: 'Review saved notes and answer daily questions here.',
        contentAlign: ContentAlign.bottom,
      ));
    }

    if (homeInterviewKey.currentContext != null) {
      final renderBox = homeInterviewKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && renderBox.size.height > 0) {
        targets.add(_target(
          key: homeInterviewKey,
          identify: 'interview_banner',
          title: 'Practice Interviews',
          description: 'Prepare for real-world scenarios with our AI-powered interview practice.',
          contentAlign: ContentAlign.bottom,
        ));
      }
    }

    if (homeAnalyticsKey.currentContext != null) {
      targets.add(_target(
        key: homeAnalyticsKey,
        identify: 'quiz_analytics',
        title: 'Quiz Analytics',
        description: 'Track your performance across all quizzes to identify areas for improvement.',
        contentAlign: ContentAlign.bottom,
      ));
    }

    if (homeBookmarksKey.currentContext != null) {
      targets.add(_target(
        key: homeBookmarksKey,
        identify: 'bookmarks',
        title: 'Bookmarks',
        description: 'Quickly access your saved notes and topics from any module.',
        contentAlign: ContentAlign.bottom,
      ));
    }

    if (homeModulesKey.currentContext != null) {
      targets.add(_target(
        key: homeModulesKey,
        identify: 'modules_list',
        title: 'Learning Path',
        description: 'Interactive modules from AR Basics to Advanced Scene Understanding.',
        contentAlign: ContentAlign.top,
        onBeforeNext: () async {
          if (homeCertificatesKey.currentContext != null) {
            await Scrollable.ensureVisible(
              homeCertificatesKey.currentContext!,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: 0.8,
            );
          }
        },
      ));
    }

    if (homeCertificatesKey.currentContext != null) {
      targets.add(_target(
        key: homeCertificatesKey,
        identify: 'certificates',
        title: 'Certificates',
        description: 'Earn Bronze, Silver, Gold, and Platinum certificates by mastering units.',
        contentAlign: ContentAlign.top,
      ));
    }

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
    final targets = <TargetFocus>[
      _target(
        key: rewardsDashboardKey,
        identify: 'rewards_dashboard',
        title: 'XP Dashboard',
        description: 'View your total progress, level title, and overall curriculum completion.',
        contentAlign: ContentAlign.bottom,
        onBeforeNext: () async {
          if (rewardsBadgesKey.currentContext != null) {
            await Scrollable.ensureVisible(
              rewardsBadgesKey.currentContext!,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: 0.8,
            );
          }
        },
      ),
      _target(
        key: rewardsBadgesKey,
        identify: 'badges_grid',
        title: 'Earned Badges',
        description: 'Unlock unique badges by completing challenges and mastering AR modules.',
        contentAlign: ContentAlign.top,
      ),
    ];

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
        title: 'Mission Objective',
        description: 'Understand the AR configuration required for this engineering task.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: pipelineSceneKey,
        identify: 'pipeline_flow',
        title: 'The Logic (The Code)',
        description: 'This is your AR Processing Pipeline. It works like a code sequence—order is critical!',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: pipelineWorkAreaKey,
        identify: 'pipeline_pool',
        title: 'Component Toolkit',
        description: 'Tap components here to build your logic flow in the correct engineering order.',
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

    dismiss(); // Ensure no other tour is running
    _currentMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.85,
      onFinish: () => _currentMark = null,
      onSkip: () {
        _currentMark = null;
        return true;
      },
      onClickTarget: (target) {},
      alignSkip: Alignment.topRight,
      textSkip: "SKIP",
    )..show(context: context);
  }

  static TargetFocus _target({
    required GlobalKey key,
    required String identify,
    required String title,
    required String description,
    required ContentAlign contentAlign,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    Future<void> Function()? onBeforeNext,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: 12,
      contents: [
        TargetContent(
          align: contentAlign,
          builder: (context, controller) {
            return _CoachContent(
              title: title,
              description: description,
              onNext: () async {
                if (onBeforeNext != null) {
                  await onBeforeNext();
                }
                controller.next();
              },
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
  final VoidCallback onNext;

  const _CoachContent({
    required this.title,
    required this.description,
    required this.onNext,
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
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onNext,
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
