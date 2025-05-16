import 'dart:convert';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

part 'artist_data_source_imp.dart';

abstract class ArtistDetailsApiService {
  Future<DataState<ArtistModel>> getArtistDetails(String id);
}
