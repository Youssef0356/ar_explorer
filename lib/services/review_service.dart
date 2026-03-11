import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class ReviewService extends ChangeNotifier {
  static const _lastReviewPromptKey = 'last_review_prompt_time';
  static const _reviewPromptCountKey = 'review_prompt_count';
  
  final InAppReview _inAppReview = InAppReview.instance;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Attempts to show the review prompt based on a set of rules.
  /// 
  /// Rules:
  /// - Only show after the user has completed at least [minModules] modules.
  /// - Do not prompt more than 3 times ever.
  /// - Do not prompt if the last prompt was within the last 7 days.
  /// - Random chance (e.g., 20% chance) when requested to avoid predictability.
  Future<void> tryShowReviewPrompt({
    double chance = 0.2,
    int completedModules = 0,
    int minModules = 2,
  }) async {
    if (_prefs == null) return;

    // Gate: only allow after the user has completed enough modules
    if (completedModules < minModules) return;

    final promptCount = _prefs!.getInt(_reviewPromptCountKey) ?? 0;
    
    // Stop prompting if we've already asked a few times
    if (promptCount >= 3) return;

    final lastPromptMillis = _prefs!.getInt(_lastReviewPromptKey) ?? 0;
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastPrompt = (nowMillis - lastPromptMillis) / (1000 * 60 * 60 * 24);

    // Don't prompt if we asked recently (e.g., within 7 days)
    if (lastPromptMillis != 0 && daysSinceLastPrompt < 7) {
      return;
    }

    // Apply strict random chance (e.g. 20%) to actually show it
    final random = Random().nextDouble();
    if (random > chance) {
      return;
    }

    // Check if the API is available on this device
    final isAvailable = await _inAppReview.isAvailable();
    if (isAvailable) {
      try {
        await _inAppReview.requestReview();
        
        // Save the state that we prompted the user
        await _prefs!.setInt(_lastReviewPromptKey, nowMillis);
        await _prefs!.setInt(_reviewPromptCountKey, promptCount + 1);
        debugPrint('Rate App popup shown successfully.');
      } catch (e) {
        debugPrint('Failed to show Rate App popup: $e');
      }
    } else {
      debugPrint('In-App Review API is not available on this device.');
    }
  }

  /// Manually force a redirect to the App Store / Play Store.
  /// Useful for a "Rate Us" button in a settings menu.
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {
      debugPrint('Failed to open store listing: $e');
    }
  }
}
