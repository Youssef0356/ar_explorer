import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';

class GameProgressService extends ChangeNotifier {
  // ── Pref keys ──────────────────────────────────────────────────────────────
  static const _gameProgressKey = 'ar_game_progress';
  static const _gameStarsKey    = 'ar_game_stars';
  static const _totalXPKey      = 'ar_game_total_xp';
  static const _dailyStreakKey  = 'ar_game_daily_streak';
  static const _lastPlayedKey   = 'ar_game_last_played';

  SharedPreferences? _prefs;
  Set<String> _completedLevelIds = {};
  final Map<String, int> _levelStars = {};

  // ── XP & League ────────────────────────────────────────────────────────────
  int _totalXP = 0;
  int get totalXP => _totalXP;

  String get currentLeague {
    if (_totalXP >= 1500) return 'Diamond';
    if (_totalXP >= 800) return 'Gold';
    if (_totalXP >= 300) return 'Silver';
    return 'Bronze';
  }

  // ── Streak ─────────────────────────────────────────────────────────────────
  int _dailyStreak = 0;
  int get dailyStreak => _dailyStreak;

  double get streakMultiplier => _dailyStreak > 0 ? 1.5 : 1.0;

  // ── Init ───────────────────────────────────────────────────────────────────
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

    _totalXP     = _prefs?.getInt(_totalXPKey)    ?? 0;
    _dailyStreak = _prefs?.getInt(_dailyStreakKey) ?? 0;
  }

  Future<void> _saveProgress() async {
    await _prefs?.setStringList(_gameProgressKey, _completedLevelIds.toList());

    final starsString = _levelStars.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await _prefs?.setString(_gameStarsKey, starsString);

    await _prefs?.setInt(_totalXPKey, _totalXP);
    await _prefs?.setInt(_dailyStreakKey, _dailyStreak);
  }

  // ── Existing getters (unchanged) ──────────────────────────────────────────
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

  // ── Level completion (unchanged interface, now also triggers streak) ──────
  Future<void> completeLevel(String levelId, int stars) async {
    _completedLevelIds.add(levelId);

    final existingStars = _levelStars[levelId] ?? -1;
    if (existingStars == -1 || stars > existingStars) {
      _levelStars[levelId] = stars;
    }

    await _saveProgress();
    notifyListeners();
  }

  // ── XP management ─────────────────────────────────────────────────────────
  void addXP(int amount) {
    _totalXP += (amount * streakMultiplier).round();
    _saveProgress();
    notifyListeners();
  }

  void deductXP(int amount) {
    _totalXP = (_totalXP - amount).clamp(0, double.maxFinite.toInt());
    _saveProgress();
    notifyListeners();
  }

  // ── Streak management ─────────────────────────────────────────────────────
  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastPlayed = _prefs?.getString(_lastPlayedKey);

    if (lastPlayed == null) {
      // First time playing
      _dailyStreak = 1;
    } else if (lastPlayed == today) {
      // Already played today — no change
      return;
    } else {
      final lastDate = DateTime.parse(lastPlayed);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        _dailyStreak++;
      } else {
        _dailyStreak = 1; // streak broken, restart
      }
    }

    await _prefs?.setString(_lastPlayedKey, today);
    await _saveProgress();
    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  Future<void> resetProgress() async {
    _completedLevelIds = {};
    _levelStars.clear();
    _totalXP = 0;
    _dailyStreak = 0;

    // Explicitly remove keys from SharedPreferences
    await _prefs?.remove(_gameProgressKey);
    await _prefs?.remove(_gameStarsKey);
    await _prefs?.remove(_totalXPKey);
    await _prefs?.remove(_dailyStreakKey);
    await _prefs?.remove(_lastPlayedKey);

    await _saveProgress();
    notifyListeners();
  }
}
