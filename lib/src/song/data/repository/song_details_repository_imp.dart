import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/song/data/data_source/song_details_api_service.dart';
import 'package:new_tuneflow/src/song/domain/entites/song_details_entity.dart';
import 'package:new_tuneflow/src/song/domain/repository/song_repository.dart';

class SongDetailsRepositoryImp implements SongDetailsRepository {
  final SongDetailsApiService _songDetailsApiService;
  SongDetailsRepositoryImp(this._songDetailsApiService);

  @override
  Future<DataState<SongDetailsEntity>> getSongDetails(String songId) async {
    return await _songDetailsApiService.getSongDetails(songId);
  }
}
