import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static const _completedTopicsKey = 'completed_topics';
  static const _quizScoresKey = 'quiz_scores';
  static const _achievementsKey = 'achievements';
  static const _wrongAnswersKey = 'wrong_answers';
  static const _bookmarksKey = 'bookmarks';
  static const _notesKey = 'notes';
  static const _onboardingKey = 'has_seen_onboarding';
  static const _lastDailyChallengeKey = 'last_daily_challenge';
  static const _interviewBestKey = 'interview_best_score';

  SharedPreferences? _prefs;
  Set<String> _completedTopics = {};
  Map<String, int> _quizScores = {}; // quizId -> best score percentage
  Set<String> _achievements = {};
  Set<String> _wrongAnswers = {}; // question IDs answered wrong
  Set<String> _bookmarks = {}; // topic keys (moduleId_topicId)
  Map<String, String> _notes = {}; // topic key -> note text
  int _interviewBestScore = 0;
  bool _debugUnlockAll = false; // Testing: ignore module locks

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

    final wrongJson = _prefs?.getStringList(_wrongAnswersKey);
    if (wrongJson != null) {
      _wrongAnswers = wrongJson.toSet();
    }

    final bookmarksJson = _prefs?.getStringList(_bookmarksKey);
    if (bookmarksJson != null) {
      _bookmarks = bookmarksJson.toSet();
    }

    final notesJson = _prefs?.getString(_notesKey);
    if (notesJson != null) {
      final decoded = jsonDecode(notesJson) as Map<String, dynamic>;
      _notes = decoded.map((k, v) => MapEntry(k, v as String));
    }

    _interviewBestScore = _prefs?.getInt(_interviewBestKey) ?? 0;
  }

  Future<void> _saveProgress() async {
    await _prefs?.setStringList(_completedTopicsKey, _completedTopics.toList());
    await _prefs?.setString(_quizScoresKey, jsonEncode(_quizScores));
    await _prefs?.setStringList(_achievementsKey, _achievements.toList());
    await _prefs?.setStringList(_wrongAnswersKey, _wrongAnswers.toList());
    await _prefs?.setStringList(_bookmarksKey, _bookmarks.toList());
    await _prefs?.setString(_notesKey, jsonEncode(_notes));
    await _prefs?.setInt(_interviewBestKey, _interviewBestScore);
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
  /// A module is unlocked if it has no requiredQuizId, or if the user
  /// has scored ≥ 70% on the required quiz, OR if debug mode is ON.
  bool isModuleUnlocked(String? requiredQuizId) {
    if (_debugUnlockAll) return true; // Debug mode bypass
    if (requiredQuizId == null) return true;
    final score = _quizScores[requiredQuizId];
    return score != null && score >= 70;
  }

  // ── Testing/Debug ──────────────────────────────────────────────
  bool get debugUnlockAll => _debugUnlockAll;

  void toggleDebugUnlock() {
    _debugUnlockAll = !_debugUnlockAll;
    notifyListeners();
  }

  // ── Wrong Answer Tracking (Practice Mode) ─────────────────────
  Set<String> get wrongAnswers => Set.unmodifiable(_wrongAnswers);

  Future<void> saveWrongAnswer(String questionId) async {
    _wrongAnswers.add(questionId);
    await _saveProgress();
  }

  Future<void> removeWrongAnswer(String questionId) async {
    _wrongAnswers.remove(questionId);
    await _saveProgress();
  }

  // ── Daily Challenge ────────────────────────────────────────────
  bool get hasDoneDailyChallenge {
    final lastDate = _prefs?.getString(_lastDailyChallengeKey);
    if (lastDate == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastDate == today;
  }

  Future<void> markDailyChallengeComplete() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs?.setString(_lastDailyChallengeKey, today);
    notifyListeners();
  }

  // ── Bookmarks ──────────────────────────────────────────────────
  Set<String> get bookmarks => Set.unmodifiable(_bookmarks);

  bool isBookmarked(String topicKey) => _bookmarks.contains(topicKey);

  Future<void> toggleBookmark(String topicKey) async {
    if (_bookmarks.contains(topicKey)) {
      _bookmarks.remove(topicKey);
    } else {
      _bookmarks.add(topicKey);
    }
    await _saveProgress();
    notifyListeners();
  }

  // ── Notes ──────────────────────────────────────────────────────
  String getNote(String topicKey) => _notes[topicKey] ?? '';

  Future<void> saveNote(String topicKey, String note) async {
    if (note.trim().isEmpty) {
      _notes.remove(topicKey);
    } else {
      _notes[topicKey] = note;
    }
    await _saveProgress();
    notifyListeners();
  }

  Map<String, String> get allNotes => Map.unmodifiable(_notes);

  // ── Onboarding ─────────────────────────────────────────────────
  bool get hasSeenOnboarding => _prefs?.getBool(_onboardingKey) ?? false;

  Future<void> markOnboardingSeen() async {
    await _prefs?.setBool(_onboardingKey, true);
  }

  // ── Interview Best Score ───────────────────────────────────────
  int get interviewBestScore => _interviewBestScore;

  Future<void> saveInterviewScore(int scorePercent) async {
    if (scorePercent > _interviewBestScore) {
      _interviewBestScore = scorePercent;
    }
    await _saveProgress();
    notifyListeners();
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
    _wrongAnswers.clear();
    _bookmarks.clear();
    _notes.clear();
    _interviewBestScore = 0;
    await _saveProgress();
    notifyListeners();
  }
}
