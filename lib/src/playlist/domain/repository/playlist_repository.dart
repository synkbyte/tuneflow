import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';

abstract class PlaylistRepository {
  Future<DataState<PlaylistEntity>> getPlaylistDetails(String id, String type);
}
