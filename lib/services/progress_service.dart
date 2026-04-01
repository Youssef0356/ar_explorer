import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/module_model.dart';
import '../data/modules_data.dart';
import '../data/quiz_data.dart';
import 'subscription_service.dart';
import 'game_progress_service.dart';

class ProgressService extends ChangeNotifier with WidgetsBindingObserver {
  SubscriptionService? _subscriptionService;
  GameProgressService? _gameProgressService;

  static const _completedTopicsKey = 'completed_topics';
  static const _quizScoresKey = 'quiz_scores';
  static const _achievementsKey = 'achievements';
  static const _wrongAnswersKey = 'wrong_answers';
  static const _bookmarksKey = 'bookmarks';
  static const _notesKey = 'notes';
  static const _onboardingKey = 'has_seen_onboarding';
  static const _lastDailyChallengeKey = 'last_daily_challenge';
  static const _interviewBestKey = 'interview_best_score';
  static const _interviewHistoryKey = 'interview_history';
  static const _usernameKey = 'user_name';
  static const _adUnlockedModulesKey = 'ad_unlocked_modules';
  static const _privacyAcceptedKey = 'has_accepted_privacy';
  static const _readKeyConceptsKey = 'read_key_concepts';
  static const _interviewAttemptsDateKey = 'interview_attempts_date';
  static const _interviewAttemptsCountKey = 'interview_attempts_count';
  static const _weeklyTopicsKey = 'weekly_topics_count';
  static const _weeklyStartKey = 'weekly_start_date';
  static const _weeklyCompletedKey = 'weekly_challenge_done';
  static const _streakFreezeKey = 'streak_freeze_active';
  static const _unlockedModulesKey = 'user_unlocked_modules';
  static const _lastDailyLoginKey = 'last_daily_login_date';
  static const _premiumXpGrantedKey = 'premium_xp_granted';
  static const _showDebugToolsKey = 'show_debug_tools';
  static const int weeklyTopicsGoal = 5;

  SharedPreferences? _prefs;
  String _username = '';
  Set<String> _completedTopics = {};
  Map<String, int> _quizScores = {};
  Set<String> _achievements = {};
  Set<String> _wrongAnswers = {};
  Set<String> _bookmarks = {};
  Map<String, String> _notes = {};
  Set<String> _adUnlockedModules = {};
  Set<String> _readKeyConcepts = {}; // Track module IDs where concepts were read
  int _interviewBestScore = 0;
  List<int> _interviewHistory = [];
  bool _debugUnlockAll = false;
  int _weeklyTopicsCount = 0;
  bool _weeklyChallengeDone = false;
  bool _streakFreezeActive = false;
  DateTime? _weeklyStartDate;
  Set<String> _unlockedModules = {'m1'}; // Module 1 free by default
  DateTime? _lastDailyLoginDate;
  bool _premiumXpGranted = false;
  bool _showDebugTools = kDebugMode; // Default to true in debug, but user can hide

  // Certificate IDs
  static const String certPipelineEngineer = 'cert_pipeline_engineer';
  static const String certPlatformDeveloper = 'cert_platform_developer';
  
  ProgressService();

  void setSubscriptionService(SubscriptionService service) {
    _subscriptionService = service;
    _subscriptionService!.addListener(() {
      _checkPremiumXpBonus();
      notifyListeners();
    });
  }

  void _checkPremiumXpBonus() {
    if ((_subscriptionService?.isPremium ?? false) && !_premiumXpGranted) {
      _premiumXpGranted = true;
      addXP(700);
      // addXP already saves and notifies
    }
  }

  void setGameProgressService(GameProgressService service) {
    _gameProgressService = service;
  }

  bool get isPremium => _subscriptionService?.isPremium ?? false;

  // ── Initialization ─────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _showDebugTools = _prefs?.getBool(_showDebugToolsKey) ?? kDebugMode;
    WidgetsBinding.instance.addObserver(this);
    _loadProgress();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetWeeklyIfNeeded();
      _checkDailyLoginBonus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

