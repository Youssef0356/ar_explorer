import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourStep {
  final IconData icon;
  final String title;
  final String body;
  final int targetTab;

  const TourStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.targetTab,
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
      icon: Icons.book_rounded,
      title: 'Learn Tab',
      body: 'Modules, quizzes and flashcards live here. Master AR fundamentals at your own pace.',
      targetTab: 0,
    ),
    TourStep(
      icon: Icons.gamepad_rounded,
      title: 'Play Tab',
      body: '4 immersive AR games to practice real-world engineering concepts in 3D.',
      targetTab: 2,
    ),
    TourStep(
      icon: Icons.emoji_events_rounded,
      title: 'Rewards Tab',
      body: 'Track your XP, earn certificates, and collect badges as you progress.',
      targetTab: 3,
    ),
    TourStep(
      icon: Icons.play_arrow_rounded,
      title: 'Start Learning',
      body: 'Tap any module card to begin. Complete topics to unlock quizzes and move to the next level.',
      targetTab: 0,
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
