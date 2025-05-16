import 'dart:convert';

import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/auth/data/models/signup_model.dart';

part 'artist_data_source_imp.dart';

abstract class ArtistApiService {
  Future<DataState<List<ArtistModel>>> getTopArtists();

  Future<DataState<List<ArtistModel>>> getArtistByQuery({String? query});

  Future<DataState<SignupModel>> updateSelectedArtists(
    int userId,
    List artists,
  );

  Future<DataState<List<ArtistModel>>> getSavedArtists(int userId);
}
