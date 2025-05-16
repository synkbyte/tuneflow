import 'dart:convert';

import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/player/data/models/lyrics_model.dart';
import 'package:http/http.dart' as http;

part 'lyrics_data_source_imp.dart';

abstract class LyricsApiService {
  Future<DataState<LyricsModel>> getLyrics(String id);
}
