import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/song/domain/entites/song_details_entity.dart';
import 'package:new_tuneflow/src/song/domain/repository/song_repository.dart';

class SongDetailsUseCase extends UseCase<DataState<SongDetailsEntity>, void> {
  final SongDetailsRepository _songDetailsRepository;
  SongDetailsUseCase(this._songDetailsRepository);

  @override
  Future<DataState<SongDetailsEntity>> call({
    void params,
    String? songId,
  }) async {
    return await _songDetailsRepository.getSongDetails(songId!);
  }
}
