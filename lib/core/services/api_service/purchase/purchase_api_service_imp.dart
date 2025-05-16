part of 'purchase_api_service.dart';

class PurchaseApiServiceImp implements PurchaseApiService {
  @override
  Future<void> makePurchase({
    required int userId,
    required String orderId,
    required String packageName,
    required String productId,
    required int purchaseTime,
    required int purchaseState,
    required String purchaseToken,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('purchase');
      final body = {
        'userId': userId,
        'orderId': orderId,
        'packageName': packageName,
        'productId': productId,
        'purchaseTime': purchaseTime,
        'purchaseState': purchaseState,
        'purchaseToken': purchaseToken,
      };
      await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return;
    } catch (e) {
      return;
    }
  }

  @override
  Future<Map> verifyPurchase({
    required int userId,
    required String orderId,
    required String packageName,
    required String productId,
    required int purchaseTime,
    required int purchaseState,
    required String purchaseToken,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('purchase/verify');
      final body = {
        'userId': userId,
        'orderId': orderId,
        'packageName': packageName,
        'productId': productId,
        'purchaseTime': purchaseTime,
        'purchaseState': purchaseState,
        'purchaseToken': purchaseToken,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Something went wrong'};
    }
  }
}
