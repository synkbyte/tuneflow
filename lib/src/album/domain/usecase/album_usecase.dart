import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/album/domain/entites/album_entity.dart';
import 'package:new_tuneflow/src/album/domain/repository/album_repository.dart';

class AlbumUseCase extends UseCase<DataState<AlbumEntity>, void> {
  final AlbumRepository _playlistRepository;
  AlbumUseCase(this._playlistRepository);

  @override
  Future<DataState<AlbumEntity>> call({void params, String? id}) async {
    return await _playlistRepository.getAlbumDetails(id!);
  }
}
