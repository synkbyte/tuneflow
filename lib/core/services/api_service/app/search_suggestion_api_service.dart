import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/utils/function.dart';

part 'search_suggestion_api_service_imp.dart';

abstract class SearchSuggestionApiService {
  Future<List<Map>> getTrending();
  Future<List<Map>> getSuggestion(String query);
}
