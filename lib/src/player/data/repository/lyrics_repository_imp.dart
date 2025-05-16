import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/player/data/data_source/lyrics_data_source.dart';
import 'package:new_tuneflow/src/player/domain/entities/lyrics_entity.dart';
import 'package:new_tuneflow/src/player/domain/repository/lyrics_repository.dart';

class LyricsRepositoryImp implements LyricsRepository {
  final LyricsApiService _lyricsApiService;
  LyricsRepositoryImp(this._lyricsApiService);

  @override
  Future<DataState<LyricsEntity>> getLyrics(String id) async {
    return await _lyricsApiService.getLyrics(id);
  }
}
