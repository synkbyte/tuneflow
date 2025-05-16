import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/song/domain/entites/song_details_entity.dart';

abstract class SongDetailsRepository {
  Future<DataState<SongDetailsEntity>> getSongDetails(String songId);
}
