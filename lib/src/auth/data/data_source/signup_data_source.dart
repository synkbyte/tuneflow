import 'dart:convert';

import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/auth/data/models/signup_model.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:http/http.dart' as http;

part 'signup_data_source_imp.dart';

abstract class SignupApiService {
  Future<DataState<SignupEntity>> signupRequest(
    String name,
    String phone,
    String email,
    String password,
  );

  Future<DataState<SignupEntity>> googleLogin(
    String name,
    String email,
  );
}
