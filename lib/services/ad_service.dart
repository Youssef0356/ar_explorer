import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/subscription_service.dart';

class AdService extends ChangeNotifier {
  SubscriptionService? _subscriptionService;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isInterstitialAdLoading = false;
  bool _isRewardedAdLoading = false;
  Completer<bool>? _rewardedLoadCompleter;

  // Ad Unit IDs (Test IDs vs Real IDs based on debug/release)
  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // keep test ID for debug
    }
    return 'ca-app-pub-6774620515484669/6026080464'; // your real ID
  }

  String get _rewardedAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/5224354917'; // keep test ID for debug
    }
    return 'ca-app-pub-6774620515484669/5977979008'; // your real ID
  }

  void setSubscriptionService(SubscriptionService service) {
    _subscriptionService = service;
  }

  void init() {
    debugPrint('AdService.init() called.');
    if (_subscriptionService?.isPremium ?? false) {
      debugPrint('AdService.init() skipped due to Premium status.');
      return;
    }
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    if (_subscriptionService?.isPremium ?? false) return;
    if (_isInterstitialAdLoading) return;
    _isInterstitialAdLoading = true;
    
    debugPrint('Loading InterstitialAd...');

    try {
      InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('InterstitialAd loaded successfully.');
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed to load: $error');
            _isInterstitialAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isInterstitialAdLoading = false;
    }
  }

  void _loadRewardedAd() {
    if (_subscriptionService?.isPremium ?? false) return;
    if (_isRewardedAdLoading) return;
    _isRewardedAdLoading = true;
    _rewardedLoadCompleter = Completer<bool>();

    debugPrint('Loading RewardedAd...');

    try {
      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('RewardedAd loaded successfully.');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            if (_rewardedLoadCompleter != null && !_rewardedLoadCompleter!.isCompleted) {
              _rewardedLoadCompleter!.complete(true);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedAd failed to load: $error');
            _isRewardedAdLoading = false;
            if (_rewardedLoadCompleter != null && !_rewardedLoadCompleter!.isCompleted) {
              _rewardedLoadCompleter!.complete(false);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      _isRewardedAdLoading = false;
      if (_rewardedLoadCompleter != null && !_rewardedLoadCompleter!.isCompleted) {
        _rewardedLoadCompleter!.complete(false);
      }
    }
  }

  Future<void> showInterstitialAdWithProbability(double probability) async {
    if (_subscriptionService?.isPremium ?? false) return;
    final random = Random().nextDouble();
    if (random <= probability) {
      await showInterstitialAd();
    }
  }

  Future<void> showInterstitialAd() async {
    if (_subscriptionService?.isPremium ?? false) return;
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      _loadInterstitialAd();
      return;
    }
    
    debugPrint('Attempting to show InterstitialAd...');

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('InterstitialAd showed successfully.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed.');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  Future<bool> showRewardedAd() async {
    debugPrint('showRewardedAd called...');
    if (_subscriptionService?.isPremium ?? false) {
      debugPrint('Premium user, returning success for RewardedAd.');
      return true; // Auto-success for premium
    }
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded ad before loaded. Waiting to load...');
      if (!_isRewardedAdLoading) {
        _loadRewardedAd();
      }
      
      if (_rewardedLoadCompleter != null) {
        try {
          // Add a 10-second timeout for ad loading
          final loaded = await _rewardedLoadCompleter!.future.timeout(const Duration(seconds: 10));
          if (!loaded || _rewardedAd == null) {
            debugPrint('Error: Rewarded ad failed to load within timeout period.');
            return false;
          }
        } on TimeoutException {
          debugPrint('Error: Rewarded ad loading timed out.');
          return false;
        } catch (e) {
          debugPrint('Error waiting for rewarded ad: $e');
          return false;
        }
      } else {
        return false;
      }
    }

    final completer = Completer<bool>();
    bool earnedReward = false;

    debugPrint('Attempting to show RewardedAd...');

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardedAd showed successfully.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardedAd dismissed.');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('RewardedAd reward earned: ${reward.amount} ${reward.type}');
        earnedReward = true;
      },
    );

    return completer.future;
  }
}
