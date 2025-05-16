import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/player/domain/entities/lyrics_entity.dart';
import 'package:new_tuneflow/src/player/domain/repository/lyrics_repository.dart';

class LyricsUseCase extends UseCase<DataState<LyricsEntity>, void> {
  final LyricsRepository _lyricsRepository;
  LyricsUseCase(this._lyricsRepository);

  @override
  Future<DataState<LyricsEntity>> call({void params, String? id}) async {
    return await _lyricsRepository.getLyrics(id!);
  }
}
