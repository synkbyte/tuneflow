import 'dart:convert';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:http/http.dart' as http;

part 'support_api_service_imp.dart';

abstract class SupportApiService {
  Future<DefaultResponse> supportRequest(
    String name,
    String email,
    String phone,
    String message,
  );
}
