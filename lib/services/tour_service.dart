import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourStep {
  final IconData icon;
  final String title;
  final String body;
  final int targetTab;
  final bool scrollToModuleCard;
  final bool showArrow;

  const TourStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.targetTab,
    this.scrollToModuleCard = false,
    this.showArrow = false,
  });
}

class TourService extends ChangeNotifier {
  static const _tourCompleteKey = 'tour_complete';
  SharedPreferences? _prefs;

  bool _isActive = false;
  bool get isActive => _isActive;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  bool _isTourComplete = false;
  bool get isTourComplete => _isTourComplete;

  final List<TourStep> steps = const [
    TourStep(
      icon: Icons.home_rounded,
      title: 'Your Home Base',
      body: 'This is your dashboard — your daily keyword, quick actions, and learning modules are all here.',
      targetTab: 0,
    ),
    TourStep(
      icon: Icons.map_rounded,
      title: 'Roadmap',
      body: 'Tap Roadmap to see your full learning journey — track completed modules and plan ahead.',
      targetTab: 1,
    ),
    TourStep(
      icon: Icons.gamepad_rounded,
      title: 'Play & Practice',
      body: 'Tap a game to practice wiring AR components — no code needed.',
      targetTab: 2,
    ),
    TourStep(
      icon: Icons.emoji_events_rounded,
      title: 'Your Rewards',
      body: 'Check your XP, earned certificates, and achievement badges here.',
      targetTab: 3,
    ),
    TourStep(
      icon: Icons.play_arrow_rounded,
      title: 'Start Here',
      body: 'Tap this card to begin your first lesson. Complete topics to unlock quizzes and advance.',
      targetTab: 0,
      scrollToModuleCard: true,
      showArrow: true,
    ),
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isTourComplete = _prefs?.getBool(_tourCompleteKey) ?? false;
    notifyListeners();
  }

  void startTour() {
    if (_isActive) return;
    _isActive = true;
    _currentStepIndex = 0;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStepIndex < steps.length - 1) {
      _currentStepIndex++;
      notifyListeners();
    } else {
      completeTour();
    }
  }

  void skipTour() {
    completeTour();
  }

  Future<void> completeTour() async {
    _isActive = false;
    _isTourComplete = true;
    await _prefs?.setBool(_tourCompleteKey, true);
    notifyListeners();
  }

  Future<void> restartTour() async {
    _isActive = false;
    _isTourComplete = false;
    await _prefs?.setBool(_tourCompleteKey, false);
    startTour();
  }

  TourStep get currentStep => steps[_currentStepIndex];
}
