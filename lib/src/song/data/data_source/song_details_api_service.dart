import 'dart:convert';

import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/song/data/models/song_details_model.dart';
import 'package:http/http.dart' as http;

part 'song_details_api_service_imp.dart';

abstract class SongDetailsApiService {
  Future<DataState<SongDetailsModel>> getSongDetails(String songId);
}
