import 'dart:convert';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

part 'playlist_api_service_imp.dart';

abstract class PlaylistApiServiceGloble {
  Future<DataState<List<UserPlaylistModel>>> getPlaylist({required int userId});
  Future<DataState<List<PlaylistModel>>> getRecommendedPlaylists({
    required String id,
  });
  Future<DefaultResponse> addToPlaylist({required UserPlaylistModel model});
  Future<DefaultResponse> updatePlaylist({required UserPlaylistModel model});
  Future<DefaultResponse> removePlaylist({required int id});
  Future<DefaultResponse> addSongToPlaylist({
    required int id,
    required SongModel model,
  });
  Future<DefaultResponse> removeSongFromPlaylist({
    required int id,
    required String songId,
  });
  Future<DefaultResponse> deletePlaylist({required int id});
}
