import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static const _completedTopicsKey = 'completed_topics';
  static const _quizScoresKey = 'quiz_scores';
  static const _achievementsKey = 'achievements';

  SharedPreferences? _prefs;
  Set<String> _completedTopics = {};
  Map<String, int> _quizScores = {}; // quizId -> best score percentage
  Set<String> _achievements = {};

  ProgressService();

  // ── Initialization ─────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgress();
  }

  void _loadProgress() {
    final topicsJson = _prefs?.getStringList(_completedTopicsKey);
    if (topicsJson != null) {
      _completedTopics = topicsJson.toSet();
    }

    final scoresJson = _prefs?.getString(_quizScoresKey);
    if (scoresJson != null) {
      final decoded = jsonDecode(scoresJson) as Map<String, dynamic>;
      _quizScores = decoded.map((k, v) => MapEntry(k, v as int));
    }

    final achievementsJson = _prefs?.getStringList(_achievementsKey);
    if (achievementsJson != null) {
      _achievements = achievementsJson.toSet();
    }
  }

  Future<void> _saveProgress() async {
    await _prefs?.setStringList(_completedTopicsKey, _completedTopics.toList());
    await _prefs?.setString(_quizScoresKey, jsonEncode(_quizScores));
    await _prefs?.setStringList(_achievementsKey, _achievements.toList());
  }

  // ── Topic Progress ─────────────────────────────────────────────
  bool isTopicCompleted(String topicId) => _completedTopics.contains(topicId);

  Future<void> completeTopic(String topicId) async {
    _completedTopics.add(topicId);
    await _saveProgress();
    notifyListeners();
  }

  int completedTopicsInModule(String moduleId, List<String> topicIds) {
    return topicIds
        .where((id) => _completedTopics.contains('${moduleId}_$id'))
        .length;
  }

  double moduleProgress(String moduleId, int totalTopics) {
    if (totalTopics == 0) return 0.0;
    final count = _completedTopics
        .where((id) => id.startsWith('${moduleId}_'))
        .length;
    return (count / totalTopics).clamp(0.0, 1.0);
  }

  // ── Quiz Scores ────────────────────────────────────────────────
  int? getQuizScore(String quizId) => _quizScores[quizId];

  bool hasPassedQuiz(String quizId, int passingScore) {
    final score = _quizScores[quizId];
    return score != null && score >= passingScore;
  }

  Future<void> saveQuizScore(String quizId, int scorePercent) async {
    final existing = _quizScores[quizId] ?? 0;
    if (scorePercent > existing) {
      _quizScores[quizId] = scorePercent;
    }

    // Award achievement for ≥80%
    if (scorePercent >= 80) {
      _achievements.add('quiz_ace_$quizId');
    }

    await _saveProgress();
    notifyListeners();
  }

  // ── Module Unlock Logic ────────────────────────────────────────
  bool isModuleUnlocked(String? requiredQuizId) {
    // All modules are currently always unlocked.
    return true;
  }

  /// Determines if a module can be accessed based on the current points
  /// and its unlock cost. For now this assumes modules with unlockCost 0
  /// are always available.
  bool canAccessModule(int unlockCost) {
    // Points-based locking is disabled for now; all modules are accessible.
    return true;
  }

  // ── Achievements ───────────────────────────────────────────────
  Set<String> get achievements => Set.unmodifiable(_achievements);

  bool hasAchievement(String achievementId) =>
      _achievements.contains(achievementId);

  // ── Reset (for testing) ────────────────────────────────────────
  Future<void> resetAll() async {
    _completedTopics.clear();
    _quizScores.clear();
    _achievements.clear();
    await _saveProgress();
    notifyListeners();
  }
}
