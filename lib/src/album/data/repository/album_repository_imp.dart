import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/album/data/data_source/album_data_source.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/domain/repository/album_repository.dart';

class AlbumRepositoryImp implements AlbumRepository {
  final AlbumApiService _apiService;
  const AlbumRepositoryImp(this._apiService);

  @override
  Future<DataState<AlbumModel>> getAlbumDetails(String id) async {
    return await _apiService.getAlbumDetails(id);
  }
}
