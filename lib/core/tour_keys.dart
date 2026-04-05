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

  // ── MINIGAMES ──
  static final GlobalKey minigameObjectiveKey = GlobalKey();
  static final GlobalKey minigameWorkAreaKey = GlobalKey();

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

  static void startMinigameTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: minigameObjectiveKey,
        identify: 'minigame_objective',
        title: 'Challenge Objective',
        description: 'Read your mission and goals here before you start placing components.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: minigameWorkAreaKey,
        identify: 'minigame_workarea',
        title: 'The Sandbox Work Area',
        description: 'Drag and drop or interact here to build your solution. Have fun!',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'minigame_tour');
  }

  /// Shared internal method to show the tour.
  static void _show(BuildContext context, List<TargetFocus> targets, String tag) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0A0E1A),
      opacityShadow: 0.90,
      textSkip: 'SKIP',
      paddingFocus: 8,
      hideSkip: false,
      onFinish: () => debugPrint('App Tour ($tag): Finished'),
      onSkip: () => true,
    ).show(context: context);
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
