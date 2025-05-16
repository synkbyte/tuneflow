import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'recent_api_service_imp.dart';

abstract class RecentApiService {
  Future<DataState<List>> getRecentSongs(int userId);
  Future<void> updateRecentSongs(int userId, List songs);
}
