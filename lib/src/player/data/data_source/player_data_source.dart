import 'dart:convert';

import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/function.dart';

part 'player_data_source_imp.dart';

abstract class PlayerApiService {
  Future<DataState<List<SongModel>>> getInitialSongs();
}
