import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium';
  static const String _premiumProductId = 'ar_explorer_premium_lifetime';

  bool _isPremium = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _localizedPrice = '\$4.99'; // fallback

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get localizedPrice => _localizedPrice;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
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
  }

  Future<void> purchase() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    
    try {
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
    try {
      await _inAppPurchase.restorePurchases();
      // On slow connections, the purchase stream might not fire immediately.
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!_isPremium && _errorMessage == null) {
        _errorMessage = 'No purchases found to restore.';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    if (purchaseDetailsList.isEmpty) {
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
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
        _isLoading = false;
      }
    }
    notifyListeners();
  }

  Future<void> _setPremiumStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, status);
    _isPremium = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
