import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TourKeys {
  // ── Existing ──
  static final GlobalKey homeXpKey      = GlobalKey();
  static final GlobalKey homeTabKey     = GlobalKey();
  static final GlobalKey roadmapTabKey  = GlobalKey();
  static final GlobalKey playTabKey     = GlobalKey();
  static final GlobalKey rewardsTabKey  = GlobalKey();

  // ── HOME TAB (NEW) ──
  static final GlobalKey homeKeywordKey   = GlobalKey();
  static final GlobalKey homeInterviewKey = GlobalKey();
  static final GlobalKey homeAnalyticsKey = GlobalKey();
  static final GlobalKey homeBookmarksKey = GlobalKey();
  static final GlobalKey homeModulesKey   = GlobalKey();

  // ── PLAY TAB ──
  static final GlobalKey playHeaderKey    = GlobalKey();
  static final GlobalKey playGamesListKey = GlobalKey();

  // ── REWARDS TAB ──
  static final GlobalKey rewardsDashboardKey = GlobalKey();
  static final GlobalKey rewardsBadgesKey    = GlobalKey();

  /// The main on-boarding tour triggered on first launch.
  static void startHomeTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: homeXpKey,
        identify: 'xp_bar',
        title: 'Your XP Progress',
        description: 'Level up by exploring modules, games, and daily challenges.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: homeKeywordKey,
        identify: 'daily_keyword',
        title: 'Daily AR Keyword',
        description: 'Learn a new AR term every day to expand your technical vocabulary.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: homeInterviewKey,
        identify: 'interview_banner',
        title: 'Practice Interviews',
        description: 'Prepare for real-world scenarios with our AI-powered interview practice.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: homeAnalyticsKey,
        identify: 'quiz_analytics',
        title: 'Quiz Analytics',
        description: 'Track your performance Across all quizzes to identify areas for improvement.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: homeBookmarksKey,
        identify: 'bookmarks',
        title: 'Bookmarks',
        description: 'Quickly access your saved notes and topics from any module.',
        contentAlign: ContentAlign.bottom,
      ),
      _target(
        key: homeModulesKey,
        identify: 'modules_list',
        title: 'Learning Path',
        description: 'Interactive modules from AR Basics to Advanced Scene Understanding.',
        contentAlign: ContentAlign.top,
      ),
      _target(
        key: homeTabKey,
        identify: 'home_tab',
        title: 'Navigation Menu',
        description: 'Use the bottom menu to switch between Home, Roadmap, Sandbox, and Awards.',
        contentAlign: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
      ),
    ];

    _show(context, targets, 'home_tour');
  }

  /// Contextual tour for the Sandbox tab.
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
        key: playGamesListKey,
        identify: 'games_list',
        title: 'Engineering Games',
        description: 'Master XR Build, Logic Pipelines, and Scripting through interactive mini-games.',
        contentAlign: ContentAlign.top,
      ),
    ];

    _show(context, targets, 'play_tour');
  }

  /// Contextual tour for the Rewards tab.
  static void startRewardsTour(BuildContext context) {
    final targets = <TargetFocus>[
      _target(
        key: rewardsDashboardKey,
        identify: 'rewards_dashboard',
        title: 'XP Dashboard',
        description: 'View your total progress, level title, and overall curriculum completion.',
        contentAlign: ContentAlign.bottom,
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
              onNext: controller.next,
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
