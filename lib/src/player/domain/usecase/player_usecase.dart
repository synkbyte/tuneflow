import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/player/domain/repository/player_repository.dart';

class PlayerUseCase extends UseCase<DataState<List<SongModel>>, void> {
  final PlayerRepository _playerRepository;
  PlayerUseCase(this._playerRepository);

  @override
  Future<DataState<List<SongModel>>> call({void params}) async {
    return await _playerRepository.getInitialSongs();
  }
}
