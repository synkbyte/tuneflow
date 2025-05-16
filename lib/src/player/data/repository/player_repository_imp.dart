import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/player/data/data_source/player_data_source.dart';
import 'package:new_tuneflow/src/player/domain/repository/player_repository.dart';

class PlayerRepositoryImp implements PlayerRepository {
  final PlayerApiService _playerApiService;
  PlayerRepositoryImp(this._playerApiService);

  @override
  Future<DataState<List<SongModel>>> getInitialSongs() async {
    return await _playerApiService.getInitialSongs();
  }
}
