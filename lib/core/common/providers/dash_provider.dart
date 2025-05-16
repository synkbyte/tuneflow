import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/services/api_service/purchase/purchase_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';

class DashProvider extends ChangeNotifier {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final iapConnection = IAPConnection.instance;
  List<PurchaseDetails> purchases = [];
  List<ProductDetails> products = [];
  bool gotError = false;
  bool isLoading = true;
  bool isPurchashing = false;

  PurchaseApiService apiService = sl();

  initialize() {
    gotError = false;
    notifyListeners();
    final purchaseUpdated = iapConnection.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> prds) async {
        if (!await isConnected()) return;
        purchases = prds;
        _onPurchaseUpdate(prds);
      },
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    isLoading = true;
    notifyListeners();
    final available = await iapConnection.isAvailable();
    if (!available) {
      gotError = true;
      isLoading = false;
      notifyListeners();
      return;
    }
    const ids = <String>{
      DashItemsKey.quickstart,
      DashItemsKey.monthlypass,
      DashItemsKey.month3boostt,
      DashItemsKey.month6power,
      DashItemsKey.fullyearmastery,
    };

    try {
      final response = await iapConnection.queryProductDetails(ids);
      List<ProductDetails> productDetails = response.productDetails;
      await iapConnection.restorePurchases();

      if (productDetails.isEmpty) {
        gotError = true;
        isLoading = false;
      } else {
        products =
            ids.map((id) {
              return productDetails.firstWhere((product) => product.id == id);
            }).toList();

        gotError = false;
        isLoading = false;
      }
    } catch (e) {
      gotError = true;
      isLoading = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      errorMessage(
        navigatorKey.currentContext!,
        'Your purchase is still being processed. Please wait...',
      );
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        errorMessage(
          navigatorKey.currentContext!,
          'An error occurred while processing your purchase. Please try again.',
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (isPurchashing) {
          successMessage(
            navigatorKey.currentContext!,
            'Thank you for your purchase!',
          );
          isPurchashing = false;
          Navigator.pop(navigatorKey.currentContext!);
        } else {
          Map json = jsonDecode(
            purchaseDetails.verificationData.localVerificationData,
          );
          Map response = await apiService.verifyPurchase(
            userId: Cache.instance.userId,
            orderId: json['orderId'] ?? '',
            packageName: json['packageName'] ?? '',
            productId: json['productId'] ?? '',
            purchaseTime: json['purchaseTime'] ?? 0,
            purchaseState: json['purchaseState'] ?? 1,
            purchaseToken: json['purchaseToken'] ?? '',
          );
          if (!response['status']) {
            completePurchase(json);
          }
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
          Map json = jsonDecode(
            purchaseDetails.verificationData.localVerificationData,
          );
          completePurchase(json);
        } catch (error) {
          errorMessage(
            navigatorKey.currentContext!,
            'An error occurred while processing your purchase. Please try again.',
          );
        }
      }
    }
  }

  Future<bool> completePurchase(Map json) async {
    await apiService.makePurchase(
      userId: Cache.instance.userId,
      orderId: json['orderId'] ?? '',
      packageName: json['packageName'] ?? '',
      productId: json['productId'] ?? '',
      purchaseTime: json['purchaseTime'] ?? 0,
      purchaseState: json['purchaseState'] ?? 1,
      purchaseToken: json['purchaseToken'] ?? '',
    );
    await userProvider.updateUserRoom();
    if (!isPurchashing) {
      successMessage(
        navigatorKey.currentContext!,
        'Thank you for your purchase!',
      );
      isPurchashing = false;
    }
    return true;
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {}

  Future<void> buy(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      isPurchashing = true;
      await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      errorMessage(
        navigatorKey.currentContext!,
        'An error occurred while processing your purchase. Please try again.',
      );
    }
  }
}
