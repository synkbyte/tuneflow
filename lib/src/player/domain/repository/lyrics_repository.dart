import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/player/domain/entities/lyrics_entity.dart';

abstract class LyricsRepository {
  Future<DataState<LyricsEntity>> getLyrics(String id);
}
