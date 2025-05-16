import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

class DeleteAccountProvider extends ChangeNotifier {
  String reason = '';

  setReason(String reason) {
    this.reason = reason;
    notifyListeners();
  }

  Future<Map> requestForDeleteAccount(String des) async {
    try {
      final client = http.Client();
      final url = parseUrl('requestFor/delete/account');
      final body = jsonEncode({
        'userId': await CacheHelper().getUserId(),
        'reason': reason,
        'explaination': des,
      });
      final response = await client.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (error) {
      return {'status': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map> cancelDeleteAccount(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('requestFor/undelete/account');
      final body = jsonEncode({'userId': userId});
      final response = await client.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (error) {
      return {'status': false, 'message': 'Something went wrong'};
    }
  }
}
