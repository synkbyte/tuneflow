import 'dart:convert';

import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/explore/data/models/discover_model.dart';
import 'package:new_tuneflow/src/explore/data/models/explore_model.dart';
import 'package:new_tuneflow/src/explore/data/models/for_you_model.dart';
import 'package:new_tuneflow/src/explore/data/models/trending_model.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

part 'explore_remote_data_source_imp.dart';

abstract class ExploreAPIService {
  Future<DataState<List<ExploreModel>>> getExplorePlaylist();

  Future<DataState<List<SongModel>>> getExplorePlaylistSong({
    required String listId,
  });

  Future<DataState<List<DiscoverModel>>> getDiscovers();

  Future<DataState<List<TrendingModel>>> getTrending();

  Future<DataState<List<ForYouModel>>> getForYou();
}