    final adUnlockedJson = _prefs?.getStringList(_adUnlockedModulesKey);
    if (adUnlockedJson != null) {
      _adUnlockedModules = adUnlockedJson.toSet();
    }

    final readKeyConceptsJson = _prefs?.getStringList(_readKeyConceptsKey);
    if (readKeyConceptsJson != null) {
      _readKeyConcepts = readKeyConceptsJson.toSet();
    }

    _interviewBestScore = _prefs?.getInt(_interviewBestKey) ?? 0;
    
    final historyStrings = _prefs?.getStringList(_interviewHistoryKey) ?? [];
    _interviewHistory = historyStrings.map((e) => int.tryParse(e) ?? 0).toList();
    
    _username = _prefs?.getString(_usernameKey) ?? '';
    
    final unlockedModsJson = _prefs?.getStringList(_unlockedModulesKey);
    if (unlockedModsJson != null && unlockedModsJson.isNotEmpty) {
      _unlockedModules = unlockedModsJson.toSet();
    } else {
      _unlockedModules = {'m1'}; // default fallback
    }
    
    final lastDailyLoginStr = _prefs?.getString(_lastDailyLoginKey);
    if (lastDailyLoginStr != null) {
      _lastDailyLoginDate = DateTime.tryParse(lastDailyLoginStr);
    }
    
    _premiumXpGranted = _prefs?.getBool(_premiumXpGrantedKey) ?? false;

    // Weekly challenge
    final weeklyStart = _prefs?.getString(_weeklyStartKey);
    if (weeklyStart != null) {
      _weeklyStartDate = DateTime.tryParse(weeklyStart);
    }
    _resetWeeklyIfNeeded();
    _weeklyTopicsCount = _prefs?.getInt(_weeklyTopicsKey) ?? 0;
    _weeklyChallengeDone = _prefs?.getBool(_weeklyCompletedKey) ?? false;
    _streakFreezeActive = _prefs?.getBool(_streakFreezeKey) ?? false;
    
