import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/playlist/data/data_source/playlist_data_source.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/domain/repository/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistApiService _apiService;
  const PlaylistRepositoryImpl(this._apiService);

  @override
  Future<DataState<PlaylistModel>> getPlaylistDetails(
    String id,
    String type,
  ) async {
    return await _apiService.getPlaylistDetails(id, type);
  }
}
