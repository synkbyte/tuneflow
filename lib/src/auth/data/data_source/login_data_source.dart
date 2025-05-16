import 'dart:convert';

import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/services/api_service/like/like_api_service.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/data/data_source/artist_data_source.dart';
import 'package:new_tuneflow/src/auth/data/models/login_model.dart';
import 'package:http/http.dart' as http;

part 'login_data_source_imp.dart';

abstract class LoginApiService {
  Future<DataState<LoginModel>> loginRequest(
    String identifier,
    String password,
  );
}
