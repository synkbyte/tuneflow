import 'dart:convert';

import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:http/http.dart' as http;

part 'otp_api_service_imp.dart';

abstract class OtpApiService {
  Future<Map> sendOnWhatsapp({
    required String phoneNumber,
    required String name,
  });
  Future<Map> sendOnEmail({required String toEmail, required String name});
}
