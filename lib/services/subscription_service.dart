import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium';
  static const String _premiumProductId = 'ar_explorer_premium_lifetime';

  // DEBUG: Testing override for premium features
  static const String _debugPremiumOverrideKey = 'debug_premium_override';
  bool _debugPremiumOverride = false;

  bool _isPremium = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _localizedPrice = '\$4.99'; // fallback

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Completer<void>? _restoreCompleter;

  // DEBUG: Getter for debug override status
  bool get debugPremiumOverride => kDebugMode && _debugPremiumOverride;

  // Modified isPremium getter to check debug override
  bool get isPremium => (kDebugMode && _debugPremiumOverride) || _isPremium;
  bool get actualPremiumStatus => _isPremium; // Real purchase status
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get localizedPrice => _localizedPrice;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    
    if (kDebugMode) {
      _debugPremiumOverride = prefs.getBool(_debugPremiumOverrideKey) ?? false;
    }
    notifyListeners();

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
    
    // Initial product query to get localized price
    _queryProduct();
  }

  Future<void> _queryProduct() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) return;

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({_premiumProductId});
      if (response.productDetails.isNotEmpty) {
        _localizedPrice = response.productDetails.first.price;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error querying product: $e');
    }
  }

  Future<void> purchase() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _errorMessage = 'Store is not available.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({_premiumProductId});
      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = 'Premium product not found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (response.error != null) {
        _errorMessage = response.error!.message;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      _localizedPrice = productDetails.price;
      notifyListeners();

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    _restoreCompleter = Completer<void>();
    
    try {
      await _inAppPurchase.restorePurchases();
      
      // Wait for the stream to process restored purchases or timeout
      await _restoreCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (!_isPremium) {
            _errorMessage = 'No purchases found to restore.';
          }
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _restoreCompleter = null;
      notifyListeners();
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    if (purchaseDetailsList.isEmpty) {
      if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
        _restoreCompleter!.complete();
      }
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _errorMessage = purchaseDetails.error?.message ?? 'Purchase failed';
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _setPremiumStatus(true);
          // If we were restoring, we found something
          if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
            _restoreCompleter!.complete();
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
        _isLoading = false;
      }
    }
    
    // Fallback completion for empty or non-restoring updates
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted && 
        purchaseDetailsList.every((p) => p.status != PurchaseStatus.pending)) {
       _restoreCompleter!.complete();
    }

    notifyListeners();
  }

  Future<void> _setPremiumStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, status);
    _isPremium = status;
    notifyListeners();
  }

  // DEBUG: Toggle premium override for testing
  Future<void> toggleDebugPremiumOverride() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    _debugPremiumOverride = !_debugPremiumOverride;
    await prefs.setBool(_debugPremiumOverrideKey, _debugPremiumOverride);
    notifyListeners();
  }

  // DEBUG: Reset all premium status (for testing cleanup)
  Future<void> resetDebugPremiumStatus() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    _debugPremiumOverride = false;
    await prefs.setBool(_debugPremiumOverrideKey, false);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
