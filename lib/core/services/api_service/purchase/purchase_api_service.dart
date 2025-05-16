import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'purchase_api_service_imp.dart';

abstract class PurchaseApiService {
  Future<void> makePurchase({
    required int userId,
    required String orderId,
    required String packageName,
    required String productId,
    required int purchaseTime,
    required int purchaseState,
    required String purchaseToken,
  });
  Future<Map> verifyPurchase({
    required int userId,
    required String orderId,
    required String packageName,
    required String productId,
    required int purchaseTime,
    required int purchaseState,
    required String purchaseToken,
  });
}
