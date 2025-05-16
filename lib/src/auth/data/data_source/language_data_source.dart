import 'dart:convert';

import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/auth/data/models/signup_model.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:http/http.dart' as http;

part 'language_data_source_imp.dart';

abstract class LanguageApiService {
  Future<DataState<SignupEntity>> updateLanguage(int id, List languages);
}
