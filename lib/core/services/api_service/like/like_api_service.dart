import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'like_api_service_imp.dart';

abstract class LikeApiService {
  Future<void> toggleLikeSong(int userId, String songId, Map songMap);
  Future<DataState<List<SongModel>>> getUserLikedSongs(int userId);
}
