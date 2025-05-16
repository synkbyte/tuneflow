import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:new_tuneflow/src/playlist/domain/repository/playlist_repository.dart';

class PlaylistUseCase extends UseCase<DataState<PlaylistEntity>, void> {
  final PlaylistRepository _playlistRepository;
  PlaylistUseCase(this._playlistRepository);

  @override
  Future<DataState<PlaylistEntity>> call({
    void params,
    String? id,
    String? type,
  }) async {
    return await _playlistRepository.getPlaylistDetails(id!, type!);
  }
}
