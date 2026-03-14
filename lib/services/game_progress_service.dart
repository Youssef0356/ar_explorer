import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';

class GameProgressService extends ChangeNotifier {
  static const _gameProgressKey = 'ar_game_progress';
  static const _gameStarsKey = 'ar_game_stars';

  SharedPreferences? _prefs;
  Set<String> _completedLevelIds = {};
  Map<String, int> _levelStars = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgress();
  }

  void _loadProgress() {
    final completed = _prefs?.getStringList(_gameProgressKey) ?? [];
    _completedLevelIds = completed.toSet();

    final starsJson = _prefs?.getString(_gameStarsKey);
    if (starsJson != null && starsJson.isNotEmpty) {
      final pairs = starsJson.split(',');
      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          _levelStars[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }
    }
  }

  Future<void> _saveProgress() async {
    await _prefs?.setStringList(_gameProgressKey, _completedLevelIds.toList());
    
    final starsString = _levelStars.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await _prefs?.setString(_gameStarsKey, starsString);
  }

  bool isLevelCompleted(String levelId) => _completedLevelIds.contains(levelId);
  
  int getStars(String levelId) => _levelStars[levelId] ?? 0;

  bool isLevelLocked(String levelId) {
    ARLevel? currentLevel;
    int levelIndex = -1;
    int zoneIndex = -1;

    for (int i = 0; i < arGameZones.length; i++) {
      final zone = arGameZones[i];
      for (int j = 0; j < zone.levels.length; j++) {
        if (zone.levels[j].id == levelId) {
          currentLevel = zone.levels[j];
          zoneIndex = i;
          levelIndex = j;
          break;
        }
      }
      if (currentLevel != null) break;
    }

    if (currentLevel == null) return true;
    if (zoneIndex == 0 && levelIndex == 0) return false;

    if (levelIndex > 0) {
      final prevLevel = arGameZones[zoneIndex].levels[levelIndex - 1];
      return !isLevelCompleted(prevLevel.id);
    } else if (zoneIndex > 0) {
      final prevZone = arGameZones[zoneIndex - 1];
      final lastLevelPrevZone = prevZone.levels.last;
      return !isLevelCompleted(lastLevelPrevZone.id);
    }

    return true;
  }

  Future<void> completeLevel(String levelId, int stars) async {
    _completedLevelIds.add(levelId);
    
    final existingStars = _levelStars[levelId] ?? -1;
    if (existingStars == -1 || stars > existingStars) {
      _levelStars[levelId] = stars;
    }

    await _saveProgress();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _completedLevelIds.clear();
    _levelStars.clear();
    await _saveProgress();
    notifyListeners();
  }
}
