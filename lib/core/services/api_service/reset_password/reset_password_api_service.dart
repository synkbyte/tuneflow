import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'reset_password_api_service_imp.dart';

abstract class ResetPasswordApiService {
  Future<Map> checkUserRegistration(String identifier);
  Future<Map> changePassword(String phone, String password);
}
