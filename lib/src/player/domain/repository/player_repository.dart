import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';

abstract class PlayerRepository {
  Future<DataState<List<SongModel>>> getInitialSongs();
}
