import 'dart:convert';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'upload_api_service_imp.dart';

abstract class UploadApiService {
  Future<DefaultResponse> uploadFile(String filePath);
}