    _checkDailyLoginBonus();
  }

  void _checkDailyLoginBonus() {
    final now = DateTime.now();
    bool isNewDay = false;
    if (_lastDailyLoginDate == null) {
      isNewDay = true;
    } else {
      if (_lastDailyLoginDate!.year != now.year ||
          _lastDailyLoginDate!.month != now.month ||
          _lastDailyLoginDate!.day != now.day) {
        isNewDay = true;
      }
    }

    if (isNewDay) {
      _lastDailyLoginDate = now;
      addXP(5); // +5 XP for first daily entry
      // Local notification is handled by NotificationService scheduling. Map dialog triggered externally if needed.
    }
  }

  void _resetWeeklyIfNeeded() {
    final now = DateTime.now();
    // Find this week's Monday at midnight (DateTime accurately handles underflow and DSTs)
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    if (_weeklyStartDate == null || _weeklyStartDate!.isBefore(weekStart)) {
      _weeklyStartDate = weekStart;
      _weeklyTopicsCount = 0;
      _weeklyChallengeDone = false;
      _prefs?.setInt(_weeklyTopicsKey, 0);
      _prefs?.setBool(_weeklyCompletedKey, false);
      _prefs?.setString(_weeklyStartKey, weekStart.toIso8601String());
      notifyListeners();
    }
  }

  Future<void> _saveProgress() async {
    await _prefs?.setStringList(_completedTopicsKey, _completedTopics.toList());
    await _prefs?.setString(_quizScoresKey, jsonEncode(_quizScores));
    await _prefs?.setStringList(_achievementsKey, _achievements.toList());
    await _prefs?.setStringList(_wrongAnswersKey, _wrongAnswers.toList());
    await _prefs?.setStringList(_bookmarksKey, _bookmarks.toList());
    await _prefs?.setString(_notesKey, jsonEncode(_notes));
    await _prefs?.setStringList(_adUnlockedModulesKey, _adUnlockedModules.toList());
    await _prefs?.setStringList(_readKeyConceptsKey, _readKeyConcepts.toList());
    await _prefs?.setInt(_interviewBestKey, _interviewBestScore);
    await _prefs?.setStringList(_interviewHistoryKey, _interviewHistory.map((e) => e.toString()).toList());
    await _prefs?.setString(_usernameKey, _username);
    await _prefs?.setString(_weeklyStartKey, (_weeklyStartDate ?? DateTime.now()).toIso8601String());
    await _prefs?.setInt(_weeklyTopicsKey, _weeklyTopicsCount);
    await _prefs?.setBool(_weeklyCompletedKey, _weeklyChallengeDone);
    await _prefs?.setBool(_streakFreezeKey, _streakFreezeActive);
    await _prefs?.setStringList(_unlockedModulesKey, _unlockedModules.toList());
    if (_lastDailyLoginDate != null) await _prefs?.setString(_lastDailyLoginKey, _lastDailyLoginDate!.toIso8601String());
    await _prefs?.setBool(_premiumXpGrantedKey, _premiumXpGranted);
  }



  // ── Unified XP Economy ─────────────────────────────────────────

  int get xp => _gameProgressService?.unifiedXP ?? 0;
  
  bool get hasEnoughXPForModule => xp >= 50;

  Future<void> addXP(int amount) async {
    await _gameProgressService?.addUnifiedXP(amount);
    // GameProgressService handles saving and notifying for unifiedXP.
    // We notify here to ensure listeners in ProgressService update too.
    notifyListeners();
  }

  Future<bool> spendXP(int amount) async {
    if (_gameProgressService == null) return false;
    final success = await _gameProgressService!.spendUnifiedXP(amount);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // ── Module & Topic Progress ────────────────────────────────────
  bool isTopicCompleted(String topicId) => _completedTopics.contains(topicId);

  Future<void> completeTopic(String topicId) async {
    _resetWeeklyIfNeeded();
    if (_completedTopics.contains(topicId)) return;
    _completedTopics.add(topicId);
    
    // Give XP using the Unified system
    await addXP(10);
    
    _weeklyTopicsCount++;
    if (_weeklyTopicsCount >= weeklyTopicsGoal && !_weeklyChallengeDone) {
      _weeklyChallengeDone = true;
      await addXP(50); // Weekly challenge bonus
    }
    await _saveProgress();
    notifyListeners();
  }

  int completedTopicsInModule(String moduleId, List<String> topicIds) {
    return topicIds
        .where((id) => _completedTopics.contains('${moduleId}_$id'))
        .length;
  }

  bool isModuleTopicsCompleted(String moduleId, int totalTopics) {
    if (totalTopics == 0) return true;
    final count = _completedTopics
        .where((id) => id.startsWith('${moduleId}_'))
        .length;
    return count >= totalTopics;
  }

  double moduleProgress(String moduleId, int totalTopics) {
    if (totalTopics == 0) return 0.0;
    final count = _completedTopics
        .where((id) => id.startsWith('${moduleId}_'))
        .length;
    return (count / totalTopics).clamp(0.0, 1.0);
  }

  bool isCurriculumComplete(int totalTopicsAcrossAllModules) {
    return _completedTopics.length >= totalTopicsAcrossAllModules;
  }

  // ── Quiz Scores ────────────────────────────────────────────────
  int? getQuizScore(String quizId) => _quizScores[quizId];

  bool hasPassedQuiz(String quizId, int passingScore) {
    final score = _quizScores[quizId];
    return score != null && score >= passingScore;
  }

  Future<List<String>> saveQuizScore(String quizId, int scorePercent) async {
    final subscription = _subscriptionService?.isPremium ?? false;

    // Snapshot currently unlocked modules before saving
    final lockedBefore = allModules
        .where((m) => !isModuleUnlocked(m, isPremium: subscription))
        .map((m) => m.id)
        .toSet();

    final quiz = allQuizzes[quizId];
    final alreadyPassed = quiz != null && hasPassedQuiz(quizId, quiz.passingScore);

    final existing = _quizScores[quizId] ?? -1;
    if (existing == -1 || scorePercent > existing) {
      _quizScores[quizId] = scorePercent;
    }

    // Award achievement for ≥80%
    if (scorePercent >= 80) {
      _achievements.add('quiz_ace_$quizId');
    }

    if (quiz != null && !alreadyPassed && scorePercent >= quiz.passingScore) {
      _gameProgressService?.addUnifiedXP(50);
    }

    await _saveProgress();
    notifyListeners();

    // Snapshot currently unlocked modules after saving
    final stillLocked = allModules
        .where((m) => !isModuleUnlocked(m, isPremium: subscription))
        .map((m) => m.id)
        .toSet();

    // Return the newly unlocked ones
    return lockedBefore.difference(stillLocked).toList();
  }

  // ── Module Unlock Logic ────────────────────────────────────────
  /// A module is unlocked if:
  /// 1. It is 'm1' (Always free)
  /// 2. User has explicitly unlocked it by spending XP
  /// 3. Debug mode is ON
  bool isModuleUnlocked(LearningModule module, {bool isPremium = false}) {
    if (module.unlockCost == 0) return true;
    if (_debugUnlockAll) return true;
    // Premium users also need to unlock with XP now, as per user request
    // "keep modules and games locked for premium users"
    return _unlockedModules.contains(module.id);
  }

  Future<bool> unlockModuleWithXP(String moduleId, int cost) async {
    if (xp >= cost) {
      final success = await spendXP(cost);
      if (success) {
        _unlockedModules.add(moduleId);
        await _saveProgress();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool get showDebugTools => _showDebugTools;

  Future<void> toggleShowDebugTools() async {
    _showDebugTools = !_showDebugTools;
    await _prefs?.setBool(_showDebugToolsKey, _showDebugTools);
    notifyListeners();
  }

  bool canAccessModule(LearningModule module, {bool? isPremium}) {
    return isModuleUnlocked(module, isPremium: isPremium ?? false);
  }

  Future<bool> unlockModuleStatus(String moduleId) async {
    if (_unlockedModules.contains(moduleId)) return true;
    if (await spendXP(50)) {
      _unlockedModules.add(moduleId);
      await _saveProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Legacy Ad unlock hook
  Future<void> unlockModuleWithAd(String moduleId) async {
    _unlockedModules.add(moduleId);
    await _saveProgress();
    notifyListeners();
  }

  // ── Key Concepts Tracking ──────────────────────────────────────
  bool hasReadKeyConcepts(String moduleId) {
    return _readKeyConcepts.contains(moduleId);
  }

  Future<void> markKeyConceptsAsRead(String moduleId) async {
    if (!_readKeyConcepts.contains(moduleId)) {
      _readKeyConcepts.add(moduleId);
      await _saveProgress();
      notifyListeners();
    }
  }

  // ── Testing/Debug ──────────────────────────────────────────────
  bool get debugUnlockAll => _debugUnlockAll;

  void toggleDebugUnlock() {
    _debugUnlockAll = !_debugUnlockAll;
    notifyListeners();
  }

  Future<void> completeAllModules(List<dynamic> modules) async {
    for (final module in modules) {
      for (final topic in module.topics) {
        _completedTopics.add('${module.id}_${topic.id}');
      }
      // Also pass any quizzes associated
      if (module.requiredQuizId != null) {
        _quizScores[module.requiredQuizId!] = 100;
        _achievements.add('quiz_ace_${module.requiredQuizId}');
      }
    }
    await _saveProgress();
    notifyListeners();
  }

  Future<void> unlockAllCertificates() async {
    // 1. Complete all modules, mark key concepts as read, and unlock them
    for (final module in allModules) {
      _unlockedModules.add(module.id);
      _readKeyConcepts.add(module.id);
      for (final topic in module.topics) {
        _completedTopics.add('${module.id}_${topic.id}');
      }
    }

    // 2. Pass ALL quizzes (Total 9 in allQuizzes)
    for (final quizId in allQuizzes.keys) {
      _quizScores[quizId] = 100;
      _achievements.add('quiz_ace_$quizId');
    }

    // 3. Set interview best score
    _interviewBestScore = 100;
    if (!_interviewHistory.contains(100)) {
       _interviewHistory.add(100);
    }

    // 4. Complete all game zones required for Platinum
    // The CertificateProgressionScreen hardcodes these IDs in its computeProgress function
    final levelIds = [
      'z1_l1', 'z1_l2', 'z1_boss',
      'z2_l1', 'z2_l2', 'z2_boss',
      'z3_l1', 'z3_l2', 'z3_boss',
      'z4_l1', 'z4_l2', 'z4_boss',
      'z5_l1', 'z5_l2', 'z5_boss',
    ];

    if (_gameProgressService != null) {
      for (final id in levelIds) {
        bool isBoss = id.contains('boss');
        await _gameProgressService!.completeLevel(id, 3, isBoss: isBoss);
      }
    }

    await _saveProgress();
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
    _gameProgressService?.addUnifiedXP(25);
    _weeklyTopicsCount++; // Daily challenge counts toward weekly goal too
    if (_weeklyTopicsCount >= weeklyTopicsGoal && !_weeklyChallengeDone) {
      _weeklyChallengeDone = true;
      _gameProgressService?.addUnifiedXP(50);
    }
    await _saveProgress();
    notifyListeners();
  }

  // ── Weekly Challenge ───────────────────────────────────────────
  int get weeklyTopicsCount => _weeklyTopicsCount;
  bool get weeklyChallengeDone => _weeklyChallengeDone;
  DateTime? get weeklyStartDate => _weeklyStartDate;

  // ── Streak Freeze ──────────────────────────────────────────────
  bool get hasStreakFreeze => _streakFreezeActive;

  /// Spend 50 XP to activate a streak freeze for the next day.
  /// Returns false if not enough XP.
  Future<bool> purchaseStreakFreeze() async {
    const cost = 50;
    final xp = _gameProgressService?.unifiedXP ?? 0;
    if (xp < cost) return false;
    final success = await (_gameProgressService?.spendUnifiedXP(cost) ?? Future.value(false));
    if (!success) return false;
    _streakFreezeActive = true;
    await _saveProgress();
    notifyListeners();
    return true;
  }

  Future<void> consumeStreakFreeze() async {
    _streakFreezeActive = false;
    await _saveProgress();
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

  // ── Privacy Policy ──────────────────────────────────────────────
  bool get hasAcceptedPrivacy => _prefs?.getBool(_privacyAcceptedKey) ?? false;

  Future<void> markPrivacyAccepted() async {
    await _prefs?.setBool(_privacyAcceptedKey, true);
  }

  // ── Onboarding ─────────────────────────────────────────────────
  bool get hasSeenOnboarding => _prefs?.getBool(_onboardingKey) ?? false;

  Future<void> markOnboardingSeen() async {
    await _prefs?.setBool(_onboardingKey, true);
  }

  // ── Module Completion Count ─────────────────────────────────────
  /// Counts how many modules are fully completed (all topics done).
  int completedModuleCount(List<dynamic> allModules) {
    int count = 0;
    for (final module in allModules) {
      final totalTopics = module.topics.length;
      if (totalTopics == 0) continue;
      final completed = _completedTopics
          .where((id) => id.startsWith('${module.id}_'))
          .length;
      if (completed >= totalTopics) count++;
    }
    return count;
  }

  // ── Username ───────────────────────────────────────────────────
  String get username => _username.isEmpty ? 'Explorer' : _username;

  Future<void> updateUsername(String name) async {
    _username = name.trim();
    await _prefs?.setString(_usernameKey, _username);
    notifyListeners();
  }

  // ── Interview Best Score ───────────────────────────────────────
  int get interviewBestScore => _interviewBestScore;

  Future<void> saveInterviewScore(int scorePercent) async {
    if (scorePercent > _interviewBestScore) {
      _interviewBestScore = scorePercent;
    }
    
    _gameProgressService?.addUnifiedXP(100);

    _interviewHistory.add(scorePercent);
    // Keep last 15 scores for chart
    if (_interviewHistory.length > 15) {
      _interviewHistory.removeAt(0);
    }
    
    await _saveProgress();
    notifyListeners();
  }
  
  List<int> get interviewHistory => List.unmodifiable(_interviewHistory);

  // ── Achievements ───────────────────────────────────────────────
  Set<String> get achievements => Set.unmodifiable(_achievements);

  bool hasAchievement(String achievementId) =>
      _achievements.contains(achievementId);

  Future<void> unlockCertificate(String certificateId) async {
    if (!_achievements.contains(certificateId)) {
      _achievements.add(certificateId);
      await _saveProgress();
      notifyListeners();
    }
  }

  // ── Interview Limits (2 free per 3 days) ─────────────────────
  static const _interviewDateKey = 'interview_date';

  void _resetThreeDaysIfNeeded() {
    final now = DateTime.now();
    final lastDateStr = _prefs?.getString(_interviewDateKey);
    
    if (lastDateStr == null) {
      _prefs?.setString(_interviewDateKey, now.toIso8601String());
      _prefs?.setInt(_interviewAttemptsCountKey, 2);
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = now.difference(lastDate).inDays;
      if (diff >= 3) {
        _prefs?.setString(_interviewDateKey, now.toIso8601String());
        _prefs?.setInt(_interviewAttemptsCountKey, 2);
      }
    }
  }

  int get interviewAttemptsLeft {
    if (isPremium) return 999;
    _resetThreeDaysIfNeeded();
    return _prefs?.getInt(_interviewAttemptsCountKey) ?? 2;
  }

  Future<void> useInterviewAttempt() async {
    if (isPremium) return;
    _resetThreeDaysIfNeeded();
    final current = _prefs?.getInt(_interviewAttemptsCountKey) ?? 2;
    if (current > 0) {
      await _prefs?.setInt(_interviewAttemptsCountKey, current - 1);
      notifyListeners();
    }
  }

  Future<void> gainInterviewAttempts(int count) async {
    if (isPremium) return;
    _resetThreeDaysIfNeeded();
    final current = _prefs?.getInt(_interviewAttemptsCountKey) ?? 2;
    await _prefs?.setInt(_interviewAttemptsCountKey, current + count);
    notifyListeners();
  }

  Future<void> resetAll({GameProgressService? gameProgress}) async {
    // Clear in-memory sets/maps
    _completedTopics = {};
    _quizScores = {};
    _achievements = {};
    _wrongAnswers = {};
    _bookmarks = {};
    _notes = {};
    _adUnlockedModules = {};
    _readKeyConcepts = {};
    _interviewBestScore = 0;
    _interviewHistory = [];
    _username = 'Explorer'; // Reset to 'Explorer' instead of empty string
    
    // Explicitly remove ALL keys from SharedPreferences immediately
    final keys = [
      _completedTopicsKey,
      _quizScoresKey,
      _achievementsKey,
      _wrongAnswersKey,
      _bookmarksKey,
      _notesKey,
      _adUnlockedModulesKey,
      _readKeyConceptsKey,
      _interviewBestKey,
      _interviewHistoryKey,
      _usernameKey, // This will remove the stored name, getter will return 'Explorer'
      _interviewAttemptsDateKey,
      _interviewAttemptsCountKey,
      _lastDailyChallengeKey,
    ];

    for (final key in keys) {
      await _prefs?.remove(key);
    }

    if (gameProgress != null) {
      await gameProgress.resetProgress();
    }

    await _saveProgress();
    notifyListeners();
  }
}
