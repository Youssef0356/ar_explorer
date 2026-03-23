import 'package:flutter/foundation.dart';

class NavigationService extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Helper methods for specific tabs
  void goToHome() => setTab(0);
  void goToRoadmap() => setTab(1);
  void goToPlay() => setTab(2);
  void goToRewards() => setTab(3);
}
